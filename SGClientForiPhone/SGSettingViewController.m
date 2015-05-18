//
//  SGSettingViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGSettingViewController.h"
#import "SGPortPageBussiness.h"
#import "SGDBViewController.h"
#import "PureLayout.h"


@interface SGSettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *listView;
@property (nonatomic,strong) NSArray* dataList;

@end

@implementation SGSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    [self.view addSubview:self.listView];
    
    self.listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataList[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"identifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [self.dataList[indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = Lantinghei(15);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id controller;
    
    switch (indexPath.section) {
            
        case 0:
            
            switch (indexPath.row) {
                case 0:
                    controller = [SGDBViewController new];
                    break;
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - getter

-(UITableView*)listView{
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero
                                                 style:UITableViewStyleGrouped];
        [_listView setDelegate:self];
        [_listView setDataSource:self];
        [_listView setBackgroundColor:RGB(247, 247, 247)];
    }
    return _listView;
}

-(NSArray*)dataList{
    if (!_dataList) {
        _dataList = @[@[@"数据库配置",@"绘图配置"],@[@"其他配置"]];
    }
    return _dataList;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
