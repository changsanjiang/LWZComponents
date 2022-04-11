//
//  LWZCollectionLayoutContainer.m
//  SJTestAutoLayout_Example
//
//  Created by 蓝舞者 on 2021/11/9.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionLayoutContainer.h"

@implementation LWZCollectionLayoutContainer
- (instancetype)initWithCollectionSize:(CGSize)collectionSize direction:(UICollectionViewScrollDirection)direction collectionContentInsets:(UIEdgeInsets)collectionContentInsets {
    self = [super init];
    if ( self ) {
        _collectionSize = collectionSize;
        _layoutDirection = direction;
        
        CGFloat minLayoutRange = 0;
        CGFloat maxLayoutRange = 0;
        switch ( direction ) {
            case UICollectionViewScrollDirectionVertical: {
                minLayoutRange = 0;
                maxLayoutRange = collectionSize.width - (collectionContentInsets.left + collectionContentInsets.right);
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                minLayoutRange = 0;
                maxLayoutRange = collectionSize.height - (collectionContentInsets.top + collectionContentInsets.bottom);
            }
                break;
        }
        _layoutRange = UIFloatRangeMake(minLayoutRange, maxLayoutRange);
        
        
        CGSize layoutContainerSize = CGSizeZero;
        layoutContainerSize.width = collectionSize.width - (collectionContentInsets.left + collectionContentInsets.right);
        layoutContainerSize.height = collectionSize.height - (collectionContentInsets.top + collectionContentInsets.bottom);
        _layoutContainerSize = layoutContainerSize;
    }
    return self;
}

- (instancetype)initWithCollectionSize:(CGSize)collectionSize direction:(UICollectionViewScrollDirection)direction collectionContentInsets:(UIEdgeInsets)contentInsets collectionSafeAreaInsets:(UIEdgeInsets)collectionSafeAreaInsets ignoredCollectionSafeAreaInsets:(BOOL)isIgnoredSafeAreaInsets {
    self = [self initWithCollectionSize:collectionSize direction:direction collectionContentInsets:contentInsets];
    if ( self ) {
        if ( !isIgnoredSafeAreaInsets ) {
            _layoutInsets = collectionSafeAreaInsets;
            CGFloat minLayoutRange = _layoutRange.minimum;
            CGFloat maxLayoutRange = _layoutRange.maximum;
            switch ( direction ) {
                case UICollectionViewScrollDirectionVertical: {
                    minLayoutRange += collectionSafeAreaInsets.left;
                    maxLayoutRange -= collectionSafeAreaInsets.right;
                }
                    break;
                case UICollectionViewScrollDirectionHorizontal: {
                    minLayoutRange += collectionSafeAreaInsets.top;
                    maxLayoutRange -= collectionSafeAreaInsets.bottom;
                }
                    break;
            }
            _layoutRange = UIFloatRangeMake(minLayoutRange, maxLayoutRange);
            
            CGSize layoutContainerSize = _layoutContainerSize;
            layoutContainerSize.width -= collectionSafeAreaInsets.left + collectionSafeAreaInsets.right;
            layoutContainerSize.height -= collectionSafeAreaInsets.top + collectionSafeAreaInsets.bottom;
            _layoutContainerSize = layoutContainerSize;
        }
    }
    return self;
}
@end


@implementation LWZSectionLayoutContainer
- (instancetype)initWithCollectionLayoutContainer:(LWZCollectionLayoutContainer *)collectionLayoutContainer sectionEdgeSpacings:(UIEdgeInsets)edgeSpacings sectionContentInsets:(UIEdgeInsets)contentInsets {
    self = [super init];
    if ( self ) {
        _collectionLayoutContainer = collectionLayoutContainer;
        _layoutInsets = edgeSpacings;
        _contentInsets = contentInsets;
        UIFloatRange collectionLayoutRange = collectionLayoutContainer.layoutRange;
        CGFloat minLayoutRange = collectionLayoutRange.minimum;
        CGFloat maxLayoutRange = collectionLayoutRange.maximum;
        UICollectionViewScrollDirection direction = collectionLayoutContainer.layoutDirection;
        switch ( direction ) {
            case UICollectionViewScrollDirectionVertical: {
                minLayoutRange += edgeSpacings.left;
                maxLayoutRange -= edgeSpacings.right;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                minLayoutRange += edgeSpacings.top;
                maxLayoutRange -= edgeSpacings.bottom;
            }
                break;
        }
        // ranges
        // - section
        _layoutRange = UIFloatRangeMake(minLayoutRange, maxLayoutRange);
        // - headerFooter
        _layoutRangeOfHeaderFooter = _layoutRange;
        // - item
        CGFloat minItemLayoutRange = minLayoutRange;
        CGFloat maxItemLayoutRange = maxLayoutRange;
        switch ( direction ) {
            case UICollectionViewScrollDirectionVertical: {
                minItemLayoutRange += contentInsets.left;
                maxItemLayoutRange -= contentInsets.right;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                minItemLayoutRange += contentInsets.top;
                maxItemLayoutRange -= contentInsets.bottom;
            }
                break;
        }
        _layoutRangeOfItem = UIFloatRangeMake(minItemLayoutRange, maxItemLayoutRange);
        _layoutDirection = direction;
        
        CGSize layoutContainerSizeOfItem = collectionLayoutContainer.layoutContainerSize;
        layoutContainerSizeOfItem.width -= (edgeSpacings.left + edgeSpacings.right) + (contentInsets.left + contentInsets.right);
        layoutContainerSizeOfItem.height -= (edgeSpacings.top + edgeSpacings.bottom) + (contentInsets.top + contentInsets.bottom);
        _layoutContainerSizeOfItem = layoutContainerSizeOfItem;
    }
    return self;
}
@end


