//
//  UIFloatRange+LWZCollectionAdditions.h
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/9.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LWZFloatRangeComparisonResult) {
    LWZFloatRangeComparisonResultInLeft,
    LWZFloatRangeComparisonResultIntersecting,
    LWZFloatRangeComparisonResultInRight,
};

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN LWZFloatRangeComparisonResult
LWZFloatRangeCompare(UIFloatRange range1, UIFloatRange range2);

UIKIT_EXTERN UIFloatRange
LWZFloatRangeRect(CGRect rect, UICollectionViewScrollDirection direction);

UIKIT_EXTERN LWZFloatRangeComparisonResult
LWZFloatRangeRectCompare(CGRect rect1, CGRect rect2, UICollectionViewScrollDirection direction);

UIKIT_EXTERN BOOL
LWZFloatRangeRectIntersects(CGRect rect1, CGRect rect2, UICollectionViewScrollDirection direction);
NS_ASSUME_NONNULL_END
