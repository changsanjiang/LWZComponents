//
//  WLCollectionSectionHeaderFooter.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLCollectionSectionHeaderFooter.h"
#import "WLCollectionSectionHeaderFooterView.h"
#import "CommonTextLayoutSize.h"

@interface WLCollectionSectionHeaderFooter ()<WLCollectionSectionHeaderFooterViewDataSource>
@property (nonatomic, strong, nullable) NSAttributedString *title;
@end

@implementation WLCollectionSectionHeaderFooter
- (instancetype)initWithTitle:(NSAttributedString *)title {
    self = [super init];
    if ( self ) {
        _title = title;
    }
    return self;
}

- (Class)viewClass {
    return WLCollectionSectionHeaderFooterView.class;
}

- (NSBundle *)viewNibBundle {
    return NSBundle.mainBundle;
}

- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(__kindof LWZCollectionSection *)section atIndex:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    return CGSizeMake(size.width, _contentInsets.top + [_title lwz_textContainerWithLayoutSizeThatFits:size limitedToNumberOfLines:0 fixesSingleLineSpacing:YES].layoutSize.height + _contentInsets.bottom);
}

- (void)bindView:(WLCollectionSectionHeaderFooterView *)view inSection:(NSInteger)section {
    view.dataSource = self;
}
@end
