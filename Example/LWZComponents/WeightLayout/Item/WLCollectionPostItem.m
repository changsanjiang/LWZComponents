//
//  WLCollectionPostItem.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLCollectionPostItem.h"
#import "LWZDependencies.h"
#import "WLCollectionPostImageLayoutCell.h"
#import "WLCollectionPostVideoLayoutCell.h"
#import "LWZTextLayoutSize.h"

@interface WLCollectionVideoLayoutPostItem : WLCollectionPostItem
@end


@interface WLCollectionImageLayoutPostItem : WLCollectionPostItem
@end

@interface WLCollectionPostItem ()
@property (nonatomic, strong, nullable) UIImage *avatar;
@property (nonatomic, strong, nullable) NSAttributedString *name;
@property (nonatomic, strong, nullable) NSAttributedString *content;
@property (nonatomic, strong, nullable) NSAttributedString *likingNum;
@property (nonatomic, strong, nullable) NSAttributedString *commentNum;
@property (nonatomic, strong, nullable) NSAttributedString *shareNum;
- (instancetype)initWithModel:(WLPostModel *)post;
- (void)reloadLikingNum;
- (void)reloadShareNum;
@end

@implementation WLCollectionPostItem {
    NSInteger _likingCount;
}
+ (instancetype)itemWithModel:(WLPostModel *)post {
    return post.video != nil ? [WLCollectionVideoLayoutPostItem.alloc initWithModel:post] : [WLCollectionImageLayoutPostItem.alloc initWithModel:post];
}

- (instancetype)initWithModel:(WLPostModel *)post {
    self = [super init];
    if ( self ) {
        _shareCount = post.shareCount;
        _likingCount = post.likingCount;
        _isLiked = post.isLiked;
        _avatar = [UIImage imageNamed:post.user.avatar];
        _name = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(post.user.name);
            make.font([UIFont systemFontOfSize:16]);
        }];
        
        if ( post.content != nil ) {
            _content = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(post.content);
                make.font([UIFont systemFontOfSize:14]);
                make.textColor(UIColor.darkTextColor);
                make.lineBreakMode(NSLineBreakByTruncatingTail);
                make.lineSpacing(5);
            }];
        }
        
        [self reloadLikingNum];
        _commentNum = [self textWithNum:post.commentCount iconName:@"icon_comment"];
        [self reloadShareNum];
    }
    return self;
}

- (void)setIsLiked:(BOOL)isLiked {
    if ( isLiked != _isLiked ) {
        _isLiked = isLiked;
        _likingCount += isLiked ? 1 : -1;
        [self reloadLikingNum];
    }
}

- (void)setShareCount:(NSInteger)shareCount {
    if ( _shareCount != shareCount ) {
        _shareCount = shareCount;
        [self reloadShareNum];
    }
}

- (void)reloadLikingNum {
    _likingNum = [self textWithNum:_likingCount iconName:[NSString stringWithFormat:@"icon_liking_%d", _isLiked]];
}

- (void)reloadShareNum {
    _shareNum = [self textWithNum:_shareCount iconName:@"icon_share"];
}

- (NSAttributedString *)textWithNum:(NSInteger)num iconName:(NSString *)iconName {
    return [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
            make.image = [UIImage imageNamed:iconName];
            make.alignment = SJUTVerticalAlignmentCenter;
        });
        make.append([NSString stringWithFormat:@" %ld", (long)num]);
        make.font([UIFont systemFontOfSize:12]);
        make.textColor(UIColor.darkGrayColor);
    }];
}
@end

#pragma mark - <#mark#>


@interface WLCollectionVideoLayoutPostItem ()<WLCollectionPostVideoLayoutCellDataSource, WLCollectionPostVideoLayoutCellDelegate>
@property (nonatomic, strong, nullable) UIImage *cover;
@end

@implementation WLCollectionVideoLayoutPostItem {
    WLCollectionPostVideoLayoutCell *_cell;
}

- (instancetype)initWithModel:(WLPostModel *)post {
    self = [super initWithModel:post];
    if ( self ) {
        _cover = [UIImage imageNamed:post.video.cover];
    }
    return self;
}

- (Class)cellClass {
    return WLCollectionPostVideoLayoutCell.class;
}

- (NSBundle *)cellNibBundle {
    return NSBundle.mainBundle;
}

- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(LWZCollectionSection *)section atIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    CGFloat w = size.width;
    CGFloat avatarH = 44;
    CGFloat contentH = self.content != nil ? (12 + [self.content lwz_textContainerWithLayoutSizeThatFits:CGSizeMake(w, 0x1000) limitedToNumberOfLines:0 fixesSingleLineSpacing:YES].layoutSize.height) : 0;
    CGFloat coverH = 12 + w * 9 / 16.0;
    CGFloat bottomBarH = 8 + 25;
    CGFloat h = avatarH + contentH + coverH + bottomBarH;
    return CGSizeMake(w, h);
}

- (void)bindCell:(WLCollectionPostVideoLayoutCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    _cell = cell;
    cell.dataSource = self;
    cell.delegate = self;
    if ( self.needsLayout ) [cell reloadDataSource];
}

- (void)unbindCell:(__kindof UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    _cell = nil;
}

- (void)reloadLikingNum {
    [super reloadLikingNum];
    [_cell reloadLikingNum];
}

- (void)reloadShareNum {
    [super reloadShareNum];
    [_cell reloadShareNum];
}

#pragma mark - WLCollectionPostVideoLayoutCellDelegate

- (void)likingItemWasTappedInCell:(WLCollectionPostVideoLayoutCell *)cell {
    if ( self.likingItemTapHandler != nil ) self.likingItemTapHandler(self);
}

- (void)shareItemWasTappedInCell:(WLCollectionPostVideoLayoutCell *)cell {
    if ( self.shareItemTapHandler != nil ) self.shareItemTapHandler(self);
}

- (void)commentItemWasTappedInCell:(WLCollectionPostVideoLayoutCell *)cell {
    if ( self.commentItemTapHandler != nil ) self.commentItemTapHandler(self);
}
@end

#pragma mark - <#mark#>

@interface WLPostCoverItem : NSObject<WLPostCoverItem>
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) CGRect frame;
@end

@implementation WLPostCoverItem
- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if ( self ) {
        _image = image;
    }
    return self;
}
@end

@interface WLCollectionImageLayoutPostItem ()<WLCollectionPostImageLayoutCellDataSource, WLCollectionPostImageLayoutCellDelegate>
@property (nonatomic, strong, nullable) NSMutableArray<id<WLPostCoverItem>> *covers;
@end

@implementation WLCollectionImageLayoutPostItem {
    WLCollectionPostImageLayoutCell *_cell;
}

- (instancetype)initWithModel:(WLPostModel *)post {
    self = [super initWithModel:post];
    if ( self ) {
        NSArray<NSString *> *covers = post.covers;
        if ( covers.count != 0 ) {
            _covers = [NSMutableArray array];
            for ( NSString *imageName in covers ) {
                [_covers addObject:[WLPostCoverItem.alloc initWithImage:[UIImage imageNamed:imageName]]];
            }
        }
    }
    return self;
}

- (Class)cellClass {
    return WLCollectionPostImageLayoutCell.class;
}

- (NSBundle *)cellNibBundle {
    return NSBundle.mainBundle;
}

- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(LWZCollectionSection *)section atIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    NSInteger count = _covers.count;
    if ( count != 0 ) {
        // 根据布局宽度, 设置每个封面item的frame
        CGFloat boundary = size.width;
        NSInteger columns = count == 1 ? 1 : 3;
        CGFloat interitemSpacing = 6;
        CGFloat lineSpacing = 6;
        CGFloat itemWidth = floor((boundary - interitemSpacing * (columns - 1)) / columns);
        CGFloat itemHeight = floor(itemWidth);
        CGRect frame = {0, 0, itemWidth, itemHeight};
        WLPostCoverItem *previous = nil;
        for ( NSInteger i = 0 ; i < count ; ++ i ) {
            if ( previous != nil ) {
                frame.origin.x = CGRectGetMaxX(previous.frame) + interitemSpacing;
                frame.origin.y = CGRectGetMinY(previous.frame);
            }
            BOOL isNewLine = CGRectGetMaxX(frame) > boundary;
            if ( isNewLine ) {
                frame.origin.x = 0;
                frame.origin.y = CGRectGetMaxY(previous.frame) + lineSpacing;
            }
            
            WLPostCoverItem *item = _covers[i];
            item.frame = frame;
            previous = item;
        }
    }
    
    CGFloat w = size.width;
    CGFloat avatarH = 44;
    CGFloat contentH = self.content != nil ? (12 + [self.content lwz_textContainerWithLayoutSizeThatFits:CGSizeMake(w, 0x1000) limitedToNumberOfLines:0 fixesSingleLineSpacing:YES].layoutSize.height) : 0;
    CGFloat imagesH = count != 0 ? (12 + CGRectGetMaxY(_covers.lastObject.frame)) : 0;
    CGFloat bottomBarH = 8 + 25;
    CGFloat h = avatarH + contentH + imagesH + bottomBarH;
    return CGSizeMake(w, h);
}

- (void)bindCell:(WLCollectionPostImageLayoutCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    _cell = cell;
    cell.dataSource = self;
    cell.delegate = self;
    if ( self.needsLayout ) [cell reloadDataSource];
}

- (void)unbindCell:(__kindof UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    _cell = nil;
}

- (void)reloadLikingNum {
    [super reloadLikingNum];
    [_cell reloadLikingNum];
}

- (void)reloadShareNum {
    [super reloadShareNum];
    [_cell reloadShareNum];
}

#pragma mark - WLCollectionPostImageLayoutCellDelegate

- (void)likingItemWasTappedInCell:(WLCollectionPostImageLayoutCell *)cell {
    if ( self.likingItemTapHandler != nil ) self.likingItemTapHandler(self);
}

- (void)shareItemWasTappedInCell:(WLCollectionPostImageLayoutCell *)cell {
    if ( self.shareItemTapHandler != nil ) self.shareItemTapHandler(self);
}

- (void)commentItemWasTappedInCell:(WLCollectionPostImageLayoutCell *)cell {
    if ( self.commentItemTapHandler != nil ) self.commentItemTapHandler(self);
}

@end
