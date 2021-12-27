//
//  LWZCollectionSection.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2020/11/16.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionSection.h"

@interface LWZCollectionSection ()
@property (nonatomic, strong, readonly) NSMutableArray<LWZCollectionItem *> *items;
@property (nonatomic) NSInteger numberOfArrangedItemsPerLine; // LWZCollectionWaterfallFlowLayout
@property (nonatomic) LWZCollectionLayoutType layoutType; // LWZCollectionHybridLayout
@property (nonatomic, getter=isOrthogonalScrolling) BOOL orthogonalScrolling; // LWZCollectionCompositionalLayout
- (CGSize)layoutSizeThatFits:(CGSize)size forOrthogonalContentAtIndex:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection; // LWZCollectionCompositionalLayout

@property (nonatomic, copy, nullable) CGSize(^orthogonalContentLayoutSizeCalculator)(LWZCollectionSection *section, CGSize fittingSize, NSInteger index, UICollectionViewScrollDirection scrollDirection); // LWZCollectionCompositionalLayout
@property (nonatomic) LWZCollectionLayoutContentOrthogonalScrollingBehavior orthogonalScrollingBehavior; // LWZCollectionCompositionalLayout
@property (nonatomic, strong, nullable) NSArray<LWZCollectionLayoutTemplateGroup *> *layoutTemplateContainerGroups; // LWZCollectionTemplateLayout
@end

@implementation LWZCollectionSection
@synthesize hidden = _hidden;
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize minimumLineSpacing = _minimumLineSpacing;
@synthesize contentInsets = _contentInsets;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _numberOfArrangedItemsPerLine = 1;
        /// 当开启 layout.sectionHeadersPinToVisibleBounds 时,
        /// layout 会询问当前 section.header 是否可以固定到顶部
        /// 请设置该值以确定是否可以固定
        _canPinToVisibleBoundsForHeader = YES;
    }
    return self;
}

- (void)enumerateItemsUsingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionItem *item, NSInteger index, BOOL *stop))block {
    [_items enumerateObjectsUsingBlock:^(LWZCollectionItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, idx, stop);
    }];
}

- (void)enumerateItemsWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionItem *item, NSInteger index, BOOL *stop))block {
    [_items enumerateObjectsWithOptions:opts usingBlock:^(LWZCollectionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, idx, stop);
    }];
}

#pragma mark -

- (BOOL)isHidden {
    return _hidesAutomatically ? self.numberOfItems == 0 : _hidden;
}

- (NSInteger)numberOfItems {
    return _items.count;
}

- (nullable __kindof LWZCollectionItem *)firstItem {
    return _items.firstObject;
}

- (nullable __kindof LWZCollectionItem *)lastItem {
    return _items.lastObject;
} 

- (BOOL)containsItem:(LWZCollectionItem *)item {
    return item != nil ? [_items containsObject:item] : NO;
}

- (NSInteger)indexForItem:(LWZCollectionItem *)item {
    return item != nil ? [_items indexOfObject:item] : NSNotFound;
}

- (nullable NSIndexSet *)indexesForItemsInArray:(NSArray<LWZCollectionItem *> *)items {
    if ( items.count != 0 ) {
        NSMutableIndexSet *set = [NSMutableIndexSet.alloc init];
        for ( LWZCollectionItem * item in _items ) {
            NSInteger index = [self indexForItem:item];
            if ( index == NSNotFound )
                return nil;
            [set addIndex:index];
        }
        return set.copy;
    }
    return nil;
}

- (nullable __kindof LWZCollectionItem *)itemAtIndex:(NSInteger)index {
    return [self _isSafeIndexForGetting:index] ? _items[index] : nil;
}

- (NSInteger)addItem:(LWZCollectionItem *)item {
    if ( item != nil ) {
        NSInteger location = _items.count;
        [self.items addObject:item];
        return location;
    }
    return NSNotFound;
}

- (nullable NSIndexSet *)addItemsFromArray:(NSArray<LWZCollectionItem *> *)items {
    if ( items.count != 0 ) {
        NSInteger location = _items.count;
        [self.items addObjectsFromArray:items];
        return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, items.count)];
    }
    return nil;
}

- (NSInteger)insertItem:(LWZCollectionItem *)item atIndex:(NSInteger)index {
    if ( item != nil && [self _isSafeIndexForInserting:index] ) {
        [_items insertObject:item atIndex:index];
        return index;
    }
    return NSNotFound;
}

- (NSInteger)insertItem:(LWZCollectionItem *)item withPreviousItem:(LWZCollectionItem *)previousItem {
    if ( item != nil && [self containsItem:previousItem] ) {
        NSInteger index = [self indexForItem:previousItem] + 1;
        [self.items insertObject:item atIndex:index];
        return index;
    }
    return NSNotFound;
}

- (nullable NSIndexSet *)insertItems:(NSArray<LWZCollectionItem *> *)items withPreviousItem:(LWZCollectionItem *)previousItem {
    if ( items.count != 0 ) {
        NSMutableIndexSet *set = [NSMutableIndexSet.alloc init];
        for ( NSInteger i = items.count - 1 ; i >= 0 ; -- i ) {
            [set addIndex:[self insertItem:items[i] withPreviousItem:previousItem]];
        }
        return set.copy;
    }
    return nil;
}

