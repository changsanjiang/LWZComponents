//
//  WLWeightLayoutDemoViewController.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//
//  每个 item 按所占比重布局
//

#import "WLWeightLayoutDemoViewController.h"
#import "LWZDependencies.h"
#import "WLCollectionProvider.h"
#import "WLModelProvider.h"
#import "UIScrollView+LWZRefreshAdditions.h"

@interface WLWeightLayoutDemoViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, LWZCollectionViewWeightLayoutDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WLCollectionProvider *collectionProvider;
@property (nonatomic, strong) LWZCollectionViewPresenter *collectionPresenter;
@end

@implementation WLWeightLayoutDemoViewController

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
    
    LWZCollectionViewWeightLayout *layout = [LWZCollectionViewWeightLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:self];
    layout.sectionHeadersPinToVisibleBounds = YES;
    _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) _self = self;
    [_collectionView lwz_setupRefreshWithPageStartIndex:1 pageSize:10 refreshingHandler:^(UICollectionView *collectionView, NSInteger startIndex, NSInteger pageIndex, NSInteger pageSize) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        __block NSArray<WLPostModel *> * _Nullable gPosts;
        __block NSArray<WLUserModel *> * _Nullable gUsers;
        __block NSError *_Nullable gError;
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        [WLModelProvider requestPageDataWithPageIndex:pageIndex pageSize:pageSize complete:^(NSArray<WLPostModel *> * _Nullable posts, NSError * _Nullable error) {
            gPosts = posts;
            if ( error != nil ) gError = error;
            dispatch_group_leave(group);
        }];
        
        // 请求第一页的时候, 也刷新一下 users;
        if ( pageIndex == startIndex ) {
            dispatch_group_enter(group);
            [WLModelProvider requestUserDataWithComplete:^(NSArray<WLUserModel *> * _Nullable users, NSError * _Nullable error) {
                gUsers = users;
                if ( error != nil ) gError = error;
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( gError == nil ) {
                if ( pageIndex == startIndex ) {
                    // 当请求的索引为 startIndex, 表示 header 刷新, 这时候清理掉旧的数据
                    [self.collectionProvider removeAllPostItems];
                    [self.collectionProvider removeAllUserItems];
                    
                    [self.collectionProvider addUserItemsWithModelArray:gUsers];
                }
                [self.collectionProvider addPostItemsWithModelArray:gPosts];
                [self.collectionView lwz_endRefreshingWithItemCount:gPosts.count];
            }
            else {
                NSLog(@"%@", gError);
                [self.collectionView lwz_endRefreshing];
            }
            [self.collectionView reloadData];
        });
    }];
}

- (void)_setupCollection {
    __weak typeof(self) _self = self;
    _collectionProvider = [WLCollectionProvider.alloc init];
    _collectionProvider.commentItemTapHandler = ^(NSIndexPath * _Nonnull indexPath) {
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
    
    _collectionProvider.likingItemTapHandler = ^(NSIndexPath * _Nonnull indexPath) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        NSLog(@"处理点赞动作...");
        
        BOOL isLiked = [self.collectionProvider isPostLikedForItemAtIndexPath:indexPath];
        [self.collectionProvider setPostLiked:!isLiked forItemAtIndexPath:indexPath];
    };
    
    _collectionProvider.shareItemTapHandler = ^(NSIndexPath * _Nonnull indexPath) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        NSLog(@"处理分享动作...");
        
        NSInteger count = [self.collectionProvider postShareCountForItemAtIndexPath:indexPath];
        [self.collectionProvider setPostShareCount:count + 1 forItemAtIndexPath:indexPath];
    };
    
    _collectionProvider.userItemTapHandler = ^(NSInteger userId) {
        NSLog(@"%ld", (long)userId);
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

// - cell

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

// - header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [_collectionPresenter collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath {
    [_collectionPresenter collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
}

#pragma mark - LWZCollectionViewWeightLayoutDelegate

- (void)layout:(__kindof LWZCollectionViewLayout *)layout willPrepareLayoutInContainer:(LWZCollectionLayoutContainer *)container {
    [_collectionPresenter layout:layout willPrepareLayoutInContainer:container];
}

- (void)layout:(__kindof LWZCollectionViewLayout *)layout didFinishPreparingInContainer:(LWZCollectionLayoutContainer *)container {
    [_collectionPresenter layout:layout didFinishPreparingInContainer:container];
}

- (BOOL)layout:(__kindof LWZCollectionViewLayout *)layout isSectionHiddenAtIndex:(NSInteger)section {
    return [_collectionPresenter layout:layout isSectionHiddenAtIndex:section];
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
 
- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout layoutWeightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout layoutWeightForItemAtIndexPath:indexPath];
}

- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [_collectionPresenter layout:layout layoutSizeToFit:fittingSize forHeaderInSection:section scrollDirection:scrollDirection];
}

- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return [_collectionPresenter layout:layout layoutSizeToFit:fittingSize forItemAtIndexPath:indexPath scrollDirection:scrollDirection];
}

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForHeaderInSection:(NSInteger)section {
    return [_collectionPresenter layout:layout zIndexForHeaderInSection:section];
}

// - decoration

- (NSString *)layout:(__kindof LWZCollectionViewLayout *)layout decorationViewKindForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationViewKindForHeaderAtIndexPath:indexPath];
}

- (NSString *)layout:(__kindof LWZCollectionViewLayout *)layout decorationViewKindForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationViewKindForItemAtIndexPath:indexPath];
}

- (id)layout:(__kindof LWZCollectionViewLayout *)layout decorationUserInfoForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationUserInfoForHeaderAtIndexPath:indexPath];
}

- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout decorationUserInfoForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationUserInfoForItemAtIndexPath:indexPath];
}

- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout  decorationRelativeRectToFit:rect forHeaderAtIndexPath:indexPath];
}

- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout decorationRelativeRectToFit:(CGRect)rect forItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationRelativeRectToFit:rect forItemAtIndexPath:indexPath];
}

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout decorationZIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationZIndexForItemAtIndexPath:indexPath];
}

- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout decorationZIndexForHeaderAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [_collectionPresenter layout:layout decorationZIndexForHeaderAtIndexPath:indexPath];
}
@end
