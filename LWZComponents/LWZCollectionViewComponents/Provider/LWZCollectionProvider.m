//
//  LWZCollectionProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by BlueDancer on 2020/11/16.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionProvider.h"

@interface LWZCollectionProvider ()
@property (nonatomic, strong, readonly) NSMutableArray<LWZCollectionSection *> *sections;
@end

@implementation LWZCollectionProvider

- (void)addSectionWithBlock:(void(^NS_NOESCAPE)(__kindof LWZCollectionSection *make))block {
    LWZCollectionSection *section = [LWZCollectionSection.alloc init];
    block(section);
    [self addSection:section];
}

- (void)enumerateSectionsUsingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSection *section, NSInteger idx, BOOL *stop))block {
    [_sections enumerateObjectsUsingBlock:^(LWZCollectionSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, idx, stop);
    }];
}

- (void)enumerateSectionHeadersUsingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSectionHeaderFooter *header, NSInteger idx, BOOL *stop))block {
    BOOL stop = NO;
    for ( NSInteger s = 0 ; s < self.numberOfSections ; ++ s ) {
        LWZCollectionSection *section = [self sectionAtIndex:s];
        if ( section.header != nil ) {
            block(section.header, s, &stop);
            if ( stop ) return;
        }
    }
}

- (void)enumerateItemIndexPathsUsingBlock:(void(NS_NOESCAPE ^)(NSIndexPath *indexPath, BOOL *stop))block {
    BOOL stop = NO;
    for ( NSInteger s = 0 ; s < self.numberOfSections ; ++ s ) {
        LWZCollectionSection *section = [self sectionAtIndex:s];
        for ( NSInteger i = 0 ; i < section.numberOfItems ; ++ i ) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:s];
            block(indexPath, &stop);
            if ( stop )
                return;
        }
    }
}

- (void)enumerateSectionFootersUsingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSectionHeaderFooter *footer, NSInteger idx, BOOL *stop))block {
    BOOL stop = NO;
    for ( NSInteger s = 0 ; s < self.numberOfSections ; ++ s ) {
        LWZCollectionSection *section = [self sectionAtIndex:s];
        if ( section.footer != nil ) {
            block(section.footer, s, &stop);
            if ( stop ) return;
        }
    }
}

- (void)enumerateSectionsWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSection *section, NSInteger idx, BOOL *stop))block {
    [_sections enumerateObjectsWithOptions:opts usingBlock:^(LWZCollectionSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, idx, stop);
    }];
}
- (void)enumerateSectionHeadersWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSectionHeaderFooter *header, NSInteger idx, BOOL *stop))block {
    [_sections enumerateObjectsWithOptions:opts usingBlock:^(LWZCollectionSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LWZCollectionSectionHeaderFooter *header = obj.header;
        if ( header != nil ) {
            block(header, idx, stop);
        }
    }];
}
- (void)enumerateItemIndexPathsWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(NSIndexPath *indexPath, BOOL *stop))block {
    [_sections enumerateObjectsWithOptions:opts usingBlock:^(LWZCollectionSection * _Nonnull obj, NSUInteger sIdx, BOOL * _Nonnull sStop) {
        [obj enumerateItemsWithOptions:opts usingBlock:^(__kindof LWZCollectionItem * _Nonnull item, NSInteger iIdx, BOOL * _Nonnull iStop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:iIdx inSection:sIdx];
            block(indexPath, iStop);
            if ( *iStop ) *sStop = YES;
        }];
    }];
}
- (void)enumerateSectionFootersWithOptions:(NSEnumerationOptions)opts usingBlock:(void(NS_NOESCAPE ^)(__kindof LWZCollectionSectionHeaderFooter *footer, NSInteger idx, BOOL *stop))block {
    [_sections enumerateObjectsWithOptions:opts usingBlock:^(LWZCollectionSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LWZCollectionSectionHeaderFooter *footer = obj.footer;
        if ( footer != nil ) {
            block(footer, idx, stop);
        }
    }];
}

