//
//  WLCollectionSectionHeaderFooterView.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WLCollectionSectionHeaderFooterViewDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface WLCollectionSectionHeaderFooterView : UICollectionReusableView
@property (nonatomic, weak, nullable) id<WLCollectionSectionHeaderFooterViewDataSource> dataSource;
@end

@protocol WLCollectionSectionHeaderFooterViewDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) NSAttributedString *title;
@property (nonatomic, readonly) UIEdgeInsets contentInsets;
@end
NS_ASSUME_NONNULL_END
