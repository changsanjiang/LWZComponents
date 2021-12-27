//
//  RLTextItem.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "RLTextItem.h"
#import "RLTextCell.h"
#import "CommonDependencies.h"
#import "CommonTextLayoutSize.h"

@interface RLTextItem ()<RLTextCellDataSource>
@property (nonatomic, strong, nullable) NSAttributedString *text;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic) UIEdgeInsets contentInset;
@end

@implementation RLTextItem

- (instancetype)initWithModel:(RLModel *)model {
    self = [super init];
    if ( self ) {
        _text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(model.name);
            make.textColor(UIColor.whiteColor);
            make.font([UIFont systemFontOfSize:14]);
            make.alignment(NSTextAlignmentCenter);
        }];
        _backgroundColor = UIColor.magentaColor;
        _contentInset = UIEdgeInsetsMake(8, 12, 8, 12);
    }
    return self;
}

- (Class)cellClass {
    return RLTextCell.class;
}

- (NSBundle *)cellNibBundle {
    return NSBundle.mainBundle;
}

- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(LWZCollectionSection *)section atIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    CGSize textSize = CGSizeZero;
    switch ( scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            textSize = [_text lwz_layoutSizeThatFits:CGSizeMake(size.width - _contentInset.left - _contentInset.right, size.height)
                              limitedToNumberOfLines:0];
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            textSize = [_text lwz_layoutSizeThatFits:CGSizeMake(size.width, size.height - _contentInset.top - _contentInset.bottom)
                              limitedToNumberOfLines:0];
        }
            break;
    }
    textSize.width += _contentInset.left + _contentInset.right;
    textSize.height += _contentInset.top + _contentInset.bottom;
    return textSize;
}

- (void)bindCell:(RLTextCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = self;
}
@end
