//
//  WLCollectionSectionHeaderFooterView.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLCollectionSectionHeaderFooterView.h"

@interface WLCollectionSectionHeaderFooterView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation WLCollectionSectionHeaderFooterView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = UIColor.whiteColor;

    [self updateTitleLabelLayout];
}

- (void)updateTitleLabelLayout {
    _titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, _dataSource.contentInsets);
}

- (void)setDataSource:(nullable id<WLCollectionSectionHeaderFooterViewDataSource>)dataSource {
    if ( _dataSource != dataSource ) {
        _dataSource = dataSource;
        _titleLabel.attributedText = dataSource.title;
        [self updateTitleLabelLayout];
    }
}
@end
