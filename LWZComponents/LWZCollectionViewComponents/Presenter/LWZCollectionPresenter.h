//
//  LWZCollectionPresenter.h
//  LWZComponents
//
//  Created by 畅三江 on 2022/4/26.
//

#import <UIKit/UIKit.h>
@class LWZCollectionProvider;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionPresenter : NSObject
- (instancetype)initWithCollectionProvider:(LWZCollectionProvider *)collectionProvider;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
