//
//  CLViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/13.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "CLViewController.h"
#import "CLProvider.h"
#import "CommonDependencies.h"

@interface CLViewController ()
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter;
@property (nonatomic, strong) LWZCollectionView *collectionView;
@end

@implementation CLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    // Do any additional setup after loading the view.
}

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = UIColor.whiteColor;
    
    _presenter = [LWZCollectionViewPresenter.alloc initWithProvider:CLProvider.alloc.init];
    
    LWZCollectionViewCompositionalLayout *layout = [LWZCollectionViewCompositionalLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:_presenter];
    _collectionView = [LWZCollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = _presenter;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

@end
