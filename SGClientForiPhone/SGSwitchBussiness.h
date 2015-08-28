//
//  SGSwitchBussiness.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/8/24.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseBussiness.h"

@interface SGSwitchBussiness : SGBaseBussiness

+(SGSwitchBussiness*)sharedSGSwitchBussiness;

- (NSArray*)queryAllPortListByDeviceId:(NSString*)deviceId;

- (NSArray*)queryPortConnectionInfoByPort1:(NSString*)port1 port2:(NSString*)port2;

- (NSString*)queryPortById:(NSString*)portId;

@end
 