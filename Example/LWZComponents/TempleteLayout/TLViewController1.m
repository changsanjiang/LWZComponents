//
//  TLViewController1.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/13.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "TLViewController1.h"
#import "CommonDependencies.h"

@interface TLCollectionViewCell1 : UICollectionViewCell
@property (nonatomic, strong, readonly) UILabel *label;
@end

@implementation TLCollectionViewCell1
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _label = [UILabel.alloc initWithFrame:CGRectZero];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = UIColor.whiteColor;
        _label.font = [UIFont boldSystemFontOfSize:40];
        [self.contentView addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
    return self;
}
@end

@interface TLViewController1 ()<UICollectionViewDataSource, UICollectionViewDelegate, LWZCollectionTemplateLayoutDelegate>
@property (nonatomic, strong) LWZCollectionViewLayout *templateLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) CGFloat testMargin;
@end

@implementation TLViewController1

static NSString *cellReusedId = @"A";
static NSArray<UIColor *> *colors;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSStringFromClass(self.class);

    LWZCollectionViewLayout *layout = [LWZCollectionTemplateLayout.alloc initWithScrollDirection:UICollectionViewScrollDirectionVertical delegate:self];
    _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.whiteColor;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:TLCollectionViewCell1.class forCellWithReuseIdentifier:cellReusedId];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    colors = @[
        UIColor.blackColor,
        UIColor.darkGrayColor,
        UIColor.grayColor,
        UIColor.redColor,
        UIColor.greenColor,
        UIColor.blueColor,
        UIColor.cyanColor,
        UIColor.yellowColor,
        UIColor.magentaColor,
        UIColor.orangeColor,
        UIColor.purpleColor,
        UIColor.brownColor,
    ];
    
    UIBarButtonItem *rightItem = [UIBarButtonItem.alloc initWithTitle:@"Test" style:UIBarButtonItemStyleDone target:self action:@selector(test)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view.
}

- (void)test {
    _testMargin += 12;
    [_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(_testMargin, _testMargin, _testMargin, _testMargin));
    }];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:cellReusedId forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(TLCollectionViewCell1 *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    cell.contentView.backgroundColor = colors[indexPath.item % colors.count];
}


#pragma mark - LWZCollectionTemplateLayoutDelegate

