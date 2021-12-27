//
//  LWZCollectionViewPresenter.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2020/11/16.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionViewPresenter.h"
#import "LWZCollectionViewRegister.h"
#import "LWZCollectionInternals.h"
#import <objc/message.h>

UIKIT_STATIC_INLINE CGSize
LWZCollectionSectionHeaderFooterLayoutSize(LWZCollectionSectionHeaderFooter *_Nullable headerFooter,
                                           LWZCollectionSection *section,
                                           CGSize fittingSize,
                                           NSInteger index,
                                           UICollectionViewScrollDirection scrollDirection) {
    if ( headerFooter == nil ) {
        return CGSizeZero;
    }
    
    if ( headerFooter.needsLayout ) {
        headerFooter.layoutSize = [headerFooter layoutSizeThatFits:fittingSize inSection:section atIndex:index scrollDirection:scrollDirection];
//#ifdef DEBUG
//        NSLog(@"headerFooter<%p>.size: %@, .index: %ld", headerFooter, NSStringFromCGSize(headerFooter.layoutSize), (long)index);
//#endif
    }
    return headerFooter.layoutSize;
}

UIKIT_STATIC_INLINE CGSize
LWZCollectionItemLayoutSize(LWZCollectionItem *item,
                            LWZCollectionSection *section,
                            CGSize fittingSize,
                            NSIndexPath *indexPath,
                            UICollectionViewScrollDirection scrollDirection) {
    if ( item.needsLayout ) {
        item.layoutSize = [item layoutSizeThatFits:fittingSize inSection:section atIndexPath:indexPath scrollDirection:scrollDirection];
//#ifdef DEBUG
//        NSLog(@"item<%p>.size: %@, indexPath: {%ld, %ld}", item, NSStringFromCGSize(item.layoutSize), (long)indexPath.section, (long)indexPath.item);
//#endif
    }
    return item.layoutSize;
}

UIKIT_STATIC_INLINE CGRect
LWZCollectionDecorationLayoutFrame(LWZCollectionDecoration *_Nullable decoration,
                                   CGRect rect,
                                   NSIndexPath *indexPath) {
    if ( decoration == nil )
        return CGRectZero;
    
    if ( decoration.needsLayout ) {
        decoration.relativeRect = [decoration relativeRectToFit:rect atIndexPath:indexPath];
//#ifdef DEBUG
//        NSLog(@"decoration<%p>.frame: %@, indexPath: {%ld, %ld}", decoration, NSStringFromCGRect(decoration.relativeRect), (long)indexPath.section, (long)indexPath.item);
//#endif
    }
    return decoration.relativeRect;
}

