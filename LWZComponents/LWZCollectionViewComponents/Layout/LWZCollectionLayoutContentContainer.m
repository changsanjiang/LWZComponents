//
//  LWZCollectionLayoutContentContainer.m
//  SJTestAutoLayout_Example
//
//  Created by changsanjiang on 2021/11/9.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionLayoutContentContainer.h"

@implementation LWZCollectionLayoutCollectionContentContainer
- (instancetype)initWithCollectionSize:(CGSize)collectionSize direction:(UICollectionViewScrollDirection)direction collectionContentInsets:(UIEdgeInsets)collectionContentInsets collectionSafeAreaInsets:(UIEdgeInsets)safeAreaInsets {
    self = [super init];
    if ( self ) {
        _collectionSize = collectionSize;
        _layoutDirection = direction;
        
        CGFloat layoutRangeMin = 0;
        CGFloat layoutRangeMax = 0;
        switch ( direction ) {
            case UICollectionViewScrollDirectionVertical: {
                layoutRangeMin = 0;
                layoutRangeMax = collectionSize.width - (collectionContentInsets.left + collectionContentInsets.right);
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                layoutRangeMin = 0;
                layoutRangeMax = collectionSize.height - (collectionContentInsets.top + collectionContentInsets.bottom);
            }
                break;
        }
        _layoutRange = UIFloatRangeMake(layoutRangeMin, layoutRangeMax);
        
        
        CGSize layoutContainerSize = CGSizeZero;
        layoutContainerSize.width = collectionSize.width - (collectionContentInsets.left + collectionContentInsets.right);
        layoutContainerSize.height = collectionSize.height - (collectionContentInsets.top + collectionContentInsets.bottom);
        _layoutContainerSize = layoutContainerSize;
    }
    return self;
}

- (instancetype)initWithCollectionSize:(CGSize)collectionSize direction:(UICollectionViewScrollDirection)direction collectionContentInsets:(UIEdgeInsets)contentInsets collectionSafeAreaInsets:(UIEdgeInsets)collectionSafeAreaInsets ignoredCollectionSafeAreaInsets:(BOOL)isIgnoredSafeAreaInsets {
    self = [self initWithCollectionSize:collectionSize direction:direction collectionContentInsets:contentInsets collectionSafeAreaInsets:collectionSafeAreaInsets];
    if ( self ) {
        if ( !isIgnoredSafeAreaInsets ) {
            _layoutInsets = collectionSafeAreaInsets;
            CGFloat layoutRangeMin = _layoutRange.minimum;
            CGFloat layoutRangeMax = _layoutRange.maximum;
            switch ( direction ) {
                case UICollectionViewScrollDirectionVertical: {
                    layoutRangeMin += collectionSafeAreaInsets.left;
                    layoutRangeMax -= collectionSafeAreaInsets.right;
                }
                    break;
                case UICollectionViewScrollDirectionHorizontal: {
                    layoutRangeMin += collectionSafeAreaInsets.top;
                    layoutRangeMax -= collectionSafeAreaInsets.bottom;
                }
                    break;
            }
            _layoutRange = UIFloatRangeMake(layoutRangeMin, layoutRangeMax);
            
            CGSize layoutContainerSize = _layoutContainerSize;
            layoutContainerSize.width -= collectionSafeAreaInsets.left + collectionSafeAreaInsets.right;
            layoutContainerSize.height -= collectionSafeAreaInsets.top + collectionSafeAreaInsets.bottom;
            _layoutContainerSize = layoutContainerSize;
        }
    }
    return self;
}
@end


