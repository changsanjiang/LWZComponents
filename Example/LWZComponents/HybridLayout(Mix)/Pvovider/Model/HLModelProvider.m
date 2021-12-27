//
//  HLModelProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "HLModelProvider.h"
#import "WLModelProvider.h"
#import "RLModelProvider.h"
#import "WFLModelProvider.h"

@implementation HLModelProvider
+ (void)requestDataWithComplete:(void(^)(HLModel *_Nullable model, NSError *_Nullable error))completionHandler {
    __block WLDetailModel *wl_model;
    __block NSArray<RLModel *> *rl_list;
    __block NSArray<WFLModel *> *wfl_list;
    __block NSError *mError;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [WLModelProvider requestDataWithComplete:^(WLDetailModel * _Nullable detail, NSError * _Nullable error) {
        if ( mError == nil ) mError = error;
        wl_model = detail;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [RLModelProvider requestDataWithComplete:^(NSArray<RLModel *> * _Nullable list, NSError * _Nullable error) {
        if ( mError == nil ) mError = error;
        rl_list = list;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [WFLModelProvider requestDataWithComplete:^(NSArray<WFLModel *> * _Nullable list, NSError * _Nullable error) {
        if ( mError == nil ) mError = error;
        wfl_list = list;
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        HLModel *model = nil;
        if ( mError == nil ) {
            model = [HLModel new];
            model.wl_Model = wl_model;
            model.rl_List = rl_list;
            model.wfl_list = wfl_list;
        }
        if ( completionHandler != nil ) completionHandler(model, mError);
    });
}
@end
