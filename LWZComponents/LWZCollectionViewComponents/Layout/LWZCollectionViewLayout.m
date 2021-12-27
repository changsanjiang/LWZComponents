//
//  LWZCollectionViewLayout.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2020/11/13.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionViewLayout.h"
#import "LWZCollectionViewLayoutAttributes.h"
#import "LWZCollectionLayoutContentContainer.h"
#import "LWZCollectionViewLayoutSubclass.h"

typedef NS_OPTIONS(NSUInteger, LWZCollectionLayoutPrepareContext) {
    LWZCollectionLayoutPrepareContextNone = 0,
    LWZCollectionLayoutPrepareContextInvalidateEverything = 1 << 0,
    LWZCollectionLayoutPrepareContextInvalidateDataSourceCounts = 1 << 1,
    LWZCollectionLayoutPrepareContextBoundaryChanging = 1 << 2,
};
 
UIKIT_STATIC_INLINE CGSize
LWZLayoutSizeItemAdjusting(CGSize size, CGSize fittingSize, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            if ( size.width > fittingSize.width ) size.width = fittingSize.width;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            if ( size.height > fittingSize.height ) size.height = fittingSize.height;
            break;
    }
    return size;
}

UIKIT_STATIC_INLINE CGSize
LWZLayoutSizeHeaderFooterAdjusting(CGSize size, CGSize fittingSize, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            size.width = fittingSize.width;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            size.height = fittingSize.height;
            break;
    }
    return size;
}

static CGFloat const LWZ_LAYOUT_MIN_VALUE = 0.1;
UIKIT_STATIC_INLINE BOOL
LWZLayoutSizeIsInvalid(CGSize size, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            return size.height < LWZ_LAYOUT_MIN_VALUE;
        case UICollectionViewScrollDirectionHorizontal:
            return size.width < LWZ_LAYOUT_MIN_VALUE;
    }
    return NO;
}


UIKIT_STATIC_INLINE CGFloat
LWZLayoutAttributesGetMaxOffset(LWZCollectionViewLayoutAttributes *attributes, UICollectionViewScrollDirection direction) {
    CGFloat offset = 0;
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            offset = CGRectGetMaxY(attributes.frame);
            break;
        case UICollectionViewScrollDirectionHorizontal:
            offset = CGRectGetMaxX(attributes.frame);
            break;
    }
    return offset;
}

UIKIT_STATIC_INLINE CGFloat
LWZLayoutAttributesGetMaxOffset(NSArray<LWZCollectionViewLayoutAttributes *> *attributesObjects, UICollectionViewScrollDirection direction) __attribute__((overloadable)) {
    CGFloat offset = 0;
    CGFloat cur = 0;
    for ( LWZCollectionViewLayoutAttributes *attributes in attributesObjects ) {
        cur = LWZLayoutAttributesGetMaxOffset(attributes, direction);
        if ( offset < cur ) offset = cur;
    }
    return offset;
}
  
typedef NS_ENUM(NSUInteger, LWZFloatRangeComparisonResult) {
    LWZFloatRangeComparisonResultInLeft,
    LWZFloatRangeComparisonResultIntersecting,
    LWZFloatRangeComparisonResultInRight,
};

UIKIT_STATIC_INLINE LWZFloatRangeComparisonResult
LWZFloatRangeCompare(UIFloatRange range1, UIFloatRange range2) {
    if ( range1.maximum < range2.minimum )
        return LWZFloatRangeComparisonResultInLeft;;
    if ( range1.minimum > range2.maximum )
        return LWZFloatRangeComparisonResultInRight;
    return LWZFloatRangeComparisonResultIntersecting;
}

UIKIT_STATIC_INLINE UIFloatRange
LWZRectFloatRangeForDirection(CGRect rect, UICollectionViewScrollDirection direction) {
  UIFloatRange range = UIFloatRangeZero;
  switch ( direction ) {
      case UICollectionViewScrollDirectionVertical:
          range = UIFloatRangeMake(CGRectGetMinY(rect), CGRectGetMaxY(rect));
          break;
      case UICollectionViewScrollDirectionHorizontal:
          range = UIFloatRangeMake(CGRectGetMinX(rect), CGRectGetMaxX(rect));
          break;
  }
  return range;
}

UIKIT_STATIC_INLINE LWZFloatRangeComparisonResult
LWZRectFloatRangeCompare(CGRect rect1, CGRect rect2, UICollectionViewScrollDirection direction) {
    UIFloatRange range1 = LWZRectFloatRangeForDirection(rect1, direction);
    UIFloatRange range2 = LWZRectFloatRangeForDirection(rect2, direction);
    return LWZFloatRangeCompare(range1, range2);
}

UIKIT_STATIC_INLINE BOOL
LWZRectFloatRangeIntersects(CGRect rect1, CGRect rect2, UICollectionViewScrollDirection direction) {
    return LWZRectFloatRangeCompare(rect1, rect2, direction) == LWZFloatRangeComparisonResultIntersecting;
}


UIKIT_STATIC_INLINE NSArray *_Nullable
LWZAllHashTableObjects(NSHashTable *table) {
    return table.count != 0 ? NSAllHashTableObjects(table) : nil;
}

@interface _LWZLayoutSection : NSObject
/// 表示当前section整个的layout.frame
/// 这个属性在设置`sectionHeadersPinToVisibleBounds == YES`时会被用到, 不会再collectionView中使用
@property (nonatomic) CGRect frame;
@property (nonatomic, strong, nullable) __kindof UIView *customView; // LWZCollectionCompositionalLayout

@property (nonatomic) BOOL canPinToVisibleBoundsForHeader;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *headerViewLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *headerViewPinnedLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *footerViewLayoutAttributes;

@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *sectionDecorationLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *headerDecorationLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *headerDecorationPinnedLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *footerDecorationLayoutAttributes;

@property (nonatomic, readonly, nullable) NSArray<LWZCollectionViewLayoutAttributes *> *cellLayoutAttributesObjects;
@property (nonatomic, readonly, nullable) NSArray<LWZCollectionViewLayoutAttributes *> *cellDecorationLayoutAttributesObjects;

- (void)removeAllLayoutAttributes;

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category;

- (nullable LWZCollectionViewLayoutAttributes *)currentHeaderViewLayoutAttributes; // @note 后面如要扩展footer时也需要添加类似的方法
- (nullable LWZCollectionViewLayoutAttributes *)currentHeaderDecorationLayoutAttributes; // @note 后面如要扩展footer时也需要添加类似的方法
@end

@implementation _LWZLayoutSection {
    NSArray<LWZCollectionViewLayoutAttributes *> *_Nullable mCellLayoutAttributesObjects;
    NSArray<LWZCollectionViewLayoutAttributes *> *_Nullable mCellDecorationLayoutAttributesObjects;
}

- (void)dealloc {
    if ( _customView != nil ) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
}
 
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category {
    switch ( category ) {
        case UICollectionElementCategoryCell:
            return self.cellLayoutAttributesObjects;
        case UICollectionElementCategorySupplementaryView: {
            NSMutableArray<LWZCollectionViewLayoutAttributes *> *m = [NSMutableArray arrayWithCapacity:2];
            if ( [self currentHeaderViewLayoutAttributes] != nil ) [m addObject:[self currentHeaderViewLayoutAttributes]];
            if ( self.footerViewLayoutAttributes != nil )  [m addObject:self.footerViewLayoutAttributes];
            return m.count != 0 ?  m : nil;
        }
            break;
        case UICollectionElementCategoryDecorationView: {
            NSMutableArray<LWZCollectionViewLayoutAttributes *> *m = NSMutableArray.array;
            if ( [self currentHeaderDecorationLayoutAttributes] ) [m addObject:[self currentHeaderDecorationLayoutAttributes]];
            if ( self.cellDecorationLayoutAttributesObjects != nil ) [m addObjectsFromArray:self.cellDecorationLayoutAttributesObjects];
            if ( self.footerDecorationLayoutAttributes != nil ) [m addObject:self.footerDecorationLayoutAttributes];
            return m.count != 0 ?  m : nil;
        }
            break;
    }
}

- (nullable LWZCollectionViewLayoutAttributes *)currentHeaderViewLayoutAttributes {
    return _headerViewPinnedLayoutAttributes ?: _headerViewLayoutAttributes;
}

- (nullable LWZCollectionViewLayoutAttributes *)currentHeaderDecorationLayoutAttributes {
    return _headerDecorationPinnedLayoutAttributes ?: _headerDecorationLayoutAttributes;
}

- (void)setCellLayoutAttributesObjects:(NSArray<LWZCollectionViewLayoutAttributes *> *)objects {
    mCellLayoutAttributesObjects = objects;
}
 
- (void)setCellDecorationLayoutAttributesObjects:(NSArray<LWZCollectionViewLayoutAttributes *> *)objects {
    mCellDecorationLayoutAttributesObjects = objects;
}
 
- (void)removeAllLayoutAttributes {
    _frame = CGRectZero;
    _footerDecorationLayoutAttributes = nil;
    _headerDecorationLayoutAttributes = nil;
    _sectionDecorationLayoutAttributes = nil;
    mCellLayoutAttributesObjects = nil;
    mCellDecorationLayoutAttributesObjects = nil;
    _headerViewLayoutAttributes = nil;
    _footerDecorationLayoutAttributes = nil;
    if ( _customView != nil ) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)cellLayoutAttributesObjects {
    return [self _layoutAttributes:mCellLayoutAttributesObjects];
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)cellDecorationLayoutAttributesObjects {
    return [self _layoutAttributes:mCellDecorationLayoutAttributesObjects];
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)_layoutAttributes:(NSArray<LWZCollectionViewLayoutAttributes *> *)array {
    return array.count == 0 ? nil : array;
}

@end

@interface _LWZLayoutCollection : NSObject
- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection;
@property (nonatomic, readonly, nullable) NSArray<_LWZLayoutSection *> *sections;

- (nullable NSArray<_LWZLayoutSection *> *)sectionsInRect:(CGRect)rect;
- (void)addSection:(_LWZLayoutSection *)section;
- (void)removeAllSections;

//- (void)

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (nullable NSArray<__kindof LWZCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)param;
@end