@implementation LWZCollectionLayoutSectionContentContainer
- (instancetype)initWithCollectionContentContainer:(LWZCollectionLayoutCollectionContentContainer *)collectionContentContainer sectionEdgeSpacings:(UIEdgeInsets)edgeSpacings sectionContentInsets:(UIEdgeInsets)contentInsets {
    self = [super init];
    if ( self ) {
        _collectionContentContainer = collectionContentContainer;
        _layoutInsets = edgeSpacings;
        _contentInsets = contentInsets;
        UIFloatRange collectionContentLayoutRange = collectionContentContainer.layoutRange;
        CGFloat layoutRangeMin = collectionContentLayoutRange.minimum;
        CGFloat layoutRangeMax = collectionContentLayoutRange.maximum;
        UICollectionViewScrollDirection direction = collectionContentContainer.layoutDirection;
        switch ( direction ) {
            case UICollectionViewScrollDirectionVertical: {
                layoutRangeMin += edgeSpacings.left;
                layoutRangeMax -= edgeSpacings.right;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                layoutRangeMin += edgeSpacings.top;
                layoutRangeMax -= edgeSpacings.bottom;
            }
                break;
        }
        // ranges
        // - section
        _layoutRange = UIFloatRangeMake(layoutRangeMin, layoutRangeMax);
        // - headerFooter
        _headerFooterLayoutRange = _layoutRange;
        // - item
        CGFloat itemLayoutRangeMin = layoutRangeMin;
        CGFloat itemLayoutRangeMax = layoutRangeMax;
        switch ( direction ) {
            case UICollectionViewScrollDirectionVertical: {
                itemLayoutRangeMin += contentInsets.left;
                itemLayoutRangeMax -= contentInsets.right;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                itemLayoutRangeMin += contentInsets.top;
                itemLayoutRangeMax -= contentInsets.bottom;
            }
                break;
        }
        _itemLayoutRange = UIFloatRangeMake(itemLayoutRangeMin, itemLayoutRangeMax);
        _layoutDirection = direction;
        
        CGSize itemLayoutContainerSize = collectionContentContainer.layoutContainerSize;
        itemLayoutContainerSize.width -= (edgeSpacings.left + edgeSpacings.right) + (contentInsets.left + contentInsets.right);
        itemLayoutContainerSize.height -= (edgeSpacings.top + edgeSpacings.bottom) + (contentInsets.top + contentInsets.bottom);
        _itemLayoutContainerSize = itemLayoutContainerSize;
    }
    return self;
}
@end


#pragma mark - Template

@interface LWZCollectionLayoutTemplateDimension ()
@property (nonatomic) LWZCollectionLayoutTemplateDimensionSemantic semantic;
@property (nonatomic) CGFloat dimension;
@end
@implementation LWZCollectionLayoutTemplateDimension
- (instancetype)initWithFractionalWidthDimension:(CGFloat)dimension {
    return [self initWithDimension:dimension semantic:LWZCollectionLayoutTemplateDimensionSemanticFractionalWidth];
}
- (instancetype)initWithFractionalHeightDimension:(CGFloat)dimension {
    return [self initWithDimension:dimension semantic:LWZCollectionLayoutTemplateDimensionSemanticFractionalHeight];
}
- (instancetype)initWithAbsoluteDimension:(CGFloat)dimension {
    return [self initWithDimension:dimension semantic:LWZCollectionLayoutTemplateDimensionSemanticAbsolute];
}
- (instancetype)initWithDimension:(CGFloat)dimension semantic:(LWZCollectionLayoutTemplateDimensionSemantic)semantic {
    self = [super init];
    if ( self ) {
        _semantic = semantic;
        _dimension = dimension;
    }
    return self;
}
@end


@implementation LWZCollectionLayoutTemplateSize
- (instancetype)initWithWidthDimension:(LWZCollectionLayoutTemplateDimension *)widthDimension heightDimension:(LWZCollectionLayoutTemplateDimension *)heightDimension {
    self = [super init];
    if ( self ) {
        _width = widthDimension;
        _height = heightDimension;
    }
    return self;
}
@end


@implementation LWZCollectionLayoutTemplateItem
- (instancetype)initWithSize:(LWZCollectionLayoutTemplateSize *)size {
    self = [super init];
    if ( self ) {
        _size = size;
    }
    return self;
}
@end

@implementation LWZCollectionLayoutTemplateContainer
- (instancetype)initWithSize:(LWZCollectionLayoutTemplateSize *)size items:(NSArray<LWZCollectionLayoutTemplateItem *> *)items {
    self = [super initWithSize:size];
    if ( self ) {
        _items = items.copy;
    }
    return self;
}
@end

@implementation LWZCollectionLayoutTemplateGroup
- (instancetype)initWithSize:(LWZCollectionLayoutTemplateSize *)size containers:(NSArray<LWZCollectionLayoutTemplateContainer *> *)containers {
    self = [super initWithSize:size];
    if ( self ) {
        _containers = containers;
    }
    return self;
}
@end

@implementation LWZCollectionLayoutTemplate
+ (NSArray<LWZCollectionLayoutTemplateGroup *> *)build:(void(^)(LWZCollectionTemplateBuilder *make))block {
    LWZCollectionTemplateBuilder *builder = [LWZCollectionTemplateBuilder.alloc init];
    block(builder);
    return builder.groups;
}
@end

