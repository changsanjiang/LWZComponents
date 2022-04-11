//
//  LWZCollectionViewLayout.m
//  LWZCollectionViewComponents_Example
//
//  Created by BlueDancer on 2020/11/13.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionViewLayout.h"
#import "LWZCollectionViewLayoutSubclass.h"
#import "LWZCollectionLayoutCollection.h"
#import "LWZCollectionLayoutContainer.h"
#import "LWZCollectionLayoutSolver.h"
#import "UICollectionViewLayoutAttributes+LWZCollectionAdditions.h"
#import "UIFloatRange+LWZCollectionAdditions.h"
#import "CGSize+LWZCollectionAdditions.h"

typedef NS_OPTIONS(NSUInteger, LWZCollectionLayoutPrepareContext) {
    LWZCollectionLayoutPrepareContextNone = 0,
    LWZCollectionLayoutPrepareContextInvalidateEverything = 1 << 0,
    LWZCollectionLayoutPrepareContextInvalidateDataSourceCounts = 1 << 1,
    LWZCollectionLayoutPrepareContextBoundaryChanging = 1 << 2,
};

UIKIT_STATIC_INLINE NSArray *_Nullable
LWZAllHashTableObjects(NSHashTable *table) {
    return table.count != 0 ? NSAllHashTableObjects(table) : nil;
}
 
#pragma mark - mark


@interface LWZCollectionViewLayout () {
    @protected
    UICollectionViewScrollDirection _mScrollDirection;
    LWZCollectionLayoutCollection *_mLayoutCollection;
    LWZCollectionLayoutSolver *_mLayoutSolver;
    NSHashTable<id<LWZCollectionViewLayoutObserver>> *_mObservers;
    CGSize _mContentSize;
    __weak id<LWZCollectionViewLayoutDelegate> _mDelegate;
    LWZCollectionLayoutPrepareContext _mPrepareContext;
    CGFloat _mBoundary;
    
    struct {
        unsigned delegateEdgeSpacingsForSection :1;
        unsigned delegateContentInsetsForSection :1;
        unsigned delegateAdjustedPinnedInsets :1;
        unsigned delegateCanPinToVisibleBoundsForHeader :1;
        unsigned delegateSizeForHeader :1;
        unsigned delegateSizeForItem :1;
        unsigned delegateSizeForFooter :1;
        unsigned delegateLineSpacingForSection :1;
        unsigned delegateInteritemSpacingForSection :1;
        unsigned delegateElementKindForSectionDecoration :1;
        unsigned delegateElementKindForHeaderDecoration :1;
        unsigned delegateElementKindForItemDecoration :1;
        unsigned delegateElementKindForFooterDecoration :1;
        unsigned delegateUserInfoForSectionDecoration :1;
        unsigned delegateUserInfoForHeaderDecoration :1;
        unsigned delegateUserInfoForItemDecoration :1;
        unsigned delegateUserInfoForFooterDecoration :1;
        unsigned delegateRelativeRectForSectionDecoration :1;
        unsigned delegateRelativeRectForHeaderDecoration :1;
        unsigned delegateRelativeRectForItemDecoration :1;
        unsigned delegateRelativeRectForFooterDecoration :1;
        unsigned delegateZIndexForHeader :1;
        unsigned delegateZIndexForItem :1;
        unsigned delegateZIndexForFooter :1;
        unsigned delegateZIndexForSectionDecoration :1;
        unsigned delegateZIndexForHeaderDecoration :1;
        unsigned delegateZIndexForItemDecoration :1;
        unsigned delegateZIndexForFooterDecoration :1;
        unsigned delegateWillPrepareLayoutInContainer :1;
        unsigned delegateDidFinishPreparingInContainer :1;

        unsigned isIgnoredSafeAreaInsets :1;
        unsigned sectionHeadersPinToVisibleBounds :1;
    } _mLayoutFlags;
}
@end

@implementation LWZCollectionViewLayout
+ (Class)layoutAttributesClass {
    return LWZCollectionViewLayoutAttributes.class;
}

+ (Class)layoutSolverClass {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [self initWithScrollDirection:scrollDirection delegate:nil];
}

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection delegate:(nullable id<LWZCollectionViewLayoutDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _mLayoutCollection = [LWZCollectionLayoutCollection.alloc initWithScrollDirection:scrollDirection];
        _mScrollDirection = scrollDirection;
        _mLayoutFlags.isIgnoredSafeAreaInsets = YES;
        _mLayoutSolver = [(LWZCollectionLayoutSolver *)[[[self class] layoutSolverClass] alloc] initWithLayout:self];
        self.delegate = delegate;
    }
    return self;
}

- (void)setDelegate:(nullable id<LWZCollectionViewLayoutDelegate>)delegate {
    if ( delegate != _mDelegate ) {
        _mDelegate = delegate;
        _mLayoutFlags.delegateEdgeSpacingsForSection = [delegate respondsToSelector:@selector(layout:edgeSpacingsForSectionAtIndex:)];
        _mLayoutFlags.delegateContentInsetsForSection = [delegate respondsToSelector:@selector(layout:contentInsetsForSectionAtIndex:)];
        _mLayoutFlags.delegateAdjustedPinnedInsets = [delegate respondsToSelector:@selector(layout:adjustedPinnedInsetsForSectionAtIndex:)];
        _mLayoutFlags.delegateCanPinToVisibleBoundsForHeader = [delegate respondsToSelector:@selector(layout:canPinToVisibleBoundsForHeaderInSection:)];
        _mLayoutFlags.delegateSizeForHeader = [delegate respondsToSelector:@selector(layout:layoutSizeToFit:forHeaderInSection:scrollDirection:)];
        _mLayoutFlags.delegateSizeForItem = [delegate respondsToSelector:@selector(layout:layoutSizeToFit:forItemAtIndexPath:scrollDirection:)];
        _mLayoutFlags.delegateSizeForFooter = [delegate respondsToSelector:@selector(layout:layoutSizeToFit:forFooterInSection:scrollDirection:)];
        _mLayoutFlags.delegateLineSpacingForSection = [delegate respondsToSelector:@selector(layout:minimumLineSpacingForSectionAtIndex:)];
        _mLayoutFlags.delegateInteritemSpacingForSection = [delegate respondsToSelector:@selector(layout:minimumInteritemSpacingForSectionAtIndex:)];
        _mLayoutFlags.delegateElementKindForSectionDecoration = [delegate respondsToSelector:@selector(layout:elementKindForSectionDecorationAtIndexPath:)];
        _mLayoutFlags.delegateElementKindForHeaderDecoration = [delegate respondsToSelector:@selector(layout:elementKindForHeaderDecorationAtIndexPath:)];
        _mLayoutFlags.delegateElementKindForItemDecoration = [delegate respondsToSelector:@selector(layout:elementKindForItemDecorationAtIndexPath:)];
        _mLayoutFlags.delegateElementKindForFooterDecoration = [delegate respondsToSelector:@selector(layout:elementKindForFooterDecorationAtIndexPath:)];
        _mLayoutFlags.delegateUserInfoForSectionDecoration = [delegate respondsToSelector:@selector(layout:userInfoForSectionDecorationAtIndexPath:)];
        _mLayoutFlags.delegateUserInfoForHeaderDecoration = [delegate respondsToSelector:@selector(layout:userInfoForHeaderDecorationAtIndexPath:)];
        _mLayoutFlags.delegateUserInfoForItemDecoration = [delegate respondsToSelector:@selector(layout:userInfoForItemDecorationAtIndexPath:)];
        _mLayoutFlags.delegateUserInfoForFooterDecoration = [delegate respondsToSelector:@selector(layout:userInfoForFooterDecorationAtIndexPath:)];
        _mLayoutFlags.delegateRelativeRectForSectionDecoration = [delegate respondsToSelector:@selector(layout:relativeRectToFit:forSectionDecorationAtIndexPath:)];
        _mLayoutFlags.delegateRelativeRectForHeaderDecoration = [delegate respondsToSelector:@selector(layout:relativeRectToFit:forHeaderDecorationAtIndexPath:)];
        _mLayoutFlags.delegateRelativeRectForItemDecoration = [delegate respondsToSelector:@selector(layout:relativeRectToFit:forItemDecorationAtIndexPath:)];
        _mLayoutFlags.delegateRelativeRectForFooterDecoration = [delegate respondsToSelector:@selector(layout:relativeRectToFit:forFooterDecorationAtIndexPath:)];
        _mLayoutFlags.delegateZIndexForHeader = [delegate respondsToSelector:@selector(layout:zIndexForHeaderInSection:)];
        _mLayoutFlags.delegateZIndexForItem = [delegate respondsToSelector:@selector(layout:zIndexForItemAtIndexPath:)];
        _mLayoutFlags.delegateZIndexForFooter = [delegate respondsToSelector:@selector(layout:zIndexForFooterInSection:)];
        _mLayoutFlags.delegateZIndexForSectionDecoration = [delegate respondsToSelector:@selector(layout:zIndexForSectionDecorationAtIndexPath:)];
        _mLayoutFlags.delegateZIndexForHeaderDecoration = [delegate respondsToSelector:@selector(layout:zIndexForHeaderDecorationAtIndexPath:)];
        _mLayoutFlags.delegateZIndexForItemDecoration = [delegate respondsToSelector:@selector(layout:zIndexForItemDecorationAtIndexPath:)];
        _mLayoutFlags.delegateZIndexForFooterDecoration = [delegate respondsToSelector:@selector(layout:zIndexForFooterDecorationAtIndexPath:)];
        _mLayoutFlags.delegateWillPrepareLayoutInContainer = [delegate respondsToSelector:@selector(layout:willPrepareLayoutInContainer:)];
        _mLayoutFlags.delegateDidFinishPreparingInContainer = [delegate respondsToSelector:@selector(layout:didFinishPreparingInContainer:)];
    }
}

