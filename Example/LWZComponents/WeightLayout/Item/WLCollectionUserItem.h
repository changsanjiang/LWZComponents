//
//  WLCollectionUserItem.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionItem.h"
#import "WLModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface WLCollectionUserItem : LWZCollectionItem
- (instancetype)initWithModel:(WLUserModel *)model;

@property (nonatomic, readonly) NSInteger userId;
@end
NS_ASSUME_NONNULL_END