@implementation _LWZLayoutCollection {
    NSMutableArray<_LWZLayoutSection *> *mSections;
    UICollectionViewScrollDirection mScrollDirection;
}

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    self = [super init];
    if ( self ) {
        mScrollDirection = scrollDirection;
    }
    return self;
}

- (void)addSection:(_LWZLayoutSection *)section {
    if ( mSections == nil )
        mSections = NSMutableArray.array;
    [mSections addObject:section];
}

- (void)removeAllSections {
    [mSections removeAllObjects];
}

- (nullable NSArray<_LWZLayoutSection *> *)sections {
    return mSections.count != 0 ? mSections : nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    _LWZLayoutSection *section = [self _sectionAtIndex:indexPath.section];
    if ( section != nil ) {
        if ( indexPath.item < section.cellLayoutAttributesObjects.count )
            return section.cellLayoutAttributesObjects[indexPath.item];
    }
    return nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    _LWZLayoutSection *section = [self _sectionAtIndex:indexPath.section];
    if ( section != nil ) {
        if      ( [elementKind isEqualToString:UICollectionElementKindSectionHeader] )
            return [section currentHeaderViewLayoutAttributes];
        else if ( [elementKind isEqualToString:UICollectionElementKindSectionFooter ] )
            return section.footerViewLayoutAttributes;
    }
    return nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    _LWZLayoutSection *section = [self _sectionAtIndex:indexPath.section];
    if ( section != nil ) {
        /// section, header, footer, cell 的`decoration`
        if ( [section.sectionDecorationLayoutAttributes.representedElementKind isEqualToString:elementKind] )
            return section.sectionDecorationLayoutAttributes;
        if ( [[section currentHeaderDecorationLayoutAttributes].representedElementKind isEqualToString:elementKind] )
            return [section currentHeaderDecorationLayoutAttributes];
        if ( [section.footerDecorationLayoutAttributes.representedElementKind isEqualToString:elementKind] )
            return section.footerDecorationLayoutAttributes;
        /// 由于可能的情况 不是所有cell都有decoration
        /// 因此这里需要遍历一下
        /// cell.decoration 需要额外的判断indexPath, 防止复用的情况
        for ( LWZCollectionViewLayoutAttributes *attr in section.cellDecorationLayoutAttributesObjects ) {
            if ( [attr.representedElementKind isEqualToString:elementKind] && [attr.indexPath isEqual:indexPath] )
                return attr;
        }
    }
    return nil;
}

- (nullable NSArray<__kindof LWZCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    UICollectionViewScrollDirection direction = mScrollDirection;
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *m = NSMutableArray.array;
    for ( _LWZLayoutSection *section in [self sectionsInRect:rect] ) {
    
        if ( [section currentHeaderViewLayoutAttributes] != nil && LWZRectFloatRangeIntersects([section currentHeaderViewLayoutAttributes].frame, rect, direction) )
            [m addObject:[section currentHeaderViewLayoutAttributes]];
        if ( section.footerViewLayoutAttributes != nil && LWZRectFloatRangeIntersects(section.footerViewLayoutAttributes.frame, rect, direction) )
            [m addObject:section.footerViewLayoutAttributes];
        if ( section.sectionDecorationLayoutAttributes != nil && LWZRectFloatRangeIntersects(section.sectionDecorationLayoutAttributes.frame, rect, direction) )
            [m addObject:section.sectionDecorationLayoutAttributes];
        if ( [section currentHeaderDecorationLayoutAttributes] != nil && LWZRectFloatRangeIntersects([section currentHeaderDecorationLayoutAttributes].frame, rect, direction) )
            [m addObject:[section currentHeaderDecorationLayoutAttributes]];
        if ( section.footerDecorationLayoutAttributes != nil && LWZRectFloatRangeIntersects(section.footerDecorationLayoutAttributes.frame, rect, direction) )
            [m addObject:section.footerDecorationLayoutAttributes];
        for ( LWZCollectionViewLayoutAttributes *attributes in section.cellLayoutAttributesObjects ) {
            LWZFloatRangeComparisonResult result = LWZRectFloatRangeCompare(attributes.frame, rect, direction);
            /* continue */
            if ( result == LWZFloatRangeComparisonResultInLeft || result == LWZFloatRangeComparisonResultInRight ) continue;
            [m addObject:attributes];
        }
        for ( LWZCollectionViewLayoutAttributes *attributes in section.cellDecorationLayoutAttributesObjects ) {
            LWZFloatRangeComparisonResult result = LWZRectFloatRangeCompare(attributes.frame, rect, direction);
            /* continue */
            if ( result == LWZFloatRangeComparisonResultInLeft || result == LWZFloatRangeComparisonResultInRight ) continue;
            [m addObject:attributes];
        }
    }
    return m;
}

- (nullable _LWZLayoutSection *)_sectionAtIndex:(NSInteger)index {
    if ( index < mSections.count ) {
        return mSections[index];
    }
    return nil;
}

- (nullable NSArray<_LWZLayoutSection *> *)sectionsInRect:(CGRect)rect {
    NSMutableArray<_LWZLayoutSection *> *m = NSMutableArray.array;
    for ( _LWZLayoutSection *section in mSections ) {
        __auto_type result = LWZRectFloatRangeCompare(section.frame, rect, mScrollDirection);
        /* break */
        if ( result == LWZFloatRangeComparisonResultInRight ) break;
        /* continue */
        if ( result == LWZFloatRangeComparisonResultInLeft ) continue;
        [m addObject:section];
    }
    return m;
}
@end


#pragma mark - mark


@interface LWZCollectionViewLayout () {
    @protected
    UICollectionViewScrollDirection _scrollDirection;
    NSHashTable<id<LWZCollectionViewLayoutObserver>> *_mObservers;
    _LWZLayoutCollection *_mCollection;
    CGSize _mContentSize;
    __kindof __weak id<LWZCollectionViewLayoutDelegate> _delegate;
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
        unsigned delegateWeightForItem :1;
        unsigned delegateAlignmentForItem :1;
        unsigned delegateNumberOfArrangedItemsPerLineInSection :1;
        unsigned delegateWillPrepareLayoutInContainer :1;
        unsigned delegateWillPrepareLayoutInContainerContentInsetsSafeAreaInsets :1 NS_AVAILABLE_IOS(11.0);
        unsigned delegateDidFinishPreparingInContainer :1;
        unsigned delegateDidFinishPreparingInContainerContentInsetsSafeAreaInsets :1 NS_AVAILABLE_IOS(11.0);

        unsigned isIgnoredSafeAreaInsets :1;
        unsigned sectionHeadersPinToVisibleBounds :1;
    } _layoutFlags;
}
@end

@implementation LWZCollectionViewLayout
+ (Class)layoutAttributesClass {
    return LWZCollectionViewLayoutAttributes.class;
}

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [self initWithScrollDirection:scrollDirection delegate:nil];
}

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection delegate:(nullable id<LWZCollectionViewLayoutDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _mCollection = [_LWZLayoutCollection.alloc initWithScrollDirection:scrollDirection];
        _scrollDirection = scrollDirection;
        _layoutFlags.isIgnoredSafeAreaInsets = YES;
        self.delegate = delegate;
    }
    return self;
}

@synthesize delegate = _delegate;
- (void)setDelegate:(nullable id<LWZCollectionViewLayoutDelegate>)delegate {
    if ( delegate != _delegate ) {
        _delegate = delegate;
        _layoutFlags.delegateEdgeSpacingsForSection = [delegate respondsToSelector:@selector(layout:edgeSpacingsForSectionAtIndex:)];
        _layoutFlags.delegateContentInsetsForSection = [delegate respondsToSelector:@selector(layout:contentInsetsForSectionAtIndex:)];
        _layoutFlags.delegateAdjustedPinnedInsets = [delegate respondsToSelector:@selector(layout:adjustedPinnedInsetsForSectionAtIndex:)];
        _layoutFlags.delegateCanPinToVisibleBoundsForHeader = [delegate respondsToSelector:@selector(layout:canPinToVisibleBoundsForHeaderInSection:)];
        _layoutFlags.delegateSizeForHeader = [delegate respondsToSelector:@selector(layout:layoutSizeToFit:forHeaderInSection:scrollDirection:)];
        _layoutFlags.delegateSizeForItem = [delegate respondsToSelector:@selector(layout:layoutSizeToFit:forItemAtIndexPath:scrollDirection:)];
        _layoutFlags.delegateSizeForFooter = [delegate respondsToSelector:@selector(layout:layoutSizeToFit:forFooterInSection:scrollDirection:)];
        _layoutFlags.delegateLineSpacingForSection = [delegate respondsToSelector:@selector(layout:minimumLineSpacingForSectionAtIndex:)];
        _layoutFlags.delegateInteritemSpacingForSection = [delegate respondsToSelector:@selector(layout:minimumInteritemSpacingForSectionAtIndex:)];
        _layoutFlags.delegateElementKindForSectionDecoration = [delegate respondsToSelector:@selector(layout:elementKindForSectionDecorationAtIndexPath:)];
        _layoutFlags.delegateElementKindForHeaderDecoration = [delegate respondsToSelector:@selector(layout:elementKindForHeaderDecorationAtIndexPath:)];
        _layoutFlags.delegateElementKindForItemDecoration = [delegate respondsToSelector:@selector(layout:elementKindForItemDecorationAtIndexPath:)];
        _layoutFlags.delegateElementKindForFooterDecoration = [delegate respondsToSelector:@selector(layout:elementKindForFooterDecorationAtIndexPath:)];
        _layoutFlags.delegateUserInfoForSectionDecoration = [delegate respondsToSelector:@selector(layout:userInfoForSectionDecorationAtIndexPath:)];
        _layoutFlags.delegateUserInfoForHeaderDecoration = [delegate respondsToSelector:@selector(layout:userInfoForHeaderDecorationAtIndexPath:)];
        _layoutFlags.delegateUserInfoForItemDecoration = [delegate respondsToSelector:@selector(layout:userInfoForItemDecorationAtIndexPath:)];
        _layoutFlags.delegateUserInfoForFooterDecoration = [delegate respondsToSelector:@selector(layout:userInfoForFooterDecorationAtIndexPath:)];
        _layoutFlags.delegateRelativeRectForSectionDecoration = [delegate respondsToSelector:@selector(layout:relativeRectToFit:forSectionDecorationAtIndexPath:)];
        _layoutFlags.delegateRelativeRectForHeaderDecoration = [delegate respondsToSelector:@selector(layout:relativeRectToFit:forHeaderDecorationAtIndexPath:)];
        _layoutFlags.delegateRelativeRectForItemDecoration = [delegate respondsToSelector:@selector(layout:relativeRectToFit:forItemDecorationAtIndexPath:)];
        _layoutFlags.delegateRelativeRectForFooterDecoration = [delegate respondsToSelector:@selector(layout:relativeRectToFit:forFooterDecorationAtIndexPath:)];
        _layoutFlags.delegateZIndexForHeader = [delegate respondsToSelector:@selector(layout:zIndexForHeaderInSection:)];
        _layoutFlags.delegateZIndexForItem = [delegate respondsToSelector:@selector(layout:zIndexForItemAtIndexPath:)];
        _layoutFlags.delegateZIndexForFooter = [delegate respondsToSelector:@selector(layout:zIndexForFooterInSection:)];
        _layoutFlags.delegateZIndexForSectionDecoration = [delegate respondsToSelector:@selector(layout:zIndexForSectionDecorationAtIndexPath:)];
        _layoutFlags.delegateZIndexForHeaderDecoration = [delegate respondsToSelector:@selector(layout:zIndexForHeaderDecorationAtIndexPath:)];
        _layoutFlags.delegateZIndexForItemDecoration = [delegate respondsToSelector:@selector(layout:zIndexForItemDecorationAtIndexPath:)];
        _layoutFlags.delegateZIndexForFooterDecoration = [delegate respondsToSelector:@selector(layout:zIndexForFooterDecorationAtIndexPath:)];
        _layoutFlags.delegateWeightForItem = [delegate respondsToSelector:@selector(layout:weightForItemAtIndexPath:)];
        _layoutFlags.delegateAlignmentForItem = [delegate respondsToSelector:@selector(layout:layoutAlignmentForItemAtIndexPath:)];
        _layoutFlags.delegateNumberOfArrangedItemsPerLineInSection = [delegate respondsToSelector:@selector(layout:numberOfArrangedItemsPerLineInSection:)];
        _layoutFlags.delegateWillPrepareLayoutInContainer = [delegate respondsToSelector:@selector(layout:willPrepareLayoutInContainer:)];
        _layoutFlags.delegateDidFinishPreparingInContainer = [delegate respondsToSelector:@selector(layout:didFinishPreparingInContainer:)];
    }
}

