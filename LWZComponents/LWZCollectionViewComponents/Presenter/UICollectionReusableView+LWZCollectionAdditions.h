//
//  UICollectionReusableView+LWZCollectionAdditions.h
//  LWZComponents
//
//  Created by 畅三江 on 2022/4/29.
//

#import "LWZCollectionSectionHeaderFooter.h"
#import "LWZCollectionItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface UICollectionReusableView (LWZCollectionAdditions)
@property (nonatomic, strong, nullable) __kindof id lwz_boundItem;
@end

@interface UICollectionViewCell (LWZCollectionAdditions)
@property (nonatomic, readonly) BOOL lwz_respondsToWillDisplaySelector;
@property (nonatomic, readonly) BOOL lwz_respondsToDidEndDisplaySelector;
@end
NS_ASSUME_NONNULL_END
