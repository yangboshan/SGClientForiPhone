//
//  SGRoomCell.m
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGRoomCell.h"
#import "SGMacro.h"


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
        
//        [self.deviceListView setBackgroundColor:NavBarColorAlpha(0.7)];
        [self.roomInfo setTextColor:[UIColor darkGrayColor]];
        [self.roomInfo setFont:Lantinghei(16)];
        [self.roomInfo setNumberOfLines:0];
 
        
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped)];
        [self addGestureRecognizer:gesture];
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
    NSArray* ary = (NSArray*)[self.data objectForKey:@"device"];
    if(ary)
        return ary.count;
    else
    {
        NSDictionary* dict = (NSDictionary*)[self.data objectForKey:@"device"];
        if(dict)
            return 1;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
//    cell.contentView.backgroundColor = NavBarColorAlpha(0.7);
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

@end
