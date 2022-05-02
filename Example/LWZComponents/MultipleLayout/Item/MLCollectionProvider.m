//
//  MLCollectionProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "MLCollectionProvider.h"
#import "LWZDependencies.h"
#import "WLCollectionUserItem.h"
#import "WLCollectionPostItem.h"
#import "WLCollectionSectionHeaderFooter.h"
#import "RLCollectionTextItem.h"
#import "WFLCollectionItem.h"
#import "CLCollectionItem.h"

@implementation MLCollectionProvider
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

- (void)_addWLSection:(NSArray<WLPostModel *> *)model {
    __weak typeof(self) _self = self;
    [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
        make.layoutType = LWZCollectionLayoutTypeWeight;
        make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        make.minimumLineSpacing = 24;
        
        // 设置 sectionHeaderView
        WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"Weight Layout");
            make.font([UIFont boldSystemFontOfSize:18]);
        }]];
        header.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        // 可以为 header 添加 decoration
        LWZCollectionSeparatorDecoration *headerDecoration = [LWZCollectionSeparatorDecoration headerSeparatorDecorationWithColor:[UIColor redColor] height:2];
        headerDecoration.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        header.decoration = headerDecoration;
        make.header = header;
        
        // 添加 postItem
        for ( WLPostModel *post in model ) {
            WLCollectionPostItem *item = [WLCollectionPostItem itemWithModel:post];
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
            
            [make addItem:item];
        }
    }];
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


#pragma mark - RestrictedLayout

- (void)_addRLSection:(NSArray<RLModel *> *)list {
    [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
        make.layoutType = LWZCollectionLayoutTypeRestrictedLayout;
        make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        make.minimumLineSpacing = 5;
        make.minimumInteritemSpacing = 5;
        
        // 设置 sectionHeaderView
        WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"Restricted Layout");
            make.font([UIFont boldSystemFontOfSize:18]);
        }]];
        header.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        // 可以为 header 添加 decoration
        LWZCollectionSeparatorDecoration *headerDecoration = [LWZCollectionSeparatorDecoration headerSeparatorDecorationWithColor:[UIColor redColor] height:2];
        headerDecoration.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        header.decoration = headerDecoration;
        make.header = header;
 
        for ( RLModel *tagModel in list ) {
            RLCollectionTextItem *item = [RLCollectionTextItem.alloc initWithModel:tagModel];
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
        
        // 设置 sectionHeaderView
        WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"Waterfall Flow Layout");
            make.font([UIFont boldSystemFontOfSize:18]);
        }]];
        header.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        // 可以为 header 添加 decoration
        LWZCollectionSeparatorDecoration *headerDecoration = [LWZCollectionSeparatorDecoration headerSeparatorDecorationWithColor:[UIColor redColor] height:2];
        headerDecoration.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        header.decoration = headerDecoration;
        make.header = header;
        
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
        
        // 设置 sectionHeaderView
        WLCollectionSectionHeaderFooter *header = [WLCollectionSectionHeaderFooter.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"Template Layout");
            make.font([UIFont boldSystemFontOfSize:18]);
        }]];
        header.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        // 可以为 header 添加 decoration
        LWZCollectionSeparatorDecoration *headerDecoration = [LWZCollectionSeparatorDecoration headerSeparatorDecorationWithColor:[UIColor redColor] height:2];
        headerDecoration.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        header.decoration = headerDecoration;
        make.header = header;
        
        for ( NSInteger i = 0 ; i < 6 ; ++ i ) {
            [make addItem:CLCollectionItem.alloc.init];
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
