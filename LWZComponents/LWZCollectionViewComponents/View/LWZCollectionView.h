//
//  LWZCollectionView.h
//  LWZFoundation
//
//  Created by BlueDancer on 2020/12/22.
//
 
#import "LWZCollectionViewPresenter.h"
 
NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionView : UICollectionView

@property (nonatomic, weak, nullable) LWZCollectionViewPresenter *dataSource;

@end
NS_ASSUME_NONNULL_END
