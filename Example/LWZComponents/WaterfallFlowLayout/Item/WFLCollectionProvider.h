//
//  WFLCollectionProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/29.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionProvider.h"
#import "WFLModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFLCollectionProvider : LWZCollectionProvider

@property (nonatomic, copy, nullable) void(^itemTapHandler)(WFLModel *model);

- (void)addItemsWithModelArray:(NSArray<WFLModel *> *)models;

- (void)removeAllItems;
@end

NS_ASSUME_NONNULL_END
