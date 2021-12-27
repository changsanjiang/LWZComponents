//
//  RLModelProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/12/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "RLModelProvider.h"
#import "CommonDependencies.h"

@implementation RLModelProvider
+ (void)requestDataWithComplete:(void(^)(NSArray<RLModel *> *_Nullable list, NSError *_Nullable error))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [NSBundle.mainBundle pathForResource:@"RLJsonData" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray<RLModel *> *list = nil;
        if ( error == nil ) {
            list = [NSArray yy_modelArrayWithClass:RLModel.class json:jsonObj];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler != nil ) completionHandler(list, error);
        });
    });
}
@end
