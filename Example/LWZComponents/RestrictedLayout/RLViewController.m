//
//  RLViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "RLViewController.h"
#import "RLModelProvider.h"
#import "RLProvider.h"
#import "CommonDependencies.h"

@interface RLViewController ()
@property (nonatomic, strong) LWZCollectionView *collectionView;
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter;
@property (nonatomic, strong) RLProvider *provider;
@end

@implementation RLViewController

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
    
    LWZCollectionViewLayout *layout = [LWZCollectionRestrictedLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:_presenter];
    layout.sectionHeadersPinToVisibleBounds = YES;
    _collectionView = [LWZCollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = _presenter;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) _self = self;
    [RLModelProvider requestDataWithComplete:^(NSArray<RLModel *> * _Nullable list, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        if ( error != nil ) {
            NSLog(@"(%d : %s) WLViewController.error: %@", __LINE__, sel_getName(_cmd), error);
            return;
        }
        
        self.provider = [RLProvider.alloc initWithList:list];
        self.presenter.provider = self.provider;
        [self.collectionView reloadData];
    }];
}
@end
