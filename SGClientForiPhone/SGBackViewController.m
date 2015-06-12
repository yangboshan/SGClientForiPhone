//
//  SGBackViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/6/12.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBackViewController.h"

@interface SGBackViewController ()

@end

@implementation SGBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(pop)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 }
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
}

-(void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
