//
//  LWZCollectionSizes.m
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/3/26.
//

#import "LWZCollectionSizes.h"
#import "LWZCollectionInternals.h"

/**
 缓存item等数据的size;
 */
@implementation LWZCollectionSizes {
    LWZCollectionProvider *_collectionProvider;
}
- (instancetype)initWithCollectionProvider:(LWZCollectionProvider *)collectionProvider {
    self = [super init];
    if ( self ) {
        _collectionProvider = collectionProvider;
    }
    return self;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSectionHeaderFooter *header = [_collectionProvider headerForSectionAtIndex:index];
    if ( header != nil ) {
        if ( header.needsLayout ) {
            header.layoutSize = [header layoutSizeThatFits:fittingSize inSection:[_collectionProvider sectionAtIndex:index] atIndex:index scrollDirection:scrollDirection];
        }
        return header.layoutSize;
    }
    return CGSizeZero;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionItem *item = [_collectionProvider itemAtIndexPath:indexPath];
    if ( item != nil ) {
        if ( item.needsLayout ) {
            item.layoutSize = [item layoutSizeThatFits:fittingSize inSection:[_collectionProvider sectionAtIndex:indexPath.section] atIndexPath:indexPath scrollDirection:scrollDirection];
        }
        return item.layoutSize;
    }
    return CGSizeZero;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSectionHeaderFooter *footer = [_collectionProvider footerForSectionAtIndex:index];
    if ( footer != nil ) {
        if ( footer.needsLayout ) {
            footer.layoutSize = [footer layoutSizeThatFits:fittingSize inSection:[_collectionProvider sectionAtIndex:index] atIndex:index scrollDirection:scrollDirection];
        }
        return footer.layoutSize;
    }
    return CGSizeZero;
}

- (CGRect)decorationRelativeRectToFit:(CGRect)rect forSectionAtIndexPath:(NSIndexPath *)indexPath {
    return [self _relativeRectToFit:rect forDecoration:[_collectionProvider sectionAtIndex:indexPath.section].decoration atIndexPath:indexPath];
}
- (CGRect)decorationRelativeRectToFit:(CGRect)rect forHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return [self _relativeRectToFit:rect forDecoration:[_collectionProvider headerForSectionAtIndex:indexPath.section].decoration atIndexPath:indexPath];
}
- (CGRect)decorationRelativeRectToFit:(CGRect)rect forItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self _relativeRectToFit:rect forDecoration:[_collectionProvider itemAtIndexPath:indexPath].decoration atIndexPath:indexPath];
}
- (CGRect)decorationRelativeRectToFit:(CGRect)rect forFooterAtIndexPath:(NSIndexPath *)indexPath {
    return [self _relativeRectToFit:rect forDecoration:[_collectionProvider footerForSectionAtIndex:indexPath.section].decoration atIndexPath:indexPath];
}

- (CGRect)_relativeRectToFit:(CGRect)rect forDecoration:(nullable LWZCollectionDecoration *)decoration atIndexPath:(NSIndexPath *)indexPath {
    if ( decoration != nil ) {
        if ( decoration.needsLayout ) {
            decoration.relativeRect = [decoration relativeRectToFit:rect atIndexPath:indexPath];
        }
        return decoration.relativeRect;
    }
    return CGRectZero;
}

- (void)invalidateAllPresentationSizes {
    [_collectionProvider enumerateSectionsUsingBlock:^(__kindof LWZCollectionSection * _Nonnull section, NSInteger idx, BOOL * _Nonnull stop) {
        [section setNeedsLayout];
    }];
}
@end

#import "LWZCollectionLayoutSolver.h"
#import "LWZCollectionLayoutContainer.h"
#import "LWZCollectionViewLayoutSubclass.h"

@interface LWZCollectionSizesSimulatedLayout : NSObject<LWZCollectionMultipleLayout>
- (instancetype)initWithSections:(NSArray<LWZCollectionSection *> *)sections;

