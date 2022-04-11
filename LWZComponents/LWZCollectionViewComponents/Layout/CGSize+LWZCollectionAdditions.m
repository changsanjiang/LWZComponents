//
//  CGSize+LWZCollectionAdditions.m
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/9.
//

#import "CGSize+LWZCollectionAdditions.h"
#import "LWZCollectionDefines.h"

CGSize
LWZFittingSizeForWidth(CGFloat targetWidth) {
    return CGSizeMake(targetWidth, LWZFittingSizeMaxBoundary);
}

CGSize
LWZFittingSizeForHeight(CGFloat targetHeight) {
    return CGSizeMake(LWZFittingSizeMaxBoundary, targetHeight);
}

CGSize
LWZFittingSizeForFloatRange(UIFloatRange floatRange, UICollectionViewScrollDirection direction) {
    CGFloat length = floatRange.maximum - floatRange.minimum;
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            return LWZFittingSizeForWidth(length);
        case UICollectionViewScrollDirectionHorizontal:
            return LWZFittingSizeForHeight(length);
    }
}

BOOL
LWZFittingSizeInvalid(CGSize fittingSize) {
    return !((fittingSize.width == LWZFittingSizeMaxBoundary && fittingSize.height > 0) ||
             (fittingSize.height == LWZFittingSizeMaxBoundary && fittingSize.width > 0));
}


CGSize
LWZLayoutSizeAdjustItemSize(CGSize itemSize, CGSize fittingSize, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            if ( itemSize.width > fittingSize.width ) itemSize.width = fittingSize.width;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            if ( itemSize.height > fittingSize.height ) itemSize.height = fittingSize.height;
            break;
    }
    return itemSize;
}

CGSize
LWZLayoutSizeAdjustHeaderFooterSize(CGSize headerFooterSize, CGSize fittingSize, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            headerFooterSize.width = fittingSize.width;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            headerFooterSize.height = fittingSize.height;
            break;
    }
    return headerFooterSize;
}

BOOL
LWZLayoutSizeIsInvalid(CGSize layoutSize, UICollectionViewScrollDirection direction) {
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            return layoutSize.height < LWZLayoutSizeMinimumValue;
        case UICollectionViewScrollDirectionHorizontal:
            return layoutSize.width < LWZLayoutSizeMinimumValue;
    }
    return NO;
}
