//
//  WFLModelProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFLModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface WFLModelProvider : NSObject

+ (void)requestDataWithComplete:(void(^)(NSArray<WFLModel *> *_Nullable list, NSError *_Nullable error))completionHandler;

@end
NS_ASSUME_NONNULL_END
