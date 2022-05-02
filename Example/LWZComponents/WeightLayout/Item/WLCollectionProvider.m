//
//  WLCollectionProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLCollectionProvider.h"
#import "WLCollectionPostItem.h"
#import "WLCollectionUserItem.h"
#import "WLCollectionSectionHeaderFooter.h"
#import "LWZDependencies.h"
#import "WLModel.h"

@implementation WLCollectionProvider {
    LWZCollectionSection *mUserSection;
    LWZCollectionSection *mPostSection;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        // user section
        [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
            mUserSection = make;
            
            make.hidesAutomatically = YES; // item 为空的时候, 自动隐藏
            make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
            make.minimumInteritemSpacing = 8;
            make.minimumLineSpacing = 8;
            // header
            WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(@"User Section Header");
                make.font([UIFont boldSystemFontOfSize:18]);
            }]];
            header.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
            make.header = header;

            // header decoration
            LWZCollectionSeparatorDecoration *decoration = [LWZCollectionSeparatorDecoration headerSeparatorDecorationWithColor:[UIColor redColor] height:2];
            decoration.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            header.decoration = decoration;
        }];
    
        // post section
        [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
            mPostSection = make;
            
            make.hidesAutomatically = YES; // item 为空的时候, 自动隐藏
            make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
            make.minimumLineSpacing = 24;
            
            WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(@"Post Section Header");
                make.font([UIFont boldSystemFontOfSize:18]);
            }]];
            header.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
            // 可以为 header 添加 decoration
            LWZCollectionSeparatorDecoration *decoration = [LWZCollectionSeparatorDecoration headerSeparatorDecorationWithColor:[UIColor redColor] height:2];
            decoration.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            header.decoration = decoration;
            make.header = header;
        }];
    }
    return self;
}

- (BOOL)isPostLikedForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLCollectionPostItem *item = [self itemAtIndexPath:indexPath];
    return item.isLiked;
}

- (void)setPostLiked:(BOOL)isLiked forItemAtIndexPath:(NSIndexPath *)indexPath {
    WLCollectionPostItem *item = [self itemAtIndexPath:indexPath];
    item.isLiked = isLiked;
}

- (NSInteger)postShareCountForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLCollectionPostItem *item = [self itemAtIndexPath:indexPath];
    return item.shareCount;
}
- (void)setPostShareCount:(NSInteger)count forItemAtIndexPath:(NSIndexPath *)indexPath {
    WLCollectionPostItem *item = [self itemAtIndexPath:indexPath];
    item.shareCount = count;
}

- (void)addPostItemsWithModelArray:(NSArray<WLPostModel *> *)models {
    if ( models.count != 0 ) {
        __weak typeof(self) _self = self;
        // 添加 postItem
        for ( WLPostModel *model in models ) {
            WLCollectionPostItem *item = [WLCollectionPostItem itemWithModel:model];
            item.likingItemTapHandler = ^(WLCollectionPostItem * _Nonnull item) {
                __strong typeof(_self) self = _self;
                if ( self == nil ) return;
                if ( self.likingItemTapHandler != nil ) self.likingItemTapHandler([self indexPathOfItem:item]);
            };
            item.shareItemTapHandler = ^(WLCollectionPostItem * _Nonnull item) {
                __strong typeof(_self) self = _self;
                if ( self == nil ) return;
                if ( self.shareItemTapHandler != nil ) self.shareItemTapHandler([self indexPathOfItem:item]);
            };
            item.commentItemTapHandler = ^(WLCollectionPostItem * _Nonnull item) {
                __strong typeof(_self) self = _self;
                if ( self == nil ) return;
                if ( self.commentItemTapHandler != nil ) self.commentItemTapHandler([self indexPathOfItem:item]);
            };
            
            // 可以为 item 添加分割线decoration
            LWZCollectionSeparatorDecoration *decoration = [LWZCollectionSeparatorDecoration itemSeparatorDecorationWithColor:[UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1] height:0.5];
            decoration.contentInsets = UIEdgeInsetsMake(0, 0, -12, 0);
            item.decoration = decoration;

            [mPostSection addItem:item];
        }
    }
}

- (void)removeAllPostItems {
    [mPostSection removeAllItems];
}

// - users

- (void)addUserItemsWithModelArray:(NSArray<WLUserModel *> *)models {
    __weak typeof(self) _self = self;
    // 添加 userItem
    for ( WLUserModel *userModel in models ) {
        WLCollectionUserItem *item = [WLCollectionUserItem.alloc initWithModel:userModel];
        // 每行显示三个; 设置比重占`1 / 3.0`;
        item.weight = 1 / 3.0;
        
        // item 添加背景decoration
        LWZCollectionBackgroundDecoration *decoration = [LWZCollectionBackgroundDecoration itemBackgroundDecorationWithBackgroundColor:[UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1]];
        decoration.cornerRadius = 5;
        item.decoration = decoration;
        
        // 设置 userItem 点击事件
        item.selectionHandler = ^(__kindof LWZCollectionItem * _Nonnull item, NSIndexPath * _Nonnull indexPath) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            if ( self.userItemTapHandler != nil ) self.userItemTapHandler(userModel.id);
        };
        
        // 将 userItem 添加到 section 中
        [mUserSection addItem:item];
    }
}

- (void)removeAllUserItems {
    [mUserSection removeAllItems];
}
@end
