//
//  LWZImageView.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWZImageView : UIImageView

@property (nonatomic, copy, nullable) void(^layoutSubviewsExeBlock)(__kindof LWZImageView *view);

@end

NS_ASSUME_NONNULL_END
