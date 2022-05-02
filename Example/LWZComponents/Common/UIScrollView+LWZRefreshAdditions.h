//
//  UIScrollView+LWZRefreshAdditions.h
//  SJObjective-CTool_Example
//
//  Created by 畅三江 on 2016/5/28.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LWZRefreshState) {
    LWZRefreshStateIdle = 1,
    LWZRefreshStatePulling,
    LWZRefreshStateRefreshing,
    LWZRefreshStateWillRefresh,
    LWZRefreshStateNoMoreData
};

NS_ASSUME_NONNULL_BEGIN
@interface UIScrollView (LWZRefreshAdditions)

- (void)lwz_setupRefreshWithPageStartIndex:(NSInteger)startIndex pageSize:(NSInteger)pageSize refreshingHandler:(void(^)(__kindof UIScrollView *scrollView, NSInteger startIndex, NSInteger pageIndex, NSInteger pageSize))block;

- (void)lwz_setupRefreshWithRefreshingHandler:(void(^)(__kindof UIScrollView *scrollView, NSInteger startIndex, NSInteger pageIndex, NSInteger pageSize))block;

@property (nonatomic, readonly) NSInteger lwz_refreshPageStartIndex;
@property (nonatomic, readonly) NSInteger lwz_refreshPageIndex;   // current PageIndex
@property (nonatomic, readonly) NSInteger lwz_refreshPageSize;

@property (nonatomic, readonly) LWZRefreshState lwz_refreshHeaderState;
@property (nonatomic, readonly) LWZRefreshState lwz_refreshFooterState;

- (void)lwz_beginHeaderRefreshing; // 进行 header 刷新; 将会重置 pageIndex 为 pageStartIndex;
- (void)lwz_beginFooterRefreshing; // 进行 footer 刷新; 将会根据 footer 刷新状态维护 pageIndex;

- (void)lwz_endRefreshingWithItemCount:(NSInteger)count; // 结束刷新; 将会根据 itemCount 维护 footer 状态;
- (void)lwz_endRefreshing;

@end
NS_ASSUME_NONNULL_END
