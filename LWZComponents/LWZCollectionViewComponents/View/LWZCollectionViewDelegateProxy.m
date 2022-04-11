//
//  LWZCollectionViewDelegateProxy.m
//  SJTestAutoLayout_Example
//
//  Created by 蓝舞者 on 2021/11/13.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionViewDelegateProxy.h"
#import "LWZCollectionViewPresenter.h"
#import <objc/message.h>

///
/// 这里个协议列出来 presenter 需要 hook 的代理方法
/// 当以后 presenter 有新的 hook 需要时, 不要忘记修改此处及proxy的处理
///
@protocol LWZCollectionViewDelegateProxyMethods <NSObject>
- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
@end
 
@implementation LWZCollectionViewDelegateProxy
static void *kProxy = &kProxy;

static inline Class
cvd_proxy_get_method_defined_root_class(Class aClass, SEL originalSelector) {
    Class currentClass = aClass;
    Class rootClass = currentClass;
    while ( currentClass != NULL ) {
        if ( class_getInstanceMethod(currentClass, originalSelector) != NULL ) {
            rootClass = currentClass;
        }
        currentClass = class_getSuperclass(currentClass);
    }
    return rootClass;
}
 
static void cvd_proxy_empty_impl() { }

static void cvd_proxy_swizzleSelector(Class aClass, SEL originalSelector, SEL swizzledSelector) {
    Method proxyMethod = class_getInstanceMethod(LWZCollectionViewDelegateProxy.class, swizzledSelector);
    const char *methodType = method_getTypeEncoding(proxyMethod);
    IMP proxyIMP = method_getImplementation(proxyMethod);

    Class rootClass = cvd_proxy_get_method_defined_root_class(aClass, originalSelector);
    if ( class_getInstanceMethod(rootClass, originalSelector) == NULL ) {
        class_addMethod(rootClass, originalSelector, (IMP)cvd_proxy_empty_impl, methodType);
    }

    Class currentClass = aClass;
    while ( class_getInstanceMethod(currentClass, originalSelector) ) {
        Class superClass = class_getSuperclass(currentClass);
        Method currentMethod = class_getInstanceMethod(currentClass, originalSelector);
        Method superMethod = class_getInstanceMethod(superClass, originalSelector);
        IMP currentIMP = method_getImplementation(currentMethod);
        IMP superIMP = method_getImplementation(superMethod);
        if ( currentIMP != superIMP && currentIMP != proxyIMP ) {
            if ( class_addMethod(currentClass, swizzledSelector, proxyIMP, methodType) ) {
                method_exchangeImplementations(currentMethod, class_getInstanceMethod(currentClass, swizzledSelector));
            }
        }
        currentClass = superClass;
    }
}

static void cvd_proxy_init(Class aClass) {
    static void *kFlag = &kFlag;
    if ( objc_getAssociatedObject(aClass, kFlag) != nil ) return;
    static NSString *kValue = @"a";
    objc_setAssociatedObject(aClass, kFlag, kValue, OBJC_ASSOCIATION_ASSIGN);
    
    cvd_proxy_swizzleSelector(aClass, @selector(collectionView:didSelectItemAtIndexPath:), @selector(cvd_proxy_collectionView:didSelectItemAtIndexPath:));
    cvd_proxy_swizzleSelector(aClass, @selector(collectionView:didDeselectItemAtIndexPath:), @selector(cvd_proxy_collectionView:didDeselectItemAtIndexPath:));
    cvd_proxy_swizzleSelector(aClass, @selector(collectionView:willDisplayCell:forItemAtIndexPath:), @selector(cvd_proxy_collectionView:willDisplayCell:forItemAtIndexPath:));
    cvd_proxy_swizzleSelector(aClass, @selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:), @selector(cvd_proxy_collectionView:didEndDisplayingCell:forItemAtIndexPath:));
    cvd_proxy_swizzleSelector(aClass, @selector(collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:), @selector(cvd_proxy_collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:));
    cvd_proxy_swizzleSelector(aClass, @selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:), @selector(cvd_proxy_collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:));
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if ( self ) {
        _collectionView = collectionView;
    }
    return self;
}

- (void)setDelegate:(nullable id<UICollectionViewDelegate>)delegate {
    if ( delegate != _delegate ) {
        if ( delegate == _presenter || [delegate isKindOfClass:LWZCollectionViewPresenter.class] ) return;
        
        _delegate = delegate;
        if ( delegate != nil ) {
            objc_setAssociatedObject(delegate, kProxy, self, OBJC_ASSOCIATION_ASSIGN);
            cvd_proxy_init(delegate.class);
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionViewDelegateProxy *proxy = objc_getAssociatedObject(self, kProxy);
    [proxy.presenter collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    [self cvd_proxy_collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionViewDelegateProxy *proxy = objc_getAssociatedObject(self, kProxy);
    [proxy.presenter collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    [self cvd_proxy_collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
}

- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionViewDelegateProxy *proxy = objc_getAssociatedObject(self, kProxy);
    [proxy.presenter collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    [self cvd_proxy_collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
}

- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionViewDelegateProxy *proxy = objc_getAssociatedObject(self, kProxy);
    [proxy.presenter collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    [self cvd_proxy_collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionViewDelegateProxy *proxy = objc_getAssociatedObject(self, kProxy);
    [proxy.presenter collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    [self cvd_proxy_collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
}

- (void)cvd_proxy_collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LWZCollectionViewDelegateProxy *proxy = objc_getAssociatedObject(self, kProxy);
    [proxy.presenter collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    [self cvd_proxy_collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
}
@end
