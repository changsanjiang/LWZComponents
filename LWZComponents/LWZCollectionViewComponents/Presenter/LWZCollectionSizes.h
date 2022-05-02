//
//  LWZCollectionSizes.h
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/3/26.
//

#import "LWZCollectionProvider.h"

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionSizes : NSObject
- (instancetype)initWithCollectionProvider:(LWZCollectionProvider *)collectionProvider;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGRect)decorationRelativeRectToFit:(CGRect)rect forSectionAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)decorationRelativeRectToFit:(CGRect)rect forHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)decorationRelativeRectToFit:(CGRect)rect forItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)decorationRelativeRectToFit:(CGRect)rect forFooterAtIndexPath:(NSIndexPath *)indexPath;

- (void)invalidateAllPresentationSizes;
@end


@interface LWZCollectionSection (LWZCollectionSizesAdditions)
/// 计算传入的 sections 布局需要的大小
///
///     必须指定每个 section 的 `layoutType`;
+ (CGSize)layoutSizeThatFits:(CGSize)size forSections:(NSArray<LWZCollectionSection *> *)sections scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

+ (CGSize)layoutSizeThatFits:(CGSize)size forSections:(NSArray<LWZCollectionSection *> *)sections scrollDirection:(UICollectionViewScrollDirection)scrollDirection sectionSpacing:(CGFloat)sectionSpacing;
@end
NS_ASSUME_NONNULL_END
