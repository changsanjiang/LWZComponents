//
//  WFLCollectionItem.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WFLCollectionItem.h"
#import "WFLCollectionViewCell.h"
#import "CommonDependencies.h"
#import "CommonTextLayoutSize.h"

@interface WFLCollectionItem ()<WFLCollectionViewCellDataSource>
@property (nonatomic, strong, nullable) UIImage *cover;
@property (nonatomic, strong, nullable) NSAttributedString *name;
@end

@implementation WFLCollectionItem
- (instancetype)initWithModel:(WFLModel *)model {
    self = [super init];
    if ( self ) {
        _cover = [UIImage imageNamed:model.cover];
        _name = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(model.name);
            make.textColor(UIColor.blackColor);
            make.font([UIFont systemFontOfSize:14]);
        }];
    }
    return self;
}

- (Class)cellClass {
    return WFLCollectionViewCell.class;
}

- (NSBundle *)cellNibBundle {
    return NSBundle.mainBundle;
}

- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(LWZCollectionSection *)section atIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    CGFloat w = size.width;
    CGSize coverSize = _cover.size;
    CGFloat coverH = w * coverSize.height / coverSize.height;
    CGFloat nameH = 8 + [_name lwz_layoutSizeThatFits:CGSizeMake(size.width - 5 - 5, size.height) limitedToNumberOfLines:0].height + 12;
    CGFloat h = coverH + nameH;
    return CGSizeMake(w, h);
}

- (void)bindCell:(WFLCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = self;
}

@end