@property (nonatomic, strong, readonly) NSArray<LWZCollectionSection *> *sections;
@end

@implementation LWZCollectionSizesSimulatedLayout
- (instancetype)initWithSections:(NSArray<LWZCollectionSection *> *)sections {
    self = [super init];
    if ( self ) {
        _sections = sections;
    }
    return self;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return _sections[section].numberOfItems;
}

- (UIEdgeInsets)edgeSpacingsForSectionAtIndex:(NSInteger)section {
    return _sections[section].edgeSpacings;
}

- (UIEdgeInsets)contentInsetsForSectionAtIndex:(NSInteger)section {
    return _sections[section].contentInsets;
}

- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _sections[section].minimumInteritemSpacing;
}

- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _sections[section].minimumLineSpacing;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSection *collectionSection = _sections[section];
    return [collectionSection.header layoutSizeThatFits:fittingSize inSection:collectionSection atIndex:section scrollDirection:scrollDirection];
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(nonnull NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSection *collectionSection = _sections[indexPath.section];
    return [[collectionSection itemAtIndex:indexPath.item] layoutSizeThatFits:fittingSize inSection:collectionSection atIndexPath:indexPath scrollDirection:scrollDirection];
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSection *collectionSection = _sections[section];
    return [collectionSection.footer layoutSizeThatFits:fittingSize inSection:collectionSection atIndex:section scrollDirection:scrollDirection];
}

- (CGFloat)zIndexForHeaderInSection:(NSInteger)section { return 0.0; }
- (CGFloat)zIndexForItemAtIndexPath:(NSIndexPath *)indexPath { return 0.0; }
- (CGFloat)zIndexForFooterInSection:(NSInteger)section { return 0.0; }

- (nullable NSString *)decorationViewKindForCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath { return nil; }
- (CGRect)decorationRelativeRectToFit:(CGRect)fitsRect forCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath { return CGRectZero; }
- (CGFloat)decorationZIndexForCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath { return 0.0; }
- (nullable id)decorationUserInfoForCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath { return nil; }

#pragma mark -

- (CGFloat)layoutWeightForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [_sections[indexPath.section] itemAtIndex:indexPath.item].weight;
}

- (LWZCollectionLayoutAlignment)layoutAlignmentForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [_sections[indexPath.section] itemAtIndex:indexPath.item].layoutAlignment;
}

- (NSInteger)layoutNumberOfArrangedItemsPerLineInSection:(NSInteger)section {
    return [_sections[section] numberOfArrangedItemsPerLine];
}

- (nonnull NSArray<LWZCollectionTemplateGroup *> *)layoutTemplateContainerGroupsInSection:(NSInteger)section {
    return [_sections[section] layoutTemplateContainerGroups];
}

- (LWZCollectionLayoutType)layoutTypeForItemsInSection:(NSInteger)section {
    return [_sections[section] layoutType];
}
@end

@implementation LWZCollectionSection (LWZCollectionSizesAdditions)
/// 计算传入的 sections 布局需要的大小
///
///     必须指定每个 section 的 `layoutType`;
+ (CGSize)layoutSizeThatFits:(CGSize)size forSections:(NSArray<LWZCollectionSection *> *)sections scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [self layoutSizeThatFits:size forSections:sections scrollDirection:scrollDirection sectionSpacing:0.0];
}

