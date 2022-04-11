//
//  MLModelProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "MLModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLModelProvider : NSObject

+ (void)requestDataWithComplete:(void(^)(MLModel *_Nullable model, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
