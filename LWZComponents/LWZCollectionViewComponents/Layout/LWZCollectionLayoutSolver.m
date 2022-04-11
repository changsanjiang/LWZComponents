//
//  LWZCollectionLayoutSolver.m
//  mssapp_Example
//
//  Created by 畅三江 on 2022/4/8.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "LWZCollectionLayoutSolver.h"
#import "UIFloatRange+LWZCollectionAdditions.h"
#import "CGSize+LWZCollectionAdditions.h"

@implementation LWZCollectionLayoutSolver

- (instancetype)initWithLayout:(id<LWZCollectionLayout>)layout {
    self = [super init];
    if ( self ) {
        _layout = layout;
    }
    return self;
}

// header footer

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemWithKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    UIFloatRange layoutRange = container.layoutRangeOfHeaderFooter;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    
    NSInteger section = indexPath.section;
    UICollectionViewScrollDirection direction = container.collectionLayoutContainer.layoutDirection;
    CGSize fittingSize = LWZFittingSizeForFloatRange(layoutRange, direction);
    id<LWZCollectionLayout> layout = self.layout;
    CGSize layoutSize = kind == UICollectionElementKindSectionHeader ?
                                    [layout layoutSizeToFit:fittingSize forHeaderInSection:section scrollDirection:direction] :
                                    [layout layoutSizeToFit:fittingSize forFooterInSection:section scrollDirection:direction];
    if ( LWZLayoutSizeIsInvalid(layoutSize, direction) ) return nil;
    
    LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    attributes.zIndex = kind == UICollectionElementKindSectionFooter ?
                                    [layout zIndexForHeaderInSection:section] :
                                    [layout zIndexForFooterInSection:section];
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

// items

/// @param offset   item 布局开始的位置, 例如: 垂直布局时, offset = preHeader.maxY + section.contentInsets.top;
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (nullable UIView *)layoutCustomViewForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

// decorations

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForDecorationItemWithCategory:(LWZCollectionDecorationCategory)category inRect:(CGRect)rect indexPath:(NSIndexPath *)indexPath {
    NSString *kind = [_layout elementKindForDecorationOfCategory:category atIndexPath:indexPath];
    if ( kind.length != 0 ) {
        CGRect fitsRect = (CGRect){0, 0, rect.size};
        CGRect layoutFrame = [_layout relativeRectToFit:fitsRect forDecorationOfCategory:category atIndexPath:indexPath];
        layoutFrame.origin.x += rect.origin.x;
        layoutFrame.origin.y += rect.origin.y;
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
        attributes.zIndex = [_layout zIndexForDecorationOfCategory:category atIndexPath:indexPath];
        attributes.frame = layoutFrame;
        attributes.decorationUserInfo = [_layout userInfoForDecorationOfCategory:category atIndexPath:indexPath];
        return attributes;
    }
    return nil;
}
@end


@implementation LWZCollectionWeightLayoutSolver

