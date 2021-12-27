//
//  LWZCollectionLayoutFittingSize.h
//  SJTestAutoLayout_Example
//
//  Created by changsanjiang on 2021/11/9.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LWZCollectionLayoutFittingSizeForWidth(__width__) [LWZCollectionLayoutFittingSize fittingSizeForWidth:__width__]
#define LWZCollectionLayoutFittingSizeForHeight(__height__) [LWZCollectionLayoutFittingSize fittingSizeForHeight:__height__]
#define LWZCollectionLayoutFittingSizeForLayoutRange(__range__, __direction__) [LWZCollectionLayoutFittingSize fittingSizeForLayoutRange:__range__ scrollDirection:__direction__]

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionLayoutFittingSize : NSObject
+ (CGSize)fittingSizeForWidth:(CGFloat)width;
+ (CGSize)fittingSizeForHeight:(CGFloat)height;
+ (CGSize)fittingSizeForLayoutRange:(UIFloatRange)layoutRange scrollDirection:(UICollectionViewScrollDirection)direction;
+ (BOOL)isInvalid:(CGSize)size;
@end
NS_ASSUME_NONNULL_END
