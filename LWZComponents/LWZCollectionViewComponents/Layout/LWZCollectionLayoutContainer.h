//
//  LWZCollectionLayoutContainer.h
//  SJTestAutoLayout_Example
//
//  Created by 蓝舞者 on 2021/11/9.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionDefines.h"
@class LWZCollectionTemplateBuilder;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionLayoutContainer : NSObject
@property (nonatomic, readonly) CGSize collectionSize;
@property (nonatomic, readonly) UICollectionViewScrollDirection layoutDirection;
@property (nonatomic, readonly) UIEdgeInsets layoutInsets;
@property (nonatomic, readonly) UIFloatRange layoutRange;
@property (nonatomic, readonly) CGSize layoutContainerSize;
@end


@interface LWZSectionLayoutContainer : NSObject
@property (nonatomic, readonly) UIEdgeInsets edgeSpacings;
@property (nonatomic, readonly) UIEdgeInsets contentInsets;
@property (nonatomic, strong, readonly) LWZCollectionLayoutContainer *collectionLayoutContainer;
@property (nonatomic, readonly) UICollectionViewScrollDirection layoutDirection;
@property (nonatomic, readonly) UIEdgeInsets layoutInsets;
@property (nonatomic, readonly) UIFloatRange layoutRange;

@property (nonatomic, readonly) UIFloatRange layoutRangeOfHeaderFooter;
@property (nonatomic, readonly) UIFloatRange layoutRangeOfItem;
@property (nonatomic, readonly) CGSize layoutContainerSizeOfItem;
@end

#pragma mark - Template

@interface LWZCollectionTemplateDimension : NSObject
- (instancetype)initWithFractionalWidthDimension:(CGFloat)dimension; // 相对于父容器的比例
- (instancetype)initWithFractionalHeightDimension:(CGFloat)dimension; // 相对于父容器的比例
- (instancetype)initWithAbsoluteDimension:(CGFloat)dimension; // 固定值
- (instancetype)initWithDimension:(CGFloat)dimension semantic:(LWZCollectionTemplateDimensionSemantic)semantic;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, readonly) LWZCollectionTemplateDimensionSemantic semantic;
@property (nonatomic, readonly) CGFloat dimension;
@end

@interface LWZCollectionTemplateSize : NSObject
- (instancetype)initWithWidthDimension:(LWZCollectionTemplateDimension *)width heightDimension:(LWZCollectionTemplateDimension *)height;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, strong, readonly) LWZCollectionTemplateDimension *width;
@property (nonatomic, strong, readonly) LWZCollectionTemplateDimension *height;
@end

@interface LWZCollectionTemplateItem : NSObject
- (instancetype)initWithSize:(LWZCollectionTemplateSize *)size;

@property (nonatomic, strong, readonly) LWZCollectionTemplateSize *size;
@end

/**
 
 定义一个模板容器, 一个容器可以有多个item.
 
 \code
 +-----[V]-----+ <--- Container
 |             |
 |  +-------+  |
 |  |       |  |
 |  | Item1 |  |
 |  |       |  |
 |  +-------+  |
 |             |
 |  +-------+  |
 |  |       |  |
 |  | Item2 |  |
 |  |       |  |
 |  +-------+  |
 |             |
 +-------------+
 
 +-------[H]----------------------+ <---- Container
 |                                |
 |  +-----------+  +-----------+  |
 |  |           |  |           |  |
 |  |           |  |           |  |
 |  |     1     |  |     2     |  |
 |  +-----------+  +-----------+  |
 |                                |
 +--------------------------------+
 \endcode
 */
@interface LWZCollectionTemplateContainer : LWZCollectionTemplateItem
- (instancetype)initWithSize:(LWZCollectionTemplateSize *)size items:(NSArray<LWZCollectionTemplateItem *> *)items;
@property (nonatomic, copy, readonly) NSArray<LWZCollectionTemplateItem *> *items;
@end

