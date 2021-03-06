//
//  MLCollectionProvider.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionProvider.h"
#import "MLModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLCollectionProvider : LWZCollectionProvider

- (instancetype)initWithModel:(MLModel *)model;


@property (nonatomic, copy, nullable) void(^userItemTapHandler)(NSInteger userId);

@property (nonatomic, copy, nullable) void(^likingItemTapHandler)(NSIndexPath *indexPath);
@property (nonatomic, copy, nullable) void(^shareItemTapHandler)(NSIndexPath *indexPath);
@property (nonatomic, copy, nullable) void(^commentItemTapHandler)(NSIndexPath *indexPath);

- (BOOL)isPostLikedForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)setPostLiked:(BOOL)isLiked forItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)postShareCountForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)setPostShareCount:(NSInteger)count forItemAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
