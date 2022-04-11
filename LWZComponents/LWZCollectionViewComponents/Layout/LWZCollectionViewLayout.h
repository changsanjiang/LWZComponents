//
//  LWZCollectionViewLayout.h
//  LWZCollectionViewComponents_Example
//
//  Created by BlueDancer on 2020/11/13.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionDefines.h"
#import "LWZCollectionLayoutContainer.h"
#import "UICollectionViewLayoutAttributes+LWZCollectionAdditions.h"
@protocol LWZCollectionViewLayoutObserver, LWZCollectionViewLayoutDelegate;
@class LWZCollectionLayoutSolver;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionViewLayout : UICollectionViewLayout<LWZCollectionLayout>

@property(class, nonatomic, readonly) Class layoutSolverClass;

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection delegate:(nullable id<LWZCollectionViewLayoutDelegate>)delegate;
@property (nonatomic, weak, nullable) id<LWZCollectionViewLayoutDelegate> delegate;

@property (nonatomic, readonly) UICollectionViewScrollDirection scrollDirection;

@property (nonatomic, strong, readonly) LWZCollectionLayoutSolver *layoutSolver;

- (void)prepareLayoutForCollectionSize:(CGSize)size contentInsets:(UIEdgeInsets)contentInsets;

@property (nonatomic, getter=isIgnoredSafeAreaInsets) BOOL ignoredSafeAreaInsets NS_AVAILABLE_IOS(11.0); // default value is YES.
- (void)prepareLayoutForCollectionSize:(CGSize)size contentInsets:(UIEdgeInsets)contentInsets safeAreaInsets:(UIEdgeInsets)safeAreaInsets NS_AVAILABLE_IOS(11.0);

@property (nonatomic) BOOL sectionHeadersPinToVisibleBounds;
//@property (nonatomic) BOOL sectionFootersPinToVisibleBounds;

@property (nonatomic) UIEdgeInsets adjustedPinnedInsets;

- (CGRect)layoutFrameForSection:(NSInteger)section;

