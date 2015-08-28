//
//  SGSwitchBussiness.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/8/24.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGSwitchBussiness.h"

#define DP_GetPortList(d) [NSString stringWithFormat:@"select  port.board_id ,port.port_id ,port.name,port.[group] from port inner join board on port.board_id = board.board_id where board.device_id  = %@",d]

#define DP_GetPortInfo(p) [NSString stringWithFormat:@"select name as type  from port where port_id =  %@",p]

#define DP_GetPortConnection(p1,p2) [NSString stringWithFormat:@"select * from infoset where  \
switch1_txport_id in (%@,%@) or  switch1_rxport_id in (%@,%@) or \
switch2_txport_id in (%@,%@) or  switch2_rxport_id in (%@,%@) or \
switch3_txport_id in (%@,%@) or  switch3_rxport_id in (%@,%@) or \
switch4_txport_id in (%@,%@) or  switch4_rxport_id in (%@,%@) ",p1,p2,p1,p2,p1,p2,p1,p2,p1,p2,p1,p2,p1,p2,p1,p2]

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

- (NSArray*)queryPortConnectionInfoByPort1:(NSString*)port1 port2:(NSString*)port2{
    
    NSArray* infosets = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetPortConnection(port1,port2)] withEntity:@"SGInfoSetItem"];
    
    if (infosets.count) {
        
        NSMutableArray* a = [NSMutableArray array];
        SGInfoSetItem* infosetItem = infosets[0];
        [a addObject:infosetItem];
        
        for(int i = 1; i < infosets.count; i++){
            
            SGInfoSetItem* infoset = infosets[i];
            if ([infoset.group isEqualToString:infosetItem.group]) {
                [a addObject:infoset];
                return a;
            }
        }
    }
    return nil;
}

-(NSString*)queryPortById:(NSString*)portId{
    
    NSArray* l  = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetPortInfo(portId)] withEntity:@"SGPortInfo"];
    return [l[0] type];
}

@end