- (nullable id<LWZCollectionViewLayoutDelegate>)delegate {
    return _mDelegate;
}

- (LWZCollectionLayoutSolver *)layoutSolver {
    return _mLayoutSolver;
}

- (UICollectionViewScrollDirection)scrollDirection {
    return _mScrollDirection;
}

- (void)setIgnoredSafeAreaInsets:(BOOL)ignoredSafeAreaInsets {
    _mLayoutFlags.isIgnoredSafeAreaInsets = ignoredSafeAreaInsets;
}

- (BOOL)isIgnoredSafeAreaInsets {
    return _mLayoutFlags.isIgnoredSafeAreaInsets;
}

- (void)setSectionHeadersPinToVisibleBounds:(BOOL)sectionHeadersPinToVisibleBounds {
    _mLayoutFlags.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds;
}

- (BOOL)sectionHeadersPinToVisibleBounds {
    return _mLayoutFlags.sectionHeadersPinToVisibleBounds;
}

- (CGRect)layoutFrameForSection:(NSInteger)section {
    LWZCollectionLayoutSection *layoutSection = [_mLayoutCollection sectionAtIndex:section];
    if ( layoutSection != nil ) {
        return layoutSection.frame;
    }
    return CGRectZero;
}

- (void)enumerateLayoutAttributesWithElementCategory:(UICollectionElementCategory)category usingBlock:(void(NS_NOESCAPE ^)(UICollectionViewLayoutAttributes *attributes, BOOL *stop))block {
    [_mLayoutCollection enumerateLayoutAttributesWithElementCategory:category usingBlock:block];
}

