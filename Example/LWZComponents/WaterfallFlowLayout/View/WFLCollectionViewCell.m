//
//  WFLCollectionViewCell.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WFLCollectionViewCell.h"

@interface WFLCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation WFLCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1];
    self.contentView.layer.cornerRadius = 5;
    self.contentView.clipsToBounds = YES;
    // Initialization code
}


- (void)setDataSource:(nullable id<WFLCollectionViewCellDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        
        _coverImageView.image = dataSource.cover;
        _nameLabel.attributedText = dataSource.name;
    }
}
@end
