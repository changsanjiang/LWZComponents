//
//  MLProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "MLProvider.h"
#import "CommonDependencies.h"
#import "WLUserCollectionItem.h"
#import "WLPostCollectionItem.h"
#import "WLCollectionSectionHeaderFooter.h"
#import "RLTextItem.h"
#import "WFLCollectionItem.h"
#import "CLItem.h"

@implementation MLProvider
- (instancetype)initWithModel:(MLModel *)model {
    self = [super init];
    if ( self ) {
        [self _addRLSection:model.rl_List];
        [self _addWLSection:model.wl_Model];
        [self _addWFLSection:model.wfl_list];
        [self _addTLSection];
    }
    return self;
}

#pragma mark - WeightLayout

- (void)_addWLSection:(WLDetailModel *)model {
    __weak typeof(self) _self = self;
    if ( model.users.count != 0 ) {
        [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
            make.layoutType = LWZCollectionLayoutTypeWeight;
            make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
            make.minimumInteritemSpacing = 8;
            make.minimumLineSpacing = 8;
            
            // 设置 sectionHeaderView
            WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(@"Header1");
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
            make.layoutType = LWZCollectionLayoutTypeWeight;
            make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
            make.minimumLineSpacing = 24;
            
            // 设置 sectionHeaderView
            WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(@"Header2");
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


#pragma mark - RestrictedLayout

- (void)_addRLSection:(NSArray<RLModel *> *)list {
    [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
        make.layoutType = LWZCollectionLayoutTypeRestrictedLayout;
        make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        make.minimumLineSpacing = 5;
        make.minimumInteritemSpacing = 5;
        
        for ( RLModel *tagModel in list ) {
            RLTextItem *item = [RLTextItem.alloc initWithModel:tagModel];
            [make addItem:item];
        }
    }];
}

#pragma mark - WaterfallFlowLayout

- (void)_addWFLSection:(NSArray<WFLModel *> *)list {
    [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
        make.layoutType = LWZCollectionLayoutTypeWaterfallFlow;
        make.minimumInteritemSpacing = 8;
        make.minimumLineSpacing = 8;
        make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        make.numberOfArrangedItemsPerLine = 2;
        
        for ( WFLModel *model in list ) {
            WFLCollectionItem *item = [WFLCollectionItem.alloc initWithModel:model];
            [make addItem:item];
        }
    }];
}

#pragma mark - TemplateLayout

- (void)_addTLSection {
    [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
        make.layoutType = LWZCollectionLayoutTypeTemplate;
        make.minimumLineSpacing = 12;
        make.minimumInteritemSpacing = 12;
        make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);

        for ( NSInteger i = 0 ; i < 6 ; ++ i ) {
            [make addItem:CLItem.alloc.init];
        }
        
        make.layoutTemplateContainerGroups = [LWZCollectionTemplate templateWithBuildBlock:^(LWZCollectionTemplateBuilder * _Nonnull make) {
            // 添加1个容器组
            make.addGroup(^(LWZCollectionTemplateGroupBuilder * _Nonnull group) {
                // 设置容器组的宽度等于父布局的宽度
                group.width.fractionalWidth(1.0);
                // 设置容器组的高度等于父布局的宽度
                group.height.fractionalWidth(1.0);
                 
                // 向组内添加容器1
                group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                    // 设置容器1的宽度等于父布局的宽度的一半
                    container.width.fractionalWidth(0.5);
                    // 设置容器1的高度等于父布局的高度
                    container.height.fractionalHeight(1.0);
                    
                    // 左侧安排1个item
                    container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                        // 设置item的宽度等于父布局的宽度
                        item.width.fractionalWidth(1.0);
                        // 设置item的高度等于父布局的高度
                        item.height.fractionalHeight(1.0);
                    });
                });
                
                // 向组内添加容器2
                group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                    container.width.fractionalWidth(0.5);
                    container.height.fractionalHeight(1.0);
                    
                    // 右侧安排2个item
                    for ( NSInteger i = 0 ; i < 2 ; ++ i ) {
                        container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                            item.width.fractionalWidth(1.0);
                            item.height.fractionalHeight(0.5);
                        });
                    }
                });
            });
        }];
    }];
}
@end