- (void)setIgnoredSafeAreaInsets:(BOOL)ignoredSafeAreaInsets {
    _layoutFlags.isIgnoredSafeAreaInsets = ignoredSafeAreaInsets;
}

- (BOOL)isIgnoredSafeAreaInsets {
    return _layoutFlags.isIgnoredSafeAreaInsets;
}

- (void)setSectionHeadersPinToVisibleBounds:(BOOL)sectionHeadersPinToVisibleBounds {
    _layoutFlags.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds;
}

- (BOOL)sectionHeadersPinToVisibleBounds {
    return _layoutFlags.sectionHeadersPinToVisibleBounds;
}

- (CGRect)layoutFrameForSection:(NSInteger)section {
    if ( section >= 0 && section < _mCollection.sections.count ) {
        _LWZLayoutSection *s = _mCollection.sections[section];
        return s.frame;
    }
    return CGRectZero;
}

- (void)enumerateLayoutAttributesWithElementCategory:(UICollectionElementCategory)category usingBlock:(void(NS_NOESCAPE ^)(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop))block {
    BOOL stop = NO;
    NSInteger idx = 0;
    for ( _LWZLayoutSection *section in _mCollection.sections ) {
        for ( UICollectionViewLayoutAttributes *attributes in [section layoutAttributesObjectsForElementCategory:category] ) {
            block(attributes, idx++, &stop);
            if ( stop ) return;
        }
    }
}

