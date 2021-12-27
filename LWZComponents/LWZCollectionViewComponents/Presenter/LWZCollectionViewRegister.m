//
//  LWZCollectionViewRegister.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2020/12/7.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionViewRegister.h"
#import <objc/message.h>

@interface UICollectionView (LWZCollectionViewRegisterAdditions)
@property (nonatomic, strong, readonly) NSMutableSet<Class> *lwz_registeredClasses;
@property (nonatomic, strong, readonly) NSMutableSet<Class> *lwz_registeredClassesForFooter;
@end

@implementation UICollectionView (LWZCollectionViewRegisterAdditions)
// header or cell
- (NSMutableSet<Class> *)lwz_registeredClasses {
    NSMutableSet<Class> *set = objc_getAssociatedObject(self, _cmd);
    if ( set == nil ) {
        set = NSMutableSet.set;
        objc_setAssociatedObject(self, _cmd, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return set;
}

// footer
- (NSMutableSet<Class> *)lwz_registeredClassesForFooter {
    NSMutableSet<Class> *set = objc_getAssociatedObject(self, _cmd);
    if ( set == nil ) {
        set = NSMutableSet.set;
        objc_setAssociatedObject(self, _cmd, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return set;
}

@end

@interface UICollectionViewLayout (LWZCollectionViewRegisterAdditions)

@end

@implementation UICollectionViewLayout (LWZCollectionViewRegisterAdditions)
// decoration
- (NSMutableSet<Class> *)lwz_registeredDecorations {
    NSMutableSet<Class> *set = objc_getAssociatedObject(self, _cmd);
    if ( set == nil ) {
        set = NSMutableSet.set;
        objc_setAssociatedObject(self, _cmd, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return set;
}
@end

@interface LWZCollectionViewRegister ()

@end

@implementation LWZCollectionViewRegister
 
- (nullable __kindof UICollectionReusableView *)collectionView:(UICollectionView *)collectionView dequeueReusableHeaderFooterViewWithHeaderFooter:(LWZCollectionSectionHeaderFooter *)headerFooter kind:(NSString *)kind indexPath:(NSIndexPath *)indexPath {
    if ( headerFooter == nil )
        return nil;
    
    Class cls = headerFooter.viewClass;
    NSParameterAssert([(id)cls isKindOfClass:object_getClass(UICollectionReusableView.class)]);
    
    // register if needed
    NSString *name = NSStringFromClass(cls);
    NSString *identifier = name;
    NSMutableSet<Class> *classes = kind == UICollectionElementKindSectionHeader ? [collectionView lwz_registeredClasses] : [collectionView lwz_registeredClassesForFooter];
    if ( ![classes containsObject:cls] ) {
        [classes addObject:cls];
        
        NSBundle *nibBundle = [headerFooter respondsToSelector:@selector(viewNibBundle)] ? [headerFooter viewNibBundle] : nil;
        UINib *nib = nibBundle != nil ? [UINib nibWithNibName:name bundle:nibBundle] : ([headerFooter respondsToSelector:@selector(viewNib)] ? headerFooter.viewNib : nil);
        
        nib == nil ? [collectionView registerClass:cls forSupplementaryViewOfKind:kind withReuseIdentifier:identifier] :
                     [collectionView registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    }
    
    // dequeue
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
}

- (nullable __kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView dequeueReusableCellWithItem:(LWZCollectionItem *)item forIndexPath:(NSIndexPath *)indexPath {
    if ( item == nil ) {
        NSParameterAssert(item != nil);
        return nil;
    }
    
    Class cls = item.cellClass;
    NSParameterAssert([(id)cls isKindOfClass:object_getClass(UICollectionViewCell.class)]);
    
    // register if needed
    NSString *name = NSStringFromClass(cls);
    NSString *identifier = name;
    if ( ![collectionView.lwz_registeredClasses containsObject:cls] ) {
        [collectionView.lwz_registeredClasses addObject:cls];
        NSBundle *nibBundle = [item respondsToSelector:@selector(cellNibBundle)] ? item.cellNibBundle : nil;
        UINib *nib = nibBundle != nil ? [UINib nibWithNibName:name bundle:nibBundle] : ([item respondsToSelector:@selector(cellNib)] ? item.cellNib : nil);
        nib == nil ? [collectionView registerClass:cls forCellWithReuseIdentifier:identifier] :
                     [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }
    
    // dequeue
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

/// 返回 reuseIdentifier
///
- (nullable NSString *)layout:(UICollectionViewLayout *)layout registerDecoration:(LWZCollectionDecoration *)decoration {
    if ( decoration == nil )
        return nil;

    Class viewClass = decoration.viewClass;
    NSParameterAssert([(id)viewClass isKindOfClass:object_getClass(UICollectionReusableView.class)]);
    
    // register if needed
    Class cls = decoration.class;
    NSString *identifier = NSStringFromClass(cls);
    NSMutableSet<Class> *classes = [layout lwz_registeredDecorations];
    if ( ![classes containsObject:cls] ) {
        [classes addObject:cls];
         
        NSString *viewName = NSStringFromClass(viewClass);
        NSBundle *nibBundle = [decoration respondsToSelector:@selector(viewNibBundle)] ? [decoration viewNibBundle] : nil;
        UINib *viewNib = nibBundle != nil ? [UINib nibWithNibName:viewName bundle:nibBundle] : ([decoration respondsToSelector:@selector(viewNib)] ? decoration.viewNib : nil);
        
        viewNib == nil ? [layout registerClass:viewClass forDecorationViewOfKind:identifier] :
                         [layout registerNib:viewNib forDecorationViewOfKind:identifier];
    }
    return identifier;
}
@end