- (nullable NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category {
    return [_mLayoutCollection layoutAttributesObjectsForElementCategory:category];
}

- (nullable NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category inSection:(NSInteger)section {
    return [_mLayoutCollection layoutAttributesObjectsForElementCategory:category inSection:section];
}

- (void)registerObserver:(id<LWZCollectionViewLayoutObserver>)observer {
    if ( _mObservers == nil ) {
        _mObservers = [NSHashTable weakObjectsHashTable];
    }
    [_mObservers addObject:observer];
}

- (void)removeObserver:(id<LWZCollectionViewLayoutObserver>)observer {
    [_mObservers removeObject:observer];
}

#pragma mark - mark

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
#ifdef LWZ_DEBUG
    printf("%d : %s\n", __LINE__, sel_getName(_cmd));
#endif

#ifdef LWZ_DEBUG
    NSString *log = [NSString stringWithFormat:@"\ninvalidateEverything: %d, \ninvalidateDataSourceCounts: %d, \ninvalidatedItemIndexPaths: %@, \ninvalidatedSupplementaryIndexPaths: %@, \ninvalidatedDecorationIndexPaths: %@, \ncontentOffsetAdjustment: %@, \ncontentSizeAdjustment: %@, \npreviousIndexPathsForInteractivelyMovingItems: %@, \ntargetIndexPathsForInteractivelyMovingItems: %@, \ninteractiveMovementTarget: %@",
                     context.invalidateEverything,
                     context.invalidateDataSourceCounts,
                     context.invalidatedItemIndexPaths,
                     context.invalidatedSupplementaryIndexPaths,
                     context.invalidatedDecorationIndexPaths,
                     NSStringFromCGPoint(context.contentOffsetAdjustment),
                     NSStringFromCGSize(context.contentSizeAdjustment),
                     context.previousIndexPathsForInteractivelyMovingItems,
                     context.targetIndexPathsForInteractivelyMovingItems,
                     NSStringFromCGPoint(context.interactiveMovementTarget)];
    printf("%s\n", log.UTF8String);
    
    printf("%s\n\n", self.collectionView.description.UTF8String);
#endif

    LWZCollectionLayoutPrepareContext prepareContext = _mPrepareContext;
    if ( context.invalidateEverything ) {
        prepareContext |= LWZCollectionLayoutPrepareContextInvalidateEverything;
    }
    
    if ( context.invalidateDataSourceCounts ) {
        prepareContext |= LWZCollectionLayoutPrepareContextInvalidateDataSourceCounts;
    }
    
    UICollectionView *collectionView = self.collectionView;
    CGRect bounds = collectionView.bounds;
    CGFloat boundary = 0;
    
    CGSize contentSizeAdjustment = context.contentSizeAdjustment;
    if ( !CGSizeEqualToSize(CGSizeZero, contentSizeAdjustment) ) {
        switch ( _mScrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                boundary = bounds.size.width - contentSizeAdjustment.width;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                boundary = bounds.size.height - contentSizeAdjustment.height;
                break;
        }
    }
    else {
        switch ( _mScrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                boundary = bounds.size.width;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                boundary = bounds.size.height;
                break;
        }
    }
    
    CGFloat oldBoundary = _mBoundary;
    if ( boundary != oldBoundary ) {
        prepareContext |= LWZCollectionLayoutPrepareContextBoundaryChanging;
        _mBoundary = boundary;
    }
    
    _mPrepareContext = prepareContext;

    if ( oldBoundary != 0 && prepareContext & LWZCollectionLayoutPrepareContextBoundaryChanging ) {
        CGPoint oldContentOffset = collectionView.contentOffset;
        CGPoint contentOffsetAdjustment = context.contentOffsetAdjustment;
        // 如果外部未做调整, 内部再处理一下
        // 调整contentOffset, 按照boundary变化比例, 增加或减少相应比例的offset
        if ( CGPointEqualToPoint(CGPointZero, contentOffsetAdjustment) ) {
            switch ( _mScrollDirection ) {
                case UICollectionViewScrollDirectionVertical: {
                    CGFloat newOffsetX = boundary * oldContentOffset.x / oldBoundary;
                    contentOffsetAdjustment.x = newOffsetX - oldContentOffset.x;
                }
                    break;
                case UICollectionViewScrollDirectionHorizontal: {
                    CGFloat newOffsetY = boundary * oldContentOffset.y / oldBoundary;
                    contentOffsetAdjustment.y = newOffsetY - oldContentOffset.y;
                }
                    break;
            }
            context.contentOffsetAdjustment = contentOffsetAdjustment;
        }
    }
    
    [super invalidateLayoutWithContext:context];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
#ifdef LWZ_DEBUG
    printf("%d : %s\n", __LINE__, sel_getName(_cmd));
#endif

    
    BOOL isBoundaryChanged = NO;
    UICollectionView *collectionView = self.collectionView;
    switch ( _mScrollDirection ) {
        case UICollectionViewScrollDirectionVertical:
            isBoundaryChanged = newBounds.size.width != collectionView.bounds.size.width;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            isBoundaryChanged = newBounds.size.height != collectionView.bounds.size.height;
            break;
    }
    
    if ( isBoundaryChanged )
        return YES;
    
    if ( _mLayoutFlags.sectionHeadersPinToVisibleBounds /*|| _sectionFootersPinToVisibleBounds*/ ) {
        NSArray<LWZCollectionLayoutSection *> *sections = [_mLayoutCollection sectionsInRect:newBounds];
        for ( LWZCollectionLayoutSection *section in sections ) {
            // 目前仅处理header, 后续如有footer的需要再扩展footer了
            //
            if ( section.headerViewLayoutAttributes != nil && section.canPinToVisibleBoundsForHeader )
                return YES;
//            if ( section.footerViewLayoutAttributes != nil )
//                return YES;
        }
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

// 目前仅处理header, 后续如有footer的需要再扩展footer了
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {
#ifdef LWZ_DEBUG
    printf("%d : %s\n", __LINE__, sel_getName(_cmd));
#endif

    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForBoundsChange:newBounds];
    if ( context == nil ) context = [UICollectionViewLayoutInvalidationContext.alloc init];
    
    UICollectionView *collectionView = self.collectionView;
    CGRect curBounds = collectionView.bounds;
    CGSize contentSizeAdjustment = CGSizeMake(newBounds.size.width - curBounds.size.width, newBounds.size.height - curBounds.size.height);
    if ( !CGSizeEqualToSize(CGSizeZero, contentSizeAdjustment) ) {
        context.contentSizeAdjustment = contentSizeAdjustment;
    }
    else {
        NSArray<LWZCollectionLayoutSection *> *sections = [_mLayoutCollection sectionsInRect:newBounds];
        if ( sections.count != 0 ) {
            for ( LWZCollectionLayoutSection *section in sections ) {
                if ( section.canPinToVisibleBoundsForHeader ) {
                    LWZCollectionViewLayoutAttributes *header = section.headerViewLayoutAttributes.copy;
                    NSArray<NSIndexPath *> *indexPaths = @[header.indexPath];
                    [context invalidateSupplementaryElementsOfKind:header.representedElementKind atIndexPaths:indexPaths];
                    
                    // decoration
                    LWZCollectionViewLayoutAttributes *decoration = section.headerDecorationLayoutAttributes.copy;
                    if ( decoration != nil ) {
                        [context invalidateDecorationElementsOfKind:decoration.representedElementKind atIndexPaths:indexPaths];
                    }
                }
            }
        }
    }
    return context;
}

- (void)prepareLayout {
#ifdef LWZ_DEBUG
    printf("%d : %s\n", __LINE__, sel_getName(_cmd));
#endif

    if ( _mPrepareContext != LWZCollectionLayoutPrepareContextNone ) {
        UICollectionView *collectionView = self.collectionView;
        CGSize collectionSize = collectionView.frame.size;
        if ( @available(iOS 11.0, *) ) {
            [self prepareLayoutForCollectionSize:collectionSize contentInsets:collectionView.contentInset safeAreaInsets:collectionView.safeAreaInsets];
        }
        else {
            [self prepareLayoutForCollectionSize:collectionSize contentInsets:collectionView.contentInset];
        }
    }
    [super prepareLayout];
}

- (void)prepareLayoutForCollectionSize:(CGSize)size contentInsets:(UIEdgeInsets)contentInsets {
    [self _prepareLayoutForCollectionSize:size contentInsets:contentInsets safeAreaInsets:UIEdgeInsetsZero];
}

- (void)prepareLayoutForCollectionSize:(CGSize)size contentInsets:(UIEdgeInsets)contentInsets safeAreaInsets:(UIEdgeInsets)safeAreaInsets NS_AVAILABLE_IOS(11.0) {
    [self _prepareLayoutForCollectionSize:size contentInsets:contentInsets safeAreaInsets:safeAreaInsets];
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_mLayoutCollection layoutAttributesForItemAtIndexPath:indexPath];
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ( _mLayoutFlags.sectionHeadersPinToVisibleBounds ) {
        NSInteger sIdx = indexPath.section;
        if ( elementKind == UICollectionElementKindSectionHeader ) {
            LWZCollectionLayoutSection *section = [_mLayoutCollection sectionAtIndex:sIdx];
            LWZCollectionViewLayoutAttributes *header = section.headerViewLayoutAttributes;
            if ( header != nil && section.canPinToVisibleBoundsForHeader ) {
                CGRect headerPinnedFrame = [self _headerPinnedFrameForSectionFrame:section.frame headerFrame:header.frame adjustedPinnedInsets:[self adjustedPinnedInsetsForSectionAtIndex:sIdx]];
                [section.headerViewPinnedLayoutAttributes setFrame:headerPinnedFrame];
            }
        }
    }
    return [_mLayoutCollection layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ( _mLayoutFlags.sectionHeadersPinToVisibleBounds ) {
        NSInteger sIdx = indexPath.section;
        LWZCollectionLayoutSection *section = [_mLayoutCollection sectionAtIndex:sIdx];
        LWZCollectionViewLayoutAttributes *decoration = section.headerDecorationLayoutAttributes;
        if ( decoration != nil && decoration.representedElementKind == elementKind && section.canPinToVisibleBoundsForHeader ) {
            LWZCollectionViewLayoutAttributes *header = section.headerViewLayoutAttributes;
            CGRect headerFrame = header.frame;
            LWZCollectionViewLayoutAttributes *headerPinnedAttributes = section.headerViewPinnedLayoutAttributes;
            CGRect headerPinnedFrame = headerPinnedAttributes.frame;
            CGRect decorationPinnedFrame = [self _headerDecorationPinnedFrameForHeaderFrame:headerFrame headerPinnedFrame:headerPinnedFrame headerDecorationFrame:decoration.frame];
            [section.headerDecorationPinnedLayoutAttributes setFrame:decorationPinnedFrame];
        }
    }
    return [_mLayoutCollection layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
}

- (nullable NSArray<__kindof LWZCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [_mLayoutCollection layoutAttributesForElementsInRect:rect];
}

- (CGSize)collectionViewContentSize {
    return _mContentSize;
}

#pragma mark - mark

- (void)_prepareLayoutForCollectionSize:(CGSize)collectionSize contentInsets:(UIEdgeInsets)contentInsets safeAreaInsets:(UIEdgeInsets)safeAreaInsets {
#ifdef LWZ_DEBUG
    printf("%s\n", [NSString stringWithFormat:@"%d - %s - %@ - %@ - %@", (int)__LINE__, __func__, NSStringFromCGSize(collectionSize), NSStringFromUIEdgeInsets(contentInsets), NSStringFromUIEdgeInsets(safeAreaInsets)].UTF8String);
    printf("%s\n\n", [NSString stringWithFormat:@"prepareContext { invalidateEverything: %d, invalidateDataSourceCounts: %d, boundaryChanging: %d }", (BOOL)(_mPrepareContext & LWZCollectionLayoutPrepareContextInvalidateEverything), (BOOL)(_mPrepareContext & LWZCollectionLayoutPrepareContextInvalidateDataSourceCounts), (BOOL)(_mPrepareContext & LWZCollectionLayoutPrepareContextBoundaryChanging)].UTF8String);
#endif
    
    [_mLayoutCollection removeAllSections];
    _mContentSize = CGSizeZero;
    _mPrepareContext = LWZCollectionLayoutPrepareContextNone;
    
    if ( _mDelegate == nil ) {
#if DEBUG
        NSLog(@"⚠️ %@<%p>: `layout.delegate`未设置!!!", NSStringFromClass(self.class), self);
#endif
        return;
    }
 
    UICollectionView *collectionView = self.collectionView;
    NSInteger numberOfSections = collectionView.numberOfSections;
    if ( numberOfSections == 0 )
        return;
 
    CGRect collectionBounds = (CGRect){0, 0, collectionSize};
    if ( CGRectIsInfinite(collectionBounds) || CGRectIsNull(collectionBounds) || CGRectIsEmpty(collectionBounds) )
        return;
    
    LWZCollectionLayoutContainer *collectionLayoutContainer = [LWZCollectionLayoutContainer.alloc initWithCollectionSize:collectionSize direction:_mScrollDirection collectionContentInsets:contentInsets collectionSafeAreaInsets:safeAreaInsets ignoredCollectionSafeAreaInsets:_mLayoutFlags.isIgnoredSafeAreaInsets];
     
    [self willPrepareLayoutInContainer:collectionLayoutContainer];
    
    CGFloat offset = 0;
    switch ( _mScrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            offset = collectionLayoutContainer.layoutInsets.top;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            offset = collectionLayoutContainer.layoutInsets.left;
        }
            break;
    }
    
    CGRect layoutSectionFrame = CGRectZero;
    for ( NSInteger section = 0 ; section < numberOfSections;  ++ section ) {
        if ( ![self shouldProcessLayoutForSectionAtIndex:section] )
            continue;
        
        UIEdgeInsets sectionEdgeSpacings = [self edgeSpacingsForSectionAtIndex:section];
        UIEdgeInsets sectionContentInsets = [self contentInsetsForSectionAtIndex:section];
        
        LWZSectionLayoutContainer *sectionLayoutContainer = [LWZSectionLayoutContainer.alloc initWithCollectionLayoutContainer:collectionLayoutContainer sectionEdgeSpacings:sectionEdgeSpacings sectionContentInsets:sectionContentInsets];
         
        LWZCollectionLayoutSection *layoutSection = [LWZCollectionLayoutSection.alloc initWithIndex:section];
        
        switch ( _mScrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                offset += sectionLayoutContainer.layoutInsets.top;
                
                layoutSectionFrame.origin.y = offset;
                layoutSectionFrame.origin.x = collectionLayoutContainer.layoutInsets.left + sectionLayoutContainer.layoutInsets.left;
                layoutSectionFrame.size.width = sectionLayoutContainer.layoutRange.maximum - sectionLayoutContainer.layoutRange.minimum;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                offset += sectionLayoutContainer.layoutInsets.left;
                
                layoutSectionFrame.origin.x = offset;
                layoutSectionFrame.origin.y = collectionLayoutContainer.layoutInsets.top + sectionLayoutContainer.layoutInsets.top;
                layoutSectionFrame.size.height = sectionLayoutContainer.layoutRange.maximum - sectionLayoutContainer.layoutRange.minimum;
            }
                break;
        }
        
        NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        // header
        LWZCollectionViewLayoutAttributes *_Nullable headerAttributes = [self layoutAttributesForSupplementaryViewWithElementKind:UICollectionElementKindSectionHeader indexPath:supplementaryViewIndexPath offset:offset container:sectionLayoutContainer];
        LWZCollectionViewLayoutAttributes *_Nullable headerDecorationAttributes = nil;
        if ( headerAttributes != nil ) {
            layoutSection.headerViewLayoutAttributes = headerAttributes;
            offset = LWZCollectionViewLayoutAttributesGetMaxOffset(headerAttributes, _mScrollDirection);
            
            // header decoration
            headerDecorationAttributes = [self layoutAttributesForHeaderDecorationViewWithIndexPath:supplementaryViewIndexPath inRect:headerAttributes.frame];
            if ( headerDecorationAttributes != nil ) layoutSection.headerDecorationLayoutAttributes = headerDecorationAttributes;
        }
        
        // cells
        switch ( _mScrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                offset += sectionContentInsets.top;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                offset += sectionContentInsets.left;
                break;
        }
        
        switch ( [self presentationModeForCellsInSection:section] ) {
            case LWZCollectionLayoutContentPresentationModeNormal: {
                NSArray<LWZCollectionViewLayoutAttributes *> *_Nullable cellAttributesObjects = [self layoutAttributesObjectsForCellsWithSection:section offset:offset container:sectionLayoutContainer];
                
                if ( cellAttributesObjects.count != 0 ) {
                    layoutSection.cellLayoutAttributesObjects = cellAttributesObjects;
                    offset = LWZCollectionViewLayoutAttributesGetMaxOffset(cellAttributesObjects, _mScrollDirection);
                    
                    // cell decoration
                    NSArray<LWZCollectionViewLayoutAttributes *> *cellDecorationAttributesObjects = [self layoutAttributesObjectsForCellDecorationViewsWithCellAttributesObjects:cellAttributesObjects];
                    
                    if ( cellDecorationAttributesObjects.count != 0 ) layoutSection.cellDecorationLayoutAttributesObjects = cellDecorationAttributesObjects;
                }
            }
                break;
            case LWZCollectionLayoutContentPresentationModeCustom: {
                UIView *customView = [self layoutCustomViewForCellsWithSection:section offset:offset container:sectionLayoutContainer];
                layoutSection.customView = customView;
                [collectionView addSubview:customView];
                
                CGRect customViewLayoutFrame = customView.frame;
                switch ( _mScrollDirection ) {
                    case UICollectionViewScrollDirectionVertical:
                        offset = CGRectGetMaxY(customViewLayoutFrame);
                        break;
                    case UICollectionViewScrollDirectionHorizontal:
                        offset = CGRectGetMaxX(customViewLayoutFrame);
                        break;
                }
            }
                break;
        }
        
        switch ( _mScrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                offset += sectionContentInsets.bottom;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                offset += sectionContentInsets.right;
                break;
        }
        
        // footer
        LWZCollectionViewLayoutAttributes *_Nullable footerAttributes = [self layoutAttributesForSupplementaryViewWithElementKind:UICollectionElementKindSectionFooter indexPath:supplementaryViewIndexPath offset:offset container:sectionLayoutContainer];
        
        if ( footerAttributes != nil ) {
            layoutSection.footerViewLayoutAttributes = footerAttributes;
            offset = LWZCollectionViewLayoutAttributesGetMaxOffset(footerAttributes, _mScrollDirection);
            
            // footer decoration
            LWZCollectionViewLayoutAttributes *_Nullable footerDecorationAttributes = [self layoutAttributesForFooterDecorationViewWithIndexPath:supplementaryViewIndexPath inRect:footerAttributes.frame];
            if ( footerDecorationAttributes != nil ) layoutSection.footerDecorationLayoutAttributes = footerDecorationAttributes;
        }
         
        switch ( _mScrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                layoutSectionFrame.size.height = offset - layoutSectionFrame.origin.y;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                layoutSectionFrame.size.width = offset - layoutSectionFrame.origin.x;
                break;
        }
        
        // section decoration
        LWZCollectionViewLayoutAttributes *_Nullable sectionDecorationAttributes = [self layoutAttributesForSectionDecorationViewWithIndexPath:supplementaryViewIndexPath inRect:layoutSectionFrame];
        if ( sectionDecorationAttributes != nil ) layoutSection.sectionDecorationLayoutAttributes = sectionDecorationAttributes;
        
        // pinned
        if ( headerAttributes != nil && _mLayoutFlags.sectionHeadersPinToVisibleBounds && [self canPinToVisibleBoundsForHeaderInSection:section] ) {
            layoutSection.canPinToVisibleBoundsForHeader = YES;
            
            CGRect headerFrame = headerAttributes.frame;
            CGRect headerPinnedFrame = [self _headerPinnedFrameForSectionFrame:layoutSectionFrame headerFrame:headerFrame adjustedPinnedInsets:[self adjustedPinnedInsetsForSectionAtIndex:section]];
            LWZCollectionViewLayoutAttributes *headerPinnedAttributes = headerAttributes.copy;
            headerPinnedAttributes.zIndex = headerAttributes.zIndex + 10;
            headerPinnedAttributes.frame = headerPinnedFrame;
            layoutSection.headerViewPinnedLayoutAttributes = headerPinnedAttributes;
            
            if ( headerDecorationAttributes != nil ) {
                CGRect headerDecorationFrame = headerDecorationAttributes.frame;
                CGRect headerDecorationPinnedFrame = [self _headerDecorationPinnedFrameForHeaderFrame:headerFrame headerPinnedFrame:headerPinnedFrame headerDecorationFrame:headerDecorationFrame];
                
                LWZCollectionViewLayoutAttributes *headerDecorationPinnedAttributes = headerDecorationAttributes.copy;
                headerDecorationPinnedAttributes.zIndex = headerDecorationAttributes.zIndex + 10;
                headerDecorationPinnedAttributes.frame = headerDecorationPinnedFrame;
                layoutSection.headerDecorationPinnedLayoutAttributes = headerDecorationPinnedAttributes;
            }
        }
        
        layoutSection.frame = layoutSectionFrame;
        [_mLayoutCollection addSection:layoutSection];
        
        switch ( _mScrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                offset += sectionEdgeSpacings.bottom;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                offset += sectionEdgeSpacings.right;
                break;
        }
    }
    
    CGFloat collectionViewContentWidth = 0;
    CGFloat collectionViewContentHeight = 0;
    switch ( _mScrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            offset += collectionLayoutContainer.layoutInsets.bottom;
            
            collectionViewContentHeight = offset;
            collectionViewContentWidth = collectionSize.width;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            offset += collectionLayoutContainer.layoutInsets.right;
            
            collectionViewContentWidth = offset;
            collectionViewContentHeight = collectionSize.height;
        }
            break;
    }
    
    _mContentSize = CGSizeMake(collectionViewContentWidth, collectionViewContentHeight);
    
    [self didFinishPreparingInContainer:collectionLayoutContainer];
}

