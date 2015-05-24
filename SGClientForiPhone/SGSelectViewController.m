//
//  SGSelectViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/18.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGSelectViewController.h"
#import "PureLayout.h"

@interface SGSelectViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong) UINavigationBar* navBar;
@property (nonatomic,strong) UITableView* listView;
@property (nonatomic,strong) UIView* headerView;
@end

@implementation SGSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"请选择一个设备进行加载"];
    [self.navBar pushNavigationItem:navItem animated:NO];
    [self.view addSubview:self.navBar];
    
    self.navBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.navBar autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.navBar autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.navBar autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];

    if (ScreenWidth>ScreenHeight) {
        [self.navBar autoSetDimension:ALDimensionHeight toSize:NavBarHeightAlone];
    }else{
        [self.navBar autoSetDimension:ALDimensionHeight toSize:NavBarHeight];
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.listView];
    
    [self.listView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.navBar withOffset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.listView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];


}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    if (size.width>size.height) {
        [self.navBar autoSetDimension:ALDimensionHeight toSize:NavBarHeightAlone];
     }else{
        [self.navBar autoSetDimension:ALDimensionHeight toSize:NavBarHeight];

    }
}

-(void)setDataSource:(NSArray *)dataSource{
    _dataSource = [dataSource valueForKeyPath:@"@distinctUnionOfObjects.self"];
}

#pragma mark - getter
//-(UIView*)headerView{
//    if (!_headerView) {
//        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
//        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, self.view.bounds.size.width, 30)];
//        [label setText:@"请选择一个设备进行加载"];
//        [label setTextColor:[UIColor grayColor]];
//        [label setTextAlignment:NSTextAlignmentLeft];
//        [_headerView addSubview:label];
//    }
//    return _headerView;
//}


-(UITableView*)listView{
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_listView setDelegate:self];
        [_listView setDataSource:self];
    }
    return _listView;
}

#pragma mark - tableView delegate&datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"cellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray* ret = [self.dataSource[indexPath.row] componentsSeparatedByString:@"****"];
    cell.textLabel.text = ret[1];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = Lantinghei(15);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray* ret = [self.dataSource[indexPath.row] componentsSeparatedByString:@"****"];

    [self.delegate userDidSelectItem:[ret[2] integerValue]];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