- (nullable NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category {
    NSMutableArray<UICollectionViewLayoutAttributes *> *m = [NSMutableArray array];
    for ( _LWZLayoutSection *section in _mCollection.sections ) {
        NSArray<UICollectionViewLayoutAttributes *> *array = [section layoutAttributesObjectsForElementCategory:category];
        if ( array.count != 0 ) [m addObjectsFromArray:array];
    }
    return m.count > 0 ? m.copy : nil;
}

- (nullable NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category inSection:(NSInteger)section {
    if ( section < _mCollection.sections.count ) {
        return [_mCollection.sections[section] layoutAttributesObjectsForElementCategory:category];
    }
    return nil;
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
        switch ( _scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                boundary = bounds.size.width - contentSizeAdjustment.width;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                boundary = bounds.size.height - contentSizeAdjustment.height;
                break;
        }
    }
    else {
        switch ( _scrollDirection ) {
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
        // 调整contentOffset, 按照boundary变化比例, 增加或减少相应比例的offset
        if ( CGPointEqualToPoint(CGPointZero, contentOffsetAdjustment) ) {
            switch ( _scrollDirection ) {
                case UICollectionViewScrollDirectionVertical: {
                    CGFloat newOffsetY = boundary * oldContentOffset.y / oldBoundary;
                    contentOffsetAdjustment.y = newOffsetY - oldContentOffset.y;
                }
                    break;
                case UICollectionViewScrollDirectionHorizontal: {
                    CGFloat newOffsetX = boundary * oldContentOffset.x / oldBoundary;
                    contentOffsetAdjustment.x = newOffsetX - oldContentOffset.x;
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
    switch ( _scrollDirection ) {
        case UICollectionViewScrollDirectionVertical:
            isBoundaryChanged = newBounds.size.width != collectionView.bounds.size.width;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            isBoundaryChanged = newBounds.size.height != collectionView.bounds.size.height;
            break;
    }
    
    if ( isBoundaryChanged )
        return YES;
    
    if ( _layoutFlags.sectionHeadersPinToVisibleBounds /*|| _sectionFootersPinToVisibleBounds*/ ) {
        NSArray<_LWZLayoutSection *> *sections = [_mCollection sectionsInRect:newBounds];
        for ( _LWZLayoutSection *section in sections ) {
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
        NSArray<_LWZLayoutSection *> *sections = [_mCollection sectionsInRect:newBounds];
        if ( sections.count != 0 ) {
            for ( _LWZLayoutSection *section in sections ) {
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
    return [_mCollection layoutAttributesForItemAtIndexPath:indexPath];
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.sectionHeadersPinToVisibleBounds ) {
        NSInteger sIdx = indexPath.section;
        if ( elementKind == UICollectionElementKindSectionHeader ) {
            _LWZLayoutSection *section = [_mCollection _sectionAtIndex:sIdx];
            LWZCollectionViewLayoutAttributes *header = section.headerViewLayoutAttributes;
            if ( header != nil && section.canPinToVisibleBoundsForHeader ) {
                CGRect headerPinnedFrame = [self _headerPinnedFrameForSectionFrame:section.frame headerFrame:header.frame adjustedPinnedInsets:[self adjustedPinnedInsetsForSectionAtIndex:sIdx]];
                [section.headerViewPinnedLayoutAttributes setFrame:headerPinnedFrame];
            }
        }
    }
    return [_mCollection layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.sectionHeadersPinToVisibleBounds ) {
        NSInteger sIdx = indexPath.section;
        _LWZLayoutSection *section = [_mCollection _sectionAtIndex:sIdx];
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
    return [_mCollection layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
}

- (nullable NSArray<__kindof LWZCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [_mCollection layoutAttributesForElementsInRect:rect];
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
    
    [_mCollection removeAllSections];
    _mContentSize = CGSizeZero;
    _mPrepareContext = LWZCollectionLayoutPrepareContextNone;
    
    if ( _delegate == nil ) {
#if DEBUG
        NSLog(@"⚠️ %@<%p>: `layout.delegate`未设置!!!", NSStringFromClass(self.class), self);
        NSLog(@"⚠️ %@<%p>: `layout.delegate`未设置!!!", NSStringFromClass(self.class), self);
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
    
    LWZCollectionLayoutCollectionContentContainer *collectionContentContainer = [LWZCollectionLayoutCollectionContentContainer.alloc initWithCollectionSize:collectionSize direction:_scrollDirection collectionContentInsets:contentInsets collectionSafeAreaInsets:safeAreaInsets ignoredCollectionSafeAreaInsets:_layoutFlags.isIgnoredSafeAreaInsets];
     
    [self willPrepareLayoutInContainer:collectionContentContainer];
    
    CGFloat offset = 0;
    switch ( _scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            offset = collectionContentContainer.layoutInsets.top;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            offset = collectionContentContainer.layoutInsets.left;
        }
            break;
    }
    
    CGRect sectionFrame = CGRectZero;
    for ( NSInteger sIdx = 0 ; sIdx < numberOfSections;  ++ sIdx ) {
        if ( ![self shouldProcessSectionLayoutAtIndex:sIdx] )
            continue;
        
        UIEdgeInsets sectionEdgeSpacings = [self edgeSpacingsForSectionAtIndex:sIdx];
        UIEdgeInsets sectionContentInsets = [self contentInsetsForSectionAtIndex:sIdx];
        
        LWZCollectionLayoutSectionContentContainer *sectionContentContainer = [LWZCollectionLayoutSectionContentContainer.alloc initWithCollectionContentContainer:collectionContentContainer sectionEdgeSpacings:sectionEdgeSpacings sectionContentInsets:sectionContentInsets];
         
        _LWZLayoutSection *sectionLayout = [_LWZLayoutSection.alloc init];
        
        switch ( _scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                offset += sectionContentContainer.layoutInsets.top;
                
                sectionFrame.origin.y = offset;
                sectionFrame.origin.x = collectionContentContainer.layoutInsets.left + sectionContentContainer.layoutInsets.left;
                sectionFrame.size.width = sectionContentContainer.layoutRange.maximum - sectionContentContainer.layoutRange.minimum;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                offset += sectionContentContainer.layoutInsets.left;
                
                sectionFrame.origin.x = offset;
                sectionFrame.origin.y = collectionContentContainer.layoutInsets.top + sectionContentContainer.layoutInsets.top;
                sectionFrame.size.height = sectionContentContainer.layoutRange.maximum - sectionContentContainer.layoutRange.minimum;
            }
                break;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:sIdx];
        // header
        LWZCollectionViewLayoutAttributes *_Nullable header = [self layoutAttributesForSupplementaryViewWithElementKind:UICollectionElementKindSectionHeader indexPath:indexPath offset:offset container:sectionContentContainer];
        LWZCollectionViewLayoutAttributes *_Nullable headerDecoration = nil;
        if ( header != nil ) {
            sectionLayout.headerViewLayoutAttributes = header;
            offset = LWZLayoutAttributesGetMaxOffset(header, _scrollDirection);
            
            // header decoration
            headerDecoration = [self layoutAttributesForHeaderDecorationViewWithIndexPath:indexPath inRect:header.frame];
            if ( headerDecoration != nil ) sectionLayout.headerDecorationLayoutAttributes = headerDecoration;
        }
        
        // cells
        switch ( _scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                offset += sectionContentInsets.top;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                offset += sectionContentInsets.left;
                break;
        }
        
        switch ( [self layoutContentPresentationModeForCellsInSection:sIdx] ) {
            case LWZCollectionLayoutContentPresentationModeNormal: {
                NSArray<LWZCollectionViewLayoutAttributes *> *_Nullable cells = [self layoutAttributesObjectsForCellsWithSection:sIdx offset:offset container:sectionContentContainer];
                if ( cells.count != 0 ) {
                    [sectionLayout setCellLayoutAttributesObjects:cells];
                    offset = LWZLayoutAttributesGetMaxOffset(cells, _scrollDirection);
                    
                    // cell decoration
                    NSArray<LWZCollectionViewLayoutAttributes *> *_Nullable cellDecorations = [self _cellDecorationAttributesObjectsWithCellAttributesArray:cells];
                    if ( cellDecorations.count != 0 ) [sectionLayout setCellDecorationLayoutAttributesObjects:cellDecorations];
                }
            }
                break;
            case LWZCollectionLayoutContentPresentationModeCustom: {
                UIView *customView = [self layoutCustomViewForCellsWithSection:sIdx offset:offset container:sectionContentContainer];
                sectionLayout.customView = customView;
                [collectionView addSubview:customView];
                
                CGRect groupFrame = customView.frame;
                switch ( _scrollDirection ) {
                    case UICollectionViewScrollDirectionVertical:
                        offset = CGRectGetMaxY(groupFrame);
                        break;
                    case UICollectionViewScrollDirectionHorizontal:
                        offset = CGRectGetMaxX(groupFrame);
                        break;
                }
            }
                break;
        }
        
        switch ( _scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                offset += sectionContentInsets.bottom;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                offset += sectionContentInsets.right;
                break;
        }
        
        // footer
        LWZCollectionViewLayoutAttributes *_Nullable footer = [self layoutAttributesForSupplementaryViewWithElementKind:UICollectionElementKindSectionFooter indexPath:indexPath offset:offset container:sectionContentContainer];
        
        if ( footer != nil ) {
            sectionLayout.footerViewLayoutAttributes = footer;
            offset = LWZLayoutAttributesGetMaxOffset(footer, _scrollDirection);
            
            // footer decoration
            LWZCollectionViewLayoutAttributes *_Nullable footerDecoration = [self layoutAttributesForFooterDecorationViewWithIndexPath:indexPath inRect:footer.frame];
            if ( footerDecoration != nil ) sectionLayout.footerDecorationLayoutAttributes = footerDecoration;
        }
         
        switch ( _scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                sectionFrame.size.height = offset - sectionFrame.origin.y;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                sectionFrame.size.width = offset - sectionFrame.origin.x;
                break;
        }
        
        // section decoration
        LWZCollectionViewLayoutAttributes *_Nullable sectionDecoration = [self layoutAttributesForSectionDecorationViewWithIndexPath:indexPath inRect:sectionFrame];
        if ( sectionDecoration != nil ) sectionLayout.sectionDecorationLayoutAttributes = sectionDecoration;
        
        // pinned
        if ( header != nil && _layoutFlags.sectionHeadersPinToVisibleBounds && [self canPinToVisibleBoundsForHeaderInSection:sIdx] ) {
            sectionLayout.canPinToVisibleBoundsForHeader = YES;
            
            CGRect headerFrame = header.frame;
            CGRect headerPinnedFrame = [self _headerPinnedFrameForSectionFrame:sectionFrame headerFrame:headerFrame adjustedPinnedInsets:[self adjustedPinnedInsetsForSectionAtIndex:sIdx]];
            LWZCollectionViewLayoutAttributes *headerPinnedAttributes = header.copy;
            headerPinnedAttributes.zIndex = header.zIndex + 10;
            headerPinnedAttributes.frame = headerPinnedFrame;
            sectionLayout.headerViewPinnedLayoutAttributes = headerPinnedAttributes;
            
            if ( headerDecoration != nil ) {
                CGRect headerDecorationFrame = headerDecoration.frame;
                CGRect headerDecorationPinnedFrame = [self _headerDecorationPinnedFrameForHeaderFrame:headerFrame headerPinnedFrame:headerPinnedFrame headerDecorationFrame:headerDecorationFrame];
                
                LWZCollectionViewLayoutAttributes *headerDecorationPinnedAttributes = headerDecoration.copy;
                headerDecorationPinnedAttributes.zIndex = headerDecoration.zIndex + 10;
                headerDecorationPinnedAttributes.frame = headerDecorationPinnedFrame;
                sectionLayout.headerDecorationPinnedLayoutAttributes = headerDecorationPinnedAttributes;
            }
        }
        
        sectionLayout.frame = sectionFrame;
        [_mCollection addSection:sectionLayout];
        
        switch ( _scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                offset += sectionEdgeSpacings.bottom;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                offset += sectionEdgeSpacings.right;
                break;
        }
    }
    
    CGFloat contentWidth = 0;
    CGFloat contentHeight = 0;
    switch ( _scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            offset += collectionContentContainer.layoutInsets.bottom;
            
            contentHeight = offset;
            contentWidth = collectionSize.width;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            offset += collectionContentContainer.layoutInsets.right;
            
            contentWidth = offset;
            contentHeight = collectionSize.height;
        }
            break;
    }
    
    _mContentSize = CGSizeMake(contentWidth, contentHeight);
    
    [self didFinishPreparingInContainer:collectionContentContainer];
}

- (void)willPrepareLayoutInContainer:(LWZCollectionLayoutCollectionContentContainer *)container {
    if ( _layoutFlags.delegateWillPrepareLayoutInContainer ) {
        [_delegate layout:self willPrepareLayoutInContainer:container];
    }
    
    for ( id<LWZCollectionViewLayoutObserver> observer in LWZAllHashTableObjects(_mObservers) ) {
        if ( [observer respondsToSelector:@selector(layout:willPrepareLayoutInContainer:)] ) {
            [observer layout:self willPrepareLayoutInContainer:container];
        }
    }
}

- (void)didFinishPreparingInContainer:(LWZCollectionLayoutCollectionContentContainer *)container {
    if ( _layoutFlags.delegateDidFinishPreparingInContainer ) {
        [_delegate layout:self didFinishPreparingInContainer:container];
    }
    
    for ( id<LWZCollectionViewLayoutObserver> observer in LWZAllHashTableObjects(_mObservers) ) {
        if ( [observer respondsToSelector:@selector(layout:didFinishPreparingInContainer:)] ) {
            [observer layout:self didFinishPreparingInContainer:container];
        }
    }
}

- (BOOL)shouldProcessSectionLayoutAtIndex:(NSInteger)index {
    return YES;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewWithElementKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    UIFloatRange layoutRange = container.headerFooterLayoutRange;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    
    NSInteger section = indexPath.section;
    UICollectionViewScrollDirection direction = _scrollDirection;
    CGSize fittingSize = LWZCollectionLayoutFittingSizeForLayoutRange(layoutRange, direction);
    CGSize layoutSize = kind == UICollectionElementKindSectionHeader ? [self layoutSizeToFit:fittingSize forHeaderInSection:section scrollDirection:direction] : [self layoutSizeToFit:fittingSize forFooterInSection:section scrollDirection:direction];
    if ( LWZLayoutSizeIsInvalid(layoutSize, _scrollDirection) ) return nil;
    
    LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    attributes.zIndex = [self zIndexForHeaderInSection:section];
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            attributes.frame = (CGRect){layoutRange.minimum, offset, layoutSize};
            break;
        case UICollectionViewScrollDirectionHorizontal:
            attributes.frame = (CGRect){offset, layoutRange.minimum, layoutSize};;
            break;
    }
    return attributes;
}

- (LWZCollectionLayoutContentPresentationMode)layoutContentPresentationModeForCellsInSection:(NSInteger)index {
    return LWZCollectionLayoutContentPresentationModeNormal;
}

- (nullable UIView *)layoutCustomViewForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/// offset => 首个cell开始的位置, 例如: 垂直布局时, offset = preHeader.maxY + sectionContentInsets.top
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSectionDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect {
    NSString *kind = [self _elementKindForSectionDecorationAtIndexPath:indexPath];
    if ( kind.length != 0 ) {
        CGRect fitsRect = (CGRect){0, 0, rect.size};
        CGRect frame = [self _relativeRectToFit:fitsRect forSectionDecorationAtIndexPath:indexPath];
        if ( LWZLayoutSizeIsInvalid(frame.size, _scrollDirection) ) return nil;
        frame.origin.x += rect.origin.x;
        frame.origin.y += rect.origin.y;
        LWZCollectionViewLayoutAttributes *attr = [LWZCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
        attr.zIndex = [self _zIndexForSectionDecorationAtIndexPath:indexPath];
        attr.frame = frame;
        attr.decorationUserInfo = [self _userInfoForSectionDecorationAtIndexPath:indexPath];
        return attr;
    }
    return nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForHeaderDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect {
    NSString *kind = [self _elementKindForHeaderDecorationAtIndexPath:indexPath];
    if ( kind.length != 0 ) {
        CGRect fitsRect = (CGRect){0, 0, rect.size};
        CGRect frame = [self _relativeRectToFit:fitsRect forHeaderDecorationAtIndexPath:indexPath];
        if ( LWZLayoutSizeIsInvalid(frame.size, _scrollDirection) ) return nil;
        frame.origin.x += rect.origin.x;
        frame.origin.y += rect.origin.y;
        LWZCollectionViewLayoutAttributes *attr = [LWZCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
        attr.zIndex = [self _zIndexForHeaderDecorationAtIndexPath:indexPath];
        attr.frame = frame;
        attr.decorationUserInfo = [self _userInfoForHeaderDecorationAtIndexPath:indexPath];
        return attr;
    }
    return nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForCellDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect {
    NSString *kind = [self _elementKindForItemDecorationAtIndexPath:indexPath];
    if ( kind.length != 0 ) {
        CGRect fitsRect = (CGRect){0, 0, rect.size};
        CGRect frame = [self _relativeRectToFit:fitsRect forItemDecorationAtIndexPath:indexPath];
        if ( LWZLayoutSizeIsInvalid(frame.size, _scrollDirection) ) return nil;
        frame.origin.x += rect.origin.x;
        frame.origin.y += rect.origin.y;
        LWZCollectionViewLayoutAttributes *attr = [LWZCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
        attr.zIndex = [self _zIndexForItemDecorationAtIndexPath:indexPath];
        attr.frame = frame;
        attr.decorationUserInfo = [self _userInfoForItemDecorationAtIndexPath:indexPath];
        return attr;
    }
    return nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForFooterDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect {
    NSString *kind = [self _elementKindForFooterDecorationAtIndexPath:indexPath];
    if ( kind.length != 0 ) {
        CGRect fitsRect = (CGRect){0, 0, rect.size};
        CGRect frame = [self _relativeRectToFit:fitsRect forFooterDecorationAtIndexPath:indexPath];
        if ( LWZLayoutSizeIsInvalid(frame.size, _scrollDirection) ) return nil;
        frame.origin.x += rect.origin.x;
        frame.origin.y += rect.origin.y;
        LWZCollectionViewLayoutAttributes *attr = [LWZCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
        attr.zIndex = [self _zIndexForFooterDecorationAtIndexPath:indexPath];
        attr.frame = frame;
        attr.decorationUserInfo = [self _userInfoForFooterDecorationAtIndexPath:indexPath];
        return attr;
    }
    return nil;
}
  
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)_cellDecorationAttributesObjectsWithCellAttributesArray:(NSArray<LWZCollectionViewLayoutAttributes *> *)cellAttributes {
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *m = [[NSMutableArray alloc] initWithCapacity:cellAttributes.count];
    for ( LWZCollectionViewLayoutAttributes *cell in cellAttributes ) {
        LWZCollectionViewLayoutAttributes *attr = [self layoutAttributesForCellDecorationViewWithIndexPath:cell.indexPath inRect:cell.frame];
        if ( attr == nil ) continue;;
        [m addObject:attr];
    }
    return m.count != 0 ? m.copy : nil;
}
 
#pragma mark - mark


- (UIEdgeInsets)edgeSpacingsForSectionAtIndex:(NSInteger)section {
    if ( _layoutFlags.delegateEdgeSpacingsForSection ) {
        return [_delegate layout:self edgeSpacingsForSectionAtIndex:section];
    }
    return UIEdgeInsetsZero;
}

- (UIEdgeInsets)contentInsetsForSectionAtIndex:(NSInteger)section {
    if ( _layoutFlags.delegateContentInsetsForSection ) {
        return [_delegate layout:self contentInsetsForSectionAtIndex:section];
    }
    return UIEdgeInsetsZero;
}

- (UIEdgeInsets)adjustedPinnedInsetsForSectionAtIndex:(NSInteger)section {
    if ( _layoutFlags.delegateAdjustedPinnedInsets ) {
        return [_delegate layout:self adjustedPinnedInsetsForSectionAtIndex:section];
    }
    return _adjustedPinnedInsets;
}

- (BOOL)canPinToVisibleBoundsForHeaderInSection:(NSInteger)section {
    if ( _layoutFlags.sectionHeadersPinToVisibleBounds && _layoutFlags.delegateCanPinToVisibleBoundsForHeader ) {
        return [_delegate layout:self canPinToVisibleBoundsForHeaderInSection:section];
    }
    return _layoutFlags.sectionHeadersPinToVisibleBounds;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    if ( _layoutFlags.delegateSizeForHeader ) {
        CGSize size = [_delegate layout:self layoutSizeToFit:fittingSize forHeaderInSection:section scrollDirection:scrollDirection];
        return LWZLayoutSizeHeaderFooterAdjusting(size, fittingSize, scrollDirection);
    }
    return CGSizeZero;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    if ( _layoutFlags.delegateSizeForItem ) {
        CGSize size = [_delegate layout:self layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
        return LWZLayoutSizeItemAdjusting(size, fittingSize, scrollDirection);
    }
    return CGSizeZero;
}
 
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    if ( _layoutFlags.delegateSizeForFooter ) {
        CGSize size = [_delegate layout:self layoutSizeToFit:fittingSize forFooterInSection:section scrollDirection:scrollDirection];
        return LWZLayoutSizeHeaderFooterAdjusting(size, fittingSize, scrollDirection);
    }
    return CGSizeZero;
}

- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ( _layoutFlags.delegateLineSpacingForSection ) {
        return [_delegate layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return 0;
}

- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ( _layoutFlags.delegateInteritemSpacingForSection ) {
        return [_delegate layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return 0;
}

- (nullable NSString *)_elementKindForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateElementKindForSectionDecoration ) {
        return [_delegate layout:self elementKindForSectionDecorationAtIndexPath:indexPath];
    }
    return nil;
}

- (CGRect)_relativeRectToFit:(CGRect)rect forSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateRelativeRectForSectionDecoration ) {
        return [_delegate layout:self relativeRectToFit:rect forSectionDecorationAtIndexPath:indexPath];
    }
    return CGRectZero;
}

- (nullable NSString *)_elementKindForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateElementKindForHeaderDecoration ) {
        return [_delegate layout:self elementKindForHeaderDecorationAtIndexPath:indexPath];
    }
    return nil;
}

- (CGRect)_relativeRectToFit:(CGRect)rect forHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateRelativeRectForHeaderDecoration ) {
        return [_delegate layout:self relativeRectToFit:rect forHeaderDecorationAtIndexPath:indexPath];
    }
    return CGRectZero;
}
 
- (nullable NSString *)_elementKindForItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateElementKindForItemDecoration ) {
        return [_delegate layout:self elementKindForItemDecorationAtIndexPath:indexPath];
    }
    return nil;
}

- (CGRect)_relativeRectToFit:(CGRect)rect forItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateRelativeRectForItemDecoration ) {
        return [_delegate layout:self relativeRectToFit:rect forItemDecorationAtIndexPath:indexPath];
    }
    return CGRectZero;
}

- (nullable NSString *)_elementKindForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateElementKindForFooterDecoration ) {
        return [_delegate layout:self elementKindForFooterDecorationAtIndexPath:indexPath];
    }
    return nil;
}

- (CGRect)_relativeRectToFit:(CGRect)rect forFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateRelativeRectForFooterDecoration ) {
        return [_delegate layout:self relativeRectToFit:rect forFooterDecorationAtIndexPath:indexPath];
    }
    return CGRectZero;
}