- (NSArray<LWZCollectionLayoutTemplateGroup *> *)layout:(__kindof LWZCollectionViewLayout *)layout layoutTemplateContainerGroupsInSection:(NSInteger)section {
  
    return [LWZCollectionLayoutTemplate build:^(LWZCollectionTemplateBuilder * _Nonnull make) {
        /**
            Container 1
             |
         +---|----------------------------------+ <-- Group
         |   v                                  |
         |  +--------------+  +--------------+ <----- Container 2
         |  |              |  |              |  |
         |  |  +--------+  |  |  +--------+ <-------- Item
         |  |  |        |  |  |  |        |  |  |
         |  |  |   1    |  |  |  |        |  |  |
         |  |  +--------+  |  |  |        |  |  |
         |  |              |  |  |        |  |  |
         |  |  +--------+  |  |  |        |  |  |
         |  |  |        |  |  |  |        |  |  |
         |  |  |   2    |  |  |  |   3    |  |  |
         |  |  +--------+  |  |  +--------+  |  |
         |  |              |  |              |  |
         |  +--------------+  +--------------+  |
         |                                      |
         +--------------------------------------+
         */
        make.addGroup(^(LWZCollectionTemplateGroupBuilder * _Nonnull group) {
            group.width.fractionalWidth(1.0);
            group.height.fractionalWidth(1.0);
            
            // container 1
            group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                container.width.fractionalWidth(0.5);
                container.height.fractionalHeight(1.0);
                
                // items
                for ( NSInteger i = 0 ; i < 2 ; ++ i ) {
                    container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                        item.width.fractionalWidth(1.0);
                        item.height.fractionalHeight(0.5);
                    });
                }
            });
            
            // container 2
            group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                container.width.fractionalWidth(0.5);
                container.height.fractionalHeight(1.0);
                
                container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                    item.width.fractionalWidth(1.0);
                    item.height.fractionalHeight(1.0);
                });
            });
        });
        
        /**
         +--------------------------------------+
         |                                      |
         |  +--------------+  +--------------+  |
         |  |              |  |              |  |
         |  |  +--------+  |  |  +--------+  |  |
         |  |  |        |  |  |  |        |  |  |
         |  |  |   1    |  |  |  |   3    |  |  |
         |  |  +--------+  |  |  +--------+  |  |
         |  |              |  |              |  |
         |  |  +--------+  |  |  +--------+  |  |
         |  |  |        |  |  |  |        |  |  |
         |  |  |   2    |  |  |  |   4    |  |  |
         |  |  +--------+  |  |  +--------+  |  |
         |  |              |  |              |  |
         |  +--------------+  +--------------+  |
         |                                      |
         +--------------------------------------+
         */
         
        make.addGroup(^(LWZCollectionTemplateGroupBuilder * _Nonnull group) {
            group.width.fractionalWidth(1.0);
            group.height.fractionalWidth(1.0);
            
            for ( NSInteger i = 0 ; i < 2 ; ++ i ) {
                // container
                group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                    container.width.fractionalWidth(0.5);
                    container.height.fractionalHeight(1.0);
                    
                    // items
                    for ( NSInteger i = 0 ; i < 2 ; ++ i ) {
                        container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                            item.width.fractionalWidth(1);
                            item.height.fractionalHeight(0.5);
                        });
                    }
                });
            }
        });
        
        /**
         +--------------------+
         |                    |
         |  +--------------+  |
         |  |              |  |
         |  |  +--------+  |  |
         |  |  |        |  |  |
         |  |  |   1    |  |  |
         |  |  +--------+  |  |
         |  |              |  |
         |  |  +--------+  |  |
         |  |  |        |  |  |
         |  |  |   2    |  |  |
         |  |  +--------+  |  |
         |  |              |  |
         |  |  +--------+  |  |
         |  |  |        |  |  |
         |  |  |   3    |  |  |
         |  |  +--------+  |  |
         |  |              |  |
         |  +--------------+  |
         |                    |
         +--------------------+
         */
        make.addGroup(^(LWZCollectionTemplateGroupBuilder * _Nonnull group) {
            group.width.fractionalWidth(1.0);
            group.height.fractionalWidth(1.0);
            
            group.addContainer(^(LWZCollectionTemplateContainerBuilder * _Nonnull container) {
                container.width.fractionalWidth(1.0);
                container.height.fractionalHeight(1.0);
                
                for ( NSInteger i = 0 ; i < 3 ; ++ i ) {
                    container.addItem(^(LWZCollectionTemplateItemBuilder * _Nonnull item) {
                        item.width.fractionalWidth(1);
                        item.height.fractionalHeight(1/3.0);
                    });
                }
            });
        });
    }];
}

- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout edgeSpacingsForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout contentInsetsForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

//- (BOOL)layout:(__kindof LWZCollectionViewLayout *)layout canPinToVisibleBoundsForHeaderInSection:(NSInteger)section;
//- (UIEdgeInsets)layout:(__kindof LWZCollectionViewLayout *)layout adjustedPinnedInsetsForSectionAtIndex:(NSInteger)section;

//- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forHeaderInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
//
//}
//- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forItemAtIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
//- (CGSize)layout:(__kindof LWZCollectionViewLayout *)layout layoutSizeToFit:(CGSize)fittingSize forFooterInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}
- (CGFloat)layout:(__kindof LWZCollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}
//- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (nullable NSString *)layout:(__kindof LWZCollectionViewLayout *)layout elementKindForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;
//
//- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (nullable id)layout:(__kindof LWZCollectionViewLayout *)layout userInfoForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;
//
//- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (CGRect)layout:(__kindof LWZCollectionViewLayout *)layout relativeRectToFit:(CGRect)rect forFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;
//
//- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForHeaderInSection:(NSInteger)section;
//- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForItemAtIndexPath:(NSIndexPath *)indexPath;
//- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForFooterInSection:(NSInteger)section;
//
//- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForSectionDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForHeaderDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForItemDecorationAtIndexPath:(NSIndexPath *)indexPath;
//- (NSInteger)layout:(__kindof LWZCollectionViewLayout *)layout zIndexForFooterDecorationAtIndexPath:(NSIndexPath *)indexPath;
@end
