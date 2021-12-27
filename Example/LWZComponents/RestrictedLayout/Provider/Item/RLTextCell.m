//
//  RLTextCell.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "RLTextCell.h"

@interface RLTextCell()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation RLTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.clipsToBounds = YES;
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    self.contentView.layer.cornerRadius = size.height < size.width ? size.height * 0.5 : size.width * 0.5;
    _label.frame = UIEdgeInsetsInsetRect(self.bounds, _dataSource.contentInset);
}

- (void)setDataSource:(id<RLTextCellDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        _label.attributedText = dataSource.text;
        
        self.contentView.backgroundColor = dataSource.backgroundColor;
    }
}
@end