@implementation UICollectionViewCell (LWZCollectionInternalAdditions)
static void *kBindingCollectionItem = &kBindingCollectionItem;
- (void)setLwz_bindingCollectionItem:(__kindof LWZCollectionItem *)lwz_bindingCollectionItem {
    objc_setAssociatedObject(self, kBindingCollectionItem, lwz_bindingCollectionItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable __kindof LWZCollectionItem *)lwz_bindingCollectionItem {
    return objc_getAssociatedObject(self, kBindingCollectionItem);
}

- (BOOL)lwz_respondsToWillDisplay {
    static void *key = &key;
    NSNumber *rev = objc_getAssociatedObject(self, key);
    if ( rev == nil ) {
        rev = @([self respondsToSelector:@selector(willDisplayAtIndexPath:)]);
        objc_setAssociatedObject(self, key, rev, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [rev boolValue];
}
- (BOOL)lwz_respondsToDidEndDisplaying {
    static void *key = &key;
    NSNumber *rev = objc_getAssociatedObject(self, key);
    if ( rev == nil ) {
        rev = @([self respondsToSelector:@selector(didEndDisplayingAtIndexPath:)]);
        objc_setAssociatedObject(self, key, rev, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [rev boolValue];
}
@end

@implementation UICollectionReusableView (LWZCollectionInternalAdditions)
static void *kBindingHeaderFooter = &kBindingHeaderFooter;
- (void)setLwz_bindingHeaderFooter:(nullable __kindof LWZCollectionSectionHeaderFooter *)lwz_bindingHeaderFooter {
    objc_setAssociatedObject(self, kBindingHeaderFooter, lwz_bindingHeaderFooter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable __kindof LWZCollectionSectionHeaderFooter *)lwz_bindingHeaderFooter {
    return objc_getAssociatedObject(self, kBindingHeaderFooter);
}
@end


@implementation LWZCollectionViewPresenter {
    LWZCollectionViewRegister *mRegister;
    
    struct {
        unsigned adjustedPinnedInsetsForSectionAtIndex :1;
        
        // 当collectionView的视图信息例如frame, bounds等发生改变时, 在布局准备完成后, 需要及时的刷新当前显示的cell
        //
        unsigned needsRefreshVisibleItems :1;
    } _mFlags;

    struct {
        UIFloatRange layoutRange;
    } _mBoundary;
}

- (instancetype)initWithProvider:(LWZCollectionProvider *)provider {
    self = [self init];
    _provider = provider;
    return self;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        mRegister = [LWZCollectionViewRegister.alloc init];
    }
    return self;
}

- (void)setDelegate:(nullable id<LWZCollectionViewPresenterDelegate>)delegate {
    if ( delegate != _delegate ) {
        _delegate = delegate;
        _mFlags.adjustedPinnedInsetsForSectionAtIndex = delegate != nil && [delegate respondsToSelector:@selector(presenter:adjustedPinnedInsetsForSectionAtIndex:)];
    }
}

- (void)invalidateAllPresentationSizes {
    [_provider enumerateSectionsUsingBlock:^(__kindof LWZCollectionSection * _Nonnull section, NSInteger idx, BOOL * _Nonnull stop) {
        [section setNeedsLayout];
    }];
}

- (void)refreshVisibleItemsForCollectionView:(UICollectionView *)collectionView {
    LWZCollectionProvider *provider = _provider;
    for ( NSIndexPath *indexPath in collectionView.indexPathsForVisibleItems ) {
        LWZCollectionItem *item = [provider itemAtIndexPath:indexPath];
        if ( item.needsLayout ) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            if ( item == cell.lwz_bindingCollectionItem ) {
                [self willDisplayCell:[collectionView cellForItemAtIndexPath:indexPath] forItemAtIndexPath:indexPath];
            }
        }

        LWZCollectionSection *section = [provider sectionAtIndex:indexPath.section];
        LWZCollectionSectionHeaderFooter *header = section.header;
        if ( header.needsLayout ) {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
            UICollectionReusableView *view = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
            if ( view != nil && header == view.lwz_bindingHeaderFooter ) {
                [self willDisplaySupplementaryView:view forElementKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
            }
        }
        
        LWZCollectionSectionHeaderFooter *footer = section.footer;
        if ( footer.needsLayout ) {
            NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
            UICollectionReusableView *view = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:footerIndexPath];
            if ( view != nil && footer == view.lwz_bindingHeaderFooter ) {
                [self willDisplaySupplementaryView:view forElementKind:UICollectionElementKindSectionFooter atIndexPath:footerIndexPath];
            }
        }
    }
}

#pragma mark - mark

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    if ( item.tapHandler != nil ) {
        item.tapHandler(item, indexPath);
    }
    
    [item didSelectAtIndexPath:indexPath];
    
    LWZCollectionSection *section = [_provider sectionAtIndex:indexPath.section];
    [section didSelectItemAtIndexPath:indexPath];
}
- (void)didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    [item didDeselectAtIndexPath:indexPath];
    
    LWZCollectionSection *section = [_provider sectionAtIndex:indexPath.section];
    [section didDeselectItemAtIndexPath:indexPath];
}
- (void)willDisplayCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    /// 为防止数据已发生改变, 此处需要做一层相同判断
    if ( cell.class == item.cellClass ) {
        cell.lwz_bindingCollectionItem = item;
        [item willDisplayCell:cell forItemAtIndexPath:indexPath];
        
        if ( [cell lwz_respondsToWillDisplay] ) {
            [(id<LWZCollectionViewCellHooks>)cell willDisplayAtIndexPath:indexPath];
        }
        
        LWZCollectionSection *section = [_provider sectionAtIndex:indexPath.section];
        [section didBindCellForItemAtIndexPath:indexPath];
    }
}
- (void)didEndDisplayingCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    /// dataSource 的数据随时可能发生变化(这会出当前 item 与 cell绑定的 item 不一致的情况), 为防止数据已发生改变, 此处需要做一层相同判断
    ///
    if ( cell.lwz_bindingCollectionItem == item ) {
        [item didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
        
        if ( [cell lwz_respondsToDidEndDisplaying] ) {
            [(id<LWZCollectionViewCellHooks>)cell didEndDisplayingAtIndexPath:indexPath];
        }
    
        LWZCollectionSection *section = [_provider sectionAtIndex:indexPath.section];
        [section didUnbindCellForItemAtIndexPath:indexPath];
        
        cell.lwz_bindingCollectionItem = nil;
    }
}
- (void)willDisplaySupplementaryView:(__kindof UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionSectionHeaderFooter *headerFooter = nil;
    if      ( elementKind == UICollectionElementKindSectionHeader ) {
        headerFooter = [_provider headerForSectionAtIndex:indexPath.section];
    }
    else if ( elementKind == UICollectionElementKindSectionFooter ) {
        headerFooter = [_provider footerForSectionAtIndex:indexPath.section];
    }
    /// 为防止数据已发生改变, 此处需要做一层相同判断
    if ( headerFooter != nil && view.class == headerFooter.viewClass ) {
        view.lwz_bindingHeaderFooter = headerFooter;
        [headerFooter willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }
}
- (void)didEndDisplayingSupplementaryView:(__kindof UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionSectionHeaderFooter *headerFooter = nil;
    if      ( elementKind == UICollectionElementKindSectionHeader ) {
        headerFooter = [_provider headerForSectionAtIndex:indexPath.section];
    }
    else if ( elementKind == UICollectionElementKindSectionFooter ) {
        headerFooter = [_provider footerForSectionAtIndex:indexPath.section];
    }
    
    /// 为防止数据已发生改变, 此处需要做一层相同判断
    if ( headerFooter != nil && view.lwz_bindingHeaderFooter == headerFooter ) {
        [headerFooter didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
        view.lwz_bindingHeaderFooter = nil;
    }
}

#pragma mark - UICollectionViewDataSource

#ifdef DEBUG

//- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
//#ifdef DEBUG
//    NSLog(@"%d : %s", __LINE__, sel_getName(_cmd));
//#endif
//
//}

#endif

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _provider.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_provider isSectionHiddenAtIndex:section] ? 0 : [_provider sectionAtIndex:section].numberOfItems;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionSectionHeaderFooter *headerFooter = kind == UICollectionElementKindSectionHeader ? [_provider headerForSectionAtIndex:indexPath.section] : [_provider footerForSectionAtIndex:indexPath.section];
    return [mRegister collectionView:collectionView dequeueReusableHeaderFooterViewWithHeaderFooter:headerFooter kind:kind indexPath:indexPath];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [mRegister collectionView:collectionView dequeueReusableCellWithItem:[_provider itemAtIndexPath:indexPath] forIndexPath:indexPath];
}

#pragma mark - LWZCollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self didDeselectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self willDisplayCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [self willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [self didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
}

