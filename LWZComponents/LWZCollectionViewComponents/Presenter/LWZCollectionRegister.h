//
//  LWZCollectionRegister.h
//  LWZCollectionViewComponents_Example
//
//  Created by BlueDancer on 2020/12/7.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LWZCollectionProvider, LWZCollectionViewLayout;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionRegister : NSObject
- (instancetype)initWithCollectionProvider:(LWZCollectionProvider *)collectionProvider;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (nullable __kindof UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (nullable __kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForSectionAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)layout:(LWZCollectionViewLayout *)layout decorationViewKindForFooterAtIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
