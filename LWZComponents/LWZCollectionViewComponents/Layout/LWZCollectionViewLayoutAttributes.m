//
//  LWZCollectionViewLayoutAttributes.m
//  LWZAppComponents
//
//  Created by changsanjiang on 2021/8/25.
//

#import "LWZCollectionViewLayoutAttributes.h"

@implementation LWZCollectionViewLayoutAttributes
- (id)copyWithZone:(nullable NSZone *)zone {
    LWZCollectionViewLayoutAttributes *attr = [super copyWithZone:zone];
    id userInfo = self.decorationUserInfo;
    if ( userInfo != nil ) {
        attr.decorationUserInfo = userInfo;
    }
    return attr;
}
@end