#pragma mark - LWZCollectionViewLayoutDelegate

- (void)layout:(__kindof LWZCollectionViewLayout *)layout willPrepareLayoutInContainer:(LWZCollectionLayoutCollectionContentContainer *)container {
    UIFloatRange layoutRange = container.layoutRange;
    if ( !UIFloatRangeIsEqualToRange(layoutRange, _mBoundary.layoutRange) ) {
        _mFlags.needsRefreshVisibleItems = YES;
        _mBoundary.layoutRange = layoutRange;
        [self invalidateAllPresentationSizes];
    }
}

- (void)layout:(__kindof LWZCollectionViewLayout *)layout didFinishPreparingInContainer:(LWZCollectionLayoutCollectionContentContainer *)container {
    if ( _mFlags.needsRefreshVisibleItems ) {
        _mFlags.needsRefreshVisibleItems = NO;
        [self refreshVisibleItemsForCollectionView:layout.collectionView];
    }
}

- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout edgeSpacingsForSectionAtIndex:(NSInteger)section {
    return [_provider isSectionHiddenAtIndex:section] ? UIEdgeInsetsZero : [_provider sectionAtIndex:section].edgeSpacings;
}

- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout contentInsetsForSectionAtIndex:(NSInteger)section {
    return [_provider isSectionHiddenAtIndex:section] ? UIEdgeInsetsZero : [_provider sectionAtIndex:section].contentInsets;
}

