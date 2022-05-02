//
//  RLCollectionProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "RLCollectionProvider.h"
#import "RLCollectionTextItem.h"
 
@implementation RLCollectionProvider {
    LWZCollectionSection *_mSection;
}
- (instancetype)init {
    self = [super init];
    if ( self ) {
        
        _mSection = [LWZCollectionSection.alloc init];
        _mSection.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        _mSection.minimumLineSpacing = 5;
        _mSection.minimumInteritemSpacing = 5;
        [self addSection:_mSection];
    }
    return self;
}

- (void)addItemsWithModelArray:(NSArray<RLModel *> *)models {
    for ( RLModel *tagModel in models ) {
        RLCollectionTextItem *item = [RLCollectionTextItem.alloc initWithModel:tagModel];
        [_mSection addItem:item];
    }
}

- (void)removeAllItems {
    [_mSection removeAllItems];
}
@end
