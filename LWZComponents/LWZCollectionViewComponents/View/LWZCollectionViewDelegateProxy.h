//
//  LWZCollectionViewDelegateProxy.h
//  SJTestAutoLayout_Example
//
//  Created by changsanjiang on 2021/11/13.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LWZCollectionViewPresenter;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionViewDelegateProxy : NSObject
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;
@property (nonatomic, weak, readonly, nullable) UICollectionView *collectionView;
@property (nonatomic, weak, nullable) id<UICollectionViewDelegate> delegate;
@property (nonatomic, weak, nullable) LWZCollectionViewPresenter *presenter;
@end
NS_ASSUME_NONNULL_END
