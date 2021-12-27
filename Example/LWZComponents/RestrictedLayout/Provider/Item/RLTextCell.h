//
//  RLTextCell.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RLTextCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface RLTextCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<RLTextCellDataSource> dataSource;
@end

@protocol RLTextCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) NSAttributedString *text;
@property (nonatomic, strong, readonly, nullable) UIColor *backgroundColor;
@property (nonatomic, readonly) UIEdgeInsets contentInset;
@end
NS_ASSUME_NONNULL_END
