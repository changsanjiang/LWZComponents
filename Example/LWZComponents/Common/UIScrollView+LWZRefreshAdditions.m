//
//  UIScrollView+LWZRefreshAdditions.m
//  SJObjective-CTool_Example
//
//  Created by 畅三江 on 2016/5/28.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import "UIScrollView+LWZRefreshAdditions.h"
#import "LWZDependencies.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface LWZRefreshPageItem : NSObject
@property (nonatomic) NSInteger startIndex;
@property (nonatomic) NSInteger refreshIndex;
@property (nonatomic) NSInteger size;
@property (nonatomic, copy, nullable) void(^refreshingHandler)(__kindof UIScrollView *scrollView, NSInteger startIndex, NSInteger pageIndex, NSInteger pageSize);
@end

@implementation LWZRefreshPageItem
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _startIndex = NSNotFound;
        _refreshIndex = NSNotFound;
        _size = NSNotFound;
    }
    return self;
}
@end

@interface UIScrollView (LWZRefreshInternal)
@property (nonatomic, strong, readonly) LWZRefreshPageItem *lwz_refreshPageItem;
@end

@implementation UIScrollView (LWZRefreshInternal)
- (LWZRefreshPageItem *)lwz_refreshPageItem {
    LWZRefreshPageItem *item = objc_getAssociatedObject(self, _cmd);
    if ( item == nil ) {
        item = [LWZRefreshPageItem.alloc init];
        objc_setAssociatedObject(self, _cmd, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return item;
}
@end

#pragma mark -

  
@implementation UIScrollView (LWZRefreshAdditions)

- (void)_lwz_refresh {
    LWZRefreshPageItem *page = self.lwz_refreshPageItem;
    if ( page.refreshingHandler != nil ) page.refreshingHandler(self, page.startIndex, page.refreshIndex, page.size);
}

- (void)lwz_setupRefreshWithPageStartIndex:(NSInteger)startIndex pageSize:(NSInteger)pageSize refreshingHandler:(void(^)(__kindof UIScrollView *scrollView, NSInteger startIndex, NSInteger pageIndex, NSInteger pageSize))block {
    LWZRefreshPageItem *page = self.lwz_refreshPageItem;
    page.startIndex = startIndex;
    page.size = pageSize;
    page.refreshingHandler = block;
    
    // header
    __weak typeof(self) _self = self;
    self.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        page.refreshIndex = page.startIndex;
        [self _lwz_refresh];
    }];
    
    // footer
    BOOL hasFooter = pageSize != NSNotFound;
    if ( hasFooter ) {
        self.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            page.refreshIndex += 1;
            [self _lwz_refresh];
        }];
        self.mj_footer.hidden = YES;
    }
    else {
        self.mj_footer = nil;
    }
}

- (void)lwz_setupRefreshWithRefreshingHandler:(void(^)(__kindof UIScrollView *scrollView, NSInteger startIndex, NSInteger pageIndex, NSInteger pageSize))block {
    [self lwz_setupRefreshWithPageStartIndex:NSNotFound pageSize:NSNotFound refreshingHandler:block];
}

- (void)lwz_beginHeaderRefreshing {
    
    /// MJRefresh 中 beginRefreshing 及 endRefreshing 方法对状态的维护:
    ///
    ///     [headerFooter beginRefreshing] 中对 state 的维护是同步的, 即调用后 state 就会被改为 MJRefreshStateRefreshing 或 MJRefreshStateWillRefresh;
    ///     [headerFooter endRefreshing] 中对 state 的维护是异步的, 即调用后, state 不会立马改为 MJRefreshStateIdle;
    ///
    ///     这就会导致 begin 和 end 操作不对称;
    ///        如: 调用顺序为 `begin, end, begin`, 因为 end 操作是异步执行, 实际执行顺序就变为 `begin, begin, end`, 这与调用顺序不符;
    ///
    /// 由于上面的原因, 在执行 lwz_beginHeaderRefreshing 和 lwz_beginFooterRefreshing 时这里对 begin 增加了一层异步操作, 用以保持操作对称;
    ///
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.mj_header == nil || self.mj_header.isRefreshing ) return;
        if ( self.mj_header.state != MJRefreshStateIdle ) [self.mj_header endRefreshing];
        
        [self.mj_header beginRefreshing];
    });
}

- (void)lwz_beginFooterRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self.mj_footer == nil || self.mj_footer.isRefreshing ) return;
        
        if ( self.mj_footer.isHidden ) self.mj_footer.hidden = NO;
        
        if ( self.mj_footer.state != MJRefreshStateIdle ) [self.mj_footer endRefreshing];
    
        if ( [self.mj_footer respondsToSelector:NSSelectorFromString(@"labelIsTrigger")] ) {
            [self.mj_footer setValue:@(YES) forKey:@"labelIsTrigger"];
            [self.mj_footer beginRefreshing];
            [self.mj_footer setValue:@(NO) forKey:@"labelIsTrigger"];
        }
        else {
            [self.mj_footer beginRefreshing];
        }
    });
}

- (void)lwz_endRefreshingWithItemCount:(NSInteger)count {
    [self lwz_endRefreshing];
    
    // endRefreshing, endRefreshingWithNoMoreData, resetNoMoreData 均为异步操作;
    
    LWZRefreshPageItem *pageItem = self.lwz_refreshPageItem;
    if ( pageItem.refreshIndex == pageItem.startIndex ) {
        if ( count == 0 || count == NSNotFound ) {
            self.mj_footer.hidden = YES;
        }
        else {
            self.mj_footer.hidden = NO;
            if      ( count < pageItem.size ) {
                [self.mj_footer endRefreshingWithNoMoreData];
            }
            else if ( self.mj_footer.state == MJRefreshStateNoMoreData ) {
                [self.mj_footer resetNoMoreData];
            }
        }
    }
    else {
        if      ( count < pageItem.size ) {
            [self.mj_footer endRefreshingWithNoMoreData];
        }
        else if ( self.mj_footer.state == MJRefreshStateNoMoreData ) {
            [self.mj_footer resetNoMoreData];
        }
        else {
            [self.mj_footer endRefreshing];
        }
    }
}

- (void)lwz_endRefreshing {
    if ( self.mj_header.state == MJRefreshStateRefreshing ) [self.mj_header endRefreshing];
    if ( self.mj_footer.state == MJRefreshStateRefreshing ) [self.mj_footer endRefreshing];
}

- (NSInteger)lwz_refreshPageStartIndex {
    return self.lwz_refreshPageItem.startIndex;
}

- (NSInteger)lwz_refreshPageIndex {
    return self.lwz_refreshPageItem.refreshIndex;
}

- (NSInteger)lwz_refreshPageSize {
    return self.lwz_refreshPageItem.size;
}

- (LWZRefreshState)lwz_refreshHeaderState {
    return (LWZRefreshState)[self.mj_header state];
}

- (LWZRefreshState)lwz_refreshFooterState {
    return (LWZRefreshState)[self.mj_footer state];
}
@end
NS_ASSUME_NONNULL_END
