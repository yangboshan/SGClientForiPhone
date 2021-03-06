//
//  SGRoomCell.m
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGRoomCell.h"
#import "SGMacro.h"
#import "UIView+Category.h"
#import "SGDeviceViewController.h"
#import "SGSwitchViewController.h"
#import "SGDeviceBussiness.h"


@implementation SGRoomCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 初始化时加载collectionCell.xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SGRoomCell" owner:self options: nil];

        if(arrayOfViews.count < 1)
        {
            return nil;
        }

        if(![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]){
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        self.deviceListView.layer.cornerRadius = 5.0;
        self.deviceListView.layer.borderColor = BorderColor;
        self.deviceListView.layer.borderWidth = 1.0;
        self.deviceListView.dataSource = self;
        self.deviceListView.delegate = self;
        
        [self.roomInfo setTextColor:[UIColor darkGrayColor]];
        [self.roomInfo setFont:Lantinghei(14)];
        [self.roomInfo setNumberOfLines:0];
        [self.roomInfo setUserInteractionEnabled:YES];
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped)];
        [self.roomInfo addGestureRecognizer:gesture];
    }
    return self;
}

-(void)cellTapped{
    [self.delegate cellDidSeletedWithCubicleId:self.data];
}

-(void)setData:(NSDictionary *)data{
    _data = data;
    self.roomInfo.text = [data objectForKey:@"name"];
    [self.deviceListView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 25;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([[self.data objectForKey:@"device"] isKindOfClass:[NSDictionary class]]) {
        return 1;
    }
    if ([[self.data objectForKey:@"device"] isKindOfClass:[NSArray class]]) {
        
        NSArray* a = (NSArray*)[self.data objectForKey:@"device"];
        return a.count;
    }
    
    
//    NSArray* ary = (NSArray*)[self.data objectForKey:@"device"];
//    if(ary)
//        return ary.count;
//    else
//    {
//        NSDictionary* dict = (NSDictionary*)[self.data objectForKey:@"device"];
//        if(dict)
//            return 1;
//    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.font = Lantinghei(12);
    cell.textLabel.textColor = [UIColor darkGrayColor];
    id deviceobj = [self.data objectForKey:@"device"];
    if ([deviceobj isKindOfClass:[NSArray class]]) {
        id text =[[[deviceobj objectAtIndex:indexPath.row] objectForKey:@"devicename"] objectForKey:@"text"];
        if(text == nil)
            text = @"";
        cell.textLabel.text = text;
        
    }
    else if ([deviceobj isKindOfClass:[NSDictionary class]]) {
        id text =[[deviceobj objectForKey:@"devicename"] objectForKey:@"text"];
        if(text == nil)
            text = @"";
        cell.textLabel.text = text;
    }
    else
        cell.textLabel.text = @"";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id deviceobj = [self.data objectForKey:@"device"];
    
    NSString* deviceId = @"";
    
    if([deviceobj isKindOfClass:[NSArray class]]){
        deviceId =[[[deviceobj objectAtIndex:indexPath.row] objectForKey:@"deviceid"] objectForKey:@"text"];
    }else{
        deviceId =[[deviceobj objectForKey:@"deviceid"] objectForKey:@"text"];
    }

    NSLog(@"------>>> %@",deviceId);
    
    if ([[[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceTypeById:deviceId] isEqualToString:@"0"]) {
        SGDeviceViewController* deviceController = [SGDeviceViewController new];
        deviceController.deviceId = deviceId;
        [[self viewController].navigationController pushViewController:deviceController animated:YES];
    }
    if ([[[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceTypeById:deviceId] isEqualToString:@"1"]) {
        SGSwitchViewController* switchController = [SGSwitchViewController new];
        switchController.deviceId = deviceId;
        [[self viewController].navigationController pushViewController:switchController animated:YES];
    }
    

}

@end