#pragma mark - Template

@interface LWZCollectionTemplateDimension ()
@property (nonatomic) LWZCollectionTemplateDimensionSemantic semantic;
@property (nonatomic) CGFloat dimension;
@end
@implementation LWZCollectionTemplateDimension
- (instancetype)initWithFractionalWidthDimension:(CGFloat)dimension {
    return [self initWithDimension:dimension semantic:LWZCollectionTemplateDimensionSemanticFractionalWidth];
}
- (instancetype)initWithFractionalHeightDimension:(CGFloat)dimension {
    return [self initWithDimension:dimension semantic:LWZCollectionTemplateDimensionSemanticFractionalHeight];
}
- (instancetype)initWithAbsoluteDimension:(CGFloat)dimension {
    return [self initWithDimension:dimension semantic:LWZCollectionTemplateDimensionSemanticAbsolute];
}
- (instancetype)initWithDimension:(CGFloat)dimension semantic:(LWZCollectionTemplateDimensionSemantic)semantic {
    self = [super init];
    if ( self ) {
        _semantic = semantic;
        _dimension = dimension;
    }
    return self;
}
@end


@implementation LWZCollectionTemplateSize
- (instancetype)initWithWidthDimension:(LWZCollectionTemplateDimension *)widthDimension heightDimension:(LWZCollectionTemplateDimension *)heightDimension {
    self = [super init];
    if ( self ) {
        _width = widthDimension;
        _height = heightDimension;
    }
    return self;
}
@end


@implementation LWZCollectionTemplateItem
- (instancetype)initWithSize:(LWZCollectionTemplateSize *)size {
    self = [super init];
    if ( self ) {
        _size = size;
    }
    return self;
}
@end

@implementation LWZCollectionTemplateContainer
- (instancetype)initWithSize:(LWZCollectionTemplateSize *)size items:(NSArray<LWZCollectionTemplateItem *> *)items {
    self = [super initWithSize:size];
    if ( self ) {
        _items = items.copy;
    }
    return self;
}
@end

@implementation LWZCollectionTemplateGroup
- (instancetype)initWithSize:(LWZCollectionTemplateSize *)size containers:(NSArray<LWZCollectionTemplateContainer *> *)containers {
    self = [super initWithSize:size];
    if ( self ) {
        _containers = containers;
    }
    return self;
}
@end

@implementation LWZCollectionTemplate
+ (NSArray<LWZCollectionTemplateGroup *> *)templateWithBuildBlock:(void(^)(LWZCollectionTemplateBuilder *make))block {
    LWZCollectionTemplateBuilder *builder = [LWZCollectionTemplateBuilder.alloc init];
    block(builder);
    return builder.groups;
}
@end

UIKIT_STATIC_INLINE CGSize
LWZCollectionTemplateItemLayoutSize(LWZCollectionTemplateSize *size, CGSize containerSize) {
    CGSize layoutSize = CGSizeZero;
    LWZCollectionTemplateDimension *widthDimension = size.width;
    LWZCollectionTemplateDimension *heightDimension = size.height;
    switch ( widthDimension.semantic ) {
        case LWZCollectionTemplateDimensionSemanticFractionalWidth:
            layoutSize.width = widthDimension.dimension * containerSize.width;
            break;
        case LWZCollectionTemplateDimensionSemanticFractionalHeight:
            layoutSize.width = widthDimension.dimension *containerSize.height;
            break;
        case LWZCollectionTemplateDimensionSemanticAbsolute:
            layoutSize.width = widthDimension.dimension;
            break;
    }
    
    switch ( heightDimension.semantic ) {
        case LWZCollectionTemplateDimensionSemanticFractionalWidth:
            layoutSize.height = heightDimension.dimension * containerSize.width;
            break;
        case LWZCollectionTemplateDimensionSemanticFractionalHeight:
            layoutSize.height = heightDimension.dimension * containerSize.height;
            break;
        case LWZCollectionTemplateDimensionSemanticAbsolute:
            layoutSize.height = heightDimension.dimension;
            break;
    }
    return layoutSize;
}

@interface LWZCollectionTemplateSolverResult : NSObject
- (instancetype)initWithFrame:(CGRect)frame; // frame in groups?
@property (nonatomic, readonly) CGRect frame;
@end

@implementation LWZCollectionTemplateSolverResult
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if ( self ) {
        _frame = frame;
    }
    return self;
}
@end

