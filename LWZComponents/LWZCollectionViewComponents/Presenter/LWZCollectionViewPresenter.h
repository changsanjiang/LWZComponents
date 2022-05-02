//
//  LWZCollectionViewPresenter.h
//  LWZComponents
//
//  Created by 畅三江 on 2022/5/1.
//

#import <UIKit/UIKit.h>
#import "LWZCollectionDefines.h"
@class LWZCollectionProvider, LWZCollectionViewLayout, LWZCollectionLayoutContainer, LWZCollectionTemplateGroup;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionViewPresenter : NSObject
- (instancetype)initWithCollectionProvider:(LWZCollectionProvider *)collectionProvider;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)invalidateAllPresentationSizes;
- (void)updateVisibleItemViewsForLayout:(LWZCollectionViewLayout *)layout;

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (nullable __kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable __kindof UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - LWZCollectionViewLayoutDelegate

- (void)layout:(LWZCollectionViewLayout *)layout willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container;
- (void)layout:(LWZCollectionViewLayout *)layout didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container;

- (CGFloat)sectionSpacingForLayout:(LWZCollectionViewLayout *)layout;
- (BOOL)layout:(LWZCollectionViewLayout *)layout isSectionHiddenAtIndex:(NSInteger)section;
- (UIEdgeInsets)layout:(LWZCollectionViewLayout *)layout edgeSpacingsForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)layout:(LWZCollectionViewLayout *)layout contentInsetsForSectionAtIndex:(NSInteger)section;
- (BOOL)layout:(LWZCollectionViewLayout *)layout canPinToVisibleBoundsForHeaderInSection:(NSInteger)section;
- (CGFloat)layout:(LWZCollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)layout:(LWZCollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

- (CGSize)layout:(LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (CGSize)layout:(LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (CGSize)layout:(LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (NSInteger)layout:(LWZCollectionViewLayout *)layout zIndexForHeaderInSection:(NSInteger)section;
- (NSInteger)layout:(LWZCollectionViewLayout *)layout zIndexForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(LWZCollectionViewLayout *)layout zIndexForFooterInSection:(NSInteger)section;

- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForSectionAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForFooterAtIndexPath:(NSIndexPath *)indexPath;

- (nullable id)layout:(LWZCollectionViewLayout *)layout decorationUserInfoForSectionAtIndexPath:(NSIndexPath *)indexPath;
- (nullable id)layout:(LWZCollectionViewLayout *)layout decorationUserInfoForHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (nullable id)layout:(LWZCollectionViewLayout *)layout decorationUserInfoForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable id)layout:(LWZCollectionViewLayout *)layout decorationUserInfoForFooterAtIndexPath:(NSIndexPath *)indexPath;

- (CGRect)layout:(LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forSectionAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)layout:(LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)layout:(LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)layout:(LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forFooterAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)layout:(LWZCollectionViewLayout *)layout decorationZIndexForSectionAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(LWZCollectionViewLayout *)layout decorationZIndexForHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(LWZCollectionViewLayout *)layout decorationZIndexForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(LWZCollectionViewLayout *)layout decorationZIndexForFooterAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)layout:(LWZCollectionViewLayout *)layout layoutWeightForItemAtIndexPath:(NSIndexPath *)indexPath;
- (LWZCollectionLayoutAlignment)layout:(LWZCollectionViewLayout *)layout layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)layout:(LWZCollectionViewLayout *)layout layoutNumberOfArrangedItemsPerLineInSection:(NSInteger)section;
- (nullable NSArray<LWZCollectionTemplateGroup *> *)layout:(LWZCollectionViewLayout *)layout layoutTemplateContainerGroupsInSection:(NSInteger)section;
- (LWZCollectionLayoutType)layout:(LWZCollectionViewLayout *)layout layoutTypeForItemsInSection:(NSInteger)section;
- (BOOL)layout:(LWZCollectionViewLayout *)layout isOrthogonalScrollingInSection:(NSInteger)section;
- (CGSize)layout:(LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forOrthogonalContentInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (LWZCollectionLayoutContentOrthogonalScrollingBehavior)layout:(LWZCollectionViewLayout *)layout orthogonalContentScrollingBehaviorInSection:(NSInteger)section;
@end
NS_ASSUME_NONNULL_END
