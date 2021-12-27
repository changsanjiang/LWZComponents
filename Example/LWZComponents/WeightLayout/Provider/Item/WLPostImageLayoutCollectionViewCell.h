//
//  WLPostImageLayoutCollectionViewCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WLPostImageLayoutCollectionViewCellDataSource, WLPostImageLayoutCollectionViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface WLPostImageLayoutCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<WLPostImageLayoutCollectionViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<WLPostImageLayoutCollectionViewCellDelegate> delegate;

- (void)reloadLikingNum;
- (void)reloadShareNum;
- (void)reloadDataSource;
@end

@protocol WLPostCoverItem <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *image;
@property (nonatomic, readonly) CGRect frame;
@end

@protocol WLPostImageLayoutCollectionViewCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *avatar;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *name;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) NSArray<id<WLPostCoverItem>> *covers;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *likingNum;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *commentNum;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *shareNum;
@end

@protocol WLPostImageLayoutCollectionViewCellDelegate <NSObject>
- (void)likingItemWasTappedInCell:(WLPostImageLayoutCollectionViewCell *)cell;
- (void)shareItemWasTappedInCell:(WLPostImageLayoutCollectionViewCell *)cell;
- (void)commentItemWasTappedInCell:(WLPostImageLayoutCollectionViewCell *)cell;
@end
NS_ASSUME_NONNULL_END
