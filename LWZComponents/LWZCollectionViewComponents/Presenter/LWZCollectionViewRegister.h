//
//  LWZCollectionViewRegister.h
//  LWZCollectionViewComponents_Example
//
//  Created by BlueDancer on 2020/12/7.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionSectionHeaderFooter.h"
#import "LWZCollectionDecoration.h"
#import "LWZCollectionItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWZCollectionViewRegister : NSObject

- (nullable __kindof UICollectionReusableView *)collectionView:(UICollectionView *)collectionView dequeueReusableHeaderFooterViewWithHeaderFooter:(LWZCollectionSectionHeaderFooter *)headerFooter kind:(NSString *)kind indexPath:(NSIndexPath *)indexPath;

- (nullable __kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView dequeueReusableCellWithItem:(LWZCollectionItem *)item forIndexPath:(NSIndexPath *)indexPath;

- (nullable NSString *)layout:(UICollectionViewLayout *)layout registerDecoration:(LWZCollectionDecoration *)decoration;
@end

NS_ASSUME_NONNULL_END
