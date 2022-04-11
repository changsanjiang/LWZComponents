//
//  UIFloatRange+LWZCollectionAdditions.m
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/9.
//

#import "UIFloatRange+LWZCollectionAdditions.h"

LWZFloatRangeComparisonResult
LWZFloatRangeCompare(UIFloatRange range1, UIFloatRange range2) {
    if ( range1.maximum < range2.minimum )
        return LWZFloatRangeComparisonResultInLeft;;
    if ( range1.minimum > range2.maximum )
        return LWZFloatRangeComparisonResultInRight;
    return LWZFloatRangeComparisonResultIntersecting;
}

UIFloatRange
LWZFloatRangeRect(CGRect rect, UICollectionViewScrollDirection direction) {
    UIFloatRange range = UIFloatRangeZero;
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            range = UIFloatRangeMake(CGRectGetMinY(rect), CGRectGetMaxY(rect));
            break;
        case UICollectionViewScrollDirectionHorizontal:
            range = UIFloatRangeMake(CGRectGetMinX(rect), CGRectGetMaxX(rect));
            break;
    }
    return range;
}

LWZFloatRangeComparisonResult
LWZFloatRangeRectCompare(CGRect rect1, CGRect rect2, UICollectionViewScrollDirection direction) {
    UIFloatRange range1 = LWZFloatRangeRect(rect1, direction);
    UIFloatRange range2 = LWZFloatRangeRect(rect2, direction);
    return LWZFloatRangeCompare(range1, range2);
}

BOOL
LWZFloatRangeRectIntersects(CGRect rect1, CGRect rect2, UICollectionViewScrollDirection direction) {
    return LWZFloatRangeRectCompare(rect1, rect2, direction) == LWZFloatRangeComparisonResultIntersecting;
}
