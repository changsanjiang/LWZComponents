//
//  LWZCollectionLayoutSection.m
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/11.
//

#import "LWZCollectionLayoutSection.h"

@implementation LWZCollectionLayoutSection {
    NSArray<LWZCollectionViewLayoutAttributes *> *_Nullable mCellLayoutAttributesObjects;
    NSArray<LWZCollectionViewLayoutAttributes *> *_Nullable mCellDecorationLayoutAttributesObjects;
}

- (instancetype)initWithIndex:(NSInteger)index {
    self = [super init];
    if ( self ){
        _index = index;
    }
    return self;
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
    return mCellLayoutAttributesObjects.count != 0 ? mCellLayoutAttributesObjects : nil;
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)cellDecorationLayoutAttributesObjects {
    return mCellDecorationLayoutAttributesObjects.count != 0 ? mCellDecorationLayoutAttributesObjects : nil;
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)_layoutAttributes:(NSArray<LWZCollectionViewLayoutAttributes *> *)array {
    return array.count == 0 ? nil : array;
}
@end