- (void)willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container {
    if ( _mLayoutFlags.delegateWillPrepareLayoutInContainer ) {
        [_mDelegate layout:self willPrepareLayoutInContainer:container];
    }
    
    for ( id<LWZCollectionViewLayoutObserver> observer in LWZAllHashTableObjects(_mObservers) ) {
        if ( [observer respondsToSelector:@selector(layout:willPrepareLayoutInContainer:)] ) {
            [observer layout:self willPrepareLayoutInContainer:container];
        }
    }
}

- (void)didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container {
    if ( _mLayoutFlags.delegateDidFinishPreparingInContainer ) {
        [_mDelegate layout:self didFinishPreparingInContainer:container];
    }
    
    for ( id<LWZCollectionViewLayoutObserver> observer in LWZAllHashTableObjects(_mObservers) ) {
        if ( [observer respondsToSelector:@selector(layout:didFinishPreparingInContainer:)] ) {
            [observer layout:self didFinishPreparingInContainer:container];
        }
    }
}

#pragma mark - solver methods

- (BOOL)shouldProcessLayoutForSectionAtIndex:(NSInteger)index {
    return YES;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewWithElementKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    return [_mLayoutSolver layoutAttributesForSupplementaryItemWithKind:kind indexPath:indexPath offset:offset container:container];
}

