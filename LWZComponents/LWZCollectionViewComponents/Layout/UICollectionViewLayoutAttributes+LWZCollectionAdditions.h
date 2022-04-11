//
//  UICollectionViewLayoutAttributes+LWZCollectionAdditions.h
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, strong, nullable) id decorationUserInfo;
@end

UIKIT_EXTERN CGFloat
LWZCollectionViewLayoutAttributesGetMaxOffset(UICollectionViewLayoutAttributes *attributes, UICollectionViewScrollDirection direction);

UIKIT_EXTERN CGFloat
LWZCollectionViewLayoutAttributesGetMaxOffset(NSArray<UICollectionViewLayoutAttributes *> *attributesObjects, UICollectionViewScrollDirection direction) __attribute__((overloadable));
  
NS_ASSUME_NONNULL_END
