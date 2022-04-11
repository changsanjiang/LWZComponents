//
//  LWZCollectionLayoutCollection.m
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/11.
//

#import "LWZCollectionLayoutCollection.h"
#import "UIFloatRange+LWZCollectionAdditions.h"

@implementation LWZCollectionLayoutCollection {
    NSMutableDictionary<NSNumber *, LWZCollectionLayoutSection *> *mLayoutSections;
    NSMutableIndexSet *mIndexes;
    UICollectionViewScrollDirection mScrollDirection;
}

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    self = [super init];
    if ( self ) {
        mScrollDirection = scrollDirection;
        mIndexes = NSMutableIndexSet.indexSet;
        mLayoutSections = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)enumerateSectionsUsingBlock:(void(NS_NOESCAPE ^)(LWZCollectionLayoutSection *section, BOOL *stop))block {
    BOOL isStop = NO;
    NSUInteger currentIndex = [mIndexes firstIndex];
    while ( currentIndex != NSNotFound ) {
        block(mLayoutSections[@(currentIndex)], &isStop);
        if ( isStop ) return;
        currentIndex = [mIndexes indexGreaterThanIndex:currentIndex];
    }
}

- (nullable NSArray<LWZCollectionLayoutSection *> *)sectionsInRect:(CGRect)rect {
    NSMutableArray<LWZCollectionLayoutSection *> *m = NSMutableArray.array;
    NSUInteger currentIndex = [mIndexes firstIndex];
    while ( currentIndex != NSNotFound ) {
        LWZCollectionLayoutSection *section = mLayoutSections[@(currentIndex)];
        __auto_type result = LWZFloatRangeRectCompare(section.frame, rect, mScrollDirection);
        /* break */
        if ( result == LWZFloatRangeComparisonResultInRight ) break;
        currentIndex = [mIndexes indexGreaterThanIndex:currentIndex];
        /* continue */
        if ( result == LWZFloatRangeComparisonResultInLeft ) continue;
        [m addObject:section];
    }
    return m.count != 0 ? m : nil;
}

- (nullable LWZCollectionLayoutSection *)sectionAtIndex:(NSInteger)index {
    return mLayoutSections[@(index)];
}

- (void)addSection:(LWZCollectionLayoutSection *)section {
    NSInteger index = section.index;
    mLayoutSections[@(index)] = section;
    [mIndexes addIndex:index];
}

- (void)removeAllSections {
    [mLayoutSections removeAllObjects];
    [mIndexes removeAllIndexes];
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionLayoutSection *section = [self sectionAtIndex:indexPath.section];
    if ( section != nil ) {
        if ( indexPath.item < section.cellLayoutAttributesObjects.count )
            return section.cellLayoutAttributesObjects[indexPath.item];
    }
    return nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionLayoutSection *section = [self sectionAtIndex:indexPath.section];
    if ( section != nil ) {
        if      ( [elementKind isEqualToString:UICollectionElementKindSectionHeader] )
            return [section currentHeaderViewLayoutAttributes];
        else if ( [elementKind isEqualToString:UICollectionElementKindSectionFooter ] )
            return section.footerViewLayoutAttributes;
    }
    return nil;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionLayoutSection *section = [self sectionAtIndex:indexPath.section];
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
    for ( LWZCollectionLayoutSection *section in [self sectionsInRect:rect] ) {
    
        if ( [section currentHeaderViewLayoutAttributes] != nil && LWZFloatRangeRectIntersects([section currentHeaderViewLayoutAttributes].frame, rect, direction) )
            [m addObject:[section currentHeaderViewLayoutAttributes]];
        if ( section.footerViewLayoutAttributes != nil && LWZFloatRangeRectIntersects(section.footerViewLayoutAttributes.frame, rect, direction) )
            [m addObject:section.footerViewLayoutAttributes];
        if ( section.sectionDecorationLayoutAttributes != nil && LWZFloatRangeRectIntersects(section.sectionDecorationLayoutAttributes.frame, rect, direction) )
            [m addObject:section.sectionDecorationLayoutAttributes];
        if ( [section currentHeaderDecorationLayoutAttributes] != nil && LWZFloatRangeRectIntersects([section currentHeaderDecorationLayoutAttributes].frame, rect, direction) )
            [m addObject:[section currentHeaderDecorationLayoutAttributes]];
        if ( section.footerDecorationLayoutAttributes != nil && LWZFloatRangeRectIntersects(section.footerDecorationLayoutAttributes.frame, rect, direction) )
            [m addObject:section.footerDecorationLayoutAttributes];
        for ( LWZCollectionViewLayoutAttributes *attributes in section.cellLayoutAttributesObjects ) {
            LWZFloatRangeComparisonResult result = LWZFloatRangeRectCompare(attributes.frame, rect, direction);
            /* continue */
            if ( result == LWZFloatRangeComparisonResultInLeft || result == LWZFloatRangeComparisonResultInRight ) continue;
            [m addObject:attributes];
        }
        for ( LWZCollectionViewLayoutAttributes *attributes in section.cellDecorationLayoutAttributesObjects ) {
            LWZFloatRangeComparisonResult result = LWZFloatRangeRectCompare(attributes.frame, rect, direction);
            /* continue */
            if ( result == LWZFloatRangeComparisonResultInLeft || result == LWZFloatRangeComparisonResultInRight ) continue;
            [m addObject:attributes];
        }
    }
    return m;
}

- (void)enumerateLayoutAttributesWithElementCategory:(UICollectionElementCategory)category usingBlock:(void(NS_NOESCAPE ^)(LWZCollectionViewLayoutAttributes *attributes, BOOL *stop))block {
    BOOL isStop = NO;
    NSUInteger currentIndex = [mIndexes firstIndex];
    while ( currentIndex != NSNotFound ) {
        LWZCollectionLayoutSection *section = mLayoutSections[@(currentIndex)];
        NSArray<LWZCollectionViewLayoutAttributes *> *attributesObjects = [section layoutAttributesObjectsForElementCategory:category];
        for ( LWZCollectionViewLayoutAttributes *attributes in attributesObjects ) {
            block(attributes, &isStop);
            if ( isStop ) return;
            currentIndex = [mIndexes indexGreaterThanIndex:currentIndex];
        }
    }
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category {
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *m = NSMutableArray.array;
    NSUInteger currentIndex = [mIndexes firstIndex];
    while ( currentIndex != NSNotFound ) {
        LWZCollectionLayoutSection *section = mLayoutSections[@(currentIndex)];
        NSArray<LWZCollectionViewLayoutAttributes *> *attributesObjects = [section layoutAttributesObjectsForElementCategory:category];
        if ( attributesObjects.count != 0 ) [m addObjectsFromArray:attributesObjects];
        currentIndex = [mIndexes indexGreaterThanIndex:currentIndex];
    }
    return m.count != 0 ? m : nil;
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category inSection:(NSInteger)section {
    LWZCollectionLayoutSection *layoutSection = mLayoutSections[@(section)];
    if ( layoutSection != nil ) {
        return [layoutSection layoutAttributesObjectsForElementCategory:category];
    }
    return nil;
}

@end
