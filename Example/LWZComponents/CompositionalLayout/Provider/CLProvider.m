//
//  CLProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/13.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "CLProvider.h"
#import "CLItem.h"
#import "CommonDependencies.h"

@implementation CLProvider
- (instancetype)init {
    self = [super init];
    if ( self ) {
        for ( NSInteger i = 0 ; i < 5 ; ++ i ) {
            // 左右滑动
            [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
                make.layoutType = LWZCollectionLayoutTypeWeight;
                make.minimumLineSpacing = 12;
                make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
                
                make.orthogonalScrolling = YES;
//                LWZCollectionLayoutContentOrthogonalScrollingBehaviorNormal,
//                LWZCollectionLayoutContentOrthogonalScrollingBehaviorContinuousCentered,
//                LWZCollectionLayoutContentOrthogonalScrollingBehaviorPaging,
                make.orthogonalScrollingBehavior = LWZCollectionLayoutContentOrthogonalScrollingBehaviorPaging;
                make.orthogonalContentLayoutSizeCalculator = ^CGSize(LWZCollectionSection * _Nonnull section, CGSize fittingSize, NSInteger index, UICollectionViewScrollDirection scrollDirection) {
                    return CGSizeMake(fittingSize.width - 24, (fittingSize.width - 24) * 9 / 16.0);
                };
               
                for ( NSInteger i = 0 ; i < 9 ; ++ i ) {
                    CLItem *item = CLItem.alloc.init;
                    LWZCollectionBackgroundDecoration *decoration = [LWZCollectionItemBackgroundDecoration.alloc initWithBackgroundColor:UIColor.greenColor];
                    decoration.contentInsets = UIEdgeInsetsMake(-2, -2, -2, -2);
                    item.decoration = decoration;
                    [make addItem:item];
                }
            }];
            
            // 常规布局
            [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
                make.layoutType = LWZCollectionLayoutTypeWeight;
                make.minimumLineSpacing = 12;
                make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
               
                [make addItem:CLItem.alloc.init];
            }];
            
            // 模板布局
            [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
                make.layoutType = LWZCollectionLayoutTypeTemplate;
                make.minimumLineSpacing = 12;
                make.minimumInteritemSpacing = 12;
                make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);

                for ( NSInteger i = 0 ; i < 6 ; ++ i ) {
                    [make addItem:CLItem.alloc.init];
                }

                make.layoutTemplateContainerGroups = [LWZCollectionLayoutTemplate build:^(LWZCollectionTemplateBuilder * _Nonnull make) {
                    // 添加1个容器组
                    make.addGroup(^(LWZCollectionTemplateGroupBuilder * _Nonnull group) {
                        // 设置容器组的宽度等于父布局的宽度
                        group.width.fractionalWidth(1.0);
                        // 设置容器组的高度等于父布局的宽度
                        group.width.fractionalWidth(1.0);
                         
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
    }
    return self;
}
@end
