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
#define DP_GetDeviceType(d) [NSString stringWithFormat:@"select device_type as description from device where device_id = %@",d]
#define DP_GetPortInfo(p) [NSString stringWithFormat:@"select  board.position || '/' ||port.name as type   from port inner join board on port.board_id = board.board_id where port_id =  %@",p]

@implementation SGDeviceBussiness

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGDeviceBussiness)

-(NSArray*)queryInfoSetListByDeviceId:(NSString*)deviceId{
    
    NSArray* infosetList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetInfoSetList(deviceId)] withEntity:@"SGInfoSetItem"];
    NSPredicate* predicate1 = [NSPredicate predicateWithFormat:@"switch1_id == '0'"];
    NSPredicate* predicate2 = [NSPredicate predicateWithFormat:@"switch1_id != '0'"];

    NSArray* leftList = [infosetList filteredArrayUsingPredicate:predicate1];
    NSArray* rightList = [infosetList filteredArrayUsingPredicate:predicate2];
    
    for(SGInfoSetItem* infoset in rightList){
        if ([infoset.rxied_id isEqualToString:deviceId]) {

            if (![infoset.switch4_id isEqualToString:@"0"]) {
                [self handleSwitchOrder:infoset index:4];
            }
            if (![infoset.switch3_id isEqualToString:@"0"]) {
                [self handleSwitchOrder:infoset index:3];
            }
            if (![infoset.switch2_id isEqualToString:@"0"]) {
                [self handleSwitchOrder:infoset index:2];
            }
        }
    }
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES];
    NSSortDescriptor *sorter1 = [NSSortDescriptor sortDescriptorWithKey:@"switch1_id" ascending:YES];
    NSSortDescriptor *sorter2 = [NSSortDescriptor sortDescriptorWithKey:@"switch2_id" ascending:YES];
    NSSortDescriptor *sorter3 = [NSSortDescriptor sortDescriptorWithKey:@"switch3_id" ascending:YES];
    NSSortDescriptor *sorter4 = [NSSortDescriptor sortDescriptorWithKey:@"switch4_id" ascending:YES];
    NSSortDescriptor *sorter5 = [NSSortDescriptor sortDescriptorWithKey:@"group" ascending:YES];
    rightList = [rightList sortedArrayUsingDescriptors:@[sorter1,sorter2,sorter3,sorter4,sorter5,sorter]];
    leftList = [leftList sortedArrayUsingDescriptors:@[sorter1,sorter2,sorter3,sorter4,sorter5,sorter]];

    
    return @[leftList,rightList];
}

-(void)handleSwitchOrder:(SGInfoSetItem*)infoset index:(NSInteger)index{
    
    NSString* fieldTmp = [infoset valueForKey:[self field:index]];
    NSString* fieldTxTmp = [infoset valueForKey:[self fieldtx:index]];
    NSString* fieldRxTmp = [infoset valueForKey:[self fieldrx:index]];
    
    [infoset setValue:[infoset valueForKey:[self field:1]] forKey:[self field:index]];
    [infoset setValue:[infoset valueForKey:[self fieldtx:1]] forKey:[self fieldtx:index]];
    [infoset setValue:[infoset valueForKey:[self fieldrx:1]] forKey:[self fieldrx:index]];
    
    [infoset setValue:fieldTmp forKey:[self field:1]];
    [infoset setValue:fieldTxTmp forKey:[self fieldtx:1]];
    [infoset setValue:fieldRxTmp forKey:[self fieldrx:1]];
    
    if (index == 4) {
        
        NSString* fieldTmp = [infoset valueForKey:[self field:index-1]];
        NSString* fieldTxTmp = [infoset valueForKey:[self fieldtx:index-1]];
        NSString* fieldRxTmp = [infoset valueForKey:[self fieldrx:index-1]];
        
        [infoset setValue:[infoset valueForKey:[self field:index - 2]] forKey:[self field:index - 1]];
        [infoset setValue:[infoset valueForKey:[self fieldtx:index - 2]] forKey:[self fieldtx:index - 1]];
        [infoset setValue:[infoset valueForKey:[self fieldrx:index - 2]] forKey:[self fieldrx:index - 1]];
        
        [infoset setValue:fieldTmp forKey:[self field:index - 2]];
        [infoset setValue:fieldTxTmp forKey:[self fieldtx:index - 2]];
        [infoset setValue:fieldRxTmp forKey:[self fieldrx:index - 2]];
    }
}

-(NSString*)field:(NSInteger)index{
    return [NSString stringWithFormat:@"switch%ld_id",(long)index];
}
-(NSString*)fieldtx:(NSInteger)index{
    return [NSString stringWithFormat:@"switch%ld_txport_id",(long)index];
}
-(NSString*)fieldrx:(NSInteger)index{
    return [NSString stringWithFormat:@"switch%ld_rxport_id",(long)index];
}

-(NSString*)queryDeviceById:(NSString*)deviceId{
    
    NSArray* l = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetDeviceInfo(deviceId)] withEntity:@"SGDeviceInfo"];
    return [l[0] description];
}

-(NSString*)queryPortById:(NSString*)portId{
    
    NSArray* l  = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetPortInfo(portId)] withEntity:@"SGPortInfo"];
    return [l[0] type];
}

- (NSString*)queryDeviceTypeById:(NSString*)deviceId{
    
    NSArray* l = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:DP_GetDeviceType(deviceId)] withEntity:@"SGDeviceInfo"];
    return [l[0] description];
}
@end
