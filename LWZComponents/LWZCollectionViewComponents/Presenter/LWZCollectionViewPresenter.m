//
//  LWZCollectionViewPresenter.m
//  LWZComponents
//
//  Created by 畅三江 on 2022/5/1.
//

#import "LWZCollectionViewPresenter.h"
#import "LWZCollectionViewLayout.h"
#import "LWZCollectionProvider.h"
#import "LWZCollectionSizes.h"
#import "LWZCollectionRegister.h"
#import "LWZCollectionPresenter.h"
#import "LWZCollectionInternals.h"
#import "LWZCollectionLayoutContainer.h"
#import "UICollectionReusableView+LWZCollectionAdditions.h"

/**
 这个类实现了collectionView的dataSource, delegate以及layout的delegate等方法;
 
 LWZCollectionViewPresenter 主要做了以下事情:
  
 1. cell等视图的注册;
 
 2. size的缓存;
 
 3. cell到item的绑定处理;
 
 4. 对固定写法的代理方法的封装;
 */
@implementation LWZCollectionViewPresenter {
    LWZCollectionProvider *mCollectionProvider;
    LWZCollectionSizes *mCollectionSizes;
    LWZCollectionRegister *mCollectionRegister;
    LWZCollectionPresenter *mCollectionPresenter;
    UIFloatRange mLayoutRange;
    BOOL mNeedsUpdateVisibleItemViews;
}

- (instancetype)initWithCollectionProvider:(LWZCollectionProvider *)collectionProvider {
    self = [super init];
    if ( self ) {
        mCollectionProvider = collectionProvider;
        mCollectionSizes = [LWZCollectionSizes.alloc initWithCollectionProvider:collectionProvider];
        mCollectionRegister = [LWZCollectionRegister.alloc initWithCollectionProvider:collectionProvider];
        mCollectionPresenter = [LWZCollectionPresenter.alloc initWithCollectionProvider:collectionProvider];
    }
    return self;
}

/**
 使缓存的size无效;
 
 当需要重新计算每个item的size时, 调用该方法进行标记;
 
 例如: 屏幕旋转时, collectionView 的大小会发生变化, 此时需要更新所有item的size;
 */
- (void)invalidateAllPresentationSizes {
    [mCollectionSizes invalidateAllPresentationSizes];
}

/**
 刷新当前显示的视图;
 */
- (void)updateVisibleItemViewsForLayout:(LWZCollectionViewLayout *)layout {
    UICollectionView *collectionView = layout.collectionView;
    for ( NSIndexPath *indexPath in collectionView.indexPathsForVisibleItems ) {
        LWZCollectionItem *item = [mCollectionProvider itemAtIndexPath:indexPath];
        if ( item.needsLayout ) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            if ( item == cell.lwz_boundItem ) {
                [mCollectionPresenter willDisplayCell:[collectionView cellForItemAtIndexPath:indexPath] forItemAtIndexPath:indexPath];
            }
        }

        LWZCollectionSection *section = [mCollectionProvider sectionAtIndex:indexPath.section];
        LWZCollectionSectionHeaderFooter *header = section.header;
        if ( header.needsLayout ) {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
            UICollectionReusableView *view = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
            if ( view != nil && header == view.lwz_boundItem ) {
                [mCollectionPresenter willDisplaySupplementaryView:view forElementKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
            }
        }
        
        LWZCollectionSectionHeaderFooter *footer = section.footer;
        if ( footer.needsLayout ) {
            NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
            UICollectionReusableView *view = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:footerIndexPath];
            if ( view != nil && footer == view.lwz_boundItem ) {
                [mCollectionPresenter willDisplaySupplementaryView:view forElementKind:UICollectionElementKindSectionFooter atIndexPath:footerIndexPath];
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [mCollectionProvider numberOfSections];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [mCollectionProvider numberOfItemsInSectionAtIndex:section];
}
- (nullable __kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionRegister collectionView:collectionView cellForItemAtIndexPath:indexPath];
}
- (nullable __kindof UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionRegister collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [mCollectionPresenter willDisplayCell:cell forItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [mCollectionPresenter didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [mCollectionPresenter willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath {
    [mCollectionPresenter didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [mCollectionPresenter didSelectItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [mCollectionPresenter didDeselectItemAtIndexPath:indexPath];
}

#pragma mark - LWZCollectionViewLayoutDelegate

- (void)layout:(LWZCollectionViewLayout *)layout willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container {
    if ( !UIFloatRangeIsEqualToRange(mLayoutRange, container.layoutRange) ) {
        mLayoutRange = container.layoutRange;
        mNeedsUpdateVisibleItemViews = YES;
        [self invalidateAllPresentationSizes]; // collectionView 的宽高发生改变的时候, 使缓存的size无效, 重新计算;
    }
}

- (void)layout:(LWZCollectionViewLayout *)layout didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container {
    if ( mNeedsUpdateVisibleItemViews ) {
        mNeedsUpdateVisibleItemViews = NO;
        [self updateVisibleItemViewsForLayout:layout];
    }
}

- (CGFloat)sectionSpacingForLayout:(LWZCollectionViewLayout *)layout {
    return mCollectionProvider.sectionSpacing;
}
- (BOOL)layout:(LWZCollectionViewLayout *)layout isSectionHiddenAtIndex:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].isHidden;
}
- (UIEdgeInsets)layout:(LWZCollectionViewLayout *)layout edgeSpacingsForSectionAtIndex:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].edgeSpacings;
}
- (UIEdgeInsets)layout:(LWZCollectionViewLayout *)layout contentInsetsForSectionAtIndex:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].contentInsets;
}
- (BOOL)layout:(LWZCollectionViewLayout *)layout canPinToVisibleBoundsForHeaderInSection:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].canPinToVisibleBoundsForHeader;
}
- (CGFloat)layout:(LWZCollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].minimumLineSpacing;
}
- (CGFloat)layout:(LWZCollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].minimumInteritemSpacing;
}