- (CGFloat)zIndexForHeaderInSection:(NSInteger)section {
    if ( _layoutFlags.delegateZIndexForHeader ) {
        return [_delegate layout:self zIndexForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)zIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateZIndexForItem ) {
        return [_delegate layout:self zIndexForItemAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)zIndexForFooterInSection:(NSInteger)section {
    if ( _layoutFlags.delegateZIndexForFooter ) {
        return [_delegate layout:self zIndexForFooterInSection:section];
    }
    return 0;
}

- (CGFloat)_zIndexForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateZIndexForSectionDecoration ) {
        return [_delegate layout:self zIndexForSectionDecorationAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)_zIndexForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateZIndexForHeaderDecoration ) {
        return [_delegate layout:self zIndexForHeaderDecorationAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)_zIndexForItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateZIndexForItemDecoration ) {
        return [_delegate layout:self zIndexForItemDecorationAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)_zIndexForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateZIndexForFooterDecoration ) {
        return [_delegate layout:self zIndexForFooterDecorationAtIndexPath:indexPath];
    }
    return 0;
}

- (nullable id)_userInfoForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateUserInfoForSectionDecoration ) {
        return [_delegate layout:self userInfoForSectionDecorationAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable id)_userInfoForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateUserInfoForHeaderDecoration ) {
        return [_delegate layout:self userInfoForHeaderDecorationAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable id)_userInfoForItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateUserInfoForItemDecoration ) {
        return [_delegate layout:self userInfoForItemDecorationAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable id)_userInfoForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateUserInfoForFooterDecoration ) {
        return [_delegate layout:self userInfoForFooterDecorationAtIndexPath:indexPath];
    }
    return nil;
}

- (CGRect)_headerPinnedFrameForSectionFrame:(CGRect)sectionFrame headerFrame:(CGRect)headerFrame adjustedPinnedInsets:(UIEdgeInsets)adjustedPinnedInsets {
    UICollectionView *collectionView = self.collectionView;
    CGPoint contentOffset = collectionView.contentOffset;
    CGFloat pinnedX = headerFrame.origin.x;
    CGFloat pinnedY = headerFrame.origin.y;
    /// collectionView的偏移量(需要根据滚动方向设置值`switch{}`中设置)
    CGFloat offset = 0;
    switch ( _scrollDirection ) {
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
    switch ( _scrollDirection ) {
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



#pragma mark - WeightLayout
 
@implementation LWZCollectionViewLayout (WeightLayout)

UIKIT_STATIC_INLINE CGSize
_LWZCollectionWeightLayoutFittingSize(CGFloat weight, CGSize fittingSize, NSInteger arranged, CGFloat itemSpacing, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            return CGSizeMake((fittingSize.width - ((arranged - 1) * itemSpacing)) * weight, fittingSize.height);
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake(fittingSize.width, (fittingSize.height - ((arranged - 1) * itemSpacing)) * weight);
    }
}

- (id<LWZCollectionWeightLayoutDelegate>)weight_layout_delegate {
    return (id)_delegate;
}

- (CGFloat)_weightForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateWeightForItem ) {
        return [self.weight_layout_delegate layout:(id)self weightForItemAtIndexPath:indexPath];
    }
    return 1;
}