- (void)enumerateLayoutAttributesWithElementCategory:(UICollectionElementCategory)category usingBlock:(void(NS_NOESCAPE ^)(UICollectionViewLayoutAttributes *attributes, BOOL *stop))block;
- (nullable NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category;
- (nullable NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category inSection:(NSInteger)section;

- (void)registerObserver:(id<LWZCollectionViewLayoutObserver>)observer;
- (void)removeObserver:(id<LWZCollectionViewLayoutObserver>)observer;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end


@interface LWZCollectionViewLayout (LWZCollectionFittingSize)
- (void)prepareLayoutFittingSize:(CGSize)fittingSize contentInsets:(UIEdgeInsets)contentInsets;
- (void)prepareLayoutFittingSize:(CGSize)fittingSize contentInsets:(UIEdgeInsets)contentInsets safeAreaInsets:(UIEdgeInsets)safeAreaInsets NS_AVAILABLE_IOS(11.0);
@end

#pragma mark - observer methods

@protocol LWZCollectionViewLayoutObserver <NSObject>
@optional
- (void)layout:(__kindof LWZCollectionViewLayout *)layout willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container;

- (void)layout:(__kindof LWZCollectionViewLayout *)layout didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container;
@end

 
#pragma mark - delegate methods
 
@protocol LWZCollectionViewLayoutDelegate <LWZCollectionViewLayoutObserver>
@optional

/**
 \code
 
                          +---------------------------+
                          |                           |
                          |   edgeSpacings.top        |
                          |                           |
  +-----------------------+---------------------------+-------------------------+
  |                       |                           |                         |
  |                       |                           |                         |
  |   edgeSpacings.left   |          Section          |   edgeSpacings.right    |
  |                       |                           |                         |
  |                       |                           |                         |
  +-----------------------+---------------------------+-------------------------+
                          |                           |
                          |   edgeSpacings.bottom     |
                          |                           |
                          +---------------------------+
 \endcode
 */
- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout edgeSpacingsForSectionAtIndex:(NSInteger)section;

/**
 \code
 +------------------------------------------------------------------------------+
 |                                                                              |
 |                               section.header                                 |
 |                                                                              |
 +------------------------+----------------------------+------------------------+
                          |                            |
                          |     contentInsets.top      |
                          |                            |
 +------------------------+------+---+------+---+------+------------------------+
 |                        |      |   |      |   |      |                        |
 |                        | cell |   | cell |   | cell |                        |
 |                        |      |   |      |   |      |                        |
 |                        +------+   +------+   +------+                        |
 |   contentInsets.left   |                            |   contentInset.right   |
 |                        +------+   +------+   +------+                        |
 |                        |      |   |      |   |      |                        |
 |                        | cell |   | cell |   | cell |                        |
 |                        |      |   |      |   |      |                        |
 +------------------------+------+---+------+---+------+------------------------+
                          |                            |
                          |     contentInsets.bottom   |
                          |                            |
 +------------------------+----------------------------+------------------------+
 |                                                                              |
 |                               section.footer                                 |
 |                                                                              |
 +------------------------------------------------------------------------------+
 \endcode
 */
- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout contentInsetsForSectionAtIndex:(NSInteger)section;

- (BOOL)layout:(__kindof LWZCollectionViewLayout *)layout canPinToVisibleBoundsForHeaderInSection:(NSInteger)section;
- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout adjustedPinnedInsetsForSectionAtIndex:(NSInteger)section;

- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

/**
 \code
 +--------------------------[V]-------------------------+
 |                                                      |
 |      +------------------+                            |
 |      | interitemSpacing |                            |
 |      +------------------+                            |
 |               |                                      |
 |               v                                      |
 |  +----------+   +----------+                         |
 |  | ~~~~~~~~ |   | ~~~~~~~~ |                         |
 |  | ~~~~~~~~ |   | ~~~~~~~~ |                         |
 |  | ~~~~~~~~ |   | ~~~~~~~~ |                         |
 |  | ~~~~~~~~ |   +----------+        +-------------+  |
 |  | ~~~~~~~~ |                <----- | lineSpacing |  |
 |  | ~~~~~~~~ |   +----------+        +-------------+  |
 |  +----------+   | ~~~~~~~~ |                         |
 |                 | ~~~~~~~~ |                         |
 |  +----------+   | ~~~~~~~~ |                         |
 |  | ~~~~~~~~ |   | ~~~~~~~~ |                         |
 |  |  ~~~~~~~ |   | ~~~~~~~~ |                         |
 |  |   ~~~~~~ |   |   ~~~~~~ |                         |
 |  |     .... |   |     .... |                         |
 |                                                      |
 +------------------------------------------------------+
 
 +---------------------------------[H]------------------------------+
 |                                                                  |
 |           +-------------+                                        |
 |           | lineSpacing |                                        |
 |           +-------------+                                        |
 |                  |                                               |
 |                  v                                               |
 |  +-------------+   +------------                                 |
 |  | ~~~~~~~~~~~ |   | ~~~~~~~                                     |
 |  | ~~~~~~~~~~~ |   | ~~~~~~~~                                    |
 |  | ~~~~~~~~~~~ |   | ~~~~~~~~~~                                  |
 |  +-------------+   +------------          +------------------+   |
 |                                      <--- | interitemSpacing |   |
 |  +--------------------+   +---------      +------------------+   |
 |  | ~~~~~~~~~~~~~~~~~~ |   | ~~~~~                                |
 |  | ~~~~~~~~~~~~~~~~~~ |   | ~~~~~~                               |
 |  | ~~~~~~~~~~~~~~~~~~ |   | ~~~~~~~                              |
 |  +--------------------+   +---------                             |
 |                                                                  |
 +------------------------------------------------------------------+
 \endcode
 */
- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;


- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;

- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;

- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForHeaderInSection:(NSInteger)section;
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForFooterInSection:(NSInteger)section;

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;
@end

// [V]垂直布局
// [H]水平布局

#pragma mark - weight

@protocol LWZCollectionViewWeightLayoutDelegate <LWZCollectionViewLayoutDelegate>
@optional
/// (0, 1]
/// 如果未实现, 默认为1
- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout layoutWeightForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

/**
 \code
 根据比重布局
 [V] 垂直布局时, 每行根据比重分配item的宽度, 同行item的高度与行首item一致
 [H] 水平布局同理
 
 
 [V] 垂直布局, bounds.width * weight ==> item.maxWidth,  可以小于但不能大于. 当 item.width > maxWidth 时, 将被修正为 maxWidth
 +---------------------------+
 |                           |
 |    weight = 1.0           |
 |                           |
 +-------------+-------------+
 |             |             |
 |   0.5       |    0.5      |
 |             |             |
 +---------+---+-------------+
 |         |                 |
 |         |                 |
 +---------+-----------------+
  
 [H] 水平布局, bounds.height * weight ==> item.maxHeight,  可以小于但不能大于. 当 item.height > maxHeight 时, 将被修正为 maxHeight
 +--------------+-----+------+
 |              |     |      |
 |              |     |      |
 |              |     |      |
 |              | 0.5 |      |
 | weight = 1.0 +-----+      |
 |              |     | 0.75 |
 |              |     +------+
 |              |     |      |
 |              | 0.5 | 0.25 |
 +--------------+-----+------+
 
 \endcode
 */
@interface LWZCollectionViewWeightLayout : LWZCollectionViewLayout
@property (nonatomic, weak, nullable) id<LWZCollectionViewWeightLayoutDelegate> delegate;
@end


#pragma mark - list

@protocol LWZCollectionViewListLayoutDelegate <LWZCollectionViewLayoutDelegate>
@optional
- (LWZCollectionLayoutAlignment)layout:(__kindof LWZCollectionViewLayout *)layout layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

/**
 列表布局, 列数[v]为1, 行数[h]为1, interitemSpacing 将无效;
 
 [V] CollectionView 宽度必须设置
 [H] CollectionView 高度必须设置

 +---------[V]-------+
 |                   |
 |  +---------+      |
 |  | ~~~~~~~ |    <-+-- Start(左对齐)
 |  | ~~~~~~~ |      |
 |  +---------+      |
 |                   |
 |    +---------+    |
 |    | ~~~~~~~ |  <-+-- Center(中对齐)
 |    | ~~~~~~~ |    |
 |    +---------+    |
 |                   |
 |      +---------+  |
 |      | ~~~~~~~ |<-+-- End(右对齐)
 |      | ~~~~~~~ |  |
 |      +---------+  |
 |                   |
 +-------------------+
 
 +----------------------[H]----------------------+
 |                                               |
 |  +---------+                                <-+-- Start(顶对齐)
 |  | ~~~~~~~ |     +---------+                  |
 |  | ~~~~~~~ |     | ~~~~~~~ |                <-+-- Center(中对齐)
 |  +---------+     | ~~~~~~~ |     +---------+  |
 |                  +---------+     | ~~~~~~~ |<-+-- End(底对齐)
 |                                  | ~~~~~~~ |  |
 |                                  +---------+  |
 |                                               |
 +-----------------------------------------------+
 */
@interface LWZCollectionViewListLayout : LWZCollectionViewLayout
@property (nonatomic, weak, nullable) id<LWZCollectionViewListLayoutDelegate> delegate;
@end

#pragma mark - waterfall flow



@protocol LWZCollectionViewWaterfallFlowLayoutDelegate <LWZCollectionViewLayoutDelegate>
@optional
/// (0, ...)
/// 如果未实现, 默认为1
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout layoutNumberOfArrangedItemsPerLineInSection:(NSInteger)section;
@end

/**
 \code
 瀑布流布局
 [V] 垂直布局时, 每行的item平分宽度, 高度不一
 [H] 水平布局同理
 
 +-----------[V]----------+ ==> layoutNumberOfArrangedItemsPerLineInSection == 2
 |                        |
 |  +-------+  +-------+  |
 |  |       |  |       |  |
 |  |       |  |       |  |
 |  |   1   |  |       |  |
 |  +-------+  |   2   |  |
 |             +-------+  |
 |  +-------+
 |  |       |  +-------+  |
 |  |       |  |       |  |
 |  |       |  |       |  |
 |  |   3   |  |       |  |
 |  +-------+  |       |  |
 |             |   4   |  |
 |  +-------+  +-------+  |
 |  |       |             |
 |  |   ... |       ...   |
 |  v       v             |
 |                        |
 +------------------------+
 
 +-------------[H]--------------------+ ==> layoutNumberOfArrangedItemsPerLineInSection == 2
 |                                    |
 |  +-------+  +-----------+  +--->   |
 |  |       |  |           |  |       |
 |  |       |  |           |  |  ...  |
 |  +-------+  +-----------+  +--->   |
 |                                    |
 |  +-----------+  +----------+       |
 |  |           |  |          |       |
 |  |           |  |          |  ...  |
 |  +-----------+  +----------+       |
 |                                    |
 +------------------------------------+
 \endcode
 */
@interface LWZCollectionViewWaterfallFlowLayout : LWZCollectionViewLayout
@property (nonatomic, weak, nullable) id<LWZCollectionViewWaterfallFlowLayoutDelegate> delegate;
@end

#pragma mark - restricted layout

/**
 \code
 
 受限的布局
 [V] 垂直布局时: 每行item的高度与行首item一致, 宽度不一
 [H] 水平布局同理
 
 +------------------[V]------------------------+
 |                                             |
 |  +-------+  +------------+  +------------+  |
 |  |       |  |            |  |            |  |
 |  |   1   |  |     2      |  |     3      |  |
 |  +-------+  +------------+  +------------+  |
 |                                             |
 |  +--------------------+  +-----+            |
 |  |                    |  |     |            |
 |  |         4          |  |  5  |            |
 |  +--------------------+  +-----+            |
 |                                             |
 |  +---------------+  +------------+   +---+  |
 |  |               |  |            |   |   |  |
 |  |       6       |  |     7      |   | 8 |  |
 |  +---------------+  +------------+   +---+  |
 |                                             |
 +---------------------------------------------+
 
  
 +------------------[H]-------------------------+
 |                                              |
 |  +-------+  +-------+  +-------+  +-------+  |
 |  |       |  |       |  |   6   |  |       |  |
 |  |   1   |  |       |  +-------+  |       |  |
 |  +-------+  |       |             |       |  |
 |             |       |  +-------+  |       |  |
 |  +-------+  |   4   |  |       |  |  9    |  |
 |  |       |  +-------+  |   7   |  +-------+  |
 |  |   2   |             +-------+             |
 |  +-------+  +-------+             +-------+  |
 |             |       |  +-------+  |       |  |
 |  +-------+  |       |  |       |  | 10    |  |
 |  |       |  |       |  |   8   |  +-------+  |
 |  |   3   |  |   5   |  +-------+             |
 |  +-------+  +-------+                        |
 |                                              |
 +----------------------------------------------+
 \endcode
 */
@interface LWZCollectionViewRestrictedLayout : LWZCollectionViewLayout

@end


#pragma mark - template layout

@protocol LWZCollectionViewTemplateLayoutDelegate <LWZCollectionViewLayoutDelegate>
- (NSArray<LWZCollectionTemplateGroup *> *)layout:(__kindof LWZCollectionViewLayout *)layout layoutTemplateContainerGroupsInSection:(NSInteger)section;
@end


/**
 模板布局: 定义一套模板, cell 的位置将根据模板描述进行布局.
 
 \code
 
     Container1
     |
  +--+-----------------------[V]-------------------------+ <---- Group1
  |  v                                                   |
  |  +-------------------+   +-----------------------+ <-------- Container2
  |  |                   |   |                       |   |
  |  |   +-----------+   |   |   +---------------+ <------------ Item
  |  |   |           |   |   |   |               |   |   |
  |  |   |           |   |   |   |               |   |   |
  |  |   |     1     |   |   |   |               |   |   |
  |  |   +-----------+   |   |   |               |   |   |
  |  |                   |   |   |               |   |   |
  |  |   +-----------+   |   |   |        4      |   |   |
  |  |   |           |   |   |   +---------------+   |   |
  |  |   |           |   |   |                       |   |
  |  |   |     2     |   |   |   +---------------+   |   |
  |  |   +-----------+   |   |   |               |   |   |
  |  |                   |   |   |               |   |   |
  |  |   +-----------+   |   |   |               |   |   |
  |  |   |           |   |   |   |               |   |   |
  |  |   |           |   |   |   |               |   |   |
  |  |   |     3     |   |   |   |        5      |   |   |
  |  |   +-----------+   |   |   +---------------+   |   |
  |  |                   |   |                       |   |
  |  +-------------------+   +-----------------------+   |
  |                                                      |
  +------------------------------------------------------+

  +--------------------[H]---------------------+ <--- Group1
  |                                            |
  |  +--------------------------------------+ <------ Container1
  |  |                                      |  |
  |  |  +--------+  +--------+  +--------+ <--------- Item
  |  |  |        |  |        |  |        |  |  |
  |  |  |    1   |  |    2   |  |    3   |  |  |
  |  |  +--------+  +--------+  +--------+  |  |
  |  |                                      |  |
  |  +--------------------------------------+  |
  |                                            |
  |  +--------------------------------------+ <------ Container2
  |  |                                      |  |
  |  |  +--------------------+  +--------+ <--------- Item
  |  |  |                    |  |        |  |  |
  |  |  |         4          |  |   5    |  |  |
  |  |  +--------------------+  +--------+  |  |
  |  |                                      |  |
  |  +--------------------------------------+  |
  |                                            |
  +--------------------------------------------+
 \endcode
 */
@interface LWZCollectionViewTemplateLayout : LWZCollectionViewLayout
@property (nonatomic, weak, nullable) id<LWZCollectionViewTemplateLayoutDelegate> delegate;

@end

#pragma mark - multiple layout

@protocol LWZCollectionViewMultipleLayoutDelegate <
    LWZCollectionViewWeightLayoutDelegate,
    LWZCollectionViewListLayoutDelegate,
    LWZCollectionViewWaterfallFlowLayoutDelegate,
    LWZCollectionViewTemplateLayoutDelegate
>

/// 返回指定section的布局方式
- (LWZCollectionLayoutType)layout:(__kindof LWZCollectionViewLayout *)layout layoutTypeForItemsInSection:(NSInteger)section;
@end

/// 多种方式混合布局
@interface LWZCollectionViewMultipleLayout : LWZCollectionViewLayout
@property (nonatomic, weak, nullable) id<LWZCollectionViewMultipleLayoutDelegate> delegate;

@end


#pragma mark - compositional layout

@protocol LWZCollectionViewCompositionalLayoutDelegate <LWZCollectionViewMultipleLayoutDelegate>
@optional
- (BOOL)layout:(__kindof LWZCollectionViewLayout *)layout isOrthogonalScrollingInSection:(NSInteger)section;
/**
 \code
 
 水平滑动时, 需要根据 fittingSize.width 计算出合适的布局高度
 垂直滑动时, 需要根据 fittingSize.height 计算出合适的布局宽度
 
 +------------------------------------------------------------------------------+
 |                                                                              |
 |                               section.header                                 |
 |                                                                              |
 +------------------------+----------------------------+------------------------+
                          |                            |
                          |     contentInsets.top      |
                          |                            |
 +------------------------<===== fittingSize.width ====>---+------+---+------+-+-+------+---+------+   <---+
 |                        |      |   |      |   |      |   |      |   |      | | |      |   |      |       |
 |                        | cell |   | cell |   | cell |   | cell |   | cell | | | cell |   | cell |       |
 |                        |      |   |      |   |      |   |      |   |      | | |      |   |      |       |
 |                        +------+   +------+   +------+   +------+   +------+ | +------+   +------+       |
 |   contentInsets.left   |                            |   contentInset.right  |                          ??? (layoutSize.height)
 |                        +------+   +------+   +------+   +------+   +------+ | +------+   +------+       |
 |                        |      |   |      |   |      |   |      |   |      | | |      |   |      |       |
 |                        | cell |   | cell |   | cell |   | cell |   | cell | | | cell |   | cell |       |
 |                        |      |   |      |   |      |   |      |   |      | | |      |   |      |       |
 +------------------------<======================== horizontal scroll =============================>   <---+
                          |                            |
                          |     contentInsets.bottom   |
                          |                            |
 +------------------------+----------------------------+------------------------+
 |                                                                              |
 |                               section.footer                                 |
 |                                                                              |
 +------------------------------------------------------------------------------+
 \endcode
 */
- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forOrthogonalContentInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (LWZCollectionLayoutContentOrthogonalScrollingBehavior)layout:(__kindof LWZCollectionViewLayout *)layout orthogonalContentScrollingBehaviorInSection:(NSInteger)section;
@end

/**
 这个 layout 类似于 `UICollectionViewCompositionalLayout`, 但不完全一样, 是存在缺陷的.
 OrthogonalContent 区域的 cell 会在单独的 collectionView 中显示, 通过原来的 CollectionView 无法进行 cell 及 indexPath 的转换.
 缺陷如下:
 
 缺陷1: [collectionView cellForItemAtIndexPath:] 可能获取到不到对应 cell
        替代方案: 使用 [layout isOrthogonalScrollingInSection:] & [layout orthogonalScrollingCellForItemAtIndexPath:];
 
 缺陷2: [collectionView indexPathForCell:] 可能获取到不到对应 indexPath
        替代方案: 使用 [(UICollectionView *)cell.superview indexPathForCell:];
 
 缺陷3: collectionView:willDisplayCell:forItemAtIndexPath: 及 collectionView:didEndDisplayingCell:forItemAtIndexPath: 这两个方法在滑动 OrthogonalContent 区域, cell 可见状态发生变化时, 对应的 delegate 方法会触发, 但在区域外滑动, 将不会被触发.
        目前未解决
 
 缺陷4: delete, move 等 updates 相关方法可能无法正常工作.
 */
@interface LWZCollectionViewCompositionalLayout : LWZCollectionViewMultipleLayout

@property (nonatomic, weak, nullable) id<LWZCollectionViewCompositionalLayoutDelegate> delegate;

- (BOOL)isOrthogonalScrollingInSection:(NSInteger)section;
- (nullable __kindof UICollectionViewCell *)orthogonalScrollingCellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
