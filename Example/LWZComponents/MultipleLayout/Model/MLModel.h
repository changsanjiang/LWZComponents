//
//  MLModel.h
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//
 
#import "WLModel.h"
#import "RLModel.h"
#import "WFLModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface MLModel : NSObject
@property (nonatomic, strong, nullable) NSArray<WLPostModel *> *wl_Model;
@property (nonatomic, strong, nullable) NSArray<RLModel *> *rl_List;
@property (nonatomic, strong, nullable) NSArray<WFLModel *> *wfl_list;
@end
NS_ASSUME_NONNULL_END