- (CGSize)layout:(LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [mCollectionSizes layoutSizeToFit:fittingSize forHeaderInSection:section scrollDirection:scrollDirection];
}
- (CGSize)layout:(LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [mCollectionSizes layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
}
- (CGSize)layout:(LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [mCollectionSizes layoutSizeToFit:fittingSize forFooterInSection:section scrollDirection:scrollDirection];
}

- (NSInteger)layout:(LWZCollectionViewLayout *)layout zIndexForHeaderInSection:(NSInteger)section {
    return [mCollectionProvider headerForSectionAtIndex:section].zPosition;
}
- (NSInteger)layout:(LWZCollectionViewLayout *)layout zIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider itemAtIndexPath:indexPath].zPosition;
}
- (NSInteger)layout:(LWZCollectionViewLayout *)layout zIndexForFooterInSection:(NSInteger)section {
    return [mCollectionProvider footerForSectionAtIndex:section].zPosition;
}

- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForSectionAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionRegister layout:layout decorationViewKindForSectionAtIndexPath:indexPath];
}
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionRegister layout:layout decorationViewKindForHeaderAtIndexPath:indexPath];
}
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionRegister layout:layout decorationViewKindForItemAtIndexPath:indexPath];
}
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForFooterAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionRegister layout:layout decorationViewKindForFooterAtIndexPath:indexPath];
}

- (nullable id)layout:(LWZCollectionViewLayout *)layout decorationUserInfoForSectionAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider sectionAtIndex:indexPath.section].decoration.userInfo;
}
- (nullable id)layout:(LWZCollectionViewLayout *)layout decorationUserInfoForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider headerForSectionAtIndex:indexPath.section].decoration.userInfo;
}
- (nullable id)layout:(LWZCollectionViewLayout *)layout decorationUserInfoForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider itemAtIndexPath:indexPath].decoration.userInfo;
}
- (nullable id)layout:(LWZCollectionViewLayout *)layout decorationUserInfoForFooterAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider footerForSectionAtIndex:indexPath.section].decoration.userInfo;
}

- (CGRect)layout:(LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forSectionAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionSizes decorationRelativeRectToFit:rect forSectionAtIndexPath:indexPath];
}
- (CGRect)layout:(LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionSizes decorationRelativeRectToFit:rect forHeaderAtIndexPath:indexPath];
}
- (CGRect)layout:(LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionSizes decorationRelativeRectToFit:rect forItemAtIndexPath:indexPath];
}
- (CGRect)layout:(LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forFooterAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionSizes decorationRelativeRectToFit:rect forFooterAtIndexPath:indexPath];
}

- (NSInteger)layout:(LWZCollectionViewLayout *)layout decorationZIndexForSectionAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider sectionAtIndex:indexPath.section].decoration.zPosition;
}
- (NSInteger)layout:(LWZCollectionViewLayout *)layout decorationZIndexForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider headerForSectionAtIndex:indexPath.section].decoration.zPosition;
}
- (NSInteger)layout:(LWZCollectionViewLayout *)layout decorationZIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider itemAtIndexPath:indexPath].decoration.zPosition;
}
- (NSInteger)layout:(LWZCollectionViewLayout *)layout decorationZIndexForFooterAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider footerForSectionAtIndex:indexPath.section].decoration.zPosition;
}

- (CGFloat)layout:(LWZCollectionViewLayout *)layout layoutWeightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider itemAtIndexPath:indexPath].weight;
}
- (LWZCollectionLayoutAlignment)layout:(LWZCollectionViewLayout *)layout layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mCollectionProvider itemAtIndexPath:indexPath].layoutAlignment;
}
- (NSInteger)layout:(LWZCollectionViewLayout *)layout layoutNumberOfArrangedItemsPerLineInSection:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].numberOfArrangedItemsPerLine;
}
- (nullable NSArray<LWZCollectionTemplateGroup *> *)layout:(LWZCollectionViewLayout *)layout layoutTemplateContainerGroupsInSection:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].layoutTemplateContainerGroups;
}
- (LWZCollectionLayoutType)layout:(LWZCollectionViewLayout *)layout layoutTypeForItemsInSection:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].layoutType;
}
- (BOOL)layout:(LWZCollectionViewLayout *)layout isOrthogonalScrollingInSection:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].isOrthogonalScrolling;
}
- (CGSize)layout:(LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forOrthogonalContentInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [[mCollectionProvider sectionAtIndex:section] layoutSizeThatFits:fittingSize forOrthogonalContentAtIndex:section scrollDirection:scrollDirection];
}
- (LWZCollectionLayoutContentOrthogonalScrollingBehavior)layout:(LWZCollectionViewLayout *)layout orthogonalContentScrollingBehaviorInSection:(NSInteger)section {
    return [mCollectionProvider sectionAtIndex:section].orthogonalScrollingBehavior;
}
@end
