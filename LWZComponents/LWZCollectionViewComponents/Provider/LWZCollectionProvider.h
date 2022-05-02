//
//  LWZCollectionProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by BlueDancer on 2020/11/16.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionSection.h"
#import "LWZCollectionSectionHeaderFooter.h"
#import "LWZCollectionDecoration.h"
#import "LWZCollectionItem.h"

/// 数据供应器, 数据组合
///
NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionProvider : NSObject

@property (nonatomic) CGFloat sectionSpacing;

- (void)addSectionWithBlock:(void(^NS_NOESCAPE)(__kindof LWZCollectionSection *make))block;

@property (nonatomic, readonly) NSInteger numberOfSections;
- (NSInteger)numberOfItemsInSectionAtIndex:(NSInteger)sectionIndex;

@property (nonatomic, readonly, nullable) __kindof LWZCollectionSection *firstSection;
@property (nonatomic, readonly, nullable) __kindof LWZCollectionSection *lastSection;
@property (nonatomic, readonly, nullable) NSArray<__kindof LWZCollectionSection *> *allSections;

- (void)enumerateSectionsUsingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSection *section, NSInteger idx, BOOL *stop))block;
- (void)enumerateSectionHeadersUsingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSectionHeaderFooter *header, NSInteger idx, BOOL *stop))block;
- (void)enumerateItemIndexPathsUsingBlock:(void(NS_NOESCAPE ^)(NSIndexPath *indexPath, BOOL *stop))block;
- (void)enumerateSectionFootersUsingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSectionHeaderFooter *footer, NSInteger idx, BOOL *stop))block;

- (void)enumerateSectionsWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSection *section, NSInteger idx, BOOL *stop))block;
- (void)enumerateSectionHeadersWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSectionHeaderFooter *header, NSInteger idx, BOOL *stop))block;
- (void)enumerateItemIndexPathsWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(NSIndexPath *indexPath, BOOL *stop))block;
- (void)enumerateSectionFootersWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSectionHeaderFooter *footer, NSInteger idx, BOOL *stop))block;

- (NSInteger)addSection:(LWZCollectionSection *)section;
- (nullable NSIndexSet *)addSections:(NSArray<LWZCollectionSection *> *)sections;
- (NSInteger)insertSection:(LWZCollectionSection *)section atIndex:(NSInteger)index;
- (nullable NSIndexSet *)insertSections:(NSArray<LWZCollectionSection *> *)sections withPreviousSection:(LWZCollectionSection *)section;
- (nullable NSIndexSet *)insertSections:(NSArray<LWZCollectionSection *> *)sections withNextSection:(LWZCollectionSection *)section;
- (void)replaceSectionAtIndex:(NSInteger)index withSection:(LWZCollectionSection *)section;

- (nullable __kindof LWZCollectionSection *)sectionAtIndex:(NSInteger)index;
- (nullable __kindof LWZCollectionSectionHeaderFooter *)headerForSectionAtIndex:(NSInteger)index;
- (nullable __kindof LWZCollectionSectionHeaderFooter *)footerForSectionAtIndex:(NSInteger)index;
- (nullable __kindof LWZCollectionItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)containsSection:(LWZCollectionSection *)section;
- (BOOL)containsHeader:(LWZCollectionSectionHeaderFooter *)header;
- (BOOL)containsFooter:(LWZCollectionSectionHeaderFooter *)footer;
- (BOOL)containsItem:(LWZCollectionItem *)item;

- (NSInteger)indexOfSection:(LWZCollectionSection *)section;
- (NSInteger)indexOfSectionForHeader:(LWZCollectionSectionHeaderFooter *)header;
- (NSInteger)indexOfSectionForFooter:(LWZCollectionSectionHeaderFooter *)footer;
- (nullable NSIndexSet *)indexesForSectionsInArray:(NSArray<LWZCollectionSection *> *)sections;
- (nullable NSIndexPath *)indexPathOfItem:(LWZCollectionItem *)item;
- (nullable NSArray<NSIndexPath *> *)indexPathsForItemsInArray:(NSArray<LWZCollectionItem *> *)items;

- (nullable LWZCollectionSection *)sectionOfItem:(LWZCollectionItem *)item;
- (nullable LWZCollectionSection *)sectionOfHeader:(LWZCollectionSectionHeaderFooter *)header;
- (nullable LWZCollectionSection *)sectionOfFooter:(LWZCollectionSectionHeaderFooter *)footer;

