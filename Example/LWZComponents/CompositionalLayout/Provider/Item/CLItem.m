//
//  CLItem.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/13.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "CLItem.h"

@interface CLItem () {
    UIColor *_backgroundColor;
}
@end

@implementation CLItem
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0
                                           green:arc4random() % 256 / 255.0
                                            blue:arc4random() % 256 / 255.0
                                           alpha:1.0];
    }
    return self;
}

- (Class)cellClass {
    return UICollectionViewCell.class;
}

- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(LWZCollectionSection *)section atIndexPath:(NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    switch ( scrollDirection ) {
        case UICollectionViewScrollDirectionVertical:
            return CGSizeMake(size.width, size.width * 9 / 16.0);
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake(size.height * 16 / 9.0, size.height);
    }
}

- (void)bindCell:(__kindof UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.backgroundColor = _backgroundColor;
}
@end
