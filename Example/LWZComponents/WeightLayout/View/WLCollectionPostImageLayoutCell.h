//
//  WLCollectionPostImageLayoutCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//
//  帖子-图片布局cell

#import <UIKit/UIKit.h>
@protocol WLCollectionPostImageLayoutCellDataSource, WLCollectionPostImageLayoutCellDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface WLCollectionPostImageLayoutCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<WLCollectionPostImageLayoutCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<WLCollectionPostImageLayoutCellDelegate> delegate;

- (void)reloadLikingNum;
- (void)reloadShareNum;
- (void)reloadDataSource;
@end

@protocol WLPostCoverItem <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *image;
@property (nonatomic, readonly) CGRect frame;
@end

@protocol WLCollectionPostImageLayoutCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *avatar;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *name;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) NSArray<id<WLPostCoverItem>> *covers;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *likingNum;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *commentNum;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *shareNum;
@end

@protocol WLCollectionPostImageLayoutCellDelegate <NSObject>
- (void)likingItemWasTappedInCell:(WLCollectionPostImageLayoutCell *)cell;
- (void)shareItemWasTappedInCell:(WLCollectionPostImageLayoutCell *)cell;
- (void)commentItemWasTappedInCell:(WLCollectionPostImageLayoutCell *)cell;
@end
NS_ASSUME_NONNULL_END
