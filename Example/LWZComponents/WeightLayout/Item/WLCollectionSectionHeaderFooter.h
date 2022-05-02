//
//  WLCollectionSectionHeaderFooter.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZCollectionSectionHeaderFooter.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLCollectionSectionHeaderFooter : LWZCollectionSectionHeaderFooter
- (instancetype)initWithTitle:(NSAttributedString *)title;
@property (nonatomic) UIEdgeInsets contentInsets;
@end

NS_ASSUME_NONNULL_END
