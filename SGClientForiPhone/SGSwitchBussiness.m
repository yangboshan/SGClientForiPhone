//
//  SGSwitchBussiness.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/8/24.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGSwitchBussiness.h"

#define DP_GetPortList(d) [NSString stringWithFormat:@"select  port.board_id ,port.port_id ,port.name,port.[group] from port inner join board on port.board_id = board.board_id where board.device_id  = %@",d]

@implementation SGSwitchBussiness

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGSwitchBussiness)

- (NSArray*)queryAllPortListByDeviceId:(NSString*)deviceId{
    
    NSArray* portList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetPortList(deviceId)] withEntity:@"SGPortInfo"];
    
    NSMutableArray* a = [NSMutableArray array];
    for(SGPortInfo* portInfo in portList){
        
        NSMutableArray* temp = [self getSubArrayByPortInfo:portInfo list:a];
        if (!temp) {
            NSMutableArray* s = [NSMutableArray array];
            [s addObject:portInfo];
            [a addObject:s];
        }else{
            [temp addObject:portInfo];
        }
    }
    return a;
}

- (NSMutableArray*)getSubArrayByPortInfo:(SGPortInfo*)portInfo list:(NSMutableArray*)list{
    
    for(NSMutableArray* a in list){
        for(SGPortInfo* p in a){
            if ([p.group isEqualToString:portInfo.group] && [p.board_id isEqualToString:portInfo.board_id]) {
                return a;
            }
        }
    }
    return nil;
}
@end
