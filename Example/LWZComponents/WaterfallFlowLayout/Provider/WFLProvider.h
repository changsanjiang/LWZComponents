//
//  WFLProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/29.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionProvider.h"
#import "WFLModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFLProvider : LWZCollectionProvider
- (instancetype)initWithList:(NSArray<WFLModel *> *)list;
@end

NS_ASSUME_NONNULL_END
