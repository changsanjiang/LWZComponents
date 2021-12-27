//
//  WFLProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/29.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WFLProvider.h"
#import "WFLCollectionItem.h"

@implementation WFLProvider
- (instancetype)initWithList:(NSArray<WFLModel *> *)list {
    self = [super init];
    if ( self ) {
        [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
            make.minimumInteritemSpacing = 8;
            make.minimumLineSpacing = 8;
            make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
            make.numberOfArrangedItemsPerLine = 2;
            
            for ( WFLModel *model in list ) {
                WFLCollectionItem *item = [WFLCollectionItem.alloc initWithModel:model];
                [make addItem:item];
            }
        }];
    }
    return self;
}
@end
