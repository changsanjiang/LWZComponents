//
//  LWZViewController.m
//  LWZComponents
//
//  Created by changsanjiang@gmail.com on 12/25/2021.
//  Copyright (c) 2021 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZViewController.h"
#import "WLViewController.h"
#import "LLViewController.h"
#import "WFLViewController.h"
#import "TLViewController1.h"
#import "CLViewController.h"
#import "RLViewController.h"
#import "MLViewController.h"

@interface LWZViewController ()

@end

@implementation LWZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pushWeightLayout:(id)sender {
    WLViewController *vc = [WLViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pushListLayout:(id)sender {
    LLViewController *vc = [LLViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)pushRestrictedLayout:(id)sender {
    RLViewController *vc = [RLViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)pushWaterfallFlowLayout:(id)sender {
    WFLViewController *vc = [WFLViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pushTemplateLayout:(id)sender {
    TLViewController1 *vc = [TLViewController1.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pushCompositionalLayout:(id)sender {
    CLViewController *vc = [CLViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)pushMultipleLayout:(id)sender {
    MLViewController *vc = [MLViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
