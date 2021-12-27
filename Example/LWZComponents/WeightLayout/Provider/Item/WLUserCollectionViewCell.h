//
//  WLUserCollectionViewCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WLUserCollectionViewCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface WLUserCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<WLUserCollectionViewCellDataSource> dataSource;
@end

@protocol WLUserCollectionViewCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *avatar;
@property (nonatomic, strong, readonly, nullable) NSString *name;
@end
NS_ASSUME_NONNULL_END
