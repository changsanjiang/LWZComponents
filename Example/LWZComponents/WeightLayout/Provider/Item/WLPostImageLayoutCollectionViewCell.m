//
//  WLPostImageLayoutCollectionViewCell.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLPostImageLayoutCollectionViewCell.h"
#import "CommonLabel.h"

@interface WLPostImageLayoutCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet CommonLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *likingButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopSpacing;
@property (nonatomic, strong, nullable) NSMutableArray<UIImageView *> *coverImageViews;
@end

@implementation WLPostImageLayoutCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _avatarImageView.layer.cornerRadius = 22;
    _avatarImageView.clipsToBounds = YES;
    
    // Initialization code
}

- (void)setDataSource:(nullable id<WLPostImageLayoutCollectionViewCellDataSource>)dataSource {
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

- (void)reloadCovers {
    if ( _coverImageViews == nil ) _coverImageViews = [NSMutableArray array];
    __auto_type items = _dataSource.covers;
    // 补充新增的视图
    if ( _coverImageViews.count < items.count ) {
        for ( NSInteger i = _coverImageViews.count ; i < items.count ; ++ i ) {
            UIImageView *view = [UIImageView.alloc initWithFrame:CGRectZero];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.clipsToBounds = YES;
            view.layer.cornerRadius = 5;
            view.backgroundColor = UIColor.lightGrayColor;
            [_coverImageViews addObject:view];
            [self.containerView addSubview:view];
        }
    }
 
    NSArray<id<WLPostCoverItem>> *covers = self.dataSource.covers;
    NSInteger count = covers.count;
    if ( count != 0 ) {
        _containerView.hidden = NO;
        _containerTopSpacing.constant = 12;
        [_coverImageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull imageView, NSUInteger idx, BOOL * _Nonnull stop) {
            imageView.hidden = idx >= count;
            // 旧的多余的视图将设置隐藏
            if ( imageView.isHidden )
                return;
            
            id<WLPostCoverItem> item = covers[idx];
            imageView.frame = item.frame;
            imageView.image = item.image;
        }];
    }
    else {
        _containerView.hidden = YES;
        _containerTopSpacing.constant = 0;
    }
}

- (void)reloadDataSource {
    _avatarImageView.image = _dataSource.avatar;
    _nameLabel.attributedText = _dataSource.name;
    _contentLabel.attributedText = _dataSource.content;
    
    [self reloadCovers];
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
