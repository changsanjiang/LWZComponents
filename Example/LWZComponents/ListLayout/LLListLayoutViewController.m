//
//  LLListLayoutViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//
//  列表布局
//

#import "LLListLayoutViewController.h"
#import "LWZDependencies.h"
#import "LLCollectionProvider.h"

@interface LLListLayoutViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, LWZCollectionViewListLayoutDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LLCollectionProvider *collectionProvider;
@property (nonatomic, strong) LWZCollectionViewPresenter *collectionPresenter;
@property (nonatomic) LWZCollectionLayoutAlignment layoutAlignment;
@end

@implementation LLListLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSStringFromClass(self.class);
    
    LWZCollectionViewListLayout *layout = [LWZCollectionViewListLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:self];
    _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.layer.borderColor = UIColor.orangeColor.CGColor;
    _collectionView.layer.borderWidth = 1.0;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(12, 12, 12, 12));
    }];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"更改" style:UIBarButtonItemStyleDone target:self action:@selector(changeLayoutAlignment)];
    
    _collectionProvider = [LLCollectionProvider.alloc init];
    _collectionPresenter = [LWZCollectionViewPresenter.alloc initWithCollectionProvider:_collectionProvider];
}

- (void)changeLayoutAlignment {
    LWZCollectionLayoutAlignment layoutAlignment = _layoutAlignment;
    NSInteger next = (layoutAlignment + 1) % 3;
    _layoutAlignment = next;
    [_collectionProvider setLayoutAlignment:next];
    [_collectionView.collectionViewLayout invalidateLayout];
    [_collectionView reloadData];
    
    switch ( next ) {
        case LWZCollectionLayoutAlignmentStart:
            self.navigationItem.title = @"左对齐";
            break;
        case LWZCollectionLayoutAlignmentEnd:
            self.navigationItem.title = @"右对齐";
            break;
        case LWZCollectionLayoutAlignmentCenter:
            self.navigationItem.title = @"居中对齐";
            break;
    }
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

#pragma mark - LWZCollectionViewWaterfallFlowLayoutDelegate

- (void)layout:(__kindof LWZCollectionViewLayout *)layout willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container {
    [_collectionPresenter layout:layout willPrepareLayoutInContainer:container];
}

- (void)layout:(__kindof LWZCollectionViewLayout *)layout didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container {
    [_collectionPresenter layout:layout didFinishPreparingInContainer:container];
}

- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout contentInsetsForSectionAtIndex:(NSInteger)section {
    return [_collectionPresenter layout:layout contentInsetsForSectionAtIndex:section];
}

- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [_collectionPresenter layout:layout minimumLineSpacingForSectionAtIndex:section];
}
 
- (LWZCollectionLayoutAlignment)layout:(__kindof LWZCollectionViewLayout *)layout layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout layoutAlignmentForItemAtIndexPath:indexPath];
}

- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [_collectionPresenter layout:layout layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
}
@end
