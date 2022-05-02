//
//  WLCollectionUserCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WLCollectionUserCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface WLCollectionUserCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<WLCollectionUserCellDataSource> dataSource;
@end

@protocol WLCollectionUserCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *avatar;
@property (nonatomic, strong, readonly, nullable) NSString *name;
@end
NS_ASSUME_NONNULL_END
