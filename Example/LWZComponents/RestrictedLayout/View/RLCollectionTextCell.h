//
//  RLCollectionTextCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RLCollectionTextCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface RLCollectionTextCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<RLCollectionTextCellDataSource> dataSource;
@end

@protocol RLCollectionTextCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) NSAttributedString *text;
@property (nonatomic, strong, readonly, nullable) UIColor *backgroundColor;
@property (nonatomic, readonly) UIEdgeInsets contentInset;
@end
NS_ASSUME_NONNULL_END
