//
//  LWZCollectionPresenter.m
//  LWZComponents
//
//  Created by 畅三江 on 2022/4/26.
//

#import "LWZCollectionPresenter.h"
#import "LWZCollectionProvider.h"
#import "LWZCollectionInternals.h"
#import "UICollectionReusableView+LWZCollectionAdditions.h"

/**
 将provider中的数据呈现到对应的cell等视图中;
 */
@implementation LWZCollectionPresenter {
    LWZCollectionProvider *mCollectionProvider;
}
- (instancetype)initWithCollectionProvider:(LWZCollectionProvider *)collectionProvider {
    self = [super init];
    if ( self ) {
        mCollectionProvider = collectionProvider;
    }
    return self;
}
 
/**
 将cell绑定到对应的item上;
 */
- (void)willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [mCollectionProvider itemAtIndexPath:indexPath];
    /// 为防止数据已发生改变, 此处需要做一层class的相同判断
    if ( cell.class == item.cellClass ) {
        cell.lwz_boundItem = item;
        [item willDisplayCell:cell forItemAtIndexPath:indexPath];
        
        if ( [cell lwz_respondsToWillDisplaySelector] ) [cell willDisplayAtIndexPath:indexPath];
        
        LWZCollectionSection *section = [mCollectionProvider sectionAtIndex:indexPath.section];
        [section didBindCellForItemAtIndexPath:indexPath];
    }
}
/**
 解绑;
 */
- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [mCollectionProvider itemAtIndexPath:indexPath];
    /// dataSource 的数据随时可能发生变化(这会出当前 item 与 cell绑定的 item 不一致的情况), 为防止数据已发生改变, 此处需要做一层相同判断
    ///
    if ( cell.lwz_boundItem == item ) {
        [item didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
        
        if ( [cell lwz_respondsToDidEndDisplaySelector] ) [cell didEndDisplayingAtIndexPath:indexPath];
        
        LWZCollectionSection *section = [mCollectionProvider sectionAtIndex:indexPath.section];
        [section didUnbindCellForItemAtIndexPath:indexPath];
        
        cell.lwz_boundItem = nil;
    }
}
/**
 将view绑定到对应的headerFooter上;
 */
- (void)willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionSectionHeaderFooter *headerFooter = nil;
    if      ( elementKind == UICollectionElementKindSectionHeader ) {
        headerFooter = [mCollectionProvider headerForSectionAtIndex:indexPath.section];
    }
    else if ( elementKind == UICollectionElementKindSectionFooter ) {
        headerFooter = [mCollectionProvider footerForSectionAtIndex:indexPath.section];
    }
    /// 为防止数据已发生改变, 此处需要做一层相同判断
    if ( headerFooter != nil && view.class == headerFooter.viewClass ) {
        view.lwz_boundItem = headerFooter;
        [headerFooter willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }
}
/**
 解绑;
 */
- (void)didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath {
    LWZCollectionSectionHeaderFooter *headerFooter = nil;
    if      ( elementKind == UICollectionElementKindSectionHeader ) {
        headerFooter = [mCollectionProvider headerForSectionAtIndex:indexPath.section];
    }
    else if ( elementKind == UICollectionElementKindSectionFooter ) {
        headerFooter = [mCollectionProvider footerForSectionAtIndex:indexPath.section];
    }
    
    /// 为防止数据已发生改变, 此处需要做一层相同判断
    if ( headerFooter != nil && view.lwz_boundItem == headerFooter ) {
        [headerFooter didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
        view.lwz_boundItem = nil;
    }
}
/**
 执行选中相关方法;
 */
- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [mCollectionProvider itemAtIndexPath:indexPath];
    if ( item.selectionHandler != nil ) {
        item.selectionHandler(item, indexPath);
    }
    
    [item didSelectAtIndexPath:indexPath];
    
    LWZCollectionSection *section = [mCollectionProvider sectionAtIndex:indexPath.section];
    [section didSelectItemAtIndexPath:indexPath];
}
/**
 执行取消选择相关方法;
 */
- (void)didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionItem *item = [mCollectionProvider itemAtIndexPath:indexPath];
    if ( item.deselectionHandler != nil ) {
        item.deselectionHandler(item, indexPath);
    }
    
    [item didDeselectAtIndexPath:indexPath];
    
    LWZCollectionSection *section = [mCollectionProvider sectionAtIndex:indexPath.section];
    [section didDeselectItemAtIndexPath:indexPath];
}

@end
