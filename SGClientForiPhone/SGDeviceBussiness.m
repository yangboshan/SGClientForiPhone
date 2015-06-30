//
//  SGDeviceBussiness.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/6/23.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGDeviceBussiness.h"
#import "SGEntity.h"


/*－－－－－－－－－－－－－－－－－
 根据设备ID 获取InfoSet表信息
 －－－－－－－－－－－－－－－－－*/

#define DP_GetInfoSetList(d) [NSString stringWithFormat:@"select infoset_id,name,description,type,[group],txied_id,txiedport_id,rxied_id,rxiedport_id,switch1_id,switch1_rxport_id,switch1_txport_id,switch2_id,\
switch2_rxport_id,switch2_txport_id,switch3_id,switch3_rxport_id,switch3_txport_id,switch4_id,switch4_rxport_id,switch4_txport_id,rxiedport_id from infoset \
where (txied_id = %@ or rxied_id = %@) and type!=0 order by type,switch1_id,switch2_id,switch3_id,switch4_id,[group]",d,d]

#define DP_GetDeviceInfo(d) [NSString stringWithFormat:@"select description from device where device_id = %@",d]
#define DP_GetPortInfo(p) [NSString stringWithFormat:@"select  board.position || '/' ||port.name as type   from port inner join board on port.board_id = board.board_id where port_id =  %@",p]

@implementation SGDeviceBussiness

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGDeviceBussiness)

-(NSArray*)queryInfoSetListByDeviceId:(NSString*)deviceId{
    
    NSArray* infosetList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetInfoSetList(deviceId)] withEntity:@"SGInfoSetItem"];
    NSPredicate* predicate1 = [NSPredicate predicateWithFormat:@"switch1_id == '0'"];
    NSPredicate* predicate2 = [NSPredicate predicateWithFormat:@"switch1_id != '0'"];

    NSArray* leftList = [infosetList filteredArrayUsingPredicate:predicate1];
    NSArray* rightList = [infosetList filteredArrayUsingPredicate:predicate2];
    
//    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES];
//    NSArray *leftListSorted = [leftList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    
    return @[leftList,rightList];
}

-(NSString*)queryDeviceById:(NSString*)deviceId{
    
    NSArray* l = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetDeviceInfo(deviceId)] withEntity:@"SGDeviceInfo"];
    return [l[0] description];
}

-(NSString*)queryPortById:(NSString*)portId{
    
    NSArray* l  = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetPortInfo(portId)] withEntity:@"SGPortInfo"];
    return [l[0] type];
}

@end
