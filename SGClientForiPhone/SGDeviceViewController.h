//
//  SGDeviceViewController.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/6/23.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseDrawViewController.h"
@interface SGDeviceViewController : SGBaseDrawViewController

@property(nonatomic,strong) NSString* deviceId;
@end

@interface SGDeviceEntity : NSObject

@property(nonatomic,strong) NSString* groupId;//设备ID 或 交换机ID
@property(nonatomic,assign) NSUInteger count;
@property(nonatomic,assign) BOOL isDevice;


@end
