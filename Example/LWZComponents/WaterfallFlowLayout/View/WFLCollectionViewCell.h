//
//  WFLCollectionViewCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WFLCollectionViewCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface WFLCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<WFLCollectionViewCellDataSource> dataSource;
@end

@protocol WFLCollectionViewCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) UIImage *cover;
@property (nonatomic, strong, readonly, nullable) NSAttributedString *name;
@end
NS_ASSUME_NONNULL_END
