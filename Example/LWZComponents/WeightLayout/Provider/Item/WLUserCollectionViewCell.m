//
//  WLUserCollectionViewCell.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLUserCollectionViewCell.h"
#import "CommonImageView.h"

@interface WLUserCollectionViewCell ()
@property (weak, nonatomic) IBOutlet CommonImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation WLUserCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_imageView setLayoutSubviewsExeBlock:^(__kindof CommonImageView * _Nonnull view) {
        view.layer.cornerRadius = view.bounds.size.height * 0.5;
    }];
}

- (void)setDataSource:(nullable id<WLUserCollectionViewCellDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        _imageView.image = dataSource.avatar;
        _nameLabel.text = dataSource.name;
    }
}
@end