/**
 
  定义一个模板组, 一个组可以有多个容器.
 
 \code
 +---------------------[V]----------------------+ <--- CollectionView
 |                                              |
 |  +----------------------------------------+ <------ Group1
 |  |                                        |  |
 |  |  +---------------+  +---------------+  |  |
 |  |  |               |  |               |  |  |
 |  |  |   Container1  |  |   Container2  |  |  |
 |  |  |               |  |               |  |  |
 |  |  +---------------+  +---------------+  |  |
 |  |                                        |  |
 |  +----------------------------------------+  |
 |                                              |
 |  +----------------------------------------+ <------ Group2
 |  |                                        |  |
 |  |  +----------------------------------+  |  |
 |  |  |                                  |  |  |
 |  |  |           Container1             |  |  |
 |  |  |                                  |  |  |
 |  |  +----------------------------------+  |  |
 |  |                                        |  |
 |  +----------------------------------------+  |
 |                                              |
 +----------------------------------------------+
 \endcode
 */
@interface LWZCollectionTemplateGroup : LWZCollectionTemplateItem
- (instancetype)initWithSize:(LWZCollectionTemplateSize *)size containers:(NSArray<LWZCollectionTemplateContainer *> *)containers;
@property (nonatomic, strong, readonly, nullable) NSArray<LWZCollectionTemplateContainer *> *containers;
@end

@interface LWZCollectionTemplate : NSObject
+ (NSArray<LWZCollectionTemplateGroup *> *)templateWithBuildBlock:(void(^)(LWZCollectionTemplateBuilder *make))block;
@end

// solver 对frame的解析. 每个result表示对应item在groups中的位置(frame)
@interface LWZCollectionTemplateSolver : NSObject
- (instancetype)initWithGroups:(NSArray<LWZCollectionTemplateGroup *> *)groups scrollDirection:(UICollectionViewScrollDirection)scrollDirection numberOfItems:(NSInteger)numberOfItems lineSpacing:(CGFloat)lineSpacing itemSpacing:(CGFloat)itemSpacing containerSize:(CGSize)containerSize;
- (CGRect)itemLayoutFrameAtIndex:(NSInteger)index;
@end

@interface LWZCollectionTemplateDimensionBuilder : NSObject
@property (nonatomic, copy, readonly) LWZCollectionTemplateDimensionBuilder *(^semantic)(LWZCollectionTemplateDimensionSemantic semantic);
@property (nonatomic, copy, readonly) LWZCollectionTemplateDimensionBuilder *(^dimension)(CGFloat dimension);

@property (nonatomic, copy, readonly) void(^fractionalWidth)(CGFloat dimension);
@property (nonatomic, copy, readonly) void(^fractionalHeight)(CGFloat dimension);
@property (nonatomic, copy, readonly) void(^absolute)(CGFloat dimension);
@end

@interface LWZCollectionTemplateItemBuilder : NSObject
@property (nonatomic, readonly) LWZCollectionTemplateDimensionBuilder *width;
@property (nonatomic, readonly) LWZCollectionTemplateDimensionBuilder *height;
@end

@interface LWZCollectionTemplateContainerBuilder : LWZCollectionTemplateItemBuilder
@property (nonatomic, copy, readonly) void(^addItem)(void(^block)(LWZCollectionTemplateItemBuilder *item));
@end

@interface LWZCollectionTemplateGroupBuilder : LWZCollectionTemplateItemBuilder
@property (nonatomic, copy, readonly) void(^addContainer)(void(^block)(LWZCollectionTemplateContainerBuilder *container));
@end

@interface LWZCollectionTemplateBuilder : NSObject
@property (nonatomic, copy, readonly) void(^addGroup)(void(^block)(LWZCollectionTemplateGroupBuilder *group));
@property (nonatomic, readonly) NSArray<LWZCollectionTemplateGroup *> *groups;
@end

