//
//  LWZCollectionSection.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2020/11/16.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionDefines.h"
#import "LWZCollectionSectionHeaderFooter.h"
#import "LWZCollectionDecoration.h"
#import "LWZCollectionItem.h"
@class LWZCollectionLayoutTemplateGroup;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionSection : NSObject
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) UIEdgeInsets contentInsets; // 内间距.
@property (nonatomic) UIEdgeInsets edgeSpacings; // 外间距.

@property (nonatomic, strong, nullable) __kindof LWZCollectionSectionHeaderFooter *header;
@property (nonatomic, strong, nullable) __kindof LWZCollectionSectionHeaderFooter *footer;
@property (nonatomic, strong, nullable) __kindof LWZCollectionDecoration *decoration;

@property (nonatomic) BOOL canPinToVisibleBoundsForHeader; // default value is YES.
 
@property (nonatomic, getter=isHidden) BOOL hidden;
@property (nonatomic) BOOL hidesAutomatically; // 当`items.count == 0`时, 是否自动隐藏

@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly, nullable) __kindof LWZCollectionItem *firstItem;
@property (nonatomic, readonly, nullable) __kindof LWZCollectionItem *lastItem;
- (BOOL)containsItem:(LWZCollectionItem *)item;
- (NSInteger)indexForItem:(LWZCollectionItem *)item;
- (nullable NSIndexSet *)indexesForItemsInArray:(NSArray<LWZCollectionItem *> *)items;
- (nullable __kindof LWZCollectionItem *)itemAtIndex:(NSInteger)index;
- (void)enumerateItemsUsingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionItem *item, NSInteger index, BOOL *stop))block;
- (void)enumerateItemsWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionItem *item, NSInteger index, BOOL *stop))block;

- (NSInteger)addItem:(LWZCollectionItem *)item;
- (nullable NSIndexSet *)addItemsFromArray:(NSArray<LWZCollectionItem *> *)items;

- (NSInteger)insertItem:(LWZCollectionItem *)item atIndex:(NSInteger)index;
- (NSInteger)insertItem:(LWZCollectionItem *)item withPreviousItem:(LWZCollectionItem *)previousItem;
- (NSInteger)insertItem:(LWZCollectionItem *)item withNextItem:(LWZCollectionItem *)nextItem;
- (NSInteger)insertItemToTop:(LWZCollectionItem *)item;
- (nullable NSIndexSet *)insertItems:(NSArray<LWZCollectionItem *> *)items withPreviousItem:(LWZCollectionItem *)previousItem;
- (nullable NSIndexSet *)insertItems:(NSArray<LWZCollectionItem *> *)items withNextItem:(LWZCollectionItem *)nextItem;

- (NSInteger)moveItem:(LWZCollectionItem *)item toIndex:(NSInteger)index;
- (NSInteger)moveItem:(LWZCollectionItem *)item withPreviousItem:(LWZCollectionItem *)previousItem;
- (NSInteger)moveItem:(LWZCollectionItem *)item withNextItem:(LWZCollectionItem *)nextItem;
- (nullable NSIndexSet *)moveItemsInArray:(NSArray<LWZCollectionItem *> *)items withPreviousItem:(LWZCollectionItem *)previousItem;
- (nullable NSIndexSet *)moveItemsInArray:(NSArray<LWZCollectionItem *> *)items withNextItem:(LWZCollectionItem *)nextItem;

- (NSInteger)removeItemAtIndex:(NSInteger)index;
- (NSInteger)removeItem:(LWZCollectionItem *)item;
- (nullable NSIndexSet *)removeItemsInArray:(NSArray<LWZCollectionItem *> *)items;
- (void)removeAllItems;

- (void)setNeedsLayout;
@end


@interface LWZCollectionSection (LWZCollectionWaterfallFlowLayoutAdditions)
@property (nonatomic) NSInteger numberOfArrangedItemsPerLine;
@end


@interface LWZCollectionSection (LWZCollectionTemplateLayoutAdditions)
@property (nonatomic, strong, nullable) NSArray<LWZCollectionLayoutTemplateGroup *> *layoutTemplateContainerGroups;
@end

@interface LWZCollectionSection (LWZCollectionHybridLayoutAdditions)
@property (nonatomic) LWZCollectionLayoutType layoutType;
@end


@interface LWZCollectionSection (LWZCollectionCompositionalLayoutAdditions)
@property (nonatomic, getter=isOrthogonalScrolling) BOOL orthogonalScrolling;
- (CGSize)layoutSizeThatFits:(CGSize)size forOrthogonalContentAtIndex:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

@property (nonatomic, copy, nullable) CGSize(^orthogonalContentLayoutSizeCalculator)(LWZCollectionSection *section, CGSize fittingSize, NSInteger index, UICollectionViewScrollDirection scrollDirection);
@property (nonatomic) LWZCollectionLayoutContentOrthogonalScrollingBehavior orthogonalScrollingBehavior;
@end


@interface LWZCollectionSection (LWZCollectionSubclassHooks)
- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didBindCellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didUnbindCellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
