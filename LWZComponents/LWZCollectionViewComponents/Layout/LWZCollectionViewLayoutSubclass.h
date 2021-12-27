//
//  LWZCollectionViewLayoutSubclass.h
//  SJTestAutoLayout_Example
//
//  Created by changsanjiang on 2021/11/10.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionViewLayout.h"

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionViewLayout (Subclass)

- (void)willPrepareLayoutInContainer:(LWZCollectionLayoutCollectionContentContainer *)container;

- (void)didFinishPreparingInContainer:(LWZCollectionLayoutCollectionContentContainer *)container;

#pragma mark - section

- (BOOL)shouldProcessSectionLayoutAtIndex:(NSInteger)index;

#pragma mark - header footer

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewWithElementKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container;

#pragma mark - cells

- (LWZCollectionLayoutContentPresentationMode)layoutContentPresentationModeForCellsInSection:(NSInteger)index;

- (nullable UIView *)layoutCustomViewForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container;

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container;

#pragma mark - decorations

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSectionDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForHeaderDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForCellDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForFooterDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect;

#pragma mark -

- (UIEdgeInsets)edgeSpacingsForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)contentInsetsForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)adjustedPinnedInsetsForSectionAtIndex:(NSInteger)section;

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
       
- (CGFloat)zIndexForHeaderInSection:(NSInteger)section;
- (CGFloat)zIndexForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)zIndexForFooterInSection:(NSInteger)section;
@end

@interface LWZCollectionLayoutCollectionContentContainer (Internal)
- (instancetype)initWithCollectionSize:(CGSize)collectionSize direction:(UICollectionViewScrollDirection)direction collectionContentInsets:(UIEdgeInsets)contentInsets collectionSafeAreaInsets:(UIEdgeInsets)safeAreaInsets ignoredCollectionSafeAreaInsets:(BOOL)isIgnoredSafeAreaInsets;
@end

@interface LWZCollectionLayoutSectionContentContainer (Internal)
- (instancetype)initWithCollectionContentContainer:(LWZCollectionLayoutCollectionContentContainer *)collectionContentContainer sectionEdgeSpacings:(UIEdgeInsets)edgeSpacings sectionContentInsets:(UIEdgeInsets)contentInsets;
@end
NS_ASSUME_NONNULL_END
