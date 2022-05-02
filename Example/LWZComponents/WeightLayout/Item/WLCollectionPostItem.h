//
//  WLCollectionPostItem.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionItem.h"
#import "WLModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface WLCollectionPostItem : LWZCollectionItem

+ (instancetype)itemWithModel:(WLPostModel *)post;

@property (nonatomic) BOOL isLiked;
@property (nonatomic) NSInteger shareCount;

@property (nonatomic, copy, nullable) void(^likingItemTapHandler)(WLCollectionPostItem *item);
@property (nonatomic, copy, nullable) void(^shareItemTapHandler)(WLCollectionPostItem *item);
@property (nonatomic, copy, nullable) void(^commentItemTapHandler)(WLCollectionPostItem *item);
@end
NS_ASSUME_NONNULL_END
