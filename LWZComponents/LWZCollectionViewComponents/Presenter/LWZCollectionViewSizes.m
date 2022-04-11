//
//  LWZCollectionViewSizes.m
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/3/26.
//

#import "LWZCollectionViewSizes.h"
#import "LWZCollectionInternals.h"

@implementation LWZCollectionViewSizes {
    LWZCollectionProvider *_provider;
}
- (instancetype)initWithProvider:(LWZCollectionProvider *)provider {
    self = [super init];
    if ( self ) {
        _provider = provider;
    }
    return self;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSectionHeaderFooter *header = [_provider headerForSectionAtIndex:index];
    if ( header != nil ) {
        if ( header.needsLayout ) {
            header.layoutSize = [header layoutSizeThatFits:fittingSize inSection:[_provider sectionAtIndex:index] atIndex:index scrollDirection:scrollDirection];
        }
        return header.layoutSize;
    }
    return CGSizeZero;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    if ( item != nil ) {
        if ( item.needsLayout ) {
            item.layoutSize = [item layoutSizeThatFits:fittingSize inSection:[_provider sectionAtIndex:indexPath.section] atIndexPath:indexPath scrollDirection:scrollDirection];
        }
        return item.layoutSize;
    }
    return CGSizeZero;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSectionHeaderFooter *footer = [_provider footerForSectionAtIndex:index];
    if ( footer != nil ) {
        if ( footer.needsLayout ) {
            footer.layoutSize = [footer layoutSizeThatFits:fittingSize inSection:[_provider sectionAtIndex:index] atIndex:index scrollDirection:scrollDirection];
        }
        return footer.layoutSize;
    }
    return CGSizeZero;
}

- (CGRect)relativeRectToFit:(CGRect)rect forSectionDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _relativeRectToFit:rect forDecoration:[_provider sectionAtIndex:indexPath.section].decoration atIndexPath:indexPath];
}
- (CGRect)relativeRectToFit:(CGRect)rect forHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _relativeRectToFit:rect forDecoration:[_provider headerForSectionAtIndex:indexPath.section].decoration atIndexPath:indexPath];
}
- (CGRect)relativeRectToFit:(CGRect)rect forItemDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _relativeRectToFit:rect forDecoration:[_provider itemAtIndexPath:indexPath].decoration atIndexPath:indexPath];
}
- (CGRect)relativeRectToFit:(CGRect)rect forFooterDecorationAtIndexPath:(NSIndexPath *)indexPath {
    return [self _relativeRectToFit:rect forDecoration:[_provider footerForSectionAtIndex:indexPath.section].decoration atIndexPath:indexPath];
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
    [_provider enumerateSectionsUsingBlock:^(__kindof LWZCollectionSection * _Nonnull section, NSInteger idx, BOOL * _Nonnull stop) {
        [section setNeedsLayout];
    }];
}

