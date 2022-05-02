//
//  UICollectionReusableView+LWZCollectionAdditions.m
//  LWZComponents
//
//  Created by 畅三江 on 2022/4/29.
//

#import "UICollectionReusableView+LWZCollectionAdditions.h"
#import "LWZCollectionDefines.h"
#import <objc/message.h>

@implementation UICollectionReusableView (LWZCollectionAdditions)
static void *k_boundItem = &k_boundItem;
- (void)setLwz_boundItem:(__kindof id _Nullable)lwz_boundItem {
    objc_setAssociatedObject(self, k_boundItem, lwz_boundItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (__kindof id _Nullable)lwz_boundItem {
    return objc_getAssociatedObject(self, k_boundItem);
}
@end

@implementation UICollectionViewCell (LWZCollectionAdditions)
- (BOOL)lwz_respondsToWillDisplaySelector {
    static void *key = &key;
    NSNumber *rev = objc_getAssociatedObject(self, key);
    if ( rev == nil ) {
        rev = @([self respondsToSelector:@selector(willDisplayAtIndexPath:)]);
        objc_setAssociatedObject(self, key, rev, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [rev boolValue];
}

- (BOOL)lwz_respondsToDidEndDisplaySelector {
    static void *key = &key;
    NSNumber *rev = objc_getAssociatedObject(self, key);
    if ( rev == nil ) {
        rev = @([self respondsToSelector:@selector(didEndDisplayingAtIndexPath:)]);
        objc_setAssociatedObject(self, key, rev, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [rev boolValue];
}
@end