UIKIT_STATIC_INLINE CGSize
LWZCollectionTemplateItemLayoutSize(LWZCollectionLayoutTemplateSize *size, CGSize containerSize) {
    CGSize layoutSize = CGSizeZero;
    LWZCollectionLayoutTemplateDimension *widthDimension = size.width;
    LWZCollectionLayoutTemplateDimension *heightDimension = size.height;
    switch ( widthDimension.semantic ) {
        case LWZCollectionLayoutTemplateDimensionSemanticFractionalWidth:
            layoutSize.width = widthDimension.dimension * containerSize.width;
            break;
        case LWZCollectionLayoutTemplateDimensionSemanticFractionalHeight:
            layoutSize.width = widthDimension.dimension *containerSize.height;
            break;
        case LWZCollectionLayoutTemplateDimensionSemanticAbsolute:
            layoutSize.width = widthDimension.dimension;
            break;
    }
    
    switch ( heightDimension.semantic ) {
        case LWZCollectionLayoutTemplateDimensionSemanticFractionalWidth:
            layoutSize.height = heightDimension.dimension * containerSize.width;
            break;
        case LWZCollectionLayoutTemplateDimensionSemanticFractionalHeight:
            layoutSize.height = heightDimension.dimension * containerSize.height;
            break;
        case LWZCollectionLayoutTemplateDimensionSemanticAbsolute:
            layoutSize.height = heightDimension.dimension;
            break;
    }
    return layoutSize;
}

@interface LWZCollectionTemplateLayoutSolverResult : NSObject
- (instancetype)initWithFrame:(CGRect)frame; // frame in groups?
@property (nonatomic, readonly) CGRect frame;
@end

@implementation LWZCollectionTemplateLayoutSolverResult
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if ( self ) {
        _frame = frame;
    }
    return self;
}
@end

@implementation LWZCollectionTemplateLayoutSolver {
    NSMutableArray<NSValue *> *mAllItemLayoutFrames;
}
- (instancetype)initWithGroups:(NSArray<LWZCollectionLayoutTemplateGroup *> *)groups scrollDirection:(UICollectionViewScrollDirection)scrollDirection numberOfItems:(NSInteger)numberOfItems lineSpacing:(CGFloat)lineSpacing itemSpacing:(CGFloat)itemSpacing containerSize:(CGSize)containerSize {
    self = [super init];
    if ( self ) {
        NSMutableArray<LWZCollectionTemplateLayoutSolverResult *> *results = NSMutableArray.array;
        CGPoint groupOrigin = CGPointZero;
        for ( LWZCollectionLayoutTemplateGroup *group in groups ) {
            CGSize groupLayoutSize = LWZCollectionTemplateItemLayoutSize(group.size, containerSize);
            NSArray<LWZCollectionLayoutTemplateContainer *> *containers = group.containers;
            NSInteger containerCount = containers.count;
            CGSize containerContainerSize = groupLayoutSize;
            if ( containerCount > 1 ) {
                CGFloat spacings = (containerCount - 1) * itemSpacing;
                switch ( scrollDirection ) {
                    case UICollectionViewScrollDirectionVertical:
                        containerContainerSize.width -= spacings;
                        break;
                    case UICollectionViewScrollDirectionHorizontal:
                        containerContainerSize.height -= spacings;
                        break;
                }
            }
            
            CGPoint containerOrigin = groupOrigin;
            CGPoint itemOrigin = containerOrigin;
            for ( LWZCollectionLayoutTemplateContainer *container in containers ) {
                CGSize containerLayoutSize = LWZCollectionTemplateItemLayoutSize(container.size, containerContainerSize);
                NSArray<LWZCollectionLayoutTemplateItem *> *items = container.items;
                NSInteger itemCount = items.count;
                CGSize itemContainerSize = containerLayoutSize;
                if ( itemCount > 1 ) {
                    CGFloat spacings = (itemCount - 1) * lineSpacing;
                    switch ( scrollDirection ) {
                        case UICollectionViewScrollDirectionVertical: 
                            itemContainerSize.height -= spacings;
                            break;
                        case UICollectionViewScrollDirectionHorizontal:
                            itemContainerSize.width -= spacings;
                            break;
                    }
                }
 
                CGRect itemFrame = CGRectZero;
                for ( LWZCollectionLayoutTemplateItem *item in container.items ) {
                    itemFrame.origin = itemOrigin;
                    itemFrame.size = LWZCollectionTemplateItemLayoutSize(item.size, itemContainerSize);
                    
                    [results addObject:[LWZCollectionTemplateLayoutSolverResult.alloc initWithFrame:itemFrame]];
                    
                    switch ( scrollDirection ) {
                        case UICollectionViewScrollDirectionVertical:
                            itemOrigin.y = CGRectGetMaxY(itemFrame) + lineSpacing;
                            break;
                        case UICollectionViewScrollDirectionHorizontal:
                            itemOrigin.x = CGRectGetMaxX(itemFrame) + lineSpacing;
                            break;
                    }
                }
                
                switch ( scrollDirection ) {
                    case UICollectionViewScrollDirectionVertical:
                        containerOrigin.x += containerLayoutSize.width + itemSpacing;
                        break;
                    case UICollectionViewScrollDirectionHorizontal:
                        containerOrigin.y += containerLayoutSize.height + itemSpacing;
                        break;
                }
                itemOrigin = containerOrigin;
            }
            
            switch ( scrollDirection ) {
                case UICollectionViewScrollDirectionVertical:
                    groupOrigin.y += groupLayoutSize.height + lineSpacing;
                    break;
                case UICollectionViewScrollDirectionHorizontal:
                    groupOrigin.x += groupLayoutSize.width + lineSpacing;
                    break;
            }
        }
         
        NSInteger resultCount = results.count;
        CGRect allGroupsLayoutFrame = CGRectZero;
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                allGroupsLayoutFrame.size.height = CGRectGetMaxY(results.lastObject.frame);
                allGroupsLayoutFrame.size.width = containerSize.width;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                allGroupsLayoutFrame.size.width = CGRectGetMaxX(results.lastObject.frame);
                allGroupsLayoutFrame.size.height = containerSize.height;
            }
                break;
        }
        
        NSMutableArray *itemLayoutFrames = [NSMutableArray arrayWithCapacity:resultCount];
        CGRect itemLayoutFrame = CGRectZero;
        for ( NSInteger i = 0 ; i < numberOfItems ; ++ i ) {
            NSInteger idx = i % resultCount;
            NSInteger mult = i / resultCount;
            LWZCollectionTemplateLayoutSolverResult *result = results[idx];
            itemLayoutFrame = result.frame;
            if ( mult != 0 ) {
                switch ( scrollDirection ) {
                    case UICollectionViewScrollDirectionVertical:
                        itemLayoutFrame.origin.y += CGRectGetMaxY(allGroupsLayoutFrame) * mult + mult * lineSpacing;
                        break;
                    case UICollectionViewScrollDirectionHorizontal:
                        itemLayoutFrame.origin.x += CGRectGetMaxX(allGroupsLayoutFrame) * mult + mult * lineSpacing;
                        break;
                }
            }
            [itemLayoutFrames addObject:[NSValue valueWithCGRect:itemLayoutFrame]];
        }
        mAllItemLayoutFrames = itemLayoutFrames;
    }
    return self;
}