// offset => 首个cell开始的位置, 例如: 垂直布局时, offset = preHeader.maxY + section.top
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)_weight_layout_layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.itemLayoutRange;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;
    
    /*

     item layouts
     |-----------|
     |-----|-----|
     |---|---|---|

     */
    CGSize fittingSize = LWZCollectionLayoutFittingSizeForLayoutRange(layoutRange, scrollDirection);
    CGFloat lineSpacing = [self minimumLineSpacingForSectionAtIndex:section];
    CGFloat itemSpacing = [self minimumInteritemSpacingForSectionAtIndex:section];
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesArray = [NSMutableArray.alloc initWithCapacity:numberOfItems];
    LWZCollectionViewLayoutAttributes *previousItemAttributes = nil;
    LWZCollectionViewLayoutAttributes *firstItemAttributes = nil;
    CGFloat progress = 0;
    for ( NSInteger i = 0 ; i < numberOfItems ; ++ i ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        CGFloat weight = [self _weightForItemAtIndexPath:indexPath];
        NSParameterAssert(weight > 0 && weight <= 1);
        
        // newline
        CGFloat cur = progress + weight;
        BOOL isFirstItem = firstItemAttributes == nil || cur > 1;
        BOOL isNewline = isFirstItem && firstItemAttributes != nil;
        progress = isFirstItem ? weight : cur;
        
        if ( isNewline ) {
            switch ( scrollDirection ) {
                case UICollectionViewScrollDirectionVertical:
                    offset = CGRectGetMaxY(previousItemAttributes.frame) + lineSpacing;
                    break;
                case UICollectionViewScrollDirectionHorizontal:
                    offset = CGRectGetMaxX(previousItemAttributes.frame) + lineSpacing;
                    break;
            }
        }

        NSInteger arranges = 1.0 / weight;
        CGSize itemFittingSize = _LWZCollectionWeightLayoutFittingSize(weight, fittingSize, arranges, itemSpacing, scrollDirection);
        CGSize layoutSize = [self layoutSizeToFit:itemFittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
        
        CGRect frame = (CGRect){0, 0, layoutSize};
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                frame.origin.x = isFirstItem ? layoutRange.minimum : CGRectGetMaxX(previousItemAttributes.frame) + itemSpacing;
                frame.origin.y = offset;
                // fix size
                // 同行item的高度与行首item一致
                if ( !isFirstItem ) frame.size.height = firstItemAttributes.frame.size.height;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                frame.origin.x = offset;
                frame.origin.y = isFirstItem ? layoutRange.minimum : CGRectGetMaxY(previousItemAttributes.frame) + itemSpacing;
                // fix size
                // 同行item的宽度与行首item一致
                if ( !isFirstItem ) frame.size.width = firstItemAttributes.frame.size.width;
            }
                break;
        }
        
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [self zIndexForItemAtIndexPath:indexPath];
        attributes.frame = frame;
        [attributesArray addObject:attributes];
        previousItemAttributes = attributes;
        if ( isFirstItem ) firstItemAttributes = attributes;
    }
    
    return attributesArray;
}
@end

@implementation LWZCollectionWeightLayout
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    return [self _weight_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
}
@end

#pragma mark - ListLayout

@implementation LWZCollectionViewLayout (ListLayout)
- (id<LWZCollectionListLayoutDelegate>)list_layout_delegate {
    return (id)_delegate;
}

- (LWZCollectionLayoutAlignment)layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( _layoutFlags.delegateAlignmentForItem ) {
        return [self.list_layout_delegate layout:self layoutAlignmentForItemAtIndexPath:indexPath];
    }
    return LWZCollectionLayoutAlignmentCenter;
}

// offset => 首个cell开始的位置, 例如: 垂直布局时, offset = preHeader.maxY + section.top
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)_list_layout_layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.itemLayoutRange;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;

    CGFloat lineSpacing = [self minimumLineSpacingForSectionAtIndex:section];
    CGSize fittingSize = LWZCollectionLayoutFittingSizeForLayoutRange(layoutRange, scrollDirection);
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesArray = [NSMutableArray.alloc initWithCapacity:numberOfItems];
    CGRect previousFrame = CGRectZero;
    switch ( scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            previousFrame.origin.x = layoutRange.minimum;
            previousFrame.origin.y = offset - lineSpacing;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            previousFrame.origin.x = offset - lineSpacing;
            previousFrame.origin.y = layoutRange.minimum;
        }
            break;
    }
 
    CGFloat length = layoutRange.maximum - layoutRange.minimum;
    for ( NSInteger curIdx = 0 ; curIdx < numberOfItems ; ++ curIdx ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:curIdx inSection:section];
        CGSize layoutSize = [self layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
        
        CGRect frame = (CGRect){0, 0, layoutSize};
        LWZCollectionLayoutAlignment alignment = [self layoutAlignmentForItemAtIndexPath:indexPath];
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                frame.origin.y = CGRectGetMaxY(previousFrame) + lineSpacing;
                switch ( alignment ) {
                        // 左对齐
                    case LWZCollectionLayoutAlignmentStart: {
                        frame.origin.x = layoutRange.minimum;
                    }
                        break;
                        // 右对齐
                    case LWZCollectionLayoutAlignmentEnd: {
                        frame.origin.x = layoutRange.minimum + length - frame.size.width;
                    }
                        break;
                        // 中对齐
                    case LWZCollectionLayoutAlignmentCenter: {
                        frame.origin.x = layoutRange.minimum + (length - frame.size.width) * 0.5;
                    }
                        break;
                }
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                frame.origin.x = CGRectGetMaxX(previousFrame) + lineSpacing;
                switch ( alignment ) {
                        // 顶对齐
                    case LWZCollectionLayoutAlignmentStart: {
                        frame.origin.y = layoutRange.minimum;
                    }
                        break;
                        // 底对齐
                    case LWZCollectionLayoutAlignmentEnd: {
                        frame.origin.y = layoutRange.minimum + length - frame.size.height;
                    }
                        break;
                        // 中对齐
                    case LWZCollectionLayoutAlignmentCenter: {
                        frame.origin.y = layoutRange.minimum + (length - frame.size.height) * 0.5;
                    }
                        break;
                }
            }
                break;
        }
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [self zIndexForItemAtIndexPath:indexPath];
        attributes.frame = frame;
        [attributesArray addObject:attributes];
        
        previousFrame = frame;
     }
    return attributesArray;
}
@end

@implementation LWZCollectionListLayout
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    return [self _list_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
}
@end

#pragma mark - WaterfallFlowLayout

@implementation LWZCollectionViewLayout(WaterfallFlowLayout)
- (id<LWZCollectionWaterfallFlowLayoutDelegate>)waterfall_flow_layout_delegate {
    return (id)_delegate;
}

- (NSInteger)_numberOfArrangedItemsPerLineInSection:(NSInteger)section {
    if ( _layoutFlags.delegateNumberOfArrangedItemsPerLineInSection ) {
        return [self.waterfall_flow_layout_delegate layout:self numberOfArrangedItemsPerLineInSection:section];
    }
    return 1;
}

// offset => 首个cell开始的位置, 例如: 垂直布局时, offset = preHeader.maxY + section.top
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)_waterfall_flow_layout_layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    /*
     
     item layouts
     |  |  |__|
     |__|  |  |
     |  |__|  |
     |  |  |__|
     |__|__|  |
     */
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.itemLayoutRange;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;

    CGFloat lineSpacing = [self minimumLineSpacingForSectionAtIndex:section];
    CGFloat itemSpacing = [self minimumInteritemSpacingForSectionAtIndex:section];
    NSInteger arrangements = [self _numberOfArrangedItemsPerLineInSection:section];
    NSParameterAssert(arrangements > 0);
    CGSize fittingSize = _LWZCollectionWaterfallFlowLayoutFittingSize(LWZCollectionLayoutFittingSizeForLayoutRange(layoutRange, scrollDirection), arrangements, itemSpacing, scrollDirection);
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesArray = [NSMutableArray.alloc initWithCapacity:numberOfItems];
    CGFloat columns[arrangements];
    _LWZCollectionWaterfallFlowLayoutInitColumns(columns, arrangements, offset - lineSpacing);
    for ( NSInteger curIdx = 0 ; curIdx < numberOfItems ; ++ curIdx ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:curIdx inSection:section];
        CGSize layoutSize = [self layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
        
        NSInteger minOffsetIndex = _LWZCollectionWaterfallFlowLayoutGetMinOffsetColumnIndex(columns, arrangements);
        offset = columns[minOffsetIndex];
        CGRect frame = (CGRect){0, 0, layoutSize};
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                frame.origin.x = layoutRange.minimum + minOffsetIndex * (fittingSize.width + itemSpacing);
                frame.origin.y = offset + lineSpacing;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                frame.origin.x = offset + lineSpacing;
                frame.origin.y = layoutRange.minimum + minOffsetIndex * (fittingSize.height + itemSpacing);
            }
                break;
        }
        _LWZCollectionWaterfallFlowLayoutSetColumnOffset(columns, minOffsetIndex, frame, scrollDirection);
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [self zIndexForItemAtIndexPath:indexPath];
        attributes.frame = frame;
        [attributesArray addObject:attributes];
    }
    return attributesArray;
}

UIKIT_STATIC_INLINE CGSize
_LWZCollectionWaterfallFlowLayoutFittingSize(CGSize bounds, NSInteger arrangements, CGFloat itemSpacing, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            return CGSizeMake((bounds.width - (arrangements - 1) * itemSpacing) / arrangements, bounds.height);
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake(bounds.width, (bounds.height - (arrangements - 1) * itemSpacing) / arrangements);
    }
}

UIKIT_STATIC_INLINE void
_LWZCollectionWaterfallFlowLayoutInitColumns(CGFloat *columns, NSInteger arrangements, CGFloat offset) {
    for ( NSInteger i = 0 ; i < arrangements ; ++ i ) columns[i] = offset;
}

