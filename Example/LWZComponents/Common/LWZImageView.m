//
//  LWZImageView.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZImageView.h"

@implementation LWZImageView
- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _layoutSubviewsExeBlock ) _layoutSubviewsExeBlock(self);
}
@end