- (CGRect)itemLayoutFrameAtIndex:(NSInteger)index {
    return [mAllItemLayoutFrames[index] CGRectValue];
}
@end

@interface LWZCollectionTemplateDimensionBuilder () {
    LWZCollectionLayoutTemplateDimension *mDimension;
}
- (instancetype)initWithDimension:(LWZCollectionLayoutTemplateDimension *)dimension;
@end
@implementation LWZCollectionTemplateDimensionBuilder
- (instancetype)initWithDimension:(LWZCollectionLayoutTemplateDimension *)dimension {
    self = [super init];
    if ( self ) {
        mDimension = dimension;
    }
    return self;
}
- (LWZCollectionTemplateDimensionBuilder * _Nonnull (^)(LWZCollectionLayoutTemplateDimensionSemantic))semantic {
    return ^LWZCollectionTemplateDimensionBuilder *(LWZCollectionLayoutTemplateDimensionSemantic semantic){
        self->mDimension.semantic = semantic;
        return self;
    };
}
- (LWZCollectionTemplateDimensionBuilder * _Nonnull (^)(CGFloat))dimension {
    return ^LWZCollectionTemplateDimensionBuilder *(CGFloat dimension){
        self->mDimension.dimension = dimension;
        return self;
    };
}
- (void (^)(CGFloat))fractionalWidth {
    return ^(CGFloat dimension){
        self->mDimension.semantic = LWZCollectionLayoutTemplateDimensionSemanticFractionalWidth;
        self->mDimension.dimension = dimension;
    };
}
- (void (^)(CGFloat))fractionalHeight {
    return ^(CGFloat dimension){
        self->mDimension.semantic = LWZCollectionLayoutTemplateDimensionSemanticFractionalHeight;
        self->mDimension.dimension = dimension;
    };
}
- (void (^)(CGFloat))absolute {
    return ^(CGFloat dimension){
        self->mDimension.semantic = LWZCollectionLayoutTemplateDimensionSemanticAbsolute;
        self->mDimension.dimension = dimension;
    };
}
@end

