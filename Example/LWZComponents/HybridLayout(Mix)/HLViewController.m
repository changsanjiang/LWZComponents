//
//  HLViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "HLViewController.h"
#import "CommonDependencies.h"
#import "HLModelProvider.h"
#import "HLProvider.h"

@interface HLViewController ()
@property (nonatomic, strong) LWZCollectionView *collectionView;
@property (nonatomic, strong) LWZCollectionViewPresenter *presenter;
@property (nonatomic, strong) HLProvider *provider;
@end

@implementation HLViewController

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
    
    LWZCollectionViewLayout *layout = [LWZCollectionHybridLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:_presenter];
    layout.sectionHeadersPinToVisibleBounds = YES;
    _collectionView = [LWZCollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = _presenter;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) _self = self;
    [HLModelProvider requestDataWithComplete:^(HLModel * _Nullable model, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        if ( error != nil ) {
            NSLog(@"(%d : %s) WLViewController.error: %@", __LINE__, sel_getName(_cmd), error);
            return;
        }
        
        self.provider = [HLProvider.alloc initWithModel:model];
        self.provider.userItemTapHandler = ^(NSInteger userId) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
#ifdef DEBUG
            NSLog(@"%d : %s", __LINE__, sel_getName(_cmd));
#endif
        };
        
        self.provider.commentItemTapHandler = ^(NSIndexPath * _Nonnull indexPath) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            NSLog(@"处理评论动作...");
            
            UIViewController *vc = [UIViewController.alloc init];
            vc.view.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                      green:arc4random() % 256 / 255.0
                                                       blue:arc4random() % 256 / 255.0
                                                      alpha:1];
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        self.provider.likingItemTapHandler = ^(NSIndexPath * _Nonnull indexPath) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            NSLog(@"处理点赞动作...");
            
            BOOL isLiked = [self.provider isPostLikedForItemAtIndexPath:indexPath];
            [self.provider setPostLiked:!isLiked forItemAtIndexPath:indexPath];
        };
        
        self.provider.shareItemTapHandler = ^(NSIndexPath * _Nonnull indexPath) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            NSLog(@"处理分享动作...");
            
            NSInteger count = [self.provider postShareCountForItemAtIndexPath:indexPath];
            [self.provider setPostShareCount:count + 1 forItemAtIndexPath:indexPath];
        };
        
        self.presenter.provider = self.provider;
        [self.collectionView reloadData];
    }];
}
@end
