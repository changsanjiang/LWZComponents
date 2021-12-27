//
//  LWZCollectionDefines.h
//  LWZCollectionViewComponents
//
//  Created by changsanjiang on 2021/11/25.
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

typedef NS_ENUM(NSUInteger, LWZCollectionLayoutTemplateDimensionSemantic) {
    LWZCollectionLayoutTemplateDimensionSemanticFractionalWidth,
    LWZCollectionLayoutTemplateDimensionSemanticFractionalHeight,
    LWZCollectionLayoutTemplateDimensionSemanticAbsolute
};

NS_ASSUME_NONNULL_BEGIN
  
FOUNDATION_EXTERN NSInteger const LWZCollectionDecorationDefaultZPosition;
FOUNDATION_EXTERN NSInteger const LWZCollectionDecorationSeparatorZPosition;

FOUNDATION_EXTERN NSInteger const LWZCollectionOrthogonalScrollingGroupViewZPosition;

NS_ASSUME_NONNULL_END
