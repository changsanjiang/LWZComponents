//
//  WLUserCollectionItem.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLUserCollectionItem.h"
#import "WLUserCollectionViewCell.h"

@interface WLUserCollectionItem ()<WLUserCollectionViewCellDataSource>
@property (nonatomic, strong, nullable) UIImage *avatar;
@property (nonatomic, strong, nullable) NSString *name;
@end

@implementation WLUserCollectionItem
- (instancetype)initWithModel:(WLUserModel *)model {
    self = [super init];
    if ( self ) {
        _avatar = [UIImage imageNamed:model.avatar];
        _name = model.name;
        _userId = model.id;
    }
    return self;
}

// 将要绑定的 cell 类
- (Class)cellClass {
    return WLUserCollectionViewCell.class;
}

// 如果 cell 需要从 xib 创建, 则实现这个方法, 并返回对应的 cell.xib 所在的 bundle
- (NSBundle *)cellNibBundle {
    return NSBundle.mainBundle;
}

// 计算 cell 将要显示的 size
- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(LWZCollectionSection *)section atIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    CGFloat nameH = 15;
    switch ( scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            CGFloat w = size.width;
            CGFloat coverH = w - 12 * 2;
            CGFloat h = 12 + coverH + 8 + nameH + 12;
            return CGSizeMake(w, h);
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            CGFloat h = size.height;
            CGFloat coverW = h - 12 - nameH - 8;
            CGFloat w = 12 + coverW + 12;
            return CGSizeMake(w, h);
        }
            break;
    }
}

// 绑定到 cell
// 一般在此处将数据配置到 cell 上
- (void)bindCell:(WLUserCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = self;
}
@end