@implementation LWZCollectionTemplateSolver {
    NSMutableArray<NSValue *> *mAllItemLayoutFrames;
}
- (instancetype)initWithGroups:(NSArray<LWZCollectionTemplateGroup *> *)groups scrollDirection:(UICollectionViewScrollDirection)scrollDirection numberOfItems:(NSInteger)numberOfItems lineSpacing:(CGFloat)lineSpacing itemSpacing:(CGFloat)itemSpacing containerSize:(CGSize)containerSize {
    self = [super init];
    if ( self ) {
        NSMutableArray<LWZCollectionTemplateSolverResult *> *results = NSMutableArray.array;
        CGPoint groupOrigin = CGPointZero;
        for ( LWZCollectionTemplateGroup *group in groups ) {
            CGSize groupLayoutSize = LWZCollectionTemplateItemLayoutSize(group.size, containerSize);
            NSArray<LWZCollectionTemplateContainer *> *containers = group.containers;
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
            for ( LWZCollectionTemplateContainer *container in containers ) {
                CGSize containerLayoutSize = LWZCollectionTemplateItemLayoutSize(container.size, containerContainerSize);
                NSArray<LWZCollectionTemplateItem *> *items = container.items;
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
                for ( LWZCollectionTemplateItem *item in container.items ) {
                    itemFrame.origin = itemOrigin;
                    itemFrame.size = LWZCollectionTemplateItemLayoutSize(item.size, itemContainerSize);
                    
                    [results addObject:[LWZCollectionTemplateSolverResult.alloc initWithFrame:itemFrame]];
                    
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
            LWZCollectionTemplateSolverResult *result = results[idx];
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
    LWZCollectionTemplateDimension *mDimension;
}
- (instancetype)initWithDimension:(LWZCollectionTemplateDimension *)dimension;
@end
@implementation LWZCollectionTemplateDimensionBuilder
- (instancetype)initWithDimension:(LWZCollectionTemplateDimension *)dimension {
    self = [super init];
    if ( self ) {
        mDimension = dimension;
    }
    return self;
}
- (LWZCollectionTemplateDimensionBuilder * _Nonnull (^)(LWZCollectionTemplateDimensionSemantic))semantic {
    return ^LWZCollectionTemplateDimensionBuilder *(LWZCollectionTemplateDimensionSemantic semantic){
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
        self->mDimension.semantic = LWZCollectionTemplateDimensionSemanticFractionalWidth;
        self->mDimension.dimension = dimension;
    };
}
- (void (^)(CGFloat))fractionalHeight {
    return ^(CGFloat dimension){
        self->mDimension.semantic = LWZCollectionTemplateDimensionSemanticFractionalHeight;
        self->mDimension.dimension = dimension;
    };
}
- (void (^)(CGFloat))absolute {
    return ^(CGFloat dimension){
        self->mDimension.semantic = LWZCollectionTemplateDimensionSemanticAbsolute;
        self->mDimension.dimension = dimension;
    };
}
@end

@interface LWZCollectionTemplateItemBuilder () {
    LWZCollectionTemplateSize *mSize;
    LWZCollectionTemplateDimensionBuilder *mWidth;
    LWZCollectionTemplateDimensionBuilder *mHeight;
}
@property (nonatomic, readonly) LWZCollectionTemplateSize *size;
@end
@implementation LWZCollectionTemplateItemBuilder
- (instancetype)init {
    self = [super init];
    if ( self ) {
        mSize = [LWZCollectionTemplateSize.alloc initWithWidthDimension:[LWZCollectionTemplateDimension.alloc initWithFractionalWidthDimension:1.0]
                                                              heightDimension:[LWZCollectionTemplateDimension.alloc initWithFractionalHeightDimension:1.0]];
        
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
- (LWZCollectionTemplateSize *)size {
    return mSize;
}
@end

@interface LWZCollectionTemplateContainerBuilder () {
    NSMutableArray<LWZCollectionTemplateItem *> *mItems;
}
@property (nonatomic, readonly) NSArray<LWZCollectionTemplateItem *> *items;
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
        [self->mItems addObject:[LWZCollectionTemplateItem.alloc initWithSize:builder.size]];
    };
}
- (NSArray<LWZCollectionTemplateItem *> *)items {
    return mItems;
}
@end

@interface LWZCollectionTemplateGroupBuilder () {
    NSMutableArray<LWZCollectionTemplateContainer *> *mContainers;
}
@property (nonatomic, readonly) NSArray<LWZCollectionTemplateContainer *> *containers;
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
        [self->mContainers addObject:[LWZCollectionTemplateContainer.alloc initWithSize:builder.size items:builder.items]];
    };
}

- (NSArray<LWZCollectionTemplateContainer *> *)containers {
    return mContainers;
}
@end


@interface LWZCollectionTemplateBuilder () {
    NSMutableArray<LWZCollectionTemplateGroup *> *mGroups;
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
        [self->mGroups addObject:[LWZCollectionTemplateGroup.alloc initWithSize:builder.size containers:builder.containers]];
    };
}
- (NSArray<LWZCollectionTemplateGroup *> *)groups {
    return mGroups;
}
@end