UIKIT_STATIC_INLINE CGSize
LWZFittingSizeForWeight(CGFloat weight, CGSize fittingSize, NSInteger arranged, CGFloat itemSpacing, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            return CGSizeMake((fittingSize.width - ((arranged - 1) * itemSpacing)) * weight, fittingSize.height);
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake(fittingSize.width, (fittingSize.height - ((arranged - 1) * itemSpacing)) * weight);
    }
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    id<LWZCollectionWeightLayout> layout = self.layout;
    NSInteger numberOfItems = [layout numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.layoutRangeOfItem;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;

    /*

     item layouts
     |-----------|
     |-----|-----|
     |---|---|---|

     */
    CGSize boundary = LWZFittingSizeForFloatRange(layoutRange, scrollDirection);
    CGFloat lineSpacing = [layout minimumLineSpacingForSectionAtIndex:section];
    CGFloat itemSpacing = [layout minimumInteritemSpacingForSectionAtIndex:section];
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesObjects = [NSMutableArray.alloc initWithCapacity:numberOfItems];
    LWZCollectionViewLayoutAttributes *previousItemAttributes = nil;
    LWZCollectionViewLayoutAttributes *firstItemAttributes = nil;
    CGFloat progress = 0;
    for ( NSInteger i = 0 ; i < numberOfItems ; ++ i ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        CGFloat weight = [layout layoutWeightForItemAtIndexPath:indexPath];
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
        CGSize fittingSize = LWZFittingSizeForWeight(weight, boundary, arranges, itemSpacing, scrollDirection);
        CGSize layoutSize = [layout layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];

        CGRect layoutFrame = (CGRect){0, 0, layoutSize};
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                layoutFrame.origin.x = isFirstItem ? layoutRange.minimum : CGRectGetMaxX(previousItemAttributes.frame) + itemSpacing;
                layoutFrame.origin.y = offset;
                // fix size
                // 同行item的高度与行首item一致
                if ( !isFirstItem ) layoutFrame.size.height = firstItemAttributes.frame.size.height;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                layoutFrame.origin.x = offset;
                layoutFrame.origin.y = isFirstItem ? layoutRange.minimum : CGRectGetMaxY(previousItemAttributes.frame) + itemSpacing;
                // fix size
                // 同行item的宽度与行首item一致
                if ( !isFirstItem ) layoutFrame.size.width = firstItemAttributes.frame.size.width;
            }
                break;
        }

        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [layout zIndexForItemAtIndexPath:indexPath];
        attributes.frame = layoutFrame;
        [attributesObjects addObject:attributes];
        previousItemAttributes = attributes;
        if ( isFirstItem ) firstItemAttributes = attributes;
    }

    return attributesObjects;
}
@end


@implementation LWZCollectionListLayoutSolver

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    id<LWZCollectionListLayout> layout = self.layout;
    NSInteger numberOfItems = [layout numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.layoutRangeOfItem;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;

    CGFloat lineSpacing = [layout minimumLineSpacingForSectionAtIndex:section];
    CGSize fittingSize = LWZFittingSizeForFloatRange(layoutRange, scrollDirection);
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesObjects = [NSMutableArray.alloc initWithCapacity:numberOfItems];
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
        CGSize layoutSize = [layout layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];

        CGRect layoutFrame = (CGRect){0, 0, layoutSize};
        LWZCollectionLayoutAlignment alignment = [layout layoutAlignmentForItemAtIndexPath:indexPath];
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                layoutFrame.origin.y = CGRectGetMaxY(previousFrame) + lineSpacing;
                switch ( alignment ) {
                        // 左对齐
                    case LWZCollectionLayoutAlignmentStart: {
                        layoutFrame.origin.x = layoutRange.minimum;
                    }
                        break;
                        // 右对齐
                    case LWZCollectionLayoutAlignmentEnd: {
                        layoutFrame.origin.x = layoutRange.minimum + length - layoutFrame.size.width;
                    }
                        break;
                        // 中对齐
                    case LWZCollectionLayoutAlignmentCenter: {
                        layoutFrame.origin.x = layoutRange.minimum + (length - layoutFrame.size.width) * 0.5;
                    }
                        break;
                }
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                layoutFrame.origin.x = CGRectGetMaxX(previousFrame) + lineSpacing;
                switch ( alignment ) {
                        // 顶对齐
                    case LWZCollectionLayoutAlignmentStart: {
                        layoutFrame.origin.y = layoutRange.minimum;
                    }
                        break;
                        // 底对齐
                    case LWZCollectionLayoutAlignmentEnd: {
                        layoutFrame.origin.y = layoutRange.minimum + length - layoutFrame.size.height;
                    }
                        break;
                        // 中对齐
                    case LWZCollectionLayoutAlignmentCenter: {
                        layoutFrame.origin.y = layoutRange.minimum + (length - layoutFrame.size.height) * 0.5;
                    }
                        break;
                }
            }
                break;
        }
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [layout zIndexForItemAtIndexPath:indexPath];
        attributes.frame = layoutFrame;
        [attributesObjects addObject:attributes];

        previousFrame = layoutFrame;
     }
    return attributesObjects;
}
@end


