//
//  SGScanContainerViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/19.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGScanContainerViewController.h"
#import "SGScanViewController.h"


@interface SGScanContainerViewController ()

@property(nonatomic,strong) SGScanViewController* scanController;
@end

@implementation SGScanContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描";  
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.scanController = [[SGScanViewController alloc] init];
    [self addChildViewController:self.scanController];
    [self.view addSubview:self.scanController.view];
    [self.scanController didMoveToParentViewController:self];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.scanController willMoveToParentViewController:nil];
    [self.scanController.view removeFromSuperview];
    [self.scanController removeFromParentViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