UIKIT_STATIC_INLINE NSInteger
_LWZCollectionWaterfallFlowLayoutGetMinOffsetColumnIndex(CGFloat *columns, NSInteger arrangements) {
    NSInteger index = 0;
    CGFloat min = CGFLOAT_MAX;
    for ( NSInteger i = 0 ; i < arrangements ; ++ i ) {
        if ( min > columns[i] ) {
            min = columns[i];
            index = i;
        }
    }
    return index;
}

UIKIT_STATIC_INLINE void
_LWZCollectionWaterfallFlowLayoutSetColumnOffset(CGFloat *columns, NSInteger index, CGRect itemFrame, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            columns[index] = CGRectGetMaxY(itemFrame);
            break;
        case UICollectionViewScrollDirectionHorizontal:
            columns[index] = CGRectGetMaxX(itemFrame);
            break;
    }
}
@end

@implementation LWZCollectionWaterfallFlowLayout
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    return [self _waterfall_flow_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
}
@end

#pragma mark - RestrictedLayout

@implementation LWZCollectionViewLayout(RestrictedLayout)
// offset => 首个cell开始的位置, 例如: 垂直布局时, offset = preHeader.maxY + section.top
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)_restricted_layout_layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.itemLayoutRange;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;
    /*
     
     item layouts
     |-----------|
     |-----|-|--|
     |---|---|---|
     |--|-|----|
     
     */
    CGFloat lineSpacing = [self minimumLineSpacingForSectionAtIndex:section];
    CGFloat itemSpacing = [self minimumInteritemSpacingForSectionAtIndex:section];
    CGSize fittingSize = LWZCollectionLayoutFittingSizeForLayoutRange(layoutRange, scrollDirection);
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesArray = [NSMutableArray.alloc initWithCapacity:numberOfItems];
    CGRect previousFrame = CGRectZero;
    switch ( scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            previousFrame.origin.x = layoutRange.minimum - itemSpacing;
            previousFrame.origin.y = offset - lineSpacing;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            previousFrame.origin.x = offset - lineSpacing;
            previousFrame.origin.y = layoutRange.minimum - itemSpacing;
        }
            break;
    }
    
    // 每行的第一个item
    LWZCollectionViewLayoutAttributes *firstItemAttributes = nil;
    for ( NSInteger curIdx = 0 ; curIdx < numberOfItems ; ++ curIdx ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:curIdx inSection:section];
        CGSize layoutSize = [self layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
        
        CGRect frame = (CGRect){0, 0, layoutSize};
        BOOL isFirstItem = NO;
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                CGFloat left = CGRectGetMaxX(previousFrame) + itemSpacing;
                CGFloat maxX = left + layoutSize.width;
                if ( firstItemAttributes == nil || maxX > layoutRange.maximum ) {
                    // new line
                    frame.origin.x = layoutRange.minimum;
                    frame.origin.y = CGRectGetMaxY(previousFrame) + lineSpacing;
                    isFirstItem = YES;
                }
                else {
                    // current line
                    frame.origin.x = left;
                    frame.origin.y = CGRectGetMinY(previousFrame);
                    // fix size
                    // 每行item的高度与行首item一致
                    frame.size.height = firstItemAttributes.frame.size.height;
                }
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                CGFloat top = CGRectGetMaxY(previousFrame) + itemSpacing;
                CGFloat maxY = top + layoutSize.height;
                // new line
                if ( firstItemAttributes == nil || maxY > layoutRange.maximum ) {
                    frame.origin.x = CGRectGetMaxX(previousFrame) + lineSpacing;
                    frame.origin.y = layoutRange.minimum;
                    isFirstItem = YES;
                }
                else {
                    // current line
                    frame.origin.x = CGRectGetMinX(previousFrame);
                    frame.origin.y = top;
                    // fix size
                    // 每行item的宽度度与行首item一致
                    frame.size.width = firstItemAttributes.frame.size.width;
                }
            }
                break;
        }
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [self zIndexForItemAtIndexPath:indexPath];
        attributes.frame = frame;
        [attributesArray addObject:attributes];
        
        previousFrame = frame;
        if ( isFirstItem ) firstItemAttributes = attributes;
    }
    return attributesArray;
}
@end

@implementation LWZCollectionRestrictedLayout
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    return [self _restricted_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
}
@end
 

#pragma mark - template layout

@implementation LWZCollectionViewLayout(TemplateLayout)
- (id<LWZCollectionTemplateLayoutDelegate>)template_layout_delegate {
    return (id)_delegate;
}

- (NSArray<LWZCollectionLayoutTemplateGroup *> *)_layoutTemplateGroupsInSection:(NSInteger)section {
    return [self.template_layout_delegate layout:self layoutTemplateContainerGroupsInSection:section];
}

// offset => 首个cell开始的位置, 例如: 垂直布局时, offset = preHeader.maxY + section.top
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)_template_layout_layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.itemLayoutRange;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;

    NSArray<LWZCollectionLayoutTemplateGroup *> *groups = [self _layoutTemplateGroupsInSection:section];
    NSAssert(groups != nil, @"The template groups can't be nil!");
    
    CGFloat lineSpacing = [self minimumLineSpacingForSectionAtIndex:section];
    CGFloat itemSpacing = [self minimumInteritemSpacingForSectionAtIndex:section];
    
    LWZCollectionTemplateLayoutSolver *solver = [LWZCollectionTemplateLayoutSolver.alloc initWithGroups:groups scrollDirection:scrollDirection numberOfItems:numberOfItems lineSpacing:lineSpacing itemSpacing:itemSpacing containerSize:container.itemLayoutContainerSize];
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesArray = [NSMutableArray.alloc initWithCapacity:numberOfItems];
    // 将cell填充到模板中
    for ( NSInteger i = 0 ; i < numberOfItems ; ++ i ) {
        CGRect frame = [solver itemLayoutFrameAtIndex:i];
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                frame.origin.y += offset;
                frame.origin.x += layoutRange.minimum;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                frame.origin.x += offset;
                frame.origin.y += layoutRange.minimum;
            }
                break;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [self zIndexForItemAtIndexPath:indexPath];
        attributes.frame = frame;
        [attributesArray addObject:attributes];
    }
    return attributesArray;
}
@end

@implementation LWZCollectionTemplateLayout
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    return [self _template_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
}
@end

#pragma mark - hybrid layout

@implementation LWZCollectionHybridLayout

- (id<LWZCollectionHybridLayoutDelegate>)hybrid_layout_delegate {
    return (id)self.delegate;
}

