//
//  WLCollectionProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionProvider.h"
@class WLPostModel, WLUserModel;

NS_ASSUME_NONNULL_BEGIN
@interface WLCollectionProvider : LWZCollectionProvider

// - posts

@property (nonatomic, copy, nullable) void(^likingItemTapHandler)(NSIndexPath *indexPath);
@property (nonatomic, copy, nullable) void(^shareItemTapHandler)(NSIndexPath *indexPath);
@property (nonatomic, copy, nullable) void(^commentItemTapHandler)(NSIndexPath *indexPath);

- (BOOL)isPostLikedForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)setPostLiked:(BOOL)isLiked forItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)postShareCountForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)setPostShareCount:(NSInteger)count forItemAtIndexPath:(NSIndexPath *)indexPath;

/// 每个item的比重是1, 即一行显示1个item;
- (void)addPostItemsWithModelArray:(NSArray<WLPostModel *> *)models;
- (void)removeAllPostItems;

// - users

@property (nonatomic, copy, nullable) void(^userItemTapHandler)(NSInteger userId);

/// 每个item的比重是1/3, 即一行显示3个item;
- (void)addUserItemsWithModelArray:(NSArray<WLUserModel *> *)models;
- (void)removeAllUserItems;

@end

NS_ASSUME_NONNULL_END