@implementation LWZCollectionWaterfallFlowLayoutSolver
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    id<LWZCollectionWaterfallFlowLayout> layout = self.layout;
    /*

     item layouts
     |  |  |__|
     |__|  |  |
     |  |__|  |
     |  |  |__|
     |__|__|  |
     */
    NSInteger numberOfItems = [layout numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.layoutRangeOfItem;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;

    CGFloat lineSpacing = [layout minimumLineSpacingForSectionAtIndex:section];
    CGFloat itemSpacing = [layout minimumInteritemSpacingForSectionAtIndex:section];
    NSInteger arrangements = [layout layoutNumberOfArrangedItemsPerLineInSection:section];
    NSParameterAssert(arrangements > 0);
    CGSize fittingSize = LWZFittingSizeForArrangements(arrangements, LWZFittingSizeForFloatRange(layoutRange, scrollDirection), itemSpacing, scrollDirection);
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesObjects = [NSMutableArray.alloc initWithCapacity:numberOfItems];
    CGFloat columns[arrangements];
    LWZWaterfallFlowInit(columns, arrangements, offset - lineSpacing);
    for ( NSInteger curIdx = 0 ; curIdx < numberOfItems ; ++ curIdx ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:curIdx inSection:section];
        CGSize layoutSize = [layout layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];

        NSInteger columnIndex = LWZWaterfallFlowGetColumnIndexOfMinimumOffset(columns, arrangements);
        offset = columns[columnIndex];
        CGRect frame = (CGRect){0, 0, layoutSize};
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                frame.origin.x = layoutRange.minimum + columnIndex * (fittingSize.width + itemSpacing);
                frame.origin.y = offset + lineSpacing;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                frame.origin.x = offset + lineSpacing;
                frame.origin.y = layoutRange.minimum + columnIndex * (fittingSize.height + itemSpacing);
            }
                break;
        }
        LWZWaterfallFlowSetColumnOffset(columns, columnIndex, frame, scrollDirection);
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [layout zIndexForItemAtIndexPath:indexPath];
        attributes.frame = frame;
        [attributesObjects addObject:attributes];
    }
    return attributesObjects;
}

UIKIT_STATIC_INLINE CGSize
LWZFittingSizeForArrangements(NSInteger arrangements, CGSize fittingSize, CGFloat itemSpacing, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            return CGSizeMake((fittingSize.width - (arrangements - 1) * itemSpacing) / arrangements, fittingSize.height);
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake(fittingSize.width, (fittingSize.height - (arrangements - 1) * itemSpacing) / arrangements);
    }
}

UIKIT_STATIC_INLINE void
LWZWaterfallFlowInit(CGFloat *columns, NSInteger arrangements, CGFloat offset) {
    for ( NSInteger i = 0 ; i < arrangements ; ++ i ) columns[i] = offset;
}

UIKIT_STATIC_INLINE NSInteger
LWZWaterfallFlowGetColumnIndexOfMinimumOffset(CGFloat *columns, NSInteger arrangements) {
    NSInteger index = 0;
    CGFloat minimumOffset = CGFLOAT_MAX;
    for ( NSInteger i = 0 ; i < arrangements ; ++ i ) {
        if ( minimumOffset > columns[i] ) {
            minimumOffset = columns[i];
            index = i;
        }
    }
    return index;
}

