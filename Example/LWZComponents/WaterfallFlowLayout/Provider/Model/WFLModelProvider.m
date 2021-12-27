//
//  WFLModelProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WFLModelProvider.h"
#import "CommonDependencies.h"

@implementation WFLModelProvider

+ (void)requestDataWithComplete:(void(^)(NSArray<WFLModel *> *_Nullable list, NSError *_Nullable error))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [NSBundle.mainBundle pathForResource:@"WFLJsonData" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray<WFLModel *> *list = nil;
        if ( error == nil ) {
            list = [NSArray yy_modelArrayWithClass:WFLModel.class json:jsonObj];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler != nil ) completionHandler(list, error);
        });
    });
}

@end
