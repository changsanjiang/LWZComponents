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

+ (void)requestPageDataWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize complete:(void(^)(NSArray<RLModel *> *_Nullable models, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
