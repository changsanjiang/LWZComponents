//
//  LLCollectionProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LLCollectionProvider.h"
#import "LLCollectionItem.h"

@implementation LLCollectionProvider {
    LWZCollectionSection *_mSection;
}
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _mSection = [LWZCollectionSection.alloc init];
        _mSection.minimumLineSpacing = 8;
        _mSection.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        [self addSection:_mSection];
        
        // 添加一些 item
        for ( NSInteger i = 0 ; i < 99 ; ++ i ) {
            LLCollectionItem *item = [LLCollectionItem.alloc init];
            item.layoutAlignment = arc4random() % 3; // 设置随机的对齐方式
            [_mSection addItem:item];
        }
    }
    return self;
}

- (void)setLayoutAlignment:(LWZCollectionLayoutAlignment)layoutAlignment {
    [_mSection enumerateItemsUsingBlock:^(__kindof LWZCollectionItem * _Nonnull item, NSInteger index, BOOL * _Nonnull stop) {
        item.layoutAlignment = layoutAlignment;
    }];
}
@end
