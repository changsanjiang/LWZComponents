//
//  RLModelProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "RLModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RLModelProvider : NSObject

+ (void)requestDataWithComplete:(void(^)(NSArray<RLModel *> *_Nullable list, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
