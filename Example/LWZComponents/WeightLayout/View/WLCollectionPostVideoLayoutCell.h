//
//  WLCollectionPostVideoLayoutCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//
//  帖子-视频布局cell

#import <UIKit/UIKit.h>
@protocol WLCollectionPostVideoLayoutCellDataSource, WLCollectionPostVideoLayoutCellDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface WLCollectionPostVideoLayoutCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<WLCollectionPostVideoLayoutCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<WLCollectionPostVideoLayoutCellDelegate> delegate;

- (void)reloadLikingNum;
- (void)reloadShareNum;
- (void)reloadDataSource;
@end

@protocol WLCollectionPostVideoLayoutCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *avatar;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *name;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) UIImage *cover;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *likingNum;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *commentNum;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *shareNum;
@end

@protocol WLCollectionPostVideoLayoutCellDelegate <NSObject>
- (void)likingItemWasTappedInCell:(WLCollectionPostVideoLayoutCell *)cell;
- (void)shareItemWasTappedInCell:(WLCollectionPostVideoLayoutCell *)cell;
- (void)commentItemWasTappedInCell:(WLCollectionPostVideoLayoutCell *)cell;
@end
NS_ASSUME_NONNULL_END