@interface LWZCollectionTemplateItemBuilder () {
    LWZCollectionLayoutTemplateSize *mSize;
    LWZCollectionTemplateDimensionBuilder *mWidth;
    LWZCollectionTemplateDimensionBuilder *mHeight;
}
@property (nonatomic, readonly) LWZCollectionLayoutTemplateSize *size;
@end
@implementation LWZCollectionTemplateItemBuilder
- (instancetype)init {
    self = [super init];
    if ( self ) {
        mSize = [LWZCollectionLayoutTemplateSize.alloc initWithWidthDimension:[LWZCollectionLayoutTemplateDimension.alloc initWithFractionalWidthDimension:1.0]
                                                              heightDimension:[LWZCollectionLayoutTemplateDimension.alloc initWithFractionalHeightDimension:1.0]];
        
        mWidth = [LWZCollectionTemplateDimensionBuilder.alloc initWithDimension:mSize.width];
        mHeight = [LWZCollectionTemplateDimensionBuilder.alloc initWithDimension:mSize.height];
    }
    return self;
}
- (LWZCollectionTemplateDimensionBuilder *)width {
    return mWidth;
}
- (LWZCollectionTemplateDimensionBuilder *)height {
    return mHeight;
}
- (LWZCollectionLayoutTemplateSize *)size {
    return mSize;
}
@end

@interface LWZCollectionTemplateContainerBuilder () {
    NSMutableArray<LWZCollectionLayoutTemplateItem *> *mItems;
}
@property (nonatomic, readonly) NSArray<LWZCollectionLayoutTemplateItem *> *items;
@end
@implementation LWZCollectionTemplateContainerBuilder
- (instancetype)init {
    self = [super init];
    if ( self ) {
        mItems = NSMutableArray.array;
    }
    return self;
}
- (void (^)(void (^ _Nonnull)(LWZCollectionTemplateItemBuilder * _Nonnull)))addItem {
    return ^(void(^block)(LWZCollectionTemplateItemBuilder *item)){
        LWZCollectionTemplateItemBuilder *builder = [LWZCollectionTemplateItemBuilder.alloc init];
        block(builder);
        [self->mItems addObject:[LWZCollectionLayoutTemplateItem.alloc initWithSize:builder.size]];
    };
}
- (NSArray<LWZCollectionLayoutTemplateItem *> *)items {
    return mItems;
}
@end

@interface LWZCollectionTemplateGroupBuilder () {
    NSMutableArray<LWZCollectionLayoutTemplateContainer *> *mContainers;
}
@property (nonatomic, readonly) NSArray<LWZCollectionLayoutTemplateContainer *> *containers;
@end
@implementation LWZCollectionTemplateGroupBuilder
- (instancetype)init {
    self = [super init];
    if ( self ) {
        mContainers = NSMutableArray.array;
    }
    return self;
}
- (void (^)(void (^ _Nonnull)(LWZCollectionTemplateContainerBuilder * _Nonnull)))addContainer {
    return ^(void(^block)(LWZCollectionTemplateContainerBuilder *container)) {
        LWZCollectionTemplateContainerBuilder *builder = [LWZCollectionTemplateContainerBuilder.alloc init];
        block(builder);
        [self->mContainers addObject:[LWZCollectionLayoutTemplateContainer.alloc initWithSize:builder.size items:builder.items]];
    };
}

- (NSArray<LWZCollectionLayoutTemplateContainer *> *)containers {
    return mContainers;
}
@end


@interface LWZCollectionTemplateBuilder () {
    NSMutableArray<LWZCollectionLayoutTemplateGroup *> *mGroups;
}
@end
@implementation LWZCollectionTemplateBuilder
- (instancetype)init {
    self = [super init];
    if ( self ) {
        mGroups = NSMutableArray.array;
    }
    return self;
}
- (void (^)(void (^ _Nonnull)(LWZCollectionTemplateGroupBuilder * _Nonnull)))addGroup {
    return ^(void(^block)(LWZCollectionTemplateGroupBuilder *group)){
        LWZCollectionTemplateGroupBuilder *builder = [LWZCollectionTemplateGroupBuilder.alloc init];
        block(builder);
        [self->mGroups addObject:[LWZCollectionLayoutTemplateGroup.alloc initWithSize:builder.size containers:builder.containers]];
    };
}
- (NSArray<LWZCollectionLayoutTemplateGroup *> *)groups {
    return mGroups;
}
@end
