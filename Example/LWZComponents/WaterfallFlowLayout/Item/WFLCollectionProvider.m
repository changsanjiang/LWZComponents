//
//  WFLCollectionProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/29.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WFLCollectionProvider.h"
#import "WFLCollectionItem.h"

@implementation WFLCollectionProvider {
    LWZCollectionSection *_mSection;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _mSection = [LWZCollectionSection.alloc init];
        _mSection.minimumInteritemSpacing = 8;
        _mSection.minimumLineSpacing = 8;
        _mSection.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        // 设置两列
        _mSection.numberOfArrangedItemsPerLine = 2;
        
        [self addSection:_mSection];
    }
    return self;
}

- (void)addItemsWithModelArray:(NSArray<WFLModel *> *)models {
    __weak typeof(self) _self = self;
    for ( WFLModel *model in models ) {
        WFLCollectionItem *item = [WFLCollectionItem.alloc initWithModel:model];
        item.selectionHandler = ^(__kindof LWZCollectionItem * _Nonnull item, NSIndexPath * _Nonnull indexPath) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( self.itemTapHandler != nil ) self.itemTapHandler(model);
        };
        [_mSection addItem:item];
    }
}

- (void)removeAllItems {
    [_mSection removeAllItems];
}
@end
