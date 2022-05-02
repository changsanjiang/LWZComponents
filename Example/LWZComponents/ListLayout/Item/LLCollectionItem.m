//
//  LLCollectionItem.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LLCollectionItem.h"

@interface LLCollectionItem () {
    UIColor *_backgroundColor;
}
@end

@implementation LLCollectionItem
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
            return CGSizeMake(size.width * 0.5, 44);
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake(88, size.height * 0.5);
    }
}

- (void)bindCell:(__kindof UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.backgroundColor = _backgroundColor;
}
@end