- (LWZCollectionLayoutContentPresentationMode)presentationModeForCellsInSection:(NSInteger)index {
    return LWZCollectionLayoutContentPresentationModeNormal;
}
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    return [_mLayoutSolver layoutAttributesObjectsForItemsWithSection:section offset:offset container:container];
}
- (nullable UIView *)layoutCustomViewForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    return [_mLayoutSolver layoutCustomViewForItemsWithSection:section offset:offset container:container];
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSectionDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect {
    return [_mLayoutSolver layoutAttributesForDecorationItemWithCategory:LWZCollectionDecorationCategorySection inRect:rect indexPath:indexPath];
}
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForHeaderDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect {
    return [_mLayoutSolver layoutAttributesForDecorationItemWithCategory:LWZCollectionDecorationCategoryHeader inRect:rect indexPath:indexPath];
}
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForCellDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect {
    return [_mLayoutSolver layoutAttributesForDecorationItemWithCategory:LWZCollectionDecorationCategoryItem inRect:rect indexPath:indexPath];
}
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellDecorationViewsWithCellAttributesObjects:(NSArray<LWZCollectionViewLayoutAttributes *> *)cellAttributesObjects {
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *m = [[NSMutableArray alloc] initWithCapacity:cellAttributesObjects.count];
    for ( LWZCollectionViewLayoutAttributes *cell in cellAttributesObjects ) {
        LWZCollectionViewLayoutAttributes *attributes = [self layoutAttributesForCellDecorationViewWithIndexPath:cell.indexPath inRect:cell.frame];
        if ( attributes == nil ) continue;;
        [m addObject:attributes];
    }
    return m.count != 0 ? m.copy : nil;
}
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForFooterDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect {
    return [_mLayoutSolver layoutAttributesForDecorationItemWithCategory:LWZCollectionDecorationCategoryFooter inRect:rect indexPath:indexPath];
}

