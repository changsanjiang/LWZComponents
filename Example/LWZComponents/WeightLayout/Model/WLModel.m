//
//  WLModel.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLModel.h"

@implementation WLUserModel

@end

@implementation WLVideoModel

@end

@implementation WLPostModel
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"covers" : NSString.class
    };
}
@end

@implementation WLDetailModel
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"users" : WLUserModel.class,
        @"posts" : WLPostModel.class
    };
}
@end