+ (CGSize)layoutSizeThatFits:(CGSize)size forSections:(NSArray<LWZCollectionSection *> *)sections scrollDirection:(UICollectionViewScrollDirection)scrollDirection sectionSpacing:(CGFloat)sectionSpacing {
    if ( sections.count == 0 ) return CGSizeZero;
    
    LWZCollectionSizesSimulatedLayout *layout = [LWZCollectionSizesSimulatedLayout.alloc initWithSections:sections];
    LWZCollectionMultipleLayoutSolver *solver = [LWZCollectionMultipleLayoutSolver.alloc initWithLayout:layout];
    
    LWZCollectionLayoutContainer *collectionLayoutContainer = [LWZCollectionLayoutContainer.alloc initWithCollectionSize:size direction:scrollDirection collectionContentInsets:UIEdgeInsetsZero collectionSafeAreaInsets:UIEdgeInsetsZero ignoredCollectionSafeAreaInsets:YES];
    CGFloat offset = 0;
    switch ( scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            offset = collectionLayoutContainer.layoutInsets.top;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            offset = collectionLayoutContainer.layoutInsets.left;
        }
            break;
    }
    
    NSInteger numberOfSections = sections.count;
    for ( NSInteger currentIndex = 0 ; currentIndex < numberOfSections;  ++ currentIndex ) {
        
        // sectionSpacing
        if ( sectionSpacing != 0 && currentIndex != 0 ) {
            offset += sectionSpacing;
        }
        
        LWZCollectionSection *section = sections[currentIndex];
        NSAssert(section.layoutType != LWZCollectionLayoutTypeUnspecified, @"必须指定 section 的 layoutType !");
        
        UIEdgeInsets sectionEdgeSpacings = section.edgeSpacings;
        UIEdgeInsets sectionContentInsets = section.contentInsets;
        
        LWZSectionLayoutContainer *sectionLayoutContainer = [LWZSectionLayoutContainer.alloc initWithCollectionLayoutContainer:collectionLayoutContainer sectionEdgeSpacings:sectionEdgeSpacings sectionContentInsets:sectionContentInsets];
         
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical: {
                offset += sectionLayoutContainer.layoutInsets.top;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal: {
                offset += sectionLayoutContainer.layoutInsets.left;
            }
                break;
        }
        
        NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForItem:0 inSection:currentIndex];
        // header
        LWZCollectionViewLayoutAttributes *_Nullable headerAttributes = [solver layoutAttributesForSupplementaryItemWithKind:UICollectionElementKindSectionHeader indexPath:supplementaryViewIndexPath offset:offset container:sectionLayoutContainer];
        if ( headerAttributes != nil ) {
            offset = LWZCollectionViewLayoutAttributesGetMaxOffset(headerAttributes, scrollDirection);
        }
        
        // cells
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                offset += sectionContentInsets.top;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                offset += sectionContentInsets.left;
                break;
        }
         
        NSArray<LWZCollectionViewLayoutAttributes *> *_Nullable cellAttributesObjects = [solver layoutAttributesObjectsForItemsWithSection:currentIndex offset:offset container:sectionLayoutContainer];
        
        if ( cellAttributesObjects.count != 0 ) {
            offset = LWZCollectionViewLayoutAttributesGetMaxOffset(cellAttributesObjects, scrollDirection);
        }

        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                offset += sectionContentInsets.bottom;
                break;
            case UICollectionViewScrollDirectionHorizontal:
                offset += sectionContentInsets.right;
                break;
        }
        
        // footer
        LWZCollectionViewLayoutAttributes *_Nullable footerAttributes = [solver layoutAttributesForSupplementaryItemWithKind:UICollectionElementKindSectionFooter indexPath:supplementaryViewIndexPath offset:offset container:sectionLayoutContainer];
        
        if ( footerAttributes != nil ) {
            offset = LWZCollectionViewLayoutAttributesGetMaxOffset(footerAttributes, scrollDirection);
        }

        //
        switch ( scrollDirection ) {
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
    switch ( scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            offset += collectionLayoutContainer.layoutInsets.bottom;
            
            contentHeight = offset;
            contentWidth = size.width;
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            offset += collectionLayoutContainer.layoutInsets.right;
            
            contentWidth = offset;
            contentHeight = size.height;
        }
            break;
    }
    
    CGSize contentSize = CGSizeMake(contentWidth, contentHeight);
    return contentSize;
}
@end
