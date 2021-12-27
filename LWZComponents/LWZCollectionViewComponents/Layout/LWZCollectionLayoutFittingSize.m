//
//  LWZCollectionLayoutFittingSize.m
//  SJTestAutoLayout_Example
//
//  Created by changsanjiang on 2021/11/9.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionLayoutFittingSize.h"

#define _LWZ_COLLECTION_LAYOUT_MAX_BOUNDARY   (4096)

@implementation LWZCollectionLayoutFittingSize
+ (CGSize)fittingSizeForWidth:(CGFloat)width {
    return CGSizeMake(width, _LWZ_COLLECTION_LAYOUT_MAX_BOUNDARY);
}

+ (CGSize)fittingSizeForHeight:(CGFloat)height {
    return CGSizeMake(_LWZ_COLLECTION_LAYOUT_MAX_BOUNDARY, height);
}

+ (CGSize)fittingSizeForLayoutRange:(UIFloatRange)layoutRange scrollDirection:(UICollectionViewScrollDirection)direction {
    CGFloat length = layoutRange.maximum - layoutRange.minimum;
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            return [self fittingSizeForWidth:length];
        case UICollectionViewScrollDirectionHorizontal:
            return [self fittingSizeForHeight:length];
    }
}

+ (BOOL)isInvalid:(CGSize)size {
    return !((size.width == _LWZ_COLLECTION_LAYOUT_MAX_BOUNDARY && size.height > 0) ||
             (size.height == _LWZ_COLLECTION_LAYOUT_MAX_BOUNDARY && size.width > 0));
}
@end

#undef _LWZ_COLLECTION_LAYOUT_MAX_BOUNDARY
