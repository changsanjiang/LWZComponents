//
//  LWZCollectionViewLayoutSubclass.h
//  SJTestAutoLayout_Example
//
//  Created by 蓝舞者 on 2021/11/10.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionViewLayout.h"

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionViewLayout (Subclass)
- (void)willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container;

- (void)didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container;

- (BOOL)isSectionHiddenAtIndex:(NSInteger)section;

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewWithElementKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container;

- (LWZCollectionLayoutContentPresentationMode)presentationModeForCellsInSection:(NSInteger)index;
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container;
- (nullable UIView *)layoutCustomViewForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container;

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSectionDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForHeaderDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForCellDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForFooterDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect;
@end

@interface LWZCollectionLayoutContainer (Internal)
- (instancetype)initWithCollectionSize:(CGSize)collectionSize direction:(UICollectionViewScrollDirection)direction collectionContentInsets:(UIEdgeInsets)contentInsets collectionSafeAreaInsets:(UIEdgeInsets)safeAreaInsets ignoredCollectionSafeAreaInsets:(BOOL)isIgnoredSafeAreaInsets;
@end

@interface LWZSectionLayoutContainer (Internal)
- (instancetype)initWithCollectionLayoutContainer:(LWZCollectionLayoutContainer *)collectionLayoutContainer sectionEdgeSpacings:(UIEdgeInsets)edgeSpacings sectionContentInsets:(UIEdgeInsets)contentInsets;
@end
NS_ASSUME_NONNULL_END
