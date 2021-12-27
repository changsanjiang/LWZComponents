//
//  HLModelProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "HLModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLModelProvider : NSObject

+ (void)requestDataWithComplete:(void(^)(HLModel *_Nullable model, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