UIKIT_STATIC_INLINE void
LWZWaterfallFlowSetColumnOffset(CGFloat *columns, NSInteger index, CGRect itemFrame, UICollectionViewScrollDirection direction) {
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


@implementation LWZCollectionRestrictedLayoutSolver
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    id<LWZCollectionWaterfallFlowLayout> layout = self.layout;
    NSInteger numberOfItems = [layout numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.layoutRangeOfItem;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;
    /*

     item layouts
     |-----------|
     |-----|-|--|
     |---|---|---|
     |--|-|----|

     */
    CGFloat lineSpacing = [layout minimumLineSpacingForSectionAtIndex:section];
    CGFloat itemSpacing = [layout minimumInteritemSpacingForSectionAtIndex:section];
    CGSize fittingSize = LWZFittingSizeForFloatRange(layoutRange, scrollDirection);
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesObjects = [NSMutableArray.alloc initWithCapacity:numberOfItems];
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
        CGSize layoutSize = [layout layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];

        CGRect layoutFrame = (CGRect){0, 0, layoutSize};
        BOOL isFirstItem = NO;
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                CGFloat left = CGRectGetMaxX(previousFrame) + itemSpacing;
                CGFloat maxX = left + layoutSize.width;
                if ( firstItemAttributes == nil || maxX > layoutRange.maximum ) {
                    // new line
                    layoutFrame.origin.x = layoutRange.minimum;
                    layoutFrame.origin.y = CGRectGetMaxY(previousFrame) + lineSpacing;
                    isFirstItem = YES;
                }
                else {
                    // current line
                    layoutFrame.origin.x = left;
                    layoutFrame.origin.y = CGRectGetMinY(previousFrame);
                    // fix size
                    // 每行item的高度与行首item一致
                    layoutFrame.size.height = firstItemAttributes.frame.size.height;
                }
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                CGFloat top = CGRectGetMaxY(previousFrame) + itemSpacing;
                CGFloat maxY = top + layoutSize.height;
                // new line
                if ( firstItemAttributes == nil || maxY > layoutRange.maximum ) {
                    layoutFrame.origin.x = CGRectGetMaxX(previousFrame) + lineSpacing;
                    layoutFrame.origin.y = layoutRange.minimum;
                    isFirstItem = YES;
                }
                else {
                    // current line
                    layoutFrame.origin.x = CGRectGetMinX(previousFrame);
                    layoutFrame.origin.y = top;
                    // fix size
                    // 每行item的宽度度与行首item一致
                    layoutFrame.size.width = firstItemAttributes.frame.size.width;
                }
            }
                break;
        }
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [layout zIndexForItemAtIndexPath:indexPath];
        attributes.frame = layoutFrame;
        [attributesObjects addObject:attributes];

        previousFrame = layoutFrame;
        if ( isFirstItem ) firstItemAttributes = attributes;
    }
    return attributesObjects;
}
@end


@implementation LWZCollectionTemplateLayoutSolver
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    id<LWZCollectionTemplateLayout> layout = self.layout;
    NSInteger numberOfItems = [layout numberOfItemsInSection:section];
    if ( numberOfItems == 0 ) return nil;
    UIFloatRange layoutRange = container.layoutRangeOfItem;
    if ( layoutRange.maximum <= layoutRange.minimum ) return nil;
    UICollectionViewScrollDirection scrollDirection = container.layoutDirection;

    NSArray<LWZCollectionTemplateGroup *> *groups = [layout layoutTemplateContainerGroupsInSection:section];
    NSAssert(groups != nil, @"The template groups can't be nil!");

    CGFloat lineSpacing = [layout minimumLineSpacingForSectionAtIndex:section];
    CGFloat itemSpacing = [layout minimumInteritemSpacingForSectionAtIndex:section];

    LWZCollectionTemplateSolver *solver = [LWZCollectionTemplateSolver.alloc initWithGroups:groups scrollDirection:scrollDirection numberOfItems:numberOfItems lineSpacing:lineSpacing itemSpacing:itemSpacing containerSize:container.layoutContainerSizeOfItem];
    NSMutableArray<LWZCollectionViewLayoutAttributes *> *attributesObjects = [NSMutableArray.alloc initWithCapacity:numberOfItems];
    // 将cell填充到模板中
    for ( NSInteger i = 0 ; i < numberOfItems ; ++ i ) {
        CGRect layoutFrame = [solver itemLayoutFrameAtIndex:i];
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                layoutFrame.origin.y += offset;
                layoutFrame.origin.x += layoutRange.minimum;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                layoutFrame.origin.x += offset;
                layoutFrame.origin.y += layoutRange.minimum;
            }
                break;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        LWZCollectionViewLayoutAttributes *attributes = [LWZCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = [layout zIndexForItemAtIndexPath:indexPath];
        attributes.frame = layoutFrame;
        [attributesObjects addObject:attributes];
    }
    return attributesObjects;
}
@end

#import <objc/message.h>

@implementation LWZCollectionMultipleLayoutSolver
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    id<LWZCollectionMultipleLayout> layout = self.layout;
    Class solverClass = [self solverClassForLayoutType:[layout layoutTypeForItemsInSection:section]];
    SEL sel = @selector(layoutAttributesObjectsForItemsWithSection:offset:container:);
    IMP imp = method_getImplementation(class_getInstanceMethod(solverClass, sel));
    return ((id(*)(id, SEL, NSInteger, CGFloat, id))imp)(self, sel, section, offset, container);
}