- (NSInteger)insertItem:(LWZCollectionItem *)item withNextItem:(LWZCollectionItem *)nextItem {
    if ( item != nil && [self containsItem:nextItem] ) {
        NSInteger index = [self indexForItem:nextItem];
        [self.items insertObject:item atIndex:index];
        return index;
    }
    return NSNotFound;
}

- (nullable NSIndexSet *)insertItems:(NSArray<LWZCollectionItem *> *)items withNextItem:(LWZCollectionItem *)nextItem {
    if ( items.count != 0 ) {
        NSMutableIndexSet *set = [NSMutableIndexSet.alloc init];
        for ( NSInteger i = 0 ; i < items.count ; ++ i ) {
            [set addIndex:[self insertItem:items[i] withNextItem:nextItem]];
        }
        return set.copy;
    }
    return nil;
}

- (NSInteger)insertItemToTop:(LWZCollectionItem *)item {
    if ( item != nil ) {
        [self.items insertObject:item atIndex:0];
        return 0;
    }
    return NSNotFound;
}

- (NSInteger)moveItem:(LWZCollectionItem *)item toIndex:(NSInteger)index {
    if ( [self containsItem:item] ) {
        LWZCollectionItem *sourceItem = [self itemAtIndex:index];
        if ( sourceItem != nil ) {
            [self removeItem:item];
            return [self insertItem:item withNextItem:sourceItem];
        }
    }
    return NSNotFound;
}

- (NSInteger)moveItem:(LWZCollectionItem *)i1 withPreviousItem:(LWZCollectionItem *)i2 {
    if ( i1 != i2 && [self containsItem:i1] && [self containsItem:i2] ) {
        [self removeItem:i1];
        [self insertItem:i1 withPreviousItem:i2];
        return [self indexForItem:i1];
    }
    return NSNotFound;
}

- (nullable NSIndexSet *)moveItemsInArray:(NSArray<LWZCollectionItem *> *)items withPreviousItem:(LWZCollectionItem *)previousItem {
    if ( items.count != 0 && [self containsItem:previousItem] ) {
        NSMutableIndexSet *set = [NSMutableIndexSet.alloc init];
        for ( NSInteger i = items.count - 1 ; i >= 0 ; -- i ) {
            [set addIndex:[self moveItem:items[i] withPreviousItem:previousItem]];
        }
        return set.copy;
    }
    return nil;
}

- (NSInteger)moveItem:(LWZCollectionItem *)i1 withNextItem:(LWZCollectionItem *)i2 {
    if ( i1 != i2 && [self containsItem:i1] && [self containsItem:i2] ) {
        [self removeItem:i1];
        [self insertItem:i1 withNextItem:i2];
        return [self indexForItem:i1];
    }
    return NSNotFound;
}

- (nullable NSIndexSet *)moveItemsInArray:(NSArray<LWZCollectionItem *> *)items withNextItem:(LWZCollectionItem *)nextItem {
    if ( items.count != 0 && [self containsItem:nextItem] ) {
        NSMutableIndexSet *set = [NSMutableIndexSet.alloc init];
        for ( NSInteger i = 0 ; i < items.count ; ++ i ) {
            [set addIndex:[self moveItem:items[i] withNextItem:nextItem]];
        }
        return set.copy;
    }
    return nil;
}

- (NSInteger)removeItemAtIndex:(NSInteger)index {
    if ( [self _isSafeIndexForGetting:index] ) {
        [_items removeObjectAtIndex:index];
        return index;
    }
    return NSNotFound;
}

- (NSInteger)removeItem:(LWZCollectionItem *)item {
    NSInteger index = [self indexForItem:item];
    if ( index != NSNotFound ) {
        [_items removeObjectAtIndex:index];
    }
    return index;
}

- (nullable NSIndexSet *)removeItemsInArray:(NSArray<LWZCollectionItem *> *)items {
    NSIndexSet *set = [self indexesForItemsInArray:items];
    if ( set != nil ) {
        NSUInteger currentIndex = set.lastIndex;
        do {
            [_items removeObjectAtIndex:currentIndex];
            currentIndex = [set indexLessThanIndex:currentIndex];
        } while ( currentIndex != NSNotFound );
    }
    return nil;
}

- (void)removeAllItems {
    [_items removeAllObjects];
}

- (void)setNeedsLayout {
    [_decoration setNeedsLayout];
    [_header setNeedsLayout];
    
    for ( LWZCollectionItem * item in _items ) {
        [item setNeedsLayout];
    }
    
    [_footer setNeedsLayout];
}

- (CGSize)layoutSizeThatFits:(CGSize)size forOrthogonalContentAtIndex:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    if ( _orthogonalContentLayoutSizeCalculator != nil )
        return _orthogonalContentLayoutSizeCalculator(self, size, index, scrollDirection);
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath {}
- (void)didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {}
- (void)didBindCellForItemAtIndexPath:(NSIndexPath *)indexPath {}
- (void)didUnbindCellForItemAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark -

@synthesize items = _items;
- (NSMutableArray<LWZCollectionItem *> *)items {
    if ( _items == nil ) {
        _items = NSMutableArray.array;
    }
    return _items;
}

- (BOOL)_isSafeIndexForGetting:(NSInteger)index {
    return index > -1 && index < _items.count;
}

- (BOOL)_isSafeIndexForInserting:(NSInteger)index {
    return index > -1 && index <= _items.count;
}
@end