#pragma mark - mark

- (NSInteger)numberOfSections {
    return _sections.count;
}

- (NSInteger)numberOfItemsInSectionAtIndex:(NSInteger)sectionIndex {
    return [self sectionAtIndex:sectionIndex].numberOfItems;
}

- (nullable __kindof LWZCollectionSection *)firstSection {
    return _sections.firstObject;
}

- (nullable __kindof LWZCollectionSection *)lastSection {
    return _sections.lastObject;
}

- (nullable NSArray<__kindof LWZCollectionSection *> *)allSections {
    return _sections.copy;
}

- (NSInteger)addSection:(LWZCollectionSection *)section {
    if ( section != nil ) {
        NSInteger location = _sections.count;
        [self.sections addObject:section];
        return location;
    }
    return NSNotFound;
}

- (nullable NSIndexSet *)addSections:(NSArray<LWZCollectionSection *> *)sections {
    if ( sections.count != 0 ) {
        NSInteger location = _sections.count;
        [self.sections addObjectsFromArray:sections];
        return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, sections.count)];
    }
    return nil;
}

- (NSInteger)insertSection:(LWZCollectionSection *)section atIndex:(NSInteger)index {
    if ( [self _isSafeIndexForInserting:index] ) {
        [self.sections insertObject:section atIndex:index];
        return index;
    }
    return NSNotFound;
}
 
- (nullable NSIndexSet *)insertSections:(NSArray<LWZCollectionSection *> *)sections withPreviousSection:(LWZCollectionSection *)section {
    NSInteger index = [self indexOfSection:section] + 1;
    if ( [self _isSafeIndexForInserting:index] ) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, sections.count)];
        [_sections insertObjects:sections atIndexes:set];
        return set;
    }
    return nil;
}

- (nullable NSIndexSet *)insertSections:(NSArray<LWZCollectionSection *> *)sections withNextSection:(LWZCollectionSection *)section {
    NSInteger index = [self indexOfSection:section];
    if ( [self _isSafeIndexForInserting:index] ) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, sections.count)];
        [_sections insertObjects:sections atIndexes:set];
        return set;
    }
    return nil;
}


- (void)replaceSectionAtIndex:(NSInteger)index withSection:(LWZCollectionSection *)section {
    if ( [self _isSafeIndexForGetting:index] ) {
        [self.sections replaceObjectAtIndex:index withObject:section];
    }
}

- (nullable __kindof LWZCollectionSection *)sectionAtIndex:(NSInteger)index {
    return [self _isSafeIndexForGetting:index] ? _sections[index] : nil;
}

- (nullable __kindof LWZCollectionSectionHeaderFooter *)headerForSectionAtIndex:(NSInteger)index {
    return [self sectionAtIndex:index].header;
}

- (nullable __kindof LWZCollectionSectionHeaderFooter *)footerForSectionAtIndex:(NSInteger)index {
    return [self sectionAtIndex:index].footer;
}

- (nullable __kindof LWZCollectionItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self sectionAtIndex:indexPath.section] itemAtIndex:indexPath.item];
}

- (BOOL)containsSection:(LWZCollectionSection *)section {
    return [self indexOfSection:section] != NSNotFound;
}

- (BOOL)containsHeader:(LWZCollectionSectionHeaderFooter *)header {
    return [self indexOfSectionForHeader:header] != NSNotFound;
}

- (BOOL)containsFooter:(LWZCollectionSectionHeaderFooter *)footer {
    return [self indexOfSectionForFooter:footer] != NSNotFound;
}

- (BOOL)containsItem:(LWZCollectionItem *)item {
    return [self indexPathOfItem:item] != nil;
}

- (NSInteger)indexOfSection:(LWZCollectionSection *)section {
    return section != nil ? [_sections indexOfObject:section] : NSNotFound;
}

