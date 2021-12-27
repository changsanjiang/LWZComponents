//
//  WLPostCollectionItem.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionItem.h"
#import "WLModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface WLPostCollectionItem : LWZCollectionItem

+ (instancetype)itemWithModel:(WLPostModel *)post;

@property (nonatomic) BOOL isLiked;
@property (nonatomic) NSInteger shareCount;

@property (nonatomic, copy, nullable) void(^likingItemTapHandler)(WLPostCollectionItem *item);
@property (nonatomic, copy, nullable) void(^shareItemTapHandler)(WLPostCollectionItem *item);
@property (nonatomic, copy, nullable) void(^commentItemTapHandler)(WLPostCollectionItem *item);
@end
NS_ASSUME_NONNULL_END
