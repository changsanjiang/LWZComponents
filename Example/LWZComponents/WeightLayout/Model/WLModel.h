//
//  WLModel.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface WLUserModel : NSObject
@property (nonatomic) NSInteger id;
@property (nonatomic, strong, nullable) NSString *avatar;
@property (nonatomic, strong, nullable) NSString *name;
@end

@interface WLVideoModel : NSObject
@property (nonatomic) NSInteger id;
@property (nonatomic, strong, nullable) NSString *cover;
@end

@interface WLPostModel : NSObject
@property (nonatomic) NSInteger id;
@property (nonatomic, strong, nullable) WLUserModel *user;
@property (nonatomic) BOOL isLiked;
@property (nonatomic) NSInteger likingCount;
@property (nonatomic) NSInteger commentCount;
@property (nonatomic) NSInteger shareCount;
@property (nonatomic, strong, nullable) NSString *content;
@property (nonatomic, strong, nullable) NSArray<NSString *> *covers;
@property (nonatomic, strong, nullable) WLVideoModel *video;
@end

@interface WLDetailModel : NSObject
@property (nonatomic, strong, nullable) NSArray<WLUserModel *> *users;
@property (nonatomic, strong, nullable) NSArray<WLPostModel *> *posts;
@end
NS_ASSUME_NONNULL_END
