//
//  CGSize+LWZCollectionAdditions.h
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN CGSize
LWZFittingSizeForWidth(CGFloat targetWidth);

UIKIT_EXTERN CGSize
LWZFittingSizeForHeight(CGFloat targetHeight);

UIKIT_EXTERN CGSize
LWZFittingSizeForFloatRange(UIFloatRange floatRange, UICollectionViewScrollDirection direction);

UIKIT_EXTERN BOOL
LWZFittingSizeInvalid(CGSize fittingSize);


UIKIT_EXTERN CGSize
LWZLayoutSizeAdjustItemSize(CGSize itemSize, CGSize fittingSize, UICollectionViewScrollDirection direction);

UIKIT_EXTERN CGSize
LWZLayoutSizeAdjustHeaderFooterSize(CGSize headerFooterSize, CGSize fittingSize, UICollectionViewScrollDirection direction);

UIKIT_EXTERN BOOL
LWZLayoutSizeIsInvalid(CGSize layoutSize, UICollectionViewScrollDirection direction);
NS_ASSUME_NONNULL_END

// fittingSize: 试穿的size, 限制宽高计算范围, 不是最终的size
// layoutSize: 布局的size, 是最终显示的size