#pragma mark - collection view events

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    if ( item.tapHandler != nil ) {
        item.tapHandler(item, indexPath);
    }
    
    [item didSelectAtIndexPath:indexPath];
    
    LWZCollectionSection *section = [_provider sectionAtIndex:indexPath.section];
    [section didSelectItemAtIndexPath:indexPath];
}
- (void)didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    [item didDeselectAtIndexPath:indexPath];
    
    LWZCollectionSection *section = [_provider sectionAtIndex:indexPath.section];
    [section didDeselectItemAtIndexPath:indexPath];
}
- (void)willDisplayCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    /// 为防止数据已发生改变, 此处需要做一层相同判断
    if ( cell.class == item.cellClass ) {
        cell.lwz_bindingCollectionItem = item;
        [item willDisplayCell:cell forItemAtIndexPath:indexPath];
        
        LWZCollectionSection *section = [_provider sectionAtIndex:indexPath.section];
        [section didBindCellForItemAtIndexPath:indexPath];
    }
}
- (void)didEndDisplayingCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [_provider itemAtIndexPath:indexPath];
    /// dataSource 的数据随时可能发生变化(这会出当前 item 与 cell绑定的 item 不一致的情况), 为防止数据已发生改变, 此处需要做一层相同判断
    ///
    if ( cell.lwz_bindingCollectionItem == item ) {
        [item didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
        
        LWZCollectionSection *section = [_provider sectionAtIndex:indexPath.section];
        [section didUnbindCellForItemAtIndexPath:indexPath];
        
        cell.lwz_bindingCollectionItem = nil;
    }
}
- (void)willDisplaySupplementaryView:(__kindof UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionSectionHeaderFooter *headerFooter = nil;
    if      ( elementKind == UICollectionElementKindSectionHeader ) {
        headerFooter = [_provider headerForSectionAtIndex:indexPath.section];
    }
    else if ( elementKind == UICollectionElementKindSectionFooter ) {
        headerFooter = [_provider footerForSectionAtIndex:indexPath.section];
    }
    /// 为防止数据已发生改变, 此处需要做一层相同判断
    if ( headerFooter != nil && view.class == headerFooter.viewClass ) {
        view.lwz_bindingHeaderFooter = headerFooter;
        [headerFooter willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }
}
- (void)didEndDisplayingSupplementaryView:(__kindof UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionSectionHeaderFooter *headerFooter = nil;
    if      ( elementKind == UICollectionElementKindSectionHeader ) {
        headerFooter = [_provider headerForSectionAtIndex:indexPath.section];
    }
    else if ( elementKind == UICollectionElementKindSectionFooter ) {
        headerFooter = [_provider footerForSectionAtIndex:indexPath.section];
    }
    
    /// 为防止数据已发生改变, 此处需要做一层相同判断
    if ( headerFooter != nil && view.lwz_bindingHeaderFooter == headerFooter ) {
        [headerFooter didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
        view.lwz_bindingHeaderFooter = nil;
    }
}

- (void)updateVisibleViewsForCollectionView:(UICollectionView *)collectionView {
    LWZCollectionProvider *provider = _provider;
    for ( NSIndexPath *indexPath in collectionView.indexPathsForVisibleItems ) {
        LWZCollectionItem *item = [provider itemAtIndexPath:indexPath];
        if ( item.needsLayout ) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            if ( item == cell.lwz_bindingCollectionItem ) {
                [self willDisplayCell:[collectionView cellForItemAtIndexPath:indexPath] forItemAtIndexPath:indexPath];
            }
        }

        LWZCollectionSection *section = [provider sectionAtIndex:indexPath.section];
        LWZCollectionSectionHeaderFooter *header = section.header;
        if ( header.needsLayout ) {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
            UICollectionReusableView *view = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
            if ( view != nil && header == view.lwz_bindingHeaderFooter ) {
                [self willDisplaySupplementaryView:view forElementKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
            }
        }
        
        LWZCollectionSectionHeaderFooter *footer = section.footer;
        if ( footer.needsLayout ) {
            NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
            UICollectionReusableView *view = [collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:footerIndexPath];
            if ( view != nil && footer == view.lwz_bindingHeaderFooter ) {
                [self willDisplaySupplementaryView:view forElementKind:UICollectionElementKindSectionFooter atIndexPath:footerIndexPath];
            }
        }
    }
}
@end

#import "LWZCollectionLayoutSolver.h"
#import "LWZCollectionLayoutContainer.h"
#import "LWZCollectionViewLayoutSubclass.h"

@interface LWZCollectionViewSizesSimulatedLayout : NSObject<LWZCollectionMultipleLayout>
- (instancetype)initWithSections:(NSArray<LWZCollectionSection *> *)sections;

@property (nonatomic, strong, readonly) NSArray<LWZCollectionSection *> *sections;
@end

@implementation LWZCollectionViewSizesSimulatedLayout
- (instancetype)initWithSections:(NSArray<LWZCollectionSection *> *)sections {
    self = [super init];
    if ( self ) {
        _sections = sections;
    }
    return self;
}

- (UIEdgeInsets)contentInsetsForSectionAtIndex:(NSInteger)section {
    return _sections[section].contentInsets;
}

- (UIEdgeInsets)edgeSpacingsForSectionAtIndex:(NSInteger)section {
    return _sections[section].edgeSpacings;
}

- (nullable NSString *)elementKindForDecorationOfCategory:(LWZCollectionDecorationCategory)category atIndexPath:(nonnull NSIndexPath *)indexPath {
    LWZCollectionDecoration *decoration = [self _decorationForCategory:category atIndexPath:indexPath];
    return decoration != nil ? NSStringFromClass(decoration.viewClass) : nil;
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSection *collectionSection = _sections[section];
    return [collectionSection.footer layoutSizeThatFits:fittingSize inSection:collectionSection atIndex:section scrollDirection:scrollDirection];
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSection *collectionSection = _sections[section];
    return [collectionSection.header layoutSizeThatFits:fittingSize inSection:collectionSection atIndex:section scrollDirection:scrollDirection];
}

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(nonnull NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionSection *collectionSection = _sections[indexPath.section];
    return [[collectionSection itemAtIndex:indexPath.item] layoutSizeThatFits:fittingSize inSection:collectionSection atIndexPath:indexPath scrollDirection:scrollDirection];
}

- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _sections[section].minimumInteritemSpacing;
}

- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _sections[section].minimumLineSpacing;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return _sections.count;
}

