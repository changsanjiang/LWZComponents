//
//  WLModelProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/25.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WLModelProvider.h"
#import "CommonDependencies.h"

@implementation WLModelProvider

+ (void)requestDataWithComplete:(void(^)(WLDetailModel *_Nullable detail, NSError *_Nullable error))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [NSBundle.mainBundle pathForResource:@"WLJsonData" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        WLDetailModel *model = nil;
        if ( error == nil ) {
            model = [WLDetailModel yy_modelWithJSON:jsonObj];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler != nil ) completionHandler(model, error);
        });
    });
}

@end