- (NSInteger)indexOfSectionForHeader:(LWZCollectionSectionHeaderFooter *)header {
    if ( header != nil ) {
        return [self _indexOfSectionWithCondition:^BOOL(LWZCollectionSection *section) {
            return section.header == header;
        }];
    }
    return NSNotFound;
}

- (NSInteger)indexOfSectionForFooter:(LWZCollectionSectionHeaderFooter *)footer {
    if ( footer != nil ) {
        return [self _indexOfSectionWithCondition:^BOOL(LWZCollectionSection *section) {
            return section.footer == footer;
        }];
    }
    return NSNotFound;
}

- (nullable NSIndexSet *)indexesForSectionsInArray:(NSArray<LWZCollectionSection *> *)sections {
    NSMutableIndexSet *set = [NSMutableIndexSet.alloc init];
    for ( LWZCollectionSection *section in sections ) {
        NSInteger index = [self indexOfSection:section];
        if ( index == NSNotFound )
            return nil;
        [set addIndex:index];
    }
    return set.copy;
}

- (nullable NSIndexPath *)indexPathOfItem:(LWZCollectionItem *)item {
    if ( item != nil ) {
        return [self _indexPathOfItemWithCondition:^BOOL(LWZCollectionSection *section, LWZCollectionItem * i) {
            return i == item;
        }];
    }
    return nil;
}

- (nullable NSArray<NSIndexPath *> *)indexPathsForItemsInArray:(NSArray<LWZCollectionItem *> *)items {
    if ( items.count != 0 ) {
        NSMutableArray<NSIndexPath *> *m = [NSMutableArray arrayWithCapacity:items.count];
        for ( LWZCollectionItem * item in items ) {
            NSIndexPath *indexPath = [self indexPathOfItem:item];
            if ( indexPath == nil ) return nil;
            [m addObject:indexPath];
        }
        return m.copy;
    }
    return nil;
}

- (nullable LWZCollectionSection *)sectionOfItem:(LWZCollectionItem *)item {
    return item != nil ? [self sectionAtIndex:[self indexPathOfItem:item].section] : nil;
}

- (nullable LWZCollectionSection *)sectionOfHeader:(LWZCollectionSectionHeaderFooter *)header {
    return header != nil ? [self sectionAtIndex:[self indexOfSectionForHeader:header]] : nil;
}

- (nullable LWZCollectionSection *)sectionOfFooter:(LWZCollectionSectionHeaderFooter *)footer {
    return footer != nil ? [self sectionAtIndex:[self indexOfSectionForFooter:footer]] : nil;
}

- (void)setHidden:(BOOL)isHidden forSectionAtIndex:(NSInteger)index {
    [[self sectionAtIndex:index] setHidden:isHidden];
}

- (void)setHidden:(BOOL)isHidden forSection:(LWZCollectionSection *)section {
    [self setHidden:isHidden forSectionAtIndex:[self indexOfSection:section]];
}

- (BOOL)isSectionHiddenAtIndex:(NSInteger)index {
    return [[self sectionAtIndex:index] isHidden];
}

- (BOOL)isSectionHidden:(LWZCollectionSection *)section {
    return [self isSectionHiddenAtIndex:[self indexOfSection:section]];
}

- (nullable NSIndexPath *)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    LWZCollectionItem *destinatioItem = [self itemAtIndexPath:destinationIndexPath];
    LWZCollectionItem *sourceItem = [self itemAtIndexPath:sourceIndexPath];
    NSComparisonResult result = [sourceIndexPath compare:destinationIndexPath];
    BOOL isMoveDown = NO;
    switch ( result ) {
        case NSOrderedSame:
            /* return */
            return nil;
        case NSOrderedAscending:
            isMoveDown = YES;
            break;
        case NSOrderedDescending:
            break;
    }
    return isMoveDown ? [self moveItem:sourceItem withPreviousItem:destinatioItem] : [self moveItem:sourceItem withNextItem:destinatioItem];
}

