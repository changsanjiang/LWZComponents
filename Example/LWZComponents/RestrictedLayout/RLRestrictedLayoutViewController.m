//
//  RLRestrictedLayoutViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "RLRestrictedLayoutViewController.h"
#import "RLCollectionProvider.h"
#import "RLModelProvider.h"
#import "LWZDependencies.h"
#import "UIScrollView+LWZRefreshAdditions.h"

@interface RLRestrictedLayoutViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, LWZCollectionViewLayoutDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) RLCollectionProvider *collectionProvider;
@property (nonatomic, strong) LWZCollectionViewPresenter *collectionPresenter;
@end

@implementation RLRestrictedLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self _setupCollection];
    [self.collectionView lwz_beginHeaderRefreshing];
    // Do any additional setup after loading the view.
}

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = UIColor.whiteColor;
        
    LWZCollectionViewRestrictedLayout *layout = [LWZCollectionViewRestrictedLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:self];
    _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) _self = self;
    [_collectionView lwz_setupRefreshWithPageStartIndex:1 pageSize:99 refreshingHandler:^(UICollectionView *collectionView, NSInteger startIndex, NSInteger pageIndex, NSInteger pageSize) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [RLModelProvider requestPageDataWithPageIndex:pageIndex pageSize:pageSize complete:^(NSArray<RLModel *> * _Nullable models, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( error == nil ) {
                if ( pageIndex == startIndex ) {
                    // 当请求的索引为 startIndex, 表示 header 刷新, 这时候清理掉旧的数据
                    [self.collectionProvider removeAllItems];
                }
                [self.collectionProvider addItemsWithModelArray:models];
                [self.collectionView lwz_endRefreshingWithItemCount:models.count];
            }
            else {
                NSLog(@"%@", error);
                [self.collectionView lwz_endRefreshing];
            }
            [self.collectionView reloadData];
        }];
    }];
}

- (void)_setupCollection {
    _collectionProvider = [RLCollectionProvider.alloc init];
    _collectionProvider.itemTapHandler = ^(RLModel * _Nonnull model) {
        NSLog(@"%@", model);
    };

    _collectionPresenter = [LWZCollectionViewPresenter.alloc initWithCollectionProvider:_collectionProvider];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_collectionPresenter numberOfSectionsInCollectionView:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_collectionPresenter collectionView:collectionView numberOfItemsInSection:section];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_collectionPresenter collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_collectionPresenter collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_collectionPresenter collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - LWZCollectionViewLayoutDelegate

- (void)layout:(__kindof LWZCollectionViewLayout *)layout willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container {
    [_collectionPresenter layout:layout willPrepareLayoutInContainer:container];
}

- (void)layout:(__kindof LWZCollectionViewLayout *)layout didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container {
    [_collectionPresenter layout:layout didFinishPreparingInContainer:container];
}

- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout contentInsetsForSectionAtIndex:(NSInteger)section {
    return [_collectionPresenter layout:layout contentInsetsForSectionAtIndex:section];
}

- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [_collectionPresenter layout:layout minimumInteritemSpacingForSectionAtIndex:section];
}

- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [_collectionPresenter layout:layout minimumLineSpacingForSectionAtIndex:section];
}

- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [_collectionPresenter layout:layout layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
}
@end
