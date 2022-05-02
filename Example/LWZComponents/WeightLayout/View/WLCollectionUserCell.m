//
//  WLCollectionUserCell.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLCollectionUserCell.h"
#import "LWZImageView.h"

@interface WLCollectionUserCell ()
@property (weak, nonatomic) IBOutlet LWZImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation WLCollectionUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_imageView setLayoutSubviewsExeBlock:^(__kindof LWZImageView * _Nonnull view) {
        view.layer.cornerRadius = view.bounds.size.height * 0.5;
    }];
}

- (void)setDataSource:(nullable id<WLCollectionUserCellDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        _imageView.image = dataSource.avatar;
        _nameLabel.text = dataSource.name;
    }
}
@end