///
/// 设置section隐藏.
///
/// @note 设置 hidden, 不会移除 section, 只是控制界面上是否显示.
///
- (void)setHidden:(BOOL)isHidden forSectionAtIndex:(NSInteger)index;
- (void)setHidden:(BOOL)isHidden forSection:(LWZCollectionSection *)section;
- (BOOL)isSectionHiddenAtIndex:(NSInteger)index;
- (BOOL)isSectionHidden:(LWZCollectionSection *)section;

///
/// 将`item`移动到previousItem之后.
///
/// @return 返回新位置的索引. `item`为空或当前section不包含`previousItem & item`, 将返回 nil.
///
- (nullable NSIndexPath *)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (nullable NSIndexPath *)moveItem:(LWZCollectionItem *)item withPreviousItem:(LWZCollectionItem *)previousItem;
- (nullable NSArray<NSIndexPath *> *)moveItemsInArray:(NSArray<LWZCollectionItem *> *)items withPreviousItem:(LWZCollectionItem *)previousItem;

///
/// 将`item`移动到nextItem之前.
///
/// @return 返回新位置的索引. `item`为空或当前section不包含`nextItem & item`, 将返回 nil.
///
- (nullable NSIndexPath *)moveItem:(LWZCollectionItem *)item withNextItem:(LWZCollectionItem *)nextItem;
- (nullable NSArray<NSIndexPath *> *)moveItemsInArray:(NSArray<LWZCollectionItem *> *)items withNextItem:(LWZCollectionItem *)nextItem;

///
/// 将item插入到previousItem后面.
///
/// @return 返回插入位置的索引. `item`为空或`previousItem`未添加到某个section中, 将返回 nil.
///
- (nullable NSIndexPath *)insertItem:(LWZCollectionItem *)item atIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)insertItem:(LWZCollectionItem *)item withPreviousItem:(LWZCollectionItem *)previousItem;
- (nullable NSArray<NSIndexPath *> *)insertItems:(NSArray<LWZCollectionItem *> *)items withPreviousItem:(LWZCollectionItem *)previousItem;

///
/// 将item插入到nextItem前面.
///
/// @return 返回插入位置的索引. `item`为空或`nextItem`未添加到某个section中, 将返回 nil.
///
- (nullable NSIndexPath *)insertItem:(LWZCollectionItem *)item withNextItem:(LWZCollectionItem *)nextItem;
- (nullable NSArray<NSIndexPath *> *)insertItems:(NSArray<LWZCollectionItem *> *)items withNextItem:(LWZCollectionItem *)nextItem;

///
/// 在顶部插入item
///
- (nullable NSIndexPath *)insertItemToTop:(LWZCollectionItem *)item inSection:(LWZCollectionSection *)section;

///
/// 移除整个section. 包括decoration
///
/// @return 返回section的索引. 索引越界将返回 NSNotFound.
///
- (NSInteger)removeSectionAtIndex:(NSInteger)index;
- (NSInteger)removeSection:(LWZCollectionSection *)section;
- (nullable NSIndexSet *)removeSections:(NSArray<LWZCollectionSection *> *)sections;
- (void)removeAllSections;

///
/// 移除section的header. 包括decoration
///
/// @return 返回section的索引. 索引越界将返回 NSNotFound.
///
- (NSInteger)removeHeaderForSectionAtIndex:(NSInteger)index;
- (NSInteger)removeHeaderForSection:(LWZCollectionSection *)section;

///
/// 移除section的footer. 包括decoration
///
/// @return 返回section的索引. 索引越界将返回 NSNotFound.
///
- (NSInteger)removeFooterForSectionAtIndex:(NSInteger)index;
- (NSInteger)removeFooterForSection:(LWZCollectionSection *)section;

///
/// 移除item包括decoration
///
- (nullable NSIndexPath *)removeItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)removeItem:(LWZCollectionItem *)item;
- (nullable NSArray<NSIndexPath *> *)removeItemsInArray:(NSArray<LWZCollectionItem *> *)items;
- (nullable NSArray<NSIndexPath *> *)removeItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

///
/// 移除decoration
///
- (NSInteger)removeSectionDecorationAtIndex:(NSInteger)index;
- (NSInteger)removeSectionHeaderDecorationAtIndex:(NSInteger)index;
- (nullable NSIndexPath *)removeItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)removeSectionFooterDecorationAtIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