- (nullable NSIndexPath *)moveItem:(LWZCollectionItem *)i1 withPreviousItem:(LWZCollectionItem *)i2 {
    if ( i1 != i2 && [self containsItem:i1] && [self containsItem:i2] ) {
        LWZCollectionSection *s1 = [self sectionOfItem:i1];
        LWZCollectionSection *s2 = [self sectionOfItem:i2];
        [s1 removeItem:i1];
        return [NSIndexPath indexPathForItem:[s2 insertItem:i1 withPreviousItem:i2] inSection:[self indexOfSection:s2]];
    }
    return nil;
}

- (nullable NSArray<NSIndexPath *> *)moveItemsInArray:(NSArray<LWZCollectionItem *> *)items withPreviousItem:(LWZCollectionItem *)previousItem {
#ifdef DEBUG
    for ( LWZCollectionItem * item in items ) {
        NSAssert([self containsItem:item], @"必须是已添加到列表中的item!");
    }
#endif
    
    if ( items.count != 0 && [self containsItem:previousItem] ) {
        for ( NSInteger i = items.count - 1 ; i >= 0 ; -- i ) {
            [self moveItem:items[i] withPreviousItem:previousItem];
        }
        return [self indexPathsForItemsInArray:items];
    }
    return nil;
}

- (nullable NSIndexPath *)moveItem:(LWZCollectionItem *)i1 withNextItem:(LWZCollectionItem *)i2 {
    if ( i1 != i2 && [self containsItem:i1] && [self containsItem:i2] ) {
        LWZCollectionSection *s1 = [self sectionOfItem:i1];
        LWZCollectionSection *s2 = [self sectionOfItem:i2];
        [s1 removeItem:i1];
        return [NSIndexPath indexPathForItem:[s2 insertItem:i1 withNextItem:i2] inSection:[self indexOfSection:s2]];
    }
    return nil;
}

- (nullable NSArray<NSIndexPath *> *)moveItemsInArray:(NSArray<LWZCollectionItem *> *)items withNextItem:(LWZCollectionItem *)nextItem {
#ifdef DEBUG
    for ( LWZCollectionItem * item in items ) {
        NSAssert([self containsItem:item], @"必须是已添加到列表中的item!");
    }
#endif
    
    if ( items.count != 0 && [self containsItem:nextItem] ) {
        for ( NSInteger i = 0 ; i < items.count ; ++ i ) {
            [self moveItem:items[i] withNextItem:nextItem];
        }
        return [self indexPathsForItemsInArray:items];
    }
    return nil;
}

- (nullable NSIndexPath *)insertItem:(LWZCollectionItem *)item atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *sourceItem = [self itemAtIndexPath:indexPath];
    return [self insertItem:item withNextItem:sourceItem];
}

- (nullable NSIndexPath *)insertItem:(LWZCollectionItem *)item withPreviousItem:(LWZCollectionItem *)previousItem {
    if ( item != nil && [self containsItem:previousItem] ) {
        [[self sectionOfItem:previousItem] insertItem:item withPreviousItem:previousItem];
        return [self indexPathOfItem:item];
    }
    return nil;
}

- (nullable NSArray<NSIndexPath *> *)insertItems:(NSArray<LWZCollectionItem *> *)items withPreviousItem:(LWZCollectionItem *)previousItem {
    if ( items.count != 0 && [self containsItem:previousItem] ) {
        for ( NSInteger i = items.count - 1 ; i >= 0 ; -- i ) {
            [self insertItem:items[i] withPreviousItem:previousItem];
        }
        return [self indexPathsForItemsInArray:items];
    }
    return nil;
}

- (nullable NSIndexPath *)insertItem:(LWZCollectionItem *)item withNextItem:(LWZCollectionItem *)nextItem {
    if ( item != nil && [self containsItem:nextItem] ) {
        [[self sectionOfItem:nextItem] insertItem:item withNextItem:nextItem];
        return [self indexPathOfItem:item];
    }
    return nil;
}