- (BOOL)layout:(__kindof LWZCollectionViewLayout *)layout canPinToVisibleBoundsForHeaderInSection:(NSInteger)section {
    return [_provider sectionAtIndex:section].canPinToVisibleBoundsForHeader;
}

- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout adjustedPinnedInsetsForSectionAtIndex:(NSInteger)section {
    if ( _mFlags.adjustedPinnedInsetsForSectionAtIndex ) {
        return [_delegate presenter:self adjustedPinnedInsetsForSectionAtIndex:section];
    }
    return layout.adjustedPinnedInsets;
}

- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return  [_provider isSectionHiddenAtIndex:index] ? CGSizeZero : LWZCollectionSectionHeaderFooterLayoutSize([_provider headerForSectionAtIndex:index], [_provider sectionAtIndex:index], fittingSize, index, scrollDirection);
}
- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return  [_provider isSectionHiddenAtIndex:indexPath.section] ? CGSizeZero : LWZCollectionItemLayoutSize([_provider itemAtIndexPath:indexPath], [_provider sectionAtIndex:indexPath.section], fittingSize, indexPath, scrollDirection);
}
- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return  [_provider isSectionHiddenAtIndex:index] ? CGSizeZero : LWZCollectionSectionHeaderFooterLayoutSize([_provider footerForSectionAtIndex:index], [_provider sectionAtIndex:index], fittingSize, index, scrollDirection);
}

- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [_provider sectionAtIndex:section].minimumLineSpacing;
}
- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [_provider sectionAtIndex:section].minimumInteritemSpacing;
}

- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( [_provider isSectionHiddenAtIndex:indexPath.section] ) return nil;
    LWZCollectionDecoration *decoration = [self _sectionDecorationAtIndex:indexPath.section];
    return [mRegister layout:layout registerDecoration:decoration];
}
- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( [_provider isSectionHiddenAtIndex:indexPath.section] ) return nil;
    LWZCollectionDecoration *decoration = [self _sectionHeaderDecorationAtIndex:indexPath.section];
    return [mRegister layout:layout registerDecoration:decoration];
}
- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( [_provider isSectionHiddenAtIndex:indexPath.section] ) return nil;
    LWZCollectionDecoration *decoration = [self _itemDecorationAtIndexPath:indexPath];
    return [mRegister layout:layout registerDecoration:decoration];
}
- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( [_provider isSectionHiddenAtIndex:indexPath.section] ) return nil;
    LWZCollectionDecoration *decoration = [self _sectionFooterDecorationAtIndex:indexPath.section];
    return [mRegister layout:layout registerDecoration:decoration];
}

- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _sectionDecorationAtIndex:indexPath.section].userInfo;
}
- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _sectionHeaderDecorationAtIndex:indexPath.section].userInfo;
}
- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _itemDecorationAtIndexPath:indexPath].userInfo;
}
- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _sectionFooterDecorationAtIndex:indexPath.section].userInfo;
}

- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return LWZCollectionDecorationLayoutFrame([self _sectionDecorationAtIndex:indexPath.section], rect, indexPath);
}
- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return LWZCollectionDecorationLayoutFrame([self _sectionHeaderDecorationAtIndex:indexPath.section], rect, indexPath);
}
- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return LWZCollectionDecorationLayoutFrame([self _itemDecorationAtIndexPath:indexPath], rect, indexPath);
}
- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return LWZCollectionDecorationLayoutFrame([self _sectionFooterDecorationAtIndex:indexPath.section], rect, indexPath);
}

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForHeaderInSection:(NSInteger)section {
    return [_provider headerForSectionAtIndex:section].zPosition;
}
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_provider itemAtIndexPath:indexPath].zPosition;
}
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForFooterInSection:(NSInteger)section {
    return [_provider footerForSectionAtIndex:section].zPosition;
}

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _sectionDecorationAtIndex:indexPath.section].zPosition;
}
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _sectionHeaderDecorationAtIndex:indexPath.section].zPosition;
}
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _itemDecorationAtIndexPath:indexPath].zPosition;
}
- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _sectionFooterDecorationAtIndex:indexPath.section].zPosition;
}

#pragma mark - LWZCollectionWeightLayoutDelegate

- (CGFloat)layout:(LWZCollectionWeightLayout *)layout weightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_provider itemAtIndexPath:indexPath].weight;
}

#pragma mark - LWZCollectionListLayoutDelegate

- (LWZCollectionLayoutAlignment)layout:(__kindof LWZCollectionViewLayout *)layout layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_provider itemAtIndexPath:indexPath].layoutAlignment;
}

#pragma mark - LWZCollectionWaterfallFlowLayoutDelegate

- (NSInteger)layout:(LWZCollectionWaterfallFlowLayout *)layout numberOfArrangedItemsPerLineInSection:(NSInteger)index {
    return [_provider sectionAtIndex:index].numberOfArrangedItemsPerLine;
}

#pragma mark - LWZCollectionTemplateLayoutDelegate

- (NSArray<LWZCollectionLayoutTemplateGroup *> *)layout:(__kindof LWZCollectionViewLayout *)layout layoutTemplateContainerGroupsInSection:(NSInteger)index {
    return [_provider sectionAtIndex:index].layoutTemplateContainerGroups;
}

#pragma mark - LWZCollectionHybridLayoutDelegate

- (LWZCollectionLayoutType)layout:(__kindof LWZCollectionViewLayout *)layout layoutTypeForItemsInSection:(NSInteger)index {
    return [_provider sectionAtIndex:index].layoutType;
}

#pragma mark - LWZCollectionCompositionalLayoutDelegate

- (BOOL)layout:(__kindof LWZCollectionViewLayout *)layout isOrthogonalScrollingInSection:(NSInteger)index {
    return [_provider sectionAtIndex:index].isOrthogonalScrolling;
}

- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forOrthogonalContentInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [[_provider sectionAtIndex:index] layoutSizeThatFits:fittingSize forOrthogonalContentAtIndex:index scrollDirection:scrollDirection];
}

- (LWZCollectionLayoutContentOrthogonalScrollingBehavior)layout:(__kindof LWZCollectionViewLayout *)layout orthogonalContentScrollingBehaviorInSection:(NSInteger)index {
    return [_provider sectionAtIndex:index].orthogonalScrollingBehavior;
}

#pragma mark - mark

- (nullable LWZCollectionDecoration *)_sectionDecorationAtIndex:(NSInteger)index {
    return [_provider sectionAtIndex:index].decoration;
}

- (nullable LWZCollectionDecoration *)_sectionHeaderDecorationAtIndex:(NSInteger)index {
    return [_provider headerForSectionAtIndex:index].decoration;
}

- (nullable LWZCollectionDecoration *)_itemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [_provider itemAtIndexPath:indexPath].decoration;
}

- (nullable LWZCollectionDecoration *)_sectionFooterDecorationAtIndex:(NSInteger)index {
    return [_provider footerForSectionAtIndex:index].decoration;
}

@end