- (Class)solverClassForLayoutType:(LWZCollectionLayoutType)layoutType {
    Class solverClass = NULL;
    switch ( layoutType ) {
        case LWZCollectionLayoutTypeUnspecified:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"You must specify a layout!"
                                         userInfo:nil];
            break;
        case LWZCollectionLayoutTypeWeight:
            solverClass = LWZCollectionWeightLayoutSolver.class;
            break;
        case LWZCollectionLayoutTypeList:
            solverClass = LWZCollectionListLayoutSolver.class;
            break;
        case LWZCollectionLayoutTypeWaterfallFlow:
            solverClass = LWZCollectionWaterfallFlowLayoutSolver.class;
            break;
        case LWZCollectionLayoutTypeRestrictedLayout:
            solverClass = LWZCollectionRestrictedLayoutSolver.class;
            break;
        case LWZCollectionLayoutTypeTemplate:
            solverClass = LWZCollectionTemplateLayoutSolver.class;
            break;
    }
    return solverClass;
}
@end


#import "LWZCollectionViewLayout.h"
#import "LWZCollectionViewLayoutSubclass.h"

@interface _LWZCollectionViewNestedGroupViewLayout : LWZCollectionViewLayout
- (instancetype)initWithParentLayout:(__weak LWZCollectionViewLayout *)parentLayout inSection:(NSInteger)idx scrollDirection:(UICollectionViewScrollDirection)scrollDirection orthogonalScrollingBehavior:(LWZCollectionLayoutContentOrthogonalScrollingBehavior)behavior;
@end

@implementation _LWZCollectionViewNestedGroupViewLayout {
    NSInteger mSectionIndex;

    __weak LWZCollectionViewLayout *mParentLayout;
    LWZCollectionLayoutContentOrthogonalScrollingBehavior mBehavior;
}

+ (Class)layoutSolverClass {
    return LWZCollectionCompositionalLayoutSolver.class;
}

- (instancetype)initWithParentLayout:(__weak LWZCollectionViewLayout *)parentLayout inSection:(NSInteger)idx scrollDirection:(UICollectionViewScrollDirection)scrollDirection orthogonalScrollingBehavior:(LWZCollectionLayoutContentOrthogonalScrollingBehavior)behavior {
    self = [super initWithScrollDirection:scrollDirection delegate:parentLayout.delegate];
    if ( self ) {
        mSectionIndex = idx;
        mParentLayout = parentLayout;
        mBehavior = behavior;
        if (@available(iOS 11.0, *)) {
            self.ignoredSafeAreaInsets = YES;
        }
    }
    return self;
}

- (void)willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container { }

- (void)didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container { }

- (BOOL)shouldProcessLayoutForSectionAtIndex:(NSInteger)index {
    return index == mSectionIndex;
}

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForCellsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    if ( section == mSectionIndex ) {
        return [mParentLayout layoutAttributesObjectsForCellsWithSection:section offset:offset container:container];
    }
    return nil;
}

// edgeSpacings, contentInsets, header, footer, sectionDecoration, headerDecoration, footerDecoration

- (UIEdgeInsets)edgeSpacingsForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (UIEdgeInsets)contentInsetsForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewWithElementKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
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
            switch ( self.scrollDirection ) {
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
            CGPoint retv = [self _targetContentOffsetForRefLine:refLine proposedContentOffset:proposedContentOffset];
            NSLog(@"%@, %lf", NSStringFromCGPoint(retv), refLine);
            return retv;
        }
            break;
    }
}

