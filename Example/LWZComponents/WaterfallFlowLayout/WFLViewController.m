//
//  WFLViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WFLViewController.h"
#import "WFLProvider.h"
#import "WFLModelProvider.h"
#import "CommonDependencies.h"

@interface WFLViewController ()
@property (nonatomic, strong) LWZCollectionView *collectionView;
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter;
@property (nonatomic, strong) WFLProvider *provider;
@end

@implementation WFLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    // Do any additional setup after loading the view.
}

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = UIColor.whiteColor;
    
    _presenter = [LWZCollectionViewPresenter.alloc init];
    
    LWZCollectionViewWaterfallFlowLayout *layout = [LWZCollectionViewWaterfallFlowLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:_presenter];
    _collectionView = [LWZCollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = _presenter;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) _self = self;
    [WFLModelProvider requestDataWithComplete:^(NSArray<WFLModel *> * _Nullable list, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        if ( error != nil ) {
            NSLog(@"(%d : %s) WFLViewController.error: %@", __LINE__, sel_getName(_cmd), error);
            return;
        }
        
        self.provider = [WFLProvider.alloc initWithList:list];
        self.presenter.provider = self.provider;
        [self.collectionView reloadData];
    }];

}

@end
