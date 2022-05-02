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

+ (void)requestUserDataWithComplete:(void(^)(NSArray<WLUserModel *> *_Nullable users, NSError *_Nullable error))completionHandler;

+ (void)requestPageDataWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize complete:(void(^)(NSArray<WLPostModel *> *_Nullable posts, NSError *_Nullable error))completionHandler;

@end
NS_ASSUME_NONNULL_END