/**
 \code
 - (NSArray<LWZCollectionTemplateGroup *> *)layout:(__kindof LWZCollectionViewLayout *)layout layoutTemplateContainerGroupsInSection:(NSInteger)section {

     return [LWZCollectionTemplate templateWithBuildBlock:^(LWZCollectionTemplateBuilder * _Nonnull make) {
 //
 //            Container 1
 //             |
 //         +---|----------------------------------+
 //         |   v                                   |
 //         |  +--------------+  +--------------+ <--- Container 2
 //         |  |              |  |              |  |
 //         |  |  +--------+  |  |  +--------+  |  |
 //         |  |  |        |  |  |  |        |  |  |
 //         |  |  |   1    |  |  |  |        |  |  |
 //         |  |  +--------+  |  |  |        |  |  |
 //         |  |              |  |  |        |  |  |
 //         |  |  +--------+  |  |  |        |  |  |
 //         |  |  |        |  |  |  |        |  |  |
 //         |  |  |   2    |  |  |  |   3    |  |  |
 //         |  |  +--------+  |  |  +--------+  |  |
 //         |  |              |  |              |  |
 //         |  +--------------+  +--------------+  |
 //         |                                      |
 //         +--------------------------------------+
 //
         make.addGroup(^(LWZCollectionTemplateGroupBuilder * _Nonnull group) {
             group.width.fractionalWidth(1.0);
             group.height.fractionalWidth(1.0);

             // container 1
             group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                 container.width.fractionalWidth(0.5);
                 container.height.fractionalHeight(1.0);

                 // items
                 for ( NSInteger i = 0 ; i < 2 ; ++ i ) {
                     container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                         item.width.fractionalWidth(1.0);
                         item.height.fractionalHeight(0.5);
                     });
                 }
             });

             // container 2
             group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                 container.width.fractionalWidth(0.5);
                 container.height.fractionalHeight(1.0);

                 container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                     item.width.fractionalWidth(1.0);
                     item.height.fractionalHeight(1.0);
                 });
             });
         });

 //
 //         +--------------------------------------+
 //         |                                      |
 //         |  +--------------+  +--------------+  |
 //         |  |              |  |              |  |
 //         |  |  +--------+  |  |  +--------+  |  |
 //         |  |  |        |  |  |  |        |  |  |
 //         |  |  |   1    |  |  |  |   3    |  |  |
 //         |  |  +--------+  |  |  +--------+  |  |
 //         |  |              |  |              |  |
 //         |  |  +--------+  |  |  +--------+  |  |
 //         |  |  |        |  |  |  |        |  |  |
 //         |  |  |   2    |  |  |  |   4    |  |  |
 //         |  |  +--------+  |  |  +--------+  |  |
 //         |  |              |  |              |  |
 //         |  +--------------+  +--------------+  |
 //         |                                      |
 //         +--------------------------------------+
 //
         make.addGroup(^(LWZCollectionTemplateGroupBuilder * _Nonnull group) {
             group.width.fractionalWidth(1.0);
             group.height.fractionalWidth(1.0);

             for ( NSInteger i = 0 ; i < 2 ; ++ i ) {
                 // container
                 group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                     container.width.fractionalWidth(0.5);
                     container.height.fractionalHeight(1.0);

                     // items
                     for ( NSInteger i = 0 ; i < 2 ; ++ i ) {
                         container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                             item.width.fractionalWidth(1);
                             item.height.fractionalHeight(0.5);
                         });
                     }
                 });
             }
         });

 //
 //         +--------------------+
 //         |                    |
 //         |  +--------------+  |
 //         |  |              |  |
 //         |  |  +--------+  |  |
 //         |  |  |        |  |  |
 //         |  |  |   1    |  |  |
 //         |  |  +--------+  |  |
 //         |  |              |  |
 //         |  |  +--------+  |  |
 //         |  |  |        |  |  |
 //         |  |  |   2    |  |  |
 //         |  |  +--------+  |  |
 //         |  |              |  |
 //         |  |  +--------+  |  |
 //         |  |  |        |  |  |
 //         |  |  |   3    |  |  |
 //         |  |  +--------+  |  |
 //         |  |              |  |
 //         |  +--------------+  |
 //         |                    |
 //         +--------------------+
 //
         make.addGroup(^(LWZCollectionTemplateGroupBuilder * _Nonnull group) {
             group.width.fractionalWidth(1.0);
             group.height.fractionalWidth(1.0);

             group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                 container.width.fractionalWidth(1.0);
                 container.height.fractionalHeight(1.0);

                 for ( NSInteger i = 0 ; i < 3 ; ++ i ) {
                     container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                         item.width.fractionalWidth(1);
                         item.height.fractionalHeight(1/3.0);
                     });
                 }
             });
         });
     }];
 }
 \endcode
 */
NS_ASSUME_NONNULL_END
