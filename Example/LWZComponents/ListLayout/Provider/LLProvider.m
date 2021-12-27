//
//  LLProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LLProvider.h"
#import "LLCollectionItem.h"

@implementation LLProvider
- (instancetype)initWithAlignment:(LWZCollectionLayoutAlignment)alignment {
    self = [super init];
    if ( self ) {
        [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
            make.minimumLineSpacing = 8;
            
            for ( NSInteger i = 0 ; i < 12 ; ++ i ) {
                LLCollectionItem *item = [LLCollectionItem.alloc init];
                item.layoutAlignment = alignment;
                [make addItem:item];
            }
        }];
    }
    return self;
}
@end
