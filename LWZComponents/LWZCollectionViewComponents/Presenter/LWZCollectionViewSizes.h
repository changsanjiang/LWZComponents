//
//  LWZCollectionViewSizes.h
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/3/26.
//

#import "LWZCollectionProvider.h"

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionViewSizes : NSObject
- (instancetype)initWithProvider:(LWZCollectionProvider *)provider;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGRect)relativeRectToFit:(CGRect)rect forSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)relativeRectToFit:(CGRect)rect forHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)relativeRectToFit:(CGRect)rect forItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)relativeRectToFit:(CGRect)rect forFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;

- (void)invalidateAllPresentationSizes;

#pragma mark - updates

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)willDisplayCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)willDisplaySupplementaryView:(__kindof UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingSupplementaryView:(__kindof UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;

- (void)updateVisibleViewsForCollectionView:(UICollectionView *)collectionView;
@end


@interface LWZCollectionSection (LWZCollectionSizesAdditions)
/// 计算传入的 sections 布局需要的大小
///
///     必须指定每个 section 的 `layoutType`;
+ (CGSize)layoutSizeThatFits:(CGSize)size forSections:(NSArray<LWZCollectionSection *> *)sections scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
@end
NS_ASSUME_NONNULL_END