- (LWZCollectionLayoutType)_layoutTypeForItemsInSection:(NSInteger)section {
    return [self.hybrid_layout_delegate layout:self layoutTypeForItemsInSection:section];
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    switch ( [self _layoutTypeForItemsInSection:section] ) {
        case LWZCollectionLayoutTypeUnspecified:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You must specify a layout!"
                                         userInfo:nil];
        case LWZCollectionLayoutTypeWeight:
            return [self _weight_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
        case LWZCollectionLayoutTypeList:
            return [self _list_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
        case LWZCollectionLayoutTypeWaterfallFlow:
            return [self _waterfall_flow_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
        case LWZCollectionLayoutTypeRestrictedLayout:
            return [self _restricted_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
        case LWZCollectionLayoutTypeTemplate:
            return [self _template_layout_layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
    }
}

@end

#pragma mark - compositional layout

@interface LWZCollectionNestedGroupLayout : LWZCollectionViewLayout
- (instancetype)initWithParentLayout:(__weak LWZCollectionCompositionalLayout *)parentLayout inSection:(NSInteger)idx scrollDirection:(UICollectionViewScrollDirection)scrollDirection orthogonalScrollingBehavior:(LWZCollectionLayoutContentOrthogonalScrollingBehavior)behavior;
@end
 
@implementation LWZCollectionNestedGroupLayout {
    NSInteger mSectionIdx;
    
    __weak LWZCollectionCompositionalLayout *mParentLayout;
    LWZCollectionLayoutContentOrthogonalScrollingBehavior mBehavior;
}

- (instancetype)initWithParentLayout:(__weak LWZCollectionCompositionalLayout *)parentLayout inSection:(NSInteger)idx scrollDirection:(UICollectionViewScrollDirection)scrollDirection orthogonalScrollingBehavior:(LWZCollectionLayoutContentOrthogonalScrollingBehavior)behavior {
    self = [super initWithScrollDirection:scrollDirection delegate:parentLayout.delegate];
    if ( self ) {
        mSectionIdx = idx;
        mParentLayout = parentLayout;
        mBehavior = behavior;
        if (@available(iOS 11.0, *)) {
            self.ignoredSafeAreaInsets = YES;
        }
    }
    return self;
}

- (void)willPrepareLayoutInContainer:(LWZCollectionLayoutCollectionContentContainer *)container { }

- (void)didFinishPreparingInContainer:(LWZCollectionLayoutCollectionContentContainer *)container { }

- (BOOL)shouldProcessSectionLayoutAtIndex:(NSInteger)index {
    return index == mSectionIdx;
}

- (UIEdgeInsets)edgeSpacingsForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (UIEdgeInsets)contentInsetsForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewWithElementKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    return nil;
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    if ( section == mSectionIdx ) {
        return [mParentLayout layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
    }
    return nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSectionDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect { return nil; }
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForHeaderDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect { return nil; }
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForFooterDecorationViewWithIndexPath:(NSIndexPath *)indexPath inRect:(CGRect)rect { return nil; }

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    switch ( mBehavior ) {
        case LWZCollectionLayoutContentOrthogonalScrollingBehaviorNormal:
            return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
        case LWZCollectionLayoutContentOrthogonalScrollingBehaviorContinuousCentered:
        case LWZCollectionLayoutContentOrthogonalScrollingBehaviorPaging: {
            UICollectionView *collectionView = self.collectionView;
            CGRect bounds = collectionView.bounds;
            CGPoint contentOffset = mBehavior == LWZCollectionLayoutContentOrthogonalScrollingBehaviorContinuousCentered ? proposedContentOffset : collectionView.contentOffset;
            // 计算参考线
            CGFloat refLine = 0;
            switch ( _scrollDirection ) {
                case UICollectionViewScrollDirectionVertical: {
                    if ( fabs(velocity.y) < 0.35 ) {
                        refLine = contentOffset.y + bounds.size.height * 0.5;
                    }
                    // 向上拖拽
                    else if ( velocity.y > 0 ) {
                        refLine = contentOffset.y + bounds.size.height;
                    }
                    // 向下拖拽
                    else {
                        refLine = contentOffset.y;
                    }
                }
                    break;
                case UICollectionViewScrollDirectionHorizontal: {
                    if ( fabs(velocity.x) < 0.35 ) {
                        refLine = contentOffset.x + bounds.size.width * 0.5;
                    }
                    // 向左拖拽
                    else if ( velocity.x > 0 ) {
                        refLine = contentOffset.x + bounds.size.width;
                    }
                    // 向右拖拽
                    else {
                        refLine = contentOffset.x;
                    }
                }
                    break;
            }
            return [self _targetContentOffsetForRefLine:refLine proposedContentOffset:proposedContentOffset];
        }
            break;
    }
}

- (CGPoint)_targetContentOffsetForRefLine:(CGFloat)refLine proposedContentOffset:(CGPoint)proposedContentOffset {
    // 查找距离 refline 最近的 cell
    CGFloat curMinOffset = CGFLOAT_MAX;
    LWZCollectionViewLayoutAttributes *finalAttributes = nil;
    for ( LWZCollectionViewLayoutAttributes *attributes in _mCollection.sections.firstObject.cellLayoutAttributesObjects ) {
        CGRect frame = attributes.frame;
        CGFloat midOffset = 0;
        switch ( _scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                midOffset = CGRectGetMidY(frame);
                break;
            case UICollectionViewScrollDirectionHorizontal:
                midOffset = CGRectGetMidX(frame);
                break;
        }
        CGFloat sub = floor(ABS(refLine - midOffset));
        if ( sub < curMinOffset ) {
            finalAttributes = attributes;
            curMinOffset = sub;
        }
    }
    
    UICollectionView *collectionView = self.collectionView;
    UIEdgeInsets contentInset = collectionView.contentInset;
    CGSize contentSize = _mContentSize;
    CGRect bounds = collectionView.bounds;
    switch ( _scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            CGFloat offsetY = CGRectGetMidY(finalAttributes.frame) - bounds.size.height * 0.5;
            CGFloat minY = -contentInset.top;
            CGFloat maxY = contentSize.height - bounds.size.height * 0.5;
            if ( offsetY < minY )
                offsetY = minY;
            else if ( offsetY > maxY )
                offsetY = maxY;
            proposedContentOffset.y = offsetY;
            return proposedContentOffset;
        }
        case UICollectionViewScrollDirectionHorizontal: {
            CGFloat offsetX = CGRectGetMidX(finalAttributes.frame) - bounds.size.width * 0.5;
            CGFloat minX = -contentInset.left;
            CGFloat maxX = contentSize.width - bounds.size.width * 0.5;
            if ( offsetX < minX )
                offsetX = minX;
            else if ( offsetX > maxX )
                offsetX = maxX;
            proposedContentOffset.x = offsetX;
            return proposedContentOffset;
        }
    }
}
@end

UIKIT_STATIC_INLINE CGSize
LWZLayoutSizeGroupAdjusting(CGSize size, CGSize fittingSize, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            size.width = fittingSize.width;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            size.height = fittingSize.height;
            break;
    }
    return size;
}

@implementation LWZCollectionCompositionalLayout {
    struct {
        unsigned delegateIsOrthogonalScrollingInSection :1;
        unsigned delegateOrthogonalContentScrollingBehaviorInSection :1;
    } _compositionalLayoutFlags;
}

- (void)setDelegate:(id<LWZCollectionCompositionalLayoutDelegate>)delegate {
    if ( delegate != self.delegate ) {
        [super setDelegate:delegate];
        _compositionalLayoutFlags.delegateIsOrthogonalScrollingInSection = [delegate respondsToSelector:@selector(layout:isOrthogonalScrollingInSection:)];
        _compositionalLayoutFlags.delegateOrthogonalContentScrollingBehaviorInSection = [delegate respondsToSelector:@selector(layout:orthogonalContentScrollingBehaviorInSection:)];
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    for ( _LWZLayoutSection *section in _mCollection.sections ) {
        UICollectionView *groupView = section.customView;
        if ( groupView != nil ) {
            BOOL needsHidden = LWZRectFloatRangeCompare(groupView.frame, newBounds, _scrollDirection) != LWZFloatRangeComparisonResultIntersecting;
            groupView.hidden = needsHidden;
        }
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

- (id<LWZCollectionCompositionalLayoutDelegate>)compositional_layout_delegate {
    return (id)self.delegate;
}

- (BOOL)isOrthogonalScrollingInSection:(NSInteger)section {
    if ( _compositionalLayoutFlags.delegateIsOrthogonalScrollingInSection ) {
        return [self.compositional_layout_delegate layout:self isOrthogonalScrollingInSection:section];
    }
    return NO;
}

- (nullable __kindof UICollectionViewCell *)orthogonalScrollingCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section < _mCollection.sections.count ) {
        _LWZLayoutSection *section = _mCollection.sections[indexPath.section];
        return section.customView != nil ? [section.customView cellForItemAtIndexPath:indexPath] : nil;
    }
    return nil;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forOrthogonalContentInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [self.compositional_layout_delegate layout:self layoutSizeToFit:fittingSize forOrthogonalContentInSection:section scrollDirection:scrollDirection];
}

- (LWZCollectionLayoutContentOrthogonalScrollingBehavior)_orthogonalContentScrollingBehaviorInSection:(NSInteger)section {
    if ( _compositionalLayoutFlags.delegateOrthogonalContentScrollingBehaviorInSection ) {
        return [self.compositional_layout_delegate layout:self orthogonalContentScrollingBehaviorInSection:section];
    }
    return LWZCollectionLayoutContentOrthogonalScrollingBehaviorNormal;
}
 
- (LWZCollectionLayoutContentPresentationMode)layoutContentPresentationModeForCellsInSection:(NSInteger)index {
    return [self isOrthogonalScrollingInSection:index] ? LWZCollectionLayoutContentPresentationModeCustom : LWZCollectionLayoutContentPresentationModeNormal;
}
// 包裹所有 cell 的容器.
- (nullable UIView *)layoutCustomViewForCellsWithSection:(NSInteger)sIdx offset:(CGFloat)offset container:(LWZCollectionLayoutSectionContentContainer *)container {
    LWZCollectionLayoutCollectionContentContainer *collectionContentContainer = container.collectionContentContainer;
    LWZCollectionLayoutSectionContentContainer *sectionContentContainer = container;
    UICollectionView *collectionView = self.collectionView;
    UIFloatRange layoutRange = sectionContentContainer.itemLayoutRange;
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:sIdx];
    if ( numberOfItems != 0 && layoutRange.maximum > layoutRange.minimum ) {
        UICollectionViewScrollDirection groupViewScrollDirection = _scrollDirection == UICollectionViewScrollDirectionVertical ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;

        CGSize collectionSize = collectionContentContainer.collectionSize;
        CGSize contentFittingSize = LWZCollectionLayoutFittingSizeForLayoutRange(layoutRange, _scrollDirection);
        CGSize contentLayoutSize = [self layoutSizeToFit:contentFittingSize forOrthogonalContentInSection:sIdx scrollDirection:groupViewScrollDirection];
        contentLayoutSize = LWZLayoutSizeGroupAdjusting(contentLayoutSize, contentFittingSize, _scrollDirection);
        UIEdgeInsets contentInsets = container.contentInsets;
        UIEdgeInsets groupInsets = UIEdgeInsetsZero;
        CGRect groupFrame = CGRectZero;
        switch ( _scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                groupFrame.origin.y = offset;
                groupFrame.origin.x = 0;
                groupFrame.size.width = collectionSize.width;
                groupFrame.size.height = contentLayoutSize.height;
                groupInsets.left = collectionContentContainer.layoutInsets.left + sectionContentContainer.layoutInsets.left + contentInsets.left;
                groupInsets.right = collectionContentContainer.layoutInsets.right + sectionContentContainer.layoutInsets.right + contentInsets.right;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                groupFrame.origin.x = offset;
                groupFrame.origin.y = 0;
                groupFrame.size.height = collectionSize.height;
                groupFrame.size.width = contentLayoutSize.width;
                groupInsets.top = collectionContentContainer.layoutInsets.top + sectionContentContainer.layoutInsets.top + contentInsets.top;
                groupInsets.bottom = collectionContentContainer.layoutInsets.bottom + sectionContentContainer.layoutInsets.bottom + contentInsets.bottom;
            }
                break;
        }
        
        LWZCollectionLayoutContentOrthogonalScrollingBehavior behavior = [self _orthogonalContentScrollingBehaviorInSection:sIdx];
        UICollectionView *groupView = [UICollectionView.alloc initWithFrame:groupFrame collectionViewLayout:[LWZCollectionNestedGroupLayout.alloc initWithParentLayout:self inSection:sIdx scrollDirection:groupViewScrollDirection orthogonalScrollingBehavior:behavior]];
        groupView.contentInset = groupInsets;
        groupView.backgroundColor = UIColor.clearColor;
        groupView.dataSource = collectionView.dataSource;
        groupView.delegate = collectionView.delegate;
        groupView.hidden = LWZRectFloatRangeCompare(groupFrame, collectionView.bounds, _scrollDirection) != LWZFloatRangeComparisonResultIntersecting;
        groupView.showsHorizontalScrollIndicator = NO;
        groupView.showsVerticalScrollIndicator = NO;
        groupView.layer.zPosition = LWZCollectionOrthogonalScrollingGroupViewZPosition;
        if ( behavior == LWZCollectionLayoutContentOrthogonalScrollingBehaviorPaging ) {
            groupView.decelerationRate = UIScrollViewDecelerationRateFast;
        }
        if (@available(iOS 11.0, *)) {
            groupView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        return groupView;
    }
    return nil;
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
 
 
 layoutInsets: 内容布局边缘间距
 layoutRange: 内容布局范围限制
 
 */
#endif
