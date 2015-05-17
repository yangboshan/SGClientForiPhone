//
//  SGRoomCell.h
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGRoomCellDelegate <NSObject>
-(void)cellDidSeletedWithCubicleId:(NSDictionary*)cubicleData;

@end


@interface SGRoomCell : UICollectionViewCell<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *deviceListView;
@property (weak, nonatomic) IBOutlet UILabel *roomInfo;
@property (nonatomic,strong) NSDictionary* data;
@property (nonatomic,weak) id<SGRoomCellDelegate> delegate;

@end


