//
//  LWZCollectionLayoutContentContainer.h
//  SJTestAutoLayout_Example
//
//  Created by changsanjiang on 2021/11/9.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionDefines.h"
@class LWZCollectionTemplateBuilder;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionLayoutCollectionContentContainer : NSObject
@property (nonatomic, readonly) CGSize collectionSize;
@property (nonatomic, readonly) UICollectionViewScrollDirection layoutDirection;
@property (nonatomic, readonly) UIEdgeInsets layoutInsets;
@property (nonatomic, readonly) UIFloatRange layoutRange;
@property (nonatomic, readonly) CGSize layoutContainerSize;
@end


@interface LWZCollectionLayoutSectionContentContainer : NSObject
@property (nonatomic, readonly) UIEdgeInsets edgeSpacings;
@property (nonatomic, readonly) UIEdgeInsets contentInsets;
@property (nonatomic, strong, readonly) LWZCollectionLayoutCollectionContentContainer *collectionContentContainer;
@property (nonatomic, readonly) UICollectionViewScrollDirection layoutDirection;
@property (nonatomic, readonly) UIEdgeInsets layoutInsets;
@property (nonatomic, readonly) UIFloatRange layoutRange;

@property (nonatomic, readonly) UIFloatRange headerFooterLayoutRange;
@property (nonatomic, readonly) UIFloatRange itemLayoutRange;
@property (nonatomic, readonly) CGSize itemLayoutContainerSize;
@end

#pragma mark - Template

@interface LWZCollectionLayoutTemplateDimension : NSObject
- (instancetype)initWithFractionalWidthDimension:(CGFloat)dimension; // 相对于父容器的比例
- (instancetype)initWithFractionalHeightDimension:(CGFloat)dimension; // 相对于父容器的比例
- (instancetype)initWithAbsoluteDimension:(CGFloat)dimension; // 固定值
- (instancetype)initWithDimension:(CGFloat)dimension semantic:(LWZCollectionLayoutTemplateDimensionSemantic)semantic;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, readonly) LWZCollectionLayoutTemplateDimensionSemantic semantic;
@property (nonatomic, readonly) CGFloat dimension;
@end

@interface LWZCollectionLayoutTemplateSize : NSObject
- (instancetype)initWithWidthDimension:(LWZCollectionLayoutTemplateDimension *)width heightDimension:(LWZCollectionLayoutTemplateDimension *)height;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, strong, readonly) LWZCollectionLayoutTemplateDimension *width;
@property (nonatomic, strong, readonly) LWZCollectionLayoutTemplateDimension *height;
@end

@interface LWZCollectionLayoutTemplateItem : NSObject
- (instancetype)initWithSize:(LWZCollectionLayoutTemplateSize *)size;

@property (nonatomic, strong, readonly) LWZCollectionLayoutTemplateSize *size;
@end

/**
 
 定义一个模板容器, 一个容器可以有多个item.
 
 \code
 +-----[V]-----+ <--- Container
 |             |
 |  +-------+ <------ Item
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
 |  +-----------+  +-----------+ <------- Item
 |  |           |  |           |  |
 |  |           |  |           |  |
 |  |     1     |  |     2     |  |
 |  +-----------+  +-----------+  |
 |                                |
 +--------------------------------+
 \endcode
 */
@interface LWZCollectionLayoutTemplateContainer : LWZCollectionLayoutTemplateItem
- (instancetype)initWithSize:(LWZCollectionLayoutTemplateSize *)size items:(NSArray<LWZCollectionLayoutTemplateItem *> *)items;
@property (nonatomic, copy, readonly) NSArray<LWZCollectionLayoutTemplateItem *> *items;
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
@interface LWZCollectionLayoutTemplateGroup : LWZCollectionLayoutTemplateItem
- (instancetype)initWithSize:(LWZCollectionLayoutTemplateSize *)size containers:(NSArray<LWZCollectionLayoutTemplateContainer *> *)containers;
@property (nonatomic, strong, readonly, nullable) NSArray<LWZCollectionLayoutTemplateContainer *> *containers;
@end

@interface LWZCollectionLayoutTemplate : NSObject
+ (NSArray<LWZCollectionLayoutTemplateGroup *> *)build:(void(^)(LWZCollectionTemplateBuilder *make))block;
@end

// solver 对frame的解析. 每个result表示对应item在groups中的位置(frame)
@interface LWZCollectionTemplateLayoutSolver : NSObject
- (instancetype)initWithGroups:(NSArray<LWZCollectionLayoutTemplateGroup *> *)groups scrollDirection:(UICollectionViewScrollDirection)scrollDirection numberOfItems:(NSInteger)numberOfItems lineSpacing:(CGFloat)lineSpacing itemSpacing:(CGFloat)itemSpacing containerSize:(CGSize)containerSize;
- (CGRect)itemLayoutFrameAtIndex:(NSInteger)index;
@end

@interface LWZCollectionTemplateDimensionBuilder : NSObject
@property (nonatomic, copy, readonly) LWZCollectionTemplateDimensionBuilder *(^semantic)(LWZCollectionLayoutTemplateDimensionSemantic semantic);
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
@property (nonatomic, readonly) NSArray<LWZCollectionLayoutTemplateGroup *> *groups;
@end

/**
 \code
 - (NSArray<LWZCollectionLayoutTemplateGroup *> *)layout:(__kindof LWZCollectionViewLayout *)layout layoutTemplateContainerGroupsInSection:(NSInteger)section {

     return [LWZCollectionLayoutTemplate build:^(LWZCollectionTemplateBuilder * _Nonnull make) {
 //
 //            Container 1
 //             |
 //         +---|----------------------------------+ <-- Group
 //         |   v                                  |
 //         |  +--------------+  +--------------+ <----- Container 2
 //         |  |              |  |              |  |
 //         |  |  +--------+  |  |  +--------+ <-------- Item
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