- (CGRect)relativeRectToFit:(CGRect)fitsRect forDecorationOfCategory:(LWZCollectionDecorationCategory)category atIndexPath:(nonnull NSIndexPath *)indexPath {
    return [[self _decorationForCategory:category atIndexPath:indexPath] relativeRectThatFits:fitsRect atIndexPath:indexPath];
}

- (nullable id)userInfoForDecorationOfCategory:(LWZCollectionDecorationCategory)category atIndexPath:(nonnull NSIndexPath *)indexPath {
    return [self _decorationForCategory:category atIndexPath:indexPath].userInfo;
}

- (CGFloat)zIndexForDecorationOfCategory:(LWZCollectionDecorationCategory)category atIndexPath:(nonnull NSIndexPath *)indexPath {
    return [self _decorationForCategory:category atIndexPath:indexPath].zPosition;
}

- (CGFloat)zIndexForFooterInSection:(NSInteger)section {
    return _sections[section].footer.zPosition;
}

- (CGFloat)zIndexForHeaderInSection:(NSInteger)section {
    return _sections[section].header.zPosition;
}

- (CGFloat)zIndexForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [_sections[indexPath.section] itemAtIndex:indexPath.item].zPosition;
}

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

- (LWZCollectionDecoration *)_decorationForCategory:(LWZCollectionDecorationCategory)category atIndexPath:(nonnull NSIndexPath *)indexPath {
    LWZCollectionSection *section = _sections[indexPath.section];
    LWZCollectionDecoration *decoration = nil;
    switch ( category ) {
        case LWZCollectionDecorationCategorySection:
            decoration = section.decoration;
            break;
        case LWZCollectionDecorationCategoryHeader:
            decoration = section.header.decoration;
            break;
        case LWZCollectionDecorationCategoryItem:
            decoration = [section itemAtIndex:indexPath.item].decoration;
            break;
        case LWZCollectionDecorationCategoryFooter:
            decoration = section.footer.decoration;
            break;
    }
    return decoration;
}
@end

@implementation LWZCollectionSection (LWZCollectionSizesAdditions)
/// 计算传入的 sections 布局需要的大小
///
///     必须指定每个 section 的 `layoutType`;
+ (CGSize)layoutSizeThatFits:(CGSize)size forSections:(NSArray<LWZCollectionSection *> *)sections scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    LWZCollectionViewSizesSimulatedLayout *layout = [LWZCollectionViewSizesSimulatedLayout.alloc initWithSections:sections];
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
        LWZCollectionSection *section = sections[currentIndex];
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