- (nullable NSArray<NSIndexPath *> *)insertItems:(NSArray<LWZCollectionItem *> *)items withNextItem:(LWZCollectionItem *)nextItem {
    if ( items.count != 0 && [self containsItem:nextItem] ) {
        for ( NSInteger i = 0 ; i < items.count ; ++ i ) {
            [self insertItem:items[i] withNextItem:nextItem];
        }
        return [self indexPathsForItemsInArray:items];
    }
    return nil;
}

- (nullable NSIndexPath *)insertItemToTop:(LWZCollectionItem *)item inSection:(LWZCollectionSection *)section {
    if ( item != nil && [self containsSection:section] ) {
        [section insertItemToTop:item];
        return [self indexPathOfItem:item];
    }
    return nil;
}

- (NSInteger)removeSectionAtIndex:(NSInteger)index {
    if ( [self _isSafeIndexForGetting:index] ) {
        [_sections removeObjectAtIndex:index];
        return index;
    }
    return NSNotFound;
}

- (NSInteger)removeSection:(LWZCollectionSection *)section {
    return [self removeSectionAtIndex:[self indexOfSection:section]];
}

- (nullable NSIndexSet *)removeSections:(NSArray<LWZCollectionSection *> *)sections {
    NSIndexSet *set = [self indexesForSectionsInArray:sections];
    if ( set != nil ) {
        NSUInteger currentIndex = set.lastIndex;
        do {
            [self removeSectionAtIndex:currentIndex];
            currentIndex = [set indexLessThanIndex:currentIndex];
        } while ( currentIndex != NSNotFound );
    }
    return set;
}

- (void)removeAllSections {
    [_sections removeAllObjects];
}

- (NSInteger)removeHeaderForSectionAtIndex:(NSInteger)index {
    if ( [self _isSafeIndexForGetting:index] && [self sectionAtIndex:index].header != nil ) {
        [self sectionAtIndex:index].header = nil;
        return index;
    }
    return NSNotFound;
}

- (NSInteger)removeHeaderForSection:(LWZCollectionSection *)section {
    return [self removeHeaderForSectionAtIndex:[self indexOfSection:section]];
}

- (NSInteger)removeFooterForSectionAtIndex:(NSInteger)index {
    if ( [self _isSafeIndexForGetting:index] && [self sectionAtIndex:index].footer != nil ) {
        [self sectionAtIndex:index].footer = nil;
        return index;
    }
    return NSNotFound;
}

- (NSInteger)removeFooterForSection:(LWZCollectionSection *)section {
    return [self removeFooterForSectionAtIndex:[self indexOfSection:section]];
}

- (nullable NSIndexPath *)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem * item = [self itemAtIndexPath:indexPath];
    if ( item != nil ) {
        LWZCollectionSection *section = [self sectionAtIndex:indexPath.section];
        [section removeItem:item];
        return indexPath;
    }
    return nil;
}

- (nullable NSIndexPath *)removeItem:(LWZCollectionItem *)item {
    return [self removeItemAtIndexPath:[self indexPathOfItem:item]];
}

- (nullable NSArray<NSIndexPath *> *)removeItemsInArray:(NSArray<LWZCollectionItem *> *)items {
    if ( items.count != 0 ) {
        NSMutableArray<NSIndexPath *> *m = [NSMutableArray arrayWithCapacity:items.count];
        [[self _sortedArrayForItems:items] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(LWZCollectionItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [m addObject:[self removeItem:obj]];
        }];
        return m.copy;
    }
    return nil;
}

- (nullable NSArray<NSIndexPath *> *)removeItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if ( indexPaths.count != 0 ) {
        NSMutableArray<NSIndexPath *> *m = [NSMutableArray arrayWithCapacity:indexPaths.count];
        [[self _sortedArrayForIndexPaths:indexPaths] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [m addObject:[self removeItemAtIndexPath:obj]];
        }];
        return m.copy;
    }
    return nil;
}

///
/// 移除decoration
///
- (NSInteger)removeSectionDecorationAtIndex:(NSInteger)index {
    LWZCollectionSection *section = [self sectionAtIndex:index];
    if ( section.decoration != nil ) {
        section.decoration = nil;
        return index;
    }
    return NSNotFound;
}

