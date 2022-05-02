//
//  MLModelProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "MLModelProvider.h"
#import "WLModelProvider.h"
#import "RLModelProvider.h"
#import "WFLModelProvider.h"

@implementation MLModelProvider
+ (void)requestDataWithComplete:(void(^)(MLModel *_Nullable model, NSError *_Nullable error))completionHandler {
    __block NSArray<WLPostModel *> *wl_model;
    __block NSArray<RLModel *> *rl_list;
    __block NSArray<WFLModel *> *wfl_list;
    __block NSError *mError;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [WLModelProvider requestPageDataWithPageIndex:1 pageSize:10 complete:^(NSArray<WLPostModel *> * _Nullable posts, NSError * _Nullable error) {
        if ( mError == nil ) mError = error;
        wl_model = posts;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [RLModelProvider requestPageDataWithPageIndex:1 pageSize:10 complete:^(NSArray<RLModel *> * _Nullable models, NSError * _Nullable error) {
        if ( mError == nil ) mError = error;
        rl_list = models;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [WFLModelProvider requestPageDataWithPageIndex:1 pageSize:10 complete:^(NSArray<WFLModel *> * _Nullable models, NSError * _Nullable error) {
        if ( mError == nil ) mError = error;
        wfl_list = models;
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        MLModel *model = nil;
        if ( mError == nil ) {
            model = [MLModel new];
            model.wl_Model = wl_model;
            model.rl_List = rl_list;
            model.wfl_list = wfl_list;
        }
        if ( completionHandler != nil ) completionHandler(model, mError);
    });
}
@end
