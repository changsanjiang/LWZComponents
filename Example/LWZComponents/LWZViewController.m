//
//  LWZViewController.m
//  LWZComponents
//
//  Created by changsanjiang@gmail.com on 12/25/2021.
//  Copyright (c) 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZViewController.h"
#import "WLWeightLayoutDemoViewController.h"
#import "LLListLayoutViewController.h"
#import "WFWaterfallFlowLayoutViewController.h"
#import "TLTemplateLayoutViewController.h"
#import "CLCompositionalLayoutViewController.h"
#import "RLRestrictedLayoutViewController.h"
#import "MLMultipleLayoutViewController.h"

@interface LWZViewController ()

@end

@implementation LWZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pushWeightLayout:(id)sender {
    WLWeightLayoutDemoViewController *vc = [WLWeightLayoutDemoViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pushListLayout:(id)sender {
    LLListLayoutViewController *vc = [LLListLayoutViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)pushRestrictedLayout:(id)sender {
    RLRestrictedLayoutViewController *vc = [RLRestrictedLayoutViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)pushWaterfallFlowLayout:(id)sender {
    WFWaterfallFlowLayoutViewController *vc = [WFWaterfallFlowLayoutViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pushTemplateLayout:(id)sender {
    TLTemplateLayoutViewController *vc = [TLTemplateLayoutViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pushCompositionalLayout:(id)sender {
    CLCompositionalLayoutViewController *vc = [CLCompositionalLayoutViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)pushMultipleLayout:(id)sender {
    MLMultipleLayoutViewController *vc = [MLMultipleLayoutViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