#pragma mark - LWZCollectionLayout

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self.collectionView numberOfItemsInSection:section];
}
- (UIEdgeInsets)edgeSpacingsForSectionAtIndex:(NSInteger)section {
    if ( _mLayoutFlags.delegateEdgeSpacingsForSection ) {
        return [_mDelegate layout:self edgeSpacingsForSectionAtIndex:section];
    }
    return UIEdgeInsetsZero;
}
- (UIEdgeInsets)contentInsetsForSectionAtIndex:(NSInteger)section {
    if ( _mLayoutFlags.delegateContentInsetsForSection ) {
        return [_mDelegate layout:self contentInsetsForSectionAtIndex:section];
    }
    return UIEdgeInsetsZero;
}
- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ( _mLayoutFlags.delegateLineSpacingForSection ) {
        return [_mDelegate layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return 0.0;
}
- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ( _mLayoutFlags.delegateInteritemSpacingForSection ) {
        return [_mDelegate layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return 0.0;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    if ( _mLayoutFlags.delegateSizeForHeader ) {
        CGSize layoutSize = [_mDelegate layout:self layoutSizeToFit:fittingSize forHeaderInSection:section scrollDirection:scrollDirection];
        return LWZLayoutSizeAdjustHeaderFooterSize(layoutSize, fittingSize, scrollDirection);
    }
    return CGSizeZero;
}
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    if ( _mLayoutFlags.delegateSizeForItem ) {
        CGSize layoutSize = [_mDelegate layout:self layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
        return LWZLayoutSizeAdjustItemSize(layoutSize, fittingSize, scrollDirection);
    }
    return CGSizeZero;
}
- (nullable UIView *)layoutCustomViewForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    return nil;
}
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    if ( _mLayoutFlags.delegateSizeForFooter ) {
        CGSize layoutSize = [_mDelegate layout:self layoutSizeToFit:fittingSize forFooterInSection:section scrollDirection:scrollDirection];
        return LWZLayoutSizeAdjustHeaderFooterSize(layoutSize, fittingSize, scrollDirection);
    }
    return CGSizeZero;
}

- (CGFloat)zIndexForHeaderInSection:(NSInteger)section {
    if ( _mLayoutFlags.delegateZIndexForHeader ) {
        return [_mDelegate layout:self zIndexForHeaderInSection:section];
    }
    return 0.0;
}
- (CGFloat)zIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( _mLayoutFlags.delegateZIndexForItem ) {
        return [_mDelegate layout:self zIndexForItemAtIndexPath:indexPath];
    }
    return 0.0;
}
- (CGFloat)zIndexForFooterInSection:(NSInteger)section {
    if ( _mLayoutFlags.delegateZIndexForFooter ) {
        return [_mDelegate layout:self zIndexForFooterInSection:section];
    }
    return 0.0;
}

