//
//  WLModelProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLModelProvider.h"
#import "LWZDependencies.h"

@implementation WLModelProvider

+ (void)requestUserDataWithComplete:(void(^)(NSArray<WLUserModel *> *_Nullable users, NSError *_Nullable error))completionHandler {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [NSBundle.mainBundle pathForResource:@"WLModelJsonData" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        WLDetailModel *jsonModel = nil;
        NSMutableArray<WLUserModel *> *models = nil;
        if ( error == nil ) {
            jsonModel = [WLDetailModel yy_modelWithJSON:jsonObj];
            
            // 搞点随机数据
            models = NSMutableArray.array;
            for ( NSInteger i = 0 ; i < jsonModel.users.count ; ++ i ) {
                NSInteger randomIndex = arc4random() % jsonModel.users.count;
                [models addObject:jsonModel.users[randomIndex]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler != nil ) completionHandler(models, error);
        });
    });
}

+ (void)requestPageDataWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize complete:(void(^)(NSArray<WLPostModel *> *_Nullable posts, NSError *_Nullable error))completionHandler {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [NSBundle.mainBundle pathForResource:@"WLModelJsonData" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        WLDetailModel *jsonModel = nil;
        NSMutableArray<WLPostModel *> *models = nil;
        if ( error == nil ) {
            jsonModel = [WLDetailModel yy_modelWithJSON:jsonObj];
            models = NSMutableArray.array;
            for ( NSInteger i = 0 ; i < pageSize ; ++ i ) {
                NSInteger randomIndex = arc4random() % jsonModel.posts.count;
                [models addObject:jsonModel.posts[randomIndex]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler != nil ) completionHandler(models, error);
        });
    });
}

@end
