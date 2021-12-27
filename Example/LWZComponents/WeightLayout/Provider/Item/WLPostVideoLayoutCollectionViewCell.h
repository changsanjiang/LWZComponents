//
//  WLPostVideoLayoutCollectionViewCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WLPostVideoLayoutCollectionViewCellDataSource, WLPostVideoLayoutCollectionViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface WLPostVideoLayoutCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<WLPostVideoLayoutCollectionViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<WLPostVideoLayoutCollectionViewCellDelegate> delegate;

- (void)reloadLikingNum;
- (void)reloadShareNum;
- (void)reloadDataSource;
@end

@protocol WLPostVideoLayoutCollectionViewCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *avatar;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *name;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) UIImage *cover;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *likingNum;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *commentNum;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *shareNum;
@end

@protocol WLPostVideoLayoutCollectionViewCellDelegate <NSObject>
- (void)likingItemWasTappedInCell:(WLPostVideoLayoutCollectionViewCell *)cell;
- (void)shareItemWasTappedInCell:(WLPostVideoLayoutCollectionViewCell *)cell;
- (void)commentItemWasTappedInCell:(WLPostVideoLayoutCollectionViewCell *)cell;
@end
NS_ASSUME_NONNULL_END
