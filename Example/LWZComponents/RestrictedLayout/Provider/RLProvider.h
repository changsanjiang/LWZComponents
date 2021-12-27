//
//  RLProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionProvider.h"
@class RLModel;

NS_ASSUME_NONNULL_BEGIN

@interface RLProvider : LWZCollectionProvider
- (instancetype)initWithList:(NSArray<RLModel *> * _Nullable)list;
@end

NS_ASSUME_NONNULL_END
