//
//  LWZCollectionLayoutSection.h
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/11.
//

#import "UICollectionViewLayoutAttributes+LWZCollectionAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWZCollectionLayoutSection : NSObject
- (instancetype)initWithIndex:(NSInteger)index;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NSInteger index;
/// 表示当前section整个的layout.frame
/// 这个属性在设置`sectionHeadersPinToVisibleBounds == YES`时会被用到, 不会再collectionView中使用
@property (nonatomic) CGRect frame;
@property (nonatomic, strong, nullable) __kindof UIView *customView; // LWZCollectionViewCompositionalLayout

@property (nonatomic) BOOL canPinToVisibleBoundsForHeader;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *headerViewLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *headerViewPinnedLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *footerViewLayoutAttributes;

@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *sectionDecorationLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *headerDecorationLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *headerDecorationPinnedLayoutAttributes;
@property (nonatomic, strong, nullable) LWZCollectionViewLayoutAttributes *footerDecorationLayoutAttributes;

@property (nonatomic, strong, nullable) NSArray<LWZCollectionViewLayoutAttributes *> *cellLayoutAttributesObjects;
@property (nonatomic, strong, nullable) NSArray<LWZCollectionViewLayoutAttributes *> *cellDecorationLayoutAttributesObjects;

- (void)removeAllLayoutAttributes;

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category;

- (nullable LWZCollectionViewLayoutAttributes *)currentHeaderViewLayoutAttributes; // @note 后面如要扩展footer时也需要添加类似的方法
- (nullable LWZCollectionViewLayoutAttributes *)currentHeaderDecorationLayoutAttributes; // @note 后面如要扩展footer时也需要添加类似的方法
@end

NS_ASSUME_NONNULL_END
