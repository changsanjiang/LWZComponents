//
//  LWZCollectionInternals.h
//  LWZAppComponents
//
//  Created by 蓝舞者 on 2021/8/25.
//
#import "LWZCollectionSection.h"
#import "LWZCollectionSectionHeaderFooter.h"
#import "LWZCollectionDecoration.h"
#import "LWZCollectionItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionDecoration (LWZCollectionInternalAdditions)
@property (nonatomic, readonly) id userInfo;
@property (nonatomic) CGRect relativeRect; // 由presenter维护
- (CGRect)relativeRectToFit:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath; // calls relativeRectThatFits:;
@end

@interface LWZCollectionItem (LWZCollectionInternalAdditions)
@property (nonatomic) CGSize layoutSize; // 由presenter维护

- (void)willDisplayCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface LWZCollectionSectionHeaderFooter (LWZCollectionInternalAdditions)
@property (nonatomic) CGSize layoutSize; // 由presenter维护

- (void)willDisplaySupplementaryView:(__kindof UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)didEndDisplayingSupplementaryView:(__kindof UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
@end

@interface UICollectionViewCell (LWZCollectionInternalAdditions)
@property (nonatomic, strong, nullable) __kindof LWZCollectionItem *lwz_bindingCollectionItem;
@property (nonatomic, readonly) BOOL lwz_respondsToWillDisplay;
@property (nonatomic, readonly) BOOL lwz_respondsToDidEndDisplaying;
@end

@interface UICollectionReusableView (LWZCollectionInternalAdditions)
@property (nonatomic, strong, nullable) __kindof LWZCollectionSectionHeaderFooter *lwz_bindingHeaderFooter;
@end
NS_ASSUME_NONNULL_END
