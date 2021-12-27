//
//  WLModelProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface WLModelProvider : NSObject

+ (void)requestDataWithComplete:(void(^)(WLDetailModel *_Nullable detail, NSError *_Nullable error))completionHandler;

@end
NS_ASSUME_NONNULL_END
