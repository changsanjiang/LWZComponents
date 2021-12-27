//
//  CommonImageView.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "CommonImageView.h"

@implementation CommonImageView
- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _layoutSubviewsExeBlock ) _layoutSubviewsExeBlock(self);
}
@end