- (NSInteger)removeSectionHeaderDecorationAtIndex:(NSInteger)index {
    LWZCollectionSectionHeaderFooter * header = [self headerForSectionAtIndex:index];
    if ( header != nil ) {
        header.decoration = nil;
        return index;
    }
    return NSNotFound;
}

- (nullable NSIndexPath *)removeItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem * item = [self itemAtIndexPath:indexPath];
    if ( item != nil ) {
        item.decoration = nil;
        return indexPath;
    }
    return nil;
}

- (NSInteger)removeSectionFooterDecorationAtIndex:(NSInteger)index {
    LWZCollectionSectionHeaderFooter * footer = [self footerForSectionAtIndex:index];
    if ( footer != nil ) {
        footer.decoration = nil;
        return index;
    }
    return NSNotFound;
}

#pragma mark - mark
@synthesize sections = _sections;
- (NSMutableArray<LWZCollectionSection *> *)sections {
    if ( _sections == nil ) {
        _sections = NSMutableArray.array;
    }
    return _sections;
}

- (BOOL)_isSafeIndexForGetting:(NSInteger)index {
    return index >= 0 && index < _sections.count;
}

- (BOOL)_isSafeIndexForInserting:(NSInteger)index {
    return index >= 0 && index <= _sections.count;
}

- (BOOL)_isSafeIndexPathForGetting:(NSIndexPath *)indexPath {
    LWZCollectionSection *section = [self sectionAtIndex:indexPath.section];
    return indexPath.item < section.numberOfItems;
}

- (BOOL)_isSafeIndexPathForInserting:(NSIndexPath *)indexPath {
    LWZCollectionSection *section = [self sectionAtIndex:indexPath.section];
    return section.numberOfItems > indexPath.item;
}

- (nullable NSArray<NSIndexPath *> *)_indexPathsWithIndexes:(NSIndexSet *)set inSection:(NSInteger)section {
    if ( set.count != 0 ) {
        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:set.count];
        NSInteger currentIndex = set.firstIndex;
        do {
            [indexPaths addObject:[NSIndexPath indexPathForItem:currentIndex inSection:section]];
            currentIndex = [set indexGreaterThanIndex:currentIndex];
        } while ( currentIndex != NSNotFound );
        return indexPaths;
    }
    return nil;
}

- (nullable NSIndexPath *)_indexPathOfItemWithCondition:(BOOL(^)(LWZCollectionSection *section, LWZCollectionItem * item))condition {
    for ( NSInteger s = 0 ; s < _sections.count ; ++ s ) {
        for ( NSInteger r = 0 ; r < _sections[s].numberOfItems ; ++ r ) {
            if ( condition(_sections[s], [_sections[s] itemAtIndex:r]) ) return [NSIndexPath indexPathForItem:r inSection:s];
        }
    }
    return nil;
}

- (NSInteger)_indexOfSectionWithCondition:(BOOL(^)(LWZCollectionSection *section))condition {
    for ( NSInteger s = 0 ; s < _sections.count ; ++ s ) {
        if ( condition(_sections[s]) ) return s;
    }
    return NSNotFound;
}

- (NSArray<LWZCollectionItem *> *)_sortedArrayForItems:(NSArray<LWZCollectionItem *> *)rows {
    return [rows sortedArrayUsingComparator:^NSComparisonResult(LWZCollectionItem *  _Nonnull r1, LWZCollectionItem * _Nonnull r2) {
        NSIndexPath *i1 = [self indexPathOfItem:r1];
        NSIndexPath *i2 = [self indexPathOfItem:r2];
        NSParameterAssert(i1 != nil && i2 != nil);
        return [i1 compare:i2];
    }];
}

- (NSArray<NSIndexPath *> *)_sortedArrayForIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    return [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *_Nonnull obj1, NSIndexPath *_Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}
@end
