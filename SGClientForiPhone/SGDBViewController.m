//
//  SGDBViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/18.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGDBViewController.h"
#import "SGAPPConfig.h"
#import "SGUtility.h"
#import "PureLayout.h"


@interface SGDBViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView* listView;
@property (nonatomic,strong) NSMutableArray* dataList;
@property (nonatomic,strong) UIView* headerView;
@property (nonatomic,strong) NSString* currentDBString;
@end

@implementation SGDBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    }
    return self;
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
        
        _dataList = [NSMutableArray array];
        NSFileManager *fileManager =  [NSFileManager defaultManager];
        NSArray* files = [fileManager subpathsAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                                                      objectAtIndex:0]];
        
        for(NSString* file in files){
            if ([[file pathExtension] isEqualToString:@"sqlite"]) {
                NSArray* a = [file componentsSeparatedByString:@"."];
                [_dataList addObject:a[0]];
            }
        }
    }
    return _dataList;
}

-(UIView*)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        UILabel* tip = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
        [tip setText:@"请选择一个数据库进行加载"];
        [tip setTextColor:[UIColor darkGrayColor]];
        [tip setFont:Lantinghei(16)];
        [_headerView addSubview:tip];
    }
    return _headerView;
}

-(NSString*)currentDB{
    NSArray* a = [[SGUtility getCurrentDB] componentsSeparatedByString:@"."];
    return a[0];
}
#pragma mark - tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0;
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return self.headerView;
    }
    return nil;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"identifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    cell.textLabel.text = self.dataList[indexPath.row];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = Lantinghei(15);
    if ([self.dataList[indexPath.row] isEqualToString:[self currentDB]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    for(int i = 0; i<self.dataList.count;i++){
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.currentDBString = cell.textLabel.text;
}

-(void)save{
    
    UINavigationController* nav = self.tabBarController.viewControllers[0];
    [nav popToRootViewControllerAnimated:NO];
    
    [SGUtility setCurrentDB:[NSString stringWithFormat:@"%@.sqlite",self.currentDBString]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.listView];
    
    self.listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    
    _currentDBString = [self currentDB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
