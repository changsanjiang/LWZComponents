//
//  WFLModelProvider.m
//  LWZCollectionViewComponents_Example
//
//  Created by changsanjiang on 2021/11/26.
//  Copyright © 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "WFLModelProvider.h"
#import "LWZDependencies.h"

@implementation WFLModelProvider

+ (void)requestPageDataWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize complete:(void(^)(NSArray<WFLModel *> *_Nullable models, NSError *_Nullable error))completionHandler {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [NSBundle.mainBundle pathForResource:@"WFLModelJsonData" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray<WFLModel *> *list = nil;
        if ( error == nil ) {
            list = [NSArray yy_modelArrayWithClass:WFLModel.class json:jsonObj];
        }
        
        NSMutableArray<WFLModel *> *models = NSMutableArray.array;
        for ( NSInteger i = 0 ; i < pageSize ; ++ i ) {
            NSInteger randomIndex = arc4random() % list.count;
            [models addObject:list[randomIndex]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler != nil ) completionHandler(models, error);
        });
    });
}
@end
