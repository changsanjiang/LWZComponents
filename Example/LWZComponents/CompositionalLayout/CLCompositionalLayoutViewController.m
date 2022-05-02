//
//  CLCompositionalLayoutViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/13.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "CLCompositionalLayoutViewController.h"
#import "CLCollectionProvider.h"
#import "LWZDependencies.h"

@interface CLCompositionalLayoutViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, LWZCollectionViewCompositionalLayoutDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CLCollectionProvider *collectionProvider;
@property (nonatomic, strong) LWZCollectionViewPresenter *collectionPresenter;
@end

@implementation CLCompositionalLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSStringFromClass(self.class);
     
    LWZCollectionViewCompositionalLayout *layout = [LWZCollectionViewCompositionalLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:self];
    _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
     
    _collectionProvider = [CLCollectionProvider.alloc init];
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

#pragma mark - LWZCollectionViewCompositionalLayoutDelegate

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

// - layout type

- (LWZCollectionLayoutType)layout:(__kindof LWZCollectionViewLayout *)layout layoutTypeForItemsInSection:(NSInteger)section {
    return [_collectionPresenter layout:layout layoutTypeForItemsInSection:section];
}

// - LWZCollectionLayoutTypeWeight

- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout layoutWeightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout layoutWeightForItemAtIndexPath:indexPath];
}

// - LWZCollectionLayoutTypeList

- (LWZCollectionLayoutAlignment)layout:(__kindof LWZCollectionViewLayout *)layout layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout layoutAlignmentForItemAtIndexPath:indexPath];
}

// - LWZCollectionLayoutTypeWaterfallFlow

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout layoutNumberOfArrangedItemsPerLineInSection:(NSInteger)section {
    return [_collectionPresenter layout:layout layoutNumberOfArrangedItemsPerLineInSection:section];
}

// - LWZCollectionLayoutTypeTemplate

- (NSArray<LWZCollectionTemplateGroup *> *)layout:(__kindof LWZCollectionViewLayout *)layout layoutTemplateContainerGroupsInSection:(NSInteger)section {
    return [_collectionPresenter layout:layout layoutTemplateContainerGroupsInSection:section];
}

// -

- (BOOL)layout:(__kindof LWZCollectionViewLayout *)layout isOrthogonalScrollingInSection:(NSInteger)section {
    return [_collectionPresenter layout:layout isOrthogonalScrollingInSection:section];
}

- (LWZCollectionLayoutContentOrthogonalScrollingBehavior)layout:(__kindof LWZCollectionViewLayout *)layout orthogonalContentScrollingBehaviorInSection:(NSInteger)section {
    return [_collectionPresenter layout:layout orthogonalContentScrollingBehaviorInSection:section];
}

- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forOrthogonalContentInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [_collectionPresenter layout:layout layoutSizeToFit:fittingSize forOrthogonalContentInSection:section scrollDirection:scrollDirection];
}

// - decoration

- (NSString *)layout:(__kindof LWZCollectionViewLayout *)layout decorationViewKindForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationViewKindForItemAtIndexPath:indexPath];
}

- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout decorationUserInfoForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationUserInfoForItemAtIndexPath:indexPath];
}

- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationRelativeRectToFit:rect forItemAtIndexPath:indexPath];
}

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout decorationZIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationZIndexForItemAtIndexPath:indexPath];
}
@end
