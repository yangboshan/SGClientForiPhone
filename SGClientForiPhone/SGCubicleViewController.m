//
//  SGCubicleViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGCubicleViewController.h"
#import "SGMainPageBussiness.h"

@interface SGCubicleViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) NSArray* roomList;
@property (nonatomic,strong) UICollectionView* roomView;


@end

@implementation SGCubicleViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - property



@end
