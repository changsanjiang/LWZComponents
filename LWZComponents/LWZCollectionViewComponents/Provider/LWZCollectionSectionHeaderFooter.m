//
//  LWZCollectionSectionHeaderFooter.m
//  LWZAppComponents
//
//  Created by 蓝舞者 on 2021/8/25.
//

#import "LWZCollectionSectionHeaderFooter.h"
#import "LWZCollectionDecoration.h"

@interface LWZCollectionSectionHeaderFooter ()
@property (nonatomic) CGSize layoutSize;
@end

@implementation LWZCollectionSectionHeaderFooter {
    BOOL _needsLayout;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _needsLayout = YES;
    }
    return self;
}

- (Class)viewClass {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)needsLayout {
    return _needsLayout;
}

- (void)setNeedsLayout {
    _needsLayout = YES;
    if ( _decoration != nil ) [_decoration setNeedsLayout];
}

- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(__kindof LWZCollectionSection *)section atIndex:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)willDisplaySupplementaryView:(__kindof UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [self bindView:view inSection:indexPath.section];
    _needsLayout = NO;
}

- (void)didEndDisplayingSupplementaryView:(__kindof UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [self unbindView:view inSection:indexPath.section];
}

- (void)removeDecoration {
    _decoration = nil;
}

- (void)bindView:(__kindof UICollectionReusableView *)view inSection:(NSInteger)section { }
- (void)unbindView:(__kindof UICollectionReusableView *)view inSection:(NSInteger)section { }
@end
