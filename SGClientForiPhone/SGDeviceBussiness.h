//
//  SGDeviceBussiness.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/6/23.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseBussiness.h"

@interface SGDeviceBussiness : SGBaseBussiness
+(SGDeviceBussiness*)sharedSGDeviceBussiness;

-(NSArray*)queryInfoSetListByDeviceId:(NSString*)deviceId;
-(NSString*)queryDeviceById:(NSString*)deviceId;
-(NSString*)queryPortById:(NSString*)portId;

@end
