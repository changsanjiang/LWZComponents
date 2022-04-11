//
//  LLViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LLViewController.h"
#import "CommonDependencies.h"
#import "LLProvider.h"

@interface LLViewController ()
// horizontal scroll
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter1;
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter2;
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter3;

// vertical scroll
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter4;
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter5;
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter6;
@end

@implementation LLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSStringFromClass(self.class);

#pragma mark - horizontal scroll

    
    CGRect frame = CGRectMake(12, 20, self.view.bounds.size.width - 12 * 2, 88);
    // 与 collectionView 顶部对齐
    LWZCollectionViewPresenter *presenter = [LWZCollectionViewPresenter.alloc initWithProvider:[LLProvider.alloc initWithAlignment:LWZCollectionLayoutAlignmentStart]];
    LWZCollectionViewListLayout *collectionListLayout = [LWZCollectionViewListLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionHorizontal delegate:presenter];
    LWZCollectionView *collectionView = [LWZCollectionView.alloc initWithFrame:frame collectionViewLayout:collectionListLayout];
    collectionView.dataSource = presenter;
    collectionView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:collectionView];
    _presenter1 = presenter;
    
    
    frame.origin.y = CGRectGetMaxY(frame) + 20;
    // 与 collectionView1 中心对齐
    presenter = [LWZCollectionViewPresenter.alloc initWithProvider:[LLProvider.alloc initWithAlignment:LWZCollectionLayoutAlignmentCenter]];
    collectionListLayout = [LWZCollectionViewListLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionHorizontal delegate:presenter];
    collectionView = [LWZCollectionView.alloc initWithFrame:frame collectionViewLayout:collectionListLayout];
    collectionView.dataSource = presenter;
    collectionView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:collectionView];
    _presenter2 = presenter;


    frame.origin.y = CGRectGetMaxY(frame) + 20;
    // 与 collectionView 底部对齐
    presenter = [LWZCollectionViewPresenter.alloc initWithProvider:[LLProvider.alloc initWithAlignment:LWZCollectionLayoutAlignmentEnd]];
    collectionListLayout = [LWZCollectionViewListLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionHorizontal delegate:presenter];
    collectionView = [LWZCollectionView.alloc initWithFrame:frame collectionViewLayout:collectionListLayout];
    collectionView.dataSource = presenter;
    collectionView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:collectionView];
    _presenter3 = presenter;
    
    
#pragma mark - vertical scroll

    
    frame.origin.y = CGRectGetMaxY(frame) + 20;
    // 与 collectionView 底部对齐
    presenter = [LWZCollectionViewPresenter.alloc initWithProvider:[LLProvider.alloc initWithAlignment:LWZCollectionLayoutAlignmentStart]];
    collectionListLayout = [LWZCollectionViewListLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:presenter];
    collectionView = [LWZCollectionView.alloc initWithFrame:frame collectionViewLayout:collectionListLayout];
    collectionView.dataSource = presenter;
    collectionView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:collectionView];
    _presenter4 = presenter;

    
    frame.origin.y = CGRectGetMaxY(frame) + 20;
    // 与 collectionView 底部对齐
    presenter = [LWZCollectionViewPresenter.alloc initWithProvider:[LLProvider.alloc initWithAlignment:LWZCollectionLayoutAlignmentCenter]];
    collectionListLayout = [LWZCollectionViewListLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:presenter];
    collectionView = [LWZCollectionView.alloc initWithFrame:frame collectionViewLayout:collectionListLayout];
    collectionView.dataSource = presenter;
    collectionView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:collectionView];
    _presenter5 = presenter;
    

    frame.origin.y = CGRectGetMaxY(frame) + 20;
    // 与 collectionView 底部对齐
    presenter = [LWZCollectionViewPresenter.alloc initWithProvider:[LLProvider.alloc initWithAlignment:LWZCollectionLayoutAlignmentEnd]];
    collectionListLayout = [LWZCollectionViewListLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:presenter];
    collectionView = [LWZCollectionView.alloc initWithFrame:frame collectionViewLayout:collectionListLayout];
    collectionView.dataSource = presenter;
    collectionView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:collectionView];
    _presenter6 = presenter;
}

@end
