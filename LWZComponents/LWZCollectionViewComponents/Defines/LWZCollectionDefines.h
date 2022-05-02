//
//  LWZCollectionDefines.h
//  LWZCollectionViewComponents
//
//  Created by 蓝舞者 on 2021/11/25.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LWZCollectionLayoutType) {
    /// 未指定的, 将根据collectionView的layout的类型进行布局. 例如: collectionView.layout为weightLayout, 则按照weight布局
    LWZCollectionLayoutTypeUnspecified,
    LWZCollectionLayoutTypeWeight,
    LWZCollectionLayoutTypeList,
    LWZCollectionLayoutTypeWaterfallFlow,
    LWZCollectionLayoutTypeRestrictedLayout,
    LWZCollectionLayoutTypeTemplate,
};

typedef NS_ENUM(NSUInteger, LWZCollectionLayoutAlignment) {
    LWZCollectionLayoutAlignmentStart,
    LWZCollectionLayoutAlignmentEnd,
    LWZCollectionLayoutAlignmentCenter,
};

typedef NS_ENUM(NSUInteger, LWZCollectionLayoutContentPresentationMode) {
    LWZCollectionLayoutContentPresentationModeNormal,
    LWZCollectionLayoutContentPresentationModeCustom,
};

typedef NS_ENUM(NSUInteger, LWZCollectionLayoutContentOrthogonalScrollingBehavior) {
    LWZCollectionLayoutContentOrthogonalScrollingBehaviorNormal,
    LWZCollectionLayoutContentOrthogonalScrollingBehaviorContinuousCentered,
    LWZCollectionLayoutContentOrthogonalScrollingBehaviorPaging,
};

typedef NS_ENUM(NSUInteger, LWZCollectionTemplateDimensionSemantic) {
    LWZCollectionTemplateDimensionSemanticFractionalWidth,
    LWZCollectionTemplateDimensionSemanticFractionalHeight,
    LWZCollectionTemplateDimensionSemanticAbsolute
};

typedef NS_ENUM(NSUInteger, LWZCollectionDecorationCategory) {
    LWZCollectionDecorationCategorySection,
    LWZCollectionDecorationCategoryHeader,
    LWZCollectionDecorationCategoryItem,
    LWZCollectionDecorationCategoryFooter
};

NS_ASSUME_NONNULL_BEGIN
  
FOUNDATION_EXTERN NSInteger const LWZCollectionDecorationDefaultZPosition;
FOUNDATION_EXTERN NSInteger const LWZCollectionDecorationSeparatorZPosition;

FOUNDATION_EXTERN NSInteger const LWZCollectionOrthogonalScrollingGroupViewZPosition;

FOUNDATION_EXTERN NSInteger const LWZFittingSizeMaxBoundary;
FOUNDATION_EXTERN CGFloat   const LWZLayoutSizeMinimumValue;

@interface UICollectionViewCell (LWZCollectionUpdates)
- (void)willDisplayAtIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol LWZCollectionLayout <NSObject>
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (UIEdgeInsets)edgeSpacingsForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)contentInsetsForSectionAtIndex:(NSInteger)section;
- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

- (CGSize)layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGFloat)zIndexForHeaderInSection:(NSInteger)section;
- (CGFloat)zIndexForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)zIndexForFooterInSection:(NSInteger)section;

- (nullable NSString *)decorationViewKindForCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath;
- (CGRect)decorationRelativeRectToFit:(CGRect)fitsRect forCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)decorationZIndexForCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath;
- (nullable id)decorationUserInfoForCategory:(LWZCollectionDecorationCategory)category atIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
