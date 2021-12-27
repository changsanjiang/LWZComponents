//
//  RLProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "RLProvider.h"
#import "RLTextItem.h"
 
@implementation RLProvider
- (instancetype)initWithList:(NSArray<RLModel *> * _Nullable)list {
    self = [super init];
    if ( self ) {
        
        [self addSectionWithBlock:^(__kindof LWZCollectionSection * _Nonnull make) {
            make.contentInsets = UIEdgeInsetsMake(12, 12, 12, 12);
            make.minimumLineSpacing = 5;
            make.minimumInteritemSpacing = 5;
            
            for ( RLModel *tagModel in list ) {
                RLTextItem *item = [RLTextItem.alloc initWithModel:tagModel];
                [make addItem:item];
            }
        }];
        
    }
    return self;
}
@end