- (CGPoint)_targetContentOffsetForRefLine:(CGFloat)refLine proposedContentOffset:(CGPoint)proposedContentOffset {
    // 查找距离 refline 最近的 cell
    CGFloat curMinOffset = CGFLOAT_MAX;
    LWZCollectionViewLayoutAttributes *finalAttributes = nil;
    for ( LWZCollectionViewLayoutAttributes *attributes in [self layoutAttributesObjectsForElementCategory:UICollectionElementCategoryCell inSection:mSectionIndex] ) {
        CGRect frame = attributes.frame;
        CGFloat midOffset = 0;
        switch ( self.scrollDirection ) {
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
    CGSize contentSize = self.collectionViewContentSize;
    CGRect bounds = collectionView.bounds;
    switch ( self.scrollDirection ) {
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

@implementation LWZCollectionCompositionalLayoutSolver
- (instancetype)initWithLayout:(LWZCollectionViewLayout<LWZCollectionCompositionalLayout> *)layout {
    self = [super initWithLayout:layout];
    if ( self ) {
        
    }
    return self;
}

// 包裹所有 cell 的容器.
- (nullable UIView *)layoutCustomViewForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container {
    LWZCollectionViewLayout<LWZCollectionCompositionalLayout> *layout = self.layout;
    if ( [layout isOrthogonalScrollingInSection:section] ) {
        LWZCollectionLayoutContainer *collectionLayoutContainer = container.collectionLayoutContainer;
        LWZSectionLayoutContainer *sectionLayoutContainer = container;
        UICollectionView *collectionView = layout.collectionView;
        UIFloatRange layoutRange = sectionLayoutContainer.layoutRangeOfItem;
        NSInteger numberOfItems = [layout numberOfItemsInSection:section];
        UICollectionViewScrollDirection collectionViewLayoutDirection = collectionLayoutContainer.layoutDirection;
        if ( numberOfItems != 0 && layoutRange.maximum > layoutRange.minimum ) {
            UICollectionViewScrollDirection groupViewLayoutDirection = collectionViewLayoutDirection == UICollectionViewScrollDirectionVertical ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
            CGSize collectionSize = collectionLayoutContainer.collectionSize;
            CGSize contentFittingSize = LWZFittingSizeForFloatRange(layoutRange, collectionViewLayoutDirection);
            CGSize contentLayoutSize = [layout layoutSizeToFit:contentFittingSize forOrthogonalContentInSection:section scrollDirection:groupViewLayoutDirection];
            
            contentLayoutSize = LWZLayoutSizeAdjustGroup(contentLayoutSize, contentFittingSize, collectionViewLayoutDirection);
            UIEdgeInsets contentInsets = container.contentInsets;
            UIEdgeInsets groupInsets = UIEdgeInsetsZero;
            CGRect groupFrame = CGRectZero;
            switch ( collectionViewLayoutDirection ) {
                case UICollectionViewScrollDirectionVertical: {
                    groupFrame.origin.y = offset;
                    groupFrame.origin.x = 0;
                    groupFrame.size.width = collectionSize.width;
                    groupFrame.size.height = contentLayoutSize.height;
                    groupInsets.left = collectionLayoutContainer.layoutInsets.left + sectionLayoutContainer.layoutInsets.left + contentInsets.left;
                    groupInsets.right = collectionLayoutContainer.layoutInsets.right + sectionLayoutContainer.layoutInsets.right + contentInsets.right;
                }
                    break;
                case UICollectionViewScrollDirectionHorizontal: {
                    groupFrame.origin.x = offset;
                    groupFrame.origin.y = 0;
                    groupFrame.size.height = collectionSize.height;
                    groupFrame.size.width = contentLayoutSize.width;
                    groupInsets.top = collectionLayoutContainer.layoutInsets.top + sectionLayoutContainer.layoutInsets.top + contentInsets.top;
                    groupInsets.bottom = collectionLayoutContainer.layoutInsets.bottom + sectionLayoutContainer.layoutInsets.bottom + contentInsets.bottom;
                }
                    break;
            }
            
            LWZCollectionLayoutContentOrthogonalScrollingBehavior behavior = [layout orthogonalContentScrollingBehaviorInSection:section];
            UICollectionView *groupView = [UICollectionView.alloc initWithFrame:groupFrame collectionViewLayout:[_LWZCollectionViewNestedGroupViewLayout.alloc initWithParentLayout:layout inSection:section scrollDirection:groupViewLayoutDirection orthogonalScrollingBehavior:behavior]];
            groupView.contentInset = groupInsets;
            groupView.backgroundColor = UIColor.clearColor;
            groupView.dataSource = collectionView.dataSource;
            groupView.delegate = collectionView.delegate;
            groupView.hidden = LWZFloatRangeRectCompare(groupFrame, collectionView.bounds, collectionViewLayoutDirection) != LWZFloatRangeComparisonResultIntersecting;
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
    }
    return nil;
}

UIKIT_STATIC_INLINE CGSize
LWZLayoutSizeAdjustGroup(CGSize size, CGSize fittingSize, UICollectionViewScrollDirection direction) {
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
@end
