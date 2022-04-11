//
//  LWZCollectionView.m
//  LWZFoundation
//
//  Created by BlueDancer on 2020/12/22.
//

#import "LWZCollectionView.h"
#import "LWZCollectionViewDelegateProxy.h"
   
@implementation LWZCollectionView {
    LWZCollectionViewDelegateProxy *_mDelegateProxy2;
}
@dynamic dataSource;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if ( self ) {
        self.backgroundColor = UIColor.whiteColor;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _mDelegateProxy2 = [LWZCollectionViewDelegateProxy.alloc initWithCollectionView:self];
    }
    return self;
}

- (void)setDataSource:(nullable LWZCollectionViewPresenter *)dataSource {
    [super setDataSource:dataSource];
    _mDelegateProxy2.presenter = dataSource;
    if ( dataSource != nil && self.delegate == nil ) self.delegate = dataSource;
}

/// delegate 将增加一层proxy, 使得 presenter 能够 hook UICollectionViewDelegate 相关方法
- (void)setDelegate:(nullable id<UICollectionViewDelegate>)delegate {
    _mDelegateProxy2.delegate = delegate;
    [super setDelegate:delegate];
}

#pragma mark - LWZCollectionViewCompositionalLayout

- (nullable UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( [self.collectionViewLayout isKindOfClass:LWZCollectionViewCompositionalLayout.class] ) {
        if ( [(LWZCollectionViewCompositionalLayout *)self.collectionViewLayout isOrthogonalScrollingInSection:indexPath.section] ) {
            return [(LWZCollectionViewCompositionalLayout *)self.collectionViewLayout orthogonalScrollingCellForItemAtIndexPath:indexPath];
        }
    }
    return [super cellForItemAtIndexPath:indexPath];
}

- (nullable NSIndexPath *)indexPathForCell:(UICollectionViewCell *)cell {
    if ( [self.collectionViewLayout isKindOfClass:LWZCollectionViewCompositionalLayout.class] ) {
        return [(UICollectionView *)cell.superview indexPathForCell:cell];
    }
    return [super indexPathForCell:cell];
}

#ifdef DEBUG

- (void)reloadData {
    [super reloadData];
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    [super setContentOffset:contentOffset animated:animated];
}
#endif
@end
