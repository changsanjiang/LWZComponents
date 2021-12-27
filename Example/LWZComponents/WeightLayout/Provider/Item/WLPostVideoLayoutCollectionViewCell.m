//
//  WLPostVideoLayoutCollectionViewCell.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLPostVideoLayoutCollectionViewCell.h"
#import "CommonLabel.h"

@interface WLPostVideoLayoutCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet CommonLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UIButton *likingButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@end

@implementation WLPostVideoLayoutCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _avatarImageView.layer.cornerRadius = 22;
    _avatarImageView.clipsToBounds = YES;
    
    _coverImageView.layer.cornerRadius = 5;
    _coverImageView.clipsToBounds = YES;
    _playImageView.image = [UIImage imageNamed:@"icon_play"];
    // Initialization code
}

- (void)setDataSource:(nullable id<WLPostVideoLayoutCollectionViewCellDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        [self reloadDataSource];
    }
}

- (void)reloadLikingNum {
    [_likingButton setAttributedTitle:_dataSource.likingNum forState:UIControlStateNormal];
}

- (void)reloadShareNum {
    [_shareButton setAttributedTitle:_dataSource.shareNum forState:UIControlStateNormal];
}

- (void)reloadDataSource {
    _avatarImageView.image = _dataSource.avatar;
    _nameLabel.attributedText = _dataSource.name;
    _contentLabel.attributedText = _dataSource.content;
    _coverImageView.image = _dataSource.cover;
    [_commentButton setAttributedTitle:_dataSource.commentNum forState:UIControlStateNormal];
    [self reloadLikingNum];
    [self reloadShareNum];
}

- (IBAction)handleTapAction:(id)sender {
    if ( sender == _likingButton ) {
        [_delegate likingItemWasTappedInCell:self];
    }
    else if ( sender == _commentButton ) {
        [_delegate commentItemWasTappedInCell:self];
    }
    else if ( sender == _shareButton ) {
        [_delegate shareItemWasTappedInCell:self];
    }
}

@end
