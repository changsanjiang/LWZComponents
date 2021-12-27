//
//  LWZCollectionItem.m
//  LWZAppComponents
//
//  Created by changsanjiang on 2021/8/25.
//

#import "LWZCollectionItem.h"
#import "LWZCollectionDecoration.h"

@interface LWZCollectionItem ()
@property (nonatomic) CGSize layoutSize;
@property (nonatomic) CGFloat weight;
@property (nonatomic) LWZCollectionLayoutAlignment layoutAlignment;
@end

@implementation LWZCollectionItem {
    BOOL _needsLayout;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _weight = 1;
        _needsLayout = YES;
    }
    return self;
}

- (Class)cellClass {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)needsLayout {
    return _needsLayout;
}

/**
 标记是否需要重新计算布局, LWZCollectionPresenter 将会在合适时机调用`layoutSizeThatFits:inSection:`
 */
- (void)setNeedsLayout {
    _needsLayout = YES;
    if ( _decoration != nil ) [_decoration setNeedsLayout];
}

/**
 返回布局. 当`needsLayout == YES`时, LWZCollectionPresenter 将会调用此方法.

 为避免频繁调用, 此 size 将会被 LWZCollectionPresenter 缓存, 调用`setNeedsLayout`来标记需要刷新.
 */
- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(nullable LWZCollectionSection *)section atIndexPath:(nullable NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)willDisplayCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self bindCell:cell atIndexPath:indexPath];
    _needsLayout = NO;
}

- (void)didEndDisplayingCell:(__kindof UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self unbindCell:cell atIndexPath:indexPath];
}

/// 绑定cell
- (void)bindCell:(__kindof UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath { }
/// 解绑cell
- (void)unbindCell:(__kindof UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath { }

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath {}

- (void)didDeselectAtIndexPath:(NSIndexPath *)indexPath {}
@end
