//
//  UICollectionViewLayoutAttributes+LWZCollectionAdditions.h.m
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/10.
//

#import "UICollectionViewLayoutAttributes+LWZCollectionAdditions.h"
 
@implementation LWZCollectionViewLayoutAttributes
- (id)copyWithZone:(nullable NSZone *)zone {
    LWZCollectionViewLayoutAttributes *attributes = [super copyWithZone:zone];
    id userInfo = self.decorationUserInfo;
    if ( userInfo != nil ) {
        attributes.decorationUserInfo = userInfo;
    }
    return attributes;
}
@end

CGFloat
LWZCollectionViewLayoutAttributesGetMaxOffset(UICollectionViewLayoutAttributes *attributes, UICollectionViewScrollDirection direction) {
    CGFloat offset = 0;
    switch ( direction ) {
        case UICollectionViewScrollDirectionVertical:
            offset = CGRectGetMaxY(attributes.frame);
            break;
        case UICollectionViewScrollDirectionHorizontal:
            offset = CGRectGetMaxX(attributes.frame);
            break;
    }
    return offset;
}

CGFloat
LWZCollectionViewLayoutAttributesGetMaxOffset(NSArray<UICollectionViewLayoutAttributes *> *attributesObjects, UICollectionViewScrollDirection direction) __attribute__((overloadable)) {
    CGFloat offset = 0;
    CGFloat cur = 0;
    for ( LWZCollectionViewLayoutAttributes *attributes in attributesObjects ) {
        cur = LWZCollectionViewLayoutAttributesGetMaxOffset(attributes, direction);
        if ( offset < cur ) offset = cur;
    }
    return offset;
}
