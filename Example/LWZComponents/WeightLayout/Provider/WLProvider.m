//
//  WLProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLProvider.h"
#import "WLUserCollectionItem.h"
#import "WLPostCollectionItem.h"
#import "WLCollectionSectionHeaderFooter.h"
#import "CommonDependencies.h"

@implementation WLProvider
- (instancetype)initWithModel:(WLDetailModel *)model {
    self = [super init];
    if ( self ) {
        __weak typeof(self) _self = self;
        if ( model.users.count != 0 ) {
            [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
                make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
                make.minimumInteritemSpacing = 8;
                make.minimumLineSpacing = 8;
                
                // 设置 sectionHeaderView
                WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                    make.append(@"设置比重: 每行显示三个item");
                    make.font([UIFont boldSystemFontOfSize:18]);
                }]];
                header.contentInsets = UIEdgeInsetsMake(12, 12, 0, 12);
                make.header = header;
               
                // 添加 userItem
                for ( WLUserModel *userModel in model.users ) {
                    WLUserCollectionItem *item = [WLUserCollectionItem.alloc initWithModel:userModel];
                    // 每行显示三个; 设置比重占`1 / 3.0`;
                    item.weight = 1 / 3.0;
                    
                    // item 添加背景decoration
                    LWZCollectionItemBackgroundDecoration *decoration = [LWZCollectionItemBackgroundDecoration.alloc initWithBackgroundColor:[UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1]];
                    decoration.cornerRadius = 5;
                    item.decoration = decoration;
                    
                    // 设置 userItem 点击事件
                    item.tapHandler = ^(__kindof LWZCollectionItem * _Nonnull item, NSIndexPath * _Nonnull indexPath) {
                        __strong typeof(_self) self = _self;
                        if ( self == nil ) return;
                        if ( self.userItemTapHandler ) self.userItemTapHandler(userModel.id);
                    };
                    
                    // 将 userItem 添加到 section 中
                    [make addItem:item];
                }
            }];
        }
        
        if ( model.posts.count != 0 ) {
            [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
                make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
                make.minimumLineSpacing = 24;
                
                // 设置 sectionHeaderView
                WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                    make.append(@"Header: 默认比重为 1.0, 即每行显示一个item");
                    make.font([UIFont boldSystemFontOfSize:18]);
                }]];
                header.contentInsets = UIEdgeInsetsMake(12, 12, 0, 12);
                // 可以为 header 添加 decoration
                LWZCollectionHeaderSeparatorDecoration *headerDecoration = [LWZCollectionHeaderSeparatorDecoration.alloc initWithColor:[UIColor redColor] height:2];
                headerDecoration.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                header.decoration = headerDecoration;
                make.header = header;
                
                // 添加 postItem
                for ( WLPostModel *post in model.posts ) {
                    WLPostCollectionItem *item = [WLPostCollectionItem itemWithModel:post];
                    item.likingItemTapHandler = ^(WLPostCollectionItem * _Nonnull item) {
                        __strong typeof(_self) self = _self;
                        if ( self == nil ) return;
                        if ( self.likingItemTapHandler != nil ) self.likingItemTapHandler([self indexPathOfItem:item]);
                    };
                    item.shareItemTapHandler = ^(WLPostCollectionItem * _Nonnull item) {
                        __strong typeof(_self) self = _self;
                        if ( self == nil ) return;
                        if ( self.shareItemTapHandler != nil ) self.shareItemTapHandler([self indexPathOfItem:item]);
                    };
                    item.commentItemTapHandler = ^(WLPostCollectionItem * _Nonnull item) {
                        __strong typeof(_self) self = _self;
                        if ( self == nil ) return;
                        if ( self.commentItemTapHandler != nil ) self.commentItemTapHandler([self indexPathOfItem:item]);
                    };
                    
                    // 可以为 item 添加分割线decoration
                    LWZCollectionSeparatorDecoration *decoration = [LWZCollectionSeparatorDecoration.alloc initWithColor:[UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1] height:0.5];
                    decoration.contentInsets = UIEdgeInsetsMake(0, 0, -12, 0);
                    item.decoration = decoration;

                    [make addItem:item];
                }
            }];
        }
    }
    return self;
}

- (BOOL)isPostLikedForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLPostCollectionItem *item = [self itemAtIndexPath:indexPath];
    return item.isLiked;
}

- (void)setPostLiked:(BOOL)isLiked forItemAtIndexPath:(NSIndexPath *)indexPath {
    WLPostCollectionItem *item = [self itemAtIndexPath:indexPath];
    item.isLiked = isLiked;
}

- (NSInteger)postShareCountForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLPostCollectionItem *item = [self itemAtIndexPath:indexPath];
    return item.shareCount;
}
- (void)setPostShareCount:(NSInteger)count forItemAtIndexPath:(NSIndexPath *)indexPath {
    WLPostCollectionItem *item = [self itemAtIndexPath:indexPath];
    item.shareCount = count;
}
@end