- (nullable NSString *)elementKindForDecorationOfCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath {
    switch ( category ) {
        case LWZCollectionDecorationCategorySection:
            if ( _mLayoutFlags.delegateElementKindForSectionDecoration ) {
                return [_mDelegate layout:self elementKindForSectionDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryHeader:
            if ( _mLayoutFlags.delegateElementKindForHeaderDecoration ) {
                return [_mDelegate layout:self elementKindForHeaderDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryItem:
            if ( _mLayoutFlags.delegateElementKindForItemDecoration ) {
                return [_mDelegate layout:self elementKindForItemDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryFooter:
            if ( _mLayoutFlags.delegateElementKindForFooterDecoration ) {
                return [_mDelegate layout:self elementKindForFooterDecorationAtIndexPath:indexPath];
            }
            break;
    }
    return nil;
}
- (CGRect)relativeRectToFit:(CGRect)fitsRect forDecorationOfCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath {
    switch ( category ) {
        case LWZCollectionDecorationCategorySection:
            if ( _mLayoutFlags.delegateRelativeRectForSectionDecoration ) {
                return [_mDelegate layout:self relativeRectToFit:fitsRect forSectionDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryHeader:
            if ( _mLayoutFlags.delegateRelativeRectForFooterDecoration ) {
                return [_mDelegate layout:self relativeRectToFit:fitsRect forHeaderDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryItem:
            if ( _mLayoutFlags.delegateRelativeRectForItemDecoration ) {
                return [_mDelegate layout:self relativeRectToFit:fitsRect forItemDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryFooter:
            if ( _mLayoutFlags.delegateRelativeRectForFooterDecoration ) {
                return [_mDelegate layout:self relativeRectToFit:fitsRect forFooterDecorationAtIndexPath:indexPath];
            }
            break;
    }
    return CGRectZero;
}
- (CGFloat)zIndexForDecorationOfCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath {
    switch ( category ) {
        case LWZCollectionDecorationCategorySection:
            if ( _mLayoutFlags.delegateZIndexForSectionDecoration ) {
                return [_mDelegate layout:self zIndexForSectionDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryHeader:
            if ( _mLayoutFlags.delegateZIndexForHeaderDecoration ) {
                return [_mDelegate layout:self zIndexForHeaderDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryItem:
            if ( _mLayoutFlags.delegateZIndexForItemDecoration ) {
                return [_mDelegate layout:self zIndexForItemDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryFooter:
            if ( _mLayoutFlags.delegateZIndexForFooterDecoration ) {
                return [_mDelegate layout:self zIndexForFooterDecorationAtIndexPath:indexPath];
            }
            break;
    }
    return 0.0;
}
- (nullable id)userInfoForDecorationOfCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath {
    switch ( category ) {
        case LWZCollectionDecorationCategorySection:
            if ( _mLayoutFlags.delegateUserInfoForSectionDecoration ) {
                return [_mDelegate layout:self userInfoForSectionDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryHeader:
            if ( _mLayoutFlags.delegateUserInfoForHeaderDecoration ) {
                return [_mDelegate layout:self userInfoForHeaderDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryItem:
            if ( _mLayoutFlags.delegateUserInfoForItemDecoration ) {
                return [_mDelegate layout:self userInfoForItemDecorationAtIndexPath:indexPath];
            }
            break;
        case LWZCollectionDecorationCategoryFooter:
            if ( _mLayoutFlags.delegateUserInfoForFooterDecoration ) {
                return [_mDelegate layout:self userInfoForFooterDecorationAtIndexPath:indexPath];
            }
            break;
    }
    return nil;
}

#pragma mark - pinned

- (UIEdgeInsets)adjustedPinnedInsetsForSectionAtIndex:(NSInteger)section {
  if ( _mLayoutFlags.delegateAdjustedPinnedInsets ) {
      return [_mDelegate layout:self adjustedPinnedInsetsForSectionAtIndex:section];
  }
  return _adjustedPinnedInsets;
}

- (BOOL)canPinToVisibleBoundsForHeaderInSection:(NSInteger)section {
    if ( _mLayoutFlags.sectionHeadersPinToVisibleBounds && _mLayoutFlags.delegateCanPinToVisibleBoundsForHeader ) {
        return [_mDelegate layout:self canPinToVisibleBoundsForHeaderInSection:section];
    }
    return _mLayoutFlags.sectionHeadersPinToVisibleBounds;
}

- (CGRect)_headerPinnedFrameForSectionFrame:(CGRect)sectionFrame headerFrame:(CGRect)headerFrame adjustedPinnedInsets:(UIEdgeInsets)adjustedPinnedInsets {
    UICollectionView *collectionView = self.collectionView;
    CGPoint contentOffset = collectionView.contentOffset;
    CGFloat pinnedX = headerFrame.origin.x;
    CGFloat pinnedY = headerFrame.origin.y;
    /// collectionView的偏移量(需要根据滚动方向设置值`switch{}`中设置)
    CGFloat offset = 0;
    switch ( _mScrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            if (@available(iOS 11.0, *)) {
                offset = contentOffset.y + collectionView.adjustedContentInset.top;
            } else {
                offset = contentOffset.y + collectionView.contentInset.top;
            }
            offset += adjustedPinnedInsets.top;
            if ( pinnedY < offset ) {
                if ( offset < 0 ) offset = 0;
                CGFloat maxY = CGRectGetMaxY(sectionFrame) - headerFrame.size.height;
                /// 不足以显示header
                /// 则需要跟随collectionView移动
                /// 到底maxY之后, 则跟随collectionView移动
                pinnedY = offset > maxY ? maxY : offset;
            }
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            if (@available(iOS 11.0, *)) {
                offset = contentOffset.x + collectionView.adjustedContentInset.left;
            } else {
                offset = contentOffset.x + collectionView.contentInset.left;
            }
            offset += adjustedPinnedInsets.top;
            if ( pinnedX < offset ) {
                if ( offset < 0 ) offset = 0;
                CGFloat maxX = CGRectGetMaxX(sectionFrame) - headerFrame.size.width;
                /// 不足以显示header
                /// 则需要跟随collectionView移动
                /// 到底maxX之后, 则跟随collectionView移动
                pinnedX = offset > maxX ? maxX : offset;
            }
        }
            break;
    }
    
    CGRect pinnedFrame = headerFrame;
    pinnedFrame.origin.x = pinnedX;
    pinnedFrame.origin.y = pinnedY;
    return pinnedFrame;
}

- (CGRect)_headerDecorationPinnedFrameForHeaderFrame:(CGRect)headerFrame headerPinnedFrame:(CGRect)headerPinnedFrame headerDecorationFrame:(CGRect)headerDecorationFrame {
    CGRect decorationPinnedFrame = headerDecorationFrame;
    switch ( _mScrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            decorationPinnedFrame.origin.y += headerPinnedFrame.origin.y - headerFrame.origin.y;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            decorationPinnedFrame.origin.x += headerPinnedFrame.origin.x - headerFrame.origin.x;
        }
            break;
    }
    return decorationPinnedFrame;
}
@end


@implementation LWZCollectionViewLayout (LWZCollectionFittingSize)
- (void)prepareLayoutFittingSize:(CGSize)fittingSize contentInsets:(UIEdgeInsets)contentInsets {
    [self prepareLayoutForCollectionSize:fittingSize contentInsets:contentInsets];
}
- (void)prepareLayoutFittingSize:(CGSize)fittingSize contentInsets:(UIEdgeInsets)contentInsets safeAreaInsets:(UIEdgeInsets)safeAreaInsets {
    [self prepareLayoutForCollectionSize:fittingSize contentInsets:contentInsets safeAreaInsets:safeAreaInsets];
}
@end


@interface LWZCollectionViewWeightLayout ()<LWZCollectionWeightLayout> {
    struct {
        unsigned delegateLayoutWeightForItemAtIndexPath :1;
    } _weightLayoutFlags;
}
@end

@implementation LWZCollectionViewWeightLayout
@dynamic delegate;

+ (Class)layoutSolverClass {
    return LWZCollectionWeightLayoutSolver.class;
}

- (void)setDelegate:(nullable id<LWZCollectionViewLayoutDelegate>)delegate {
    if ( delegate != self.delegate ) {
        [super setDelegate:delegate];
        _weightLayoutFlags.delegateLayoutWeightForItemAtIndexPath = [delegate respondsToSelector:@selector(layout:layoutWeightForItemAtIndexPath:)];
    }
}

- (CGFloat)layoutWeightForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( _weightLayoutFlags.delegateLayoutWeightForItemAtIndexPath ) {
        return [self.delegate layout:self layoutWeightForItemAtIndexPath:indexPath];
    }
    return 1.0;
}
@end


@interface LWZCollectionViewListLayout ()<LWZCollectionListLayout> {
    struct {
        unsigned delegateLayoutAlignmentForItemAtIndexPath :1;
    } _listLayoutFlags;
}
@end

@implementation LWZCollectionViewListLayout
@dynamic delegate;

+ (Class)layoutSolverClass {
    return LWZCollectionListLayoutSolver.class;
}

- (void)setDelegate:(nullable id<LWZCollectionViewListLayoutDelegate>)delegate {
    if ( delegate != self.delegate ) {
        [super setDelegate:delegate];
        _listLayoutFlags.delegateLayoutAlignmentForItemAtIndexPath = [delegate respondsToSelector:@selector(layout:layoutAlignmentForItemAtIndexPath:)];
    }
}

- (LWZCollectionLayoutAlignment)layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( _listLayoutFlags.delegateLayoutAlignmentForItemAtIndexPath ) {
        return [self.delegate layout:self layoutAlignmentForItemAtIndexPath:indexPath];
    }
    return LWZCollectionLayoutAlignmentCenter;
}
@end
 

@interface LWZCollectionViewWaterfallFlowLayout ()<LWZCollectionWaterfallFlowLayout> {
    struct {
        unsigned delegateLayoutNumberOfArrangedItemsPerLineInSection :1;
    } _waterfallFlowLayoutFlags;
}

@end

@implementation LWZCollectionViewWaterfallFlowLayout
@dynamic delegate;

+ (Class)layoutSolverClass {
    return LWZCollectionWaterfallFlowLayoutSolver.class;
}

- (void)setDelegate:(nullable id<LWZCollectionViewWaterfallFlowLayoutDelegate>)delegate {
    if ( delegate != self.delegate ) {
        [super setDelegate:delegate];
        
        _waterfallFlowLayoutFlags.delegateLayoutNumberOfArrangedItemsPerLineInSection = [delegate respondsToSelector:@selector(layout:layoutNumberOfArrangedItemsPerLineInSection:)];
    }
}

- (NSInteger)layoutNumberOfArrangedItemsPerLineInSection:(NSInteger)section {
    if ( _waterfallFlowLayoutFlags.delegateLayoutNumberOfArrangedItemsPerLineInSection ) {
        return [self.delegate layout:self layoutNumberOfArrangedItemsPerLineInSection:section];
    }
    return 1;
}
@end
 

@interface LWZCollectionViewRestrictedLayout ()

@end

@implementation LWZCollectionViewRestrictedLayout
+ (Class)layoutSolverClass {
    return LWZCollectionRestrictedLayoutSolver.class;
}
@end
 

@interface LWZCollectionViewTemplateLayout ()<LWZCollectionTemplateLayout>

@end

@implementation LWZCollectionViewTemplateLayout
@dynamic delegate;

+ (Class)layoutSolverClass {
    return LWZCollectionTemplateLayoutSolver.class;
}

- (NSArray<LWZCollectionTemplateGroup *> *)layoutTemplateContainerGroupsInSection:(NSInteger)section {
    NSParameterAssert(self.delegate != nil);
    
    return [self.delegate layout:self layoutTemplateContainerGroupsInSection:section];
}
@end


@interface LWZCollectionViewMultipleLayout ()<LWZCollectionMultipleLayout> {
    struct {
        unsigned delegateLayoutWeightForItemAtIndexPath :1;
        unsigned delegateLayoutAlignmentForItemAtIndexPath :1;
        unsigned delegateLayoutNumberOfArrangedItemsPerLineInSection :1;
    } _multipleLayoutFlags;
}

@end

@implementation LWZCollectionViewMultipleLayout
@dynamic delegate;

+ (Class)layoutSolverClass {
    return LWZCollectionMultipleLayoutSolver.class;
}

- (void)setDelegate:(nullable id<LWZCollectionViewMultipleLayoutDelegate>)delegate {
    if ( delegate != self.delegate ) {
        [super setDelegate:delegate];
        _multipleLayoutFlags.delegateLayoutWeightForItemAtIndexPath = [delegate respondsToSelector:@selector(layout:layoutWeightForItemAtIndexPath:)];

        _multipleLayoutFlags.delegateLayoutAlignmentForItemAtIndexPath = [delegate respondsToSelector:@selector(layout:layoutAlignmentForItemAtIndexPath:)];
        
        _multipleLayoutFlags.delegateLayoutNumberOfArrangedItemsPerLineInSection = [delegate respondsToSelector:@selector(layout:layoutNumberOfArrangedItemsPerLineInSection:)];
    }
}
- (CGFloat)layoutWeightForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( _multipleLayoutFlags.delegateLayoutWeightForItemAtIndexPath ) {
        return [self.delegate layout:self layoutWeightForItemAtIndexPath:indexPath];
    }
    return 1.0;
}
- (LWZCollectionLayoutAlignment)layoutAlignmentForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ( _multipleLayoutFlags.delegateLayoutAlignmentForItemAtIndexPath ) {
        return [self.delegate layout:self layoutAlignmentForItemAtIndexPath:indexPath];
    }
    return LWZCollectionLayoutAlignmentCenter;
}

- (NSInteger)layoutNumberOfArrangedItemsPerLineInSection:(NSInteger)section {
    if ( _multipleLayoutFlags.delegateLayoutNumberOfArrangedItemsPerLineInSection ) {
        return [self.delegate layout:self layoutNumberOfArrangedItemsPerLineInSection:section];
    }
    return 1;
}

- (nonnull NSArray<LWZCollectionTemplateGroup *> *)layoutTemplateContainerGroupsInSection:(NSInteger)section {
    NSParameterAssert(self.delegate != nil);
    
    return [self.delegate layout:self layoutTemplateContainerGroupsInSection:section];
}

- (LWZCollectionLayoutType)layoutTypeForItemsInSection:(NSInteger)section {
    NSParameterAssert(self.delegate != nil);

    return [self.delegate layout:self layoutTypeForItemsInSection:section];
}
@end

#pragma mark - compositional layout

@interface LWZCollectionViewCompositionalLayout ()<LWZCollectionCompositionalLayout> {
    struct {
        unsigned delegateIsOrthogonalScrollingInSection :1;
        unsigned delegateOrthogonalContentScrollingBehaviorInSection :1;
    } _compositionalLayoutFlags;
}
@end

@implementation LWZCollectionViewCompositionalLayout
@dynamic delegate;

+ (Class)layoutSolverClass {
    return LWZCollectionCompositionalLayoutSolver.class;
}

- (nullable __kindof UICollectionViewCell *)orthogonalScrollingCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionLayoutSection *layoutSection = [_mLayoutCollection sectionAtIndex:indexPath.section];
    if ( layoutSection != nil  ) {
        return layoutSection.customView != nil ? [(UICollectionView *)layoutSection.customView cellForItemAtIndexPath:indexPath] : nil;
    }
    return nil;
}

- (void)setDelegate:(id<LWZCollectionViewCompositionalLayoutDelegate>)delegate {
    if ( delegate != self.delegate ) {
        [super setDelegate:delegate];
        _compositionalLayoutFlags.delegateIsOrthogonalScrollingInSection = [delegate respondsToSelector:@selector(layout:isOrthogonalScrollingInSection:)];
        _compositionalLayoutFlags.delegateOrthogonalContentScrollingBehaviorInSection = [delegate respondsToSelector:@selector(layout:orthogonalContentScrollingBehaviorInSection:)];
    }
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    [_mLayoutCollection enumerateSectionsUsingBlock:^(LWZCollectionLayoutSection * _Nonnull section, BOOL * _Nonnull stop) {
        UICollectionView *groupView = section.customView;
        if ( groupView != nil ) {
            BOOL needsHidden = LWZFloatRangeRectCompare(groupView.frame, newBounds, _mScrollDirection) != LWZFloatRangeComparisonResultIntersecting;
            groupView.hidden = needsHidden;
        }
    }];
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}
- (BOOL)isOrthogonalScrollingInSection:(NSInteger)section {
    if ( _compositionalLayoutFlags.delegateIsOrthogonalScrollingInSection ) {
        return [self.delegate layout:self isOrthogonalScrollingInSection:section];
    }
    return NO;
}
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forOrthogonalContentInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [self.delegate layout:self layoutSizeToFit:fittingSize forOrthogonalContentInSection:section scrollDirection:scrollDirection];
}
- (LWZCollectionLayoutContentOrthogonalScrollingBehavior)orthogonalContentScrollingBehaviorInSection:(NSInteger)section {
    if ( _compositionalLayoutFlags.delegateOrthogonalContentScrollingBehaviorInSection ) {
        return [self.delegate layout:self orthogonalContentScrollingBehaviorInSection:section];
    }
    return LWZCollectionLayoutContentOrthogonalScrollingBehaviorNormal;
}
 
- (LWZCollectionLayoutContentPresentationMode)presentationModeForCellsInSection:(NSInteger)index {
    return [self isOrthogonalScrollingInSection:index] ? LWZCollectionLayoutContentPresentationModeCustom : LWZCollectionLayoutContentPresentationModeNormal;
}
@end

/**
 
 关于Decoration, Section, Header, Item, Footer 不能是同一个类型的`Decoration`对象, 需要分开创建.
 
 Decoration 自身分辨的依据是 ElementKind 以及 IndexPath, 因此如果Section, Header... 采用相同类型的Decoration(ElementKind一致)时, 仅通过IndexPath是无法确定谁的Decoration的.
 
 */

/**
 
 Thread 1: "layout attributes for supplementary item at index path (<NSIndexPath: 0xe529dd7261ae55ef> {length = 2, path = 0 - 0}) changed
 
 from <LWZCollectionViewLayoutAttributes: 0x1031e95a0> index path: (<NSIndexPath: 0xe529dd7261ae55ef> {length = 2, path = 0 - 0}); element kind: (UICollectionElementKindSectionHeader); frame = (0 210.5; 375 48); zIndex = 10;
 
 to <LWZCollectionViewLayoutAttributes: 0x1031de3f0> index path: (<NSIndexPath: 0xe529dd7261ae55ef> {length = 2, path = 0 - 0}); element kind: (UICollectionElementKindSectionHeader); frame = (0 0; 375 48);  without invalidating the layout"

 
 
 Thread 1: "layout attributes for supplementary item at index path (<NSIndexPath: 0xbc0693613406c6e2> {length = 2, path = 0 - 0}) changed
 
 from <LWZCollectionViewLayoutAttributes: 0x1030edaf0> index path: (<NSIndexPath: 0xbc0693613406c6e2> {length = 2, path = 0 - 0}); element kind: (UICollectionElementKindSectionHeader); frame = (0 0; 375 48); zIndex = 10;
 
 to <LWZCollectionViewLayoutAttributes: 0x1112230f0> index path: (<NSIndexPath: 0xbc0693613406c6e2> {length = 2, path = 0 - 0}); element kind: (UICollectionElementKindSectionHeader); frame = (0 0; 375 48);  without invalidating the layout"
 
 
 Thread 1: "layout attributes for supplementary item at index path (0 - 0) changed
 
 from <LWZCollectionViewLayoutAttributes: 0x10eb02360>
 
 to <LWZCollectionViewLayoutAttributes: 0x1029c5c70>
 
 without invalidating the layout"
 */
#ifdef LWZ_DEBUG


/*
 一些名词解释:
 
 fittingSize: 试穿的size, 限制宽高计算范围, 不是最终的size
 layoutSize: 布局的size, 是最终显示的size
 layoutFrame: 布局的frame, 最终显示的frame
 
 layoutInsets(UIEdgeInsets): 内容布局边缘间距
 layoutRange(UIFloatRange): 内容布局范围限制
 
 viewLayout 将具体的计算过程交给 solver,
 solver 根据 layout 必要的参数进行计算
 
 */
#endif
