//
//  LWZCollectionViewPresenter.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2020/11/16.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//
 
#import "LWZCollectionProvider.h"
#import "LWZCollectionViewLayout.h"
@protocol LWZCollectionViewPresenterDelegate;

/// 数据呈现器
///
/// 1. 实现了 `layout.delegate, collection.dataSource`
/// 2. 对各个视图高度做了缓存处理, 必要时可以调用`invalidateAllPresentationSizes`进行刷新
///
NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionViewPresenter : NSObject<UICollectionViewDataSource, LWZCollectionViewLayoutDelegate>
- (instancetype)initWithProvider:(LWZCollectionProvider *)provider;

@property (nonatomic, strong, nullable) __kindof LWZCollectionProvider *provider;
@property (nonatomic, weak, nullable) id<LWZCollectionViewPresenterDelegate> delegate;
- (void)invalidateAllPresentationSizes; // 使所有视图的size在下次显示时重新计算
- (void)refreshVisibleItemsForCollectionView:(UICollectionView *)collectionView;
@end

@protocol LWZCollectionViewPresenterDelegate <NSObject>
- (UIEdgeInsets)presenter:(LWZCollectionViewPresenter *)presenter adjustedPinnedInsetsForSectionAtIndex:(NSInteger)section;
@end

#pragma mark - hooks

@protocol LWZCollectionViewCellHooks <NSObject>
@optional
- (void)willDisplayAtIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface LWZCollectionViewPresenter (LWZCollectionViewDelegateProxyHookedMethods)<UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
@end


@interface LWZCollectionViewPresenter (LWZCollectionUpdates)
- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
