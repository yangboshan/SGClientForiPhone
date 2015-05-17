//
//  SGFiberPageBussiness.m
//  SGClient
//
//  Created by JY on 14-6-3.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import "SGFiberPageBussiness.h"

@implementation SGFiberItem
@end

//@implementation SGInfoSetItem
//@end

@implementation SGResult
@end

/*－－－－－－－－－－－－－－－－－
 根据CableId 获取纤芯信息列表
 －－－－－－－－－－－－－－－－－*/
#define FP_GetFiberItemList(cableId) [NSString stringWithFormat:@"select fiber_id,cable_id,port1_id,port2_id, \
                      [index],fiber_color,pipe_color,reserve from fiber where cable_id = %d order by [index]",cableId]


/*－－－－－－－－－－－－－－－－－
 根据两个端口 获取fiber
 －－－－－－－－－－－－－－－－－*/
#define FP_GetFiberItem(p1,p2) [NSString stringWithFormat:@"select fiber_id,cable_id,port1_id,port2_id, \
                      [index],fiber_color,pipe_color,reserve from fiber where (port1_id = %@ and port2_id = %@) or  \
                          (port2_id = %@ and port1_id = %@)",p1,p2,p1,p2]

/*－－－－－－－－－－－－－－－－－
 根据两个端口号 获取另外两个端口
 －－－－－－－－－－－－－－－－－*/
#define FP_GetAnotherTwoPorts(p1,p2) [NSString stringWithFormat:@"select a.port1_id from(\
                      select port1_id  as port1_id  from fiber   where port1_id = %@ or port2_id = %@ union \
                      select port2_id  as port1_id  from fiber   where port1_id = %@ or port2_id = %@ union \
                      select port1_id  as port1_id  from fiber   where port1_id = %@ or port2_id = %@ union \
                      select port2_id  as port1_id  from fiber   where port1_id = %@ or port2_id = %@  ) a  \
                            where a.port1_id not in (%@,%@)",p1,p1,p1,p1,p2,p2,p2,p2,p1,p2]


#define FP_CheckPortOrder(p1,p2) [NSString stringWithFormat:@"select fiber_id,cable_id,port1_id,port2_id, \
[index],fiber_color,pipe_color,reserve from fiber where (port1_id = %@ and port2_id = %@) or (port2_id = %@  and port1_id = %@)",p1,p2,p1,p2]

/*－－－－－－－－－－－－－－－－－
 根据两个端口号 获取InfoSet表信息
 －－－－－－－－－－－－－－－－－*/
#define FP_GetInfoSetList(p1,p2) [NSString stringWithFormat:@"select infoset_id,name,description,type,[group],txiedport_id,switch1_rxport_id,switch1_txport_id,\
             switch2_rxport_id,switch2_txport_id,switch3_rxport_id,switch3_txport_id,switch4_rxport_id,switch4_txport_id,rxiedport_id from infoset \
                 where txiedport_id in (%@,%@) or switch1_rxport_id in (%@,%@) or switch1_txport_id in (%@,%@)  \
               or switch2_rxport_id in (%@,%@) or switch2_txport_id in (%@,%@) or switch3_rxport_id in (%@,%@) \
               or switch3_txport_id in (%@,%@) or switch4_rxport_id in (%@,%@) or switch4_txport_id in (%@,%@) or rxiedport_id in (%@,%@)",p1,p2,p1,p2,p1,p2,p1,p2,p1,p2,p1,p2,p1,p2,p1,p2,p1,p2,p1,p2]

/*－－－－－－－－－－－－－－－－－
 根据端口号 获取device信息
 －－－－－－－－－－－－－－－－－*/
#define FP_GetDeviceInfo(p) [NSString stringWithFormat:@"select device.description from device \
               inner join board on device.device_id=board.device_id inner join port on board.board_id=port.board_id \
               where port.port_id = %@",p]

/*－－－－－－－－－－－－－－－－－
 根据端口号 获取ODF端口的device信息
 －－－－－－－－－－－－－－－－－*/
#define FP_GetDeviceInfoForOdf(p) [NSString stringWithFormat:@"select device.name as description from device \
    inner join board on device.device_id=board.device_id inner join port on board.board_id=port.board_id \
where port.port_id = %@",p]

/*－－－－－－－－－－－－－－－－－
 判断端口是否属于屏柜
 －－－－－－－－－－－－－－－－－*/
#define FP_GetCubicleIdWithPort(p) [NSString stringWithFormat:@"select device.cubicle_id as port1_id from device \
    inner join board on device.device_id=board.device_id inner join port on board.board_id=port.board_id \
where port.port_id = %@",p]


/*－－－－－－－－－－－－－－－－－
 根据端口号 获取port board信息
 －－－－－－－－－－－－－－－－－*/
#define FP_GetPortInfo(p) [NSString stringWithFormat:@"select  board.position||'/'||port.name as  description  from port inner join board on board.board_id = port.board_id where port.port_id = %@",p]

/*－－－－－－－－－－－－－－－－－
 获取TX信息
 －－－－－－－－－－－－－－－－－*/
#define FP_GetTXInfo(p1,p2) [NSString stringWithFormat:@"select cable.name ||':'||fiber.[index] as description from cable \
                                                      inner join fiber on cable.cable_id = fiber.cable_id \
                                                            where (fiber.port1_id = %@ and fiber.port2_id = %@) or (fiber.port2_id = %@ and fiber.port1_id = %@)",p1,p2,p1,p2]
/*－－－－－－－－－－－－－－－－－
 获取Port Type ODF信息
 －－－－－－－－－－－－－－－－－*/
#define FP_GetODFInfo(p) [NSString stringWithFormat:@"select name,type from port where port_id = %@",p]

#define FP_GetFiberItems(p) [NSString stringWithFormat:@"select fiber_id,cable_id,port1_id,port2_id, \
                   [index],fiber_color,pipe_color,reserve from fiber where port1_id = %@ or port2_id = %@",p,p]

#define FP_GetCableType(c) [NSString stringWithFormat:@"select cable_type as type from cable where cable_id = %@",c]

#define FP_GetCableName(c) [NSString stringWithFormat:@"select name as type from cable where cable_id = %@",c]

#define FP_GetTLGroupPort(p) [NSString stringWithFormat:@"select port_id as port1_id from  \
                                  (select port_id from port where board_id = ( \
                                    select board_id from port where port_id = %@) and [group] =  ( \
                                    select [group] from port where port_id = %@)) a where a.port_id!=%@",p,p,p]

@interface SGFiberPageBussiness()

@property (nonatomic,strong) NSString* cableId;
@property (nonatomic,assign) NSInteger cubicleId;
@property (nonatomic,assign) BOOL findGroupRecord;
@property (nonatomic,assign) NSInteger cableType;
@property (nonatomic,strong) NSArray *infoSetOrder;
@property (nonatomic,strong) NSMutableArray *portList;
@property (nonatomic,strong) NSMutableArray *typePortList;
@property (nonatomic,strong) NSMutableDictionary *cachedSet;

@property (nonatomic,strong) SGFiberItem* currentFiber;
@end

@implementation SGFiberPageBussiness

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGFiberPageBussiness)

#define CABLETYPE0 0
#define CABLETYPE1 1
#define CABLETYPE2 2
-(id)init{
    if (self = [super init]) {
        
        //infoset表匹配顺序
        _infoSetOrder = [NSArray arrayWithObjects:
                         @"txiedport_id",
                         @"switch1_rxport_id",
                         @"switch1_txport_id",
                         @"switch2_rxport_id",
                         @"switch2_txport_id",
                         @"switch3_rxport_id",
                         @"switch3_txport_id",
                         @"switch4_rxport_id",
                         @"switch4_txport_id",
                         @"rxiedport_id",nil];
    }
    return self;
}
/*－－－－－－－－－－－－－－－－－
 根据CableId 获取纤芯信息列表
 －－－－－－－－－－－－－－－－－*/
-(NSArray*)queryFiberInfoWithCableId:(NSInteger)cableId withCubicleId:(NSInteger)cubicleId{
    
    self.cubicleId = cubicleId;
    NSString* cableId_ = [NSString stringWithFormat:@"%d",cableId];
    self.cableType = [[(SGInfoSetItem*)[[SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetCableType(cableId_)] withEntity:@"SGInfoSetItem"] objectAtIndex:0] type] integerValue];
    
    //根据CableId 查询表 fiber
    NSArray* fiberList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetFiberItemList(cableId)]
                                               withEntity:@"SGFiberItem"];
    __block NSMutableArray *retList = [NSMutableArray array];
    

    
    [fiberList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        SGResult *resultItem   = [[SGResult alloc] init];
        SGFiberItem *fiberItem = (SGFiberItem*)obj;
        self.currentFiber = fiberItem;
        
        if ([self fillTypeFieldWithSGResult  :resultItem withSGFiberItem:fiberItem]) {
            [self fillDeviceFieldWithSGResult:resultItem withSGFiberItem:fiberItem];
            [self fillPortFieldWithSGResult  :resultItem withSGFiberItem:fiberItem];
            [self fillMiddleFieldWithSGResult:resultItem withSGFiberItem:fiberItem];
            
            switch (self.cableType) {
                    
                case CABLETYPE0:
                    [self fillTXFieldWithSGResult :resultItem withSGFiberItem:fiberItem];
                    [self fillOdfFieldWithSGResult:resultItem withSGFiberItem:fiberItem];
                    break;
                case CABLETYPE1:
                    break;
                case CABLETYPE2:
                    [self fillMiddleFieldForType2WithResultItem:resultItem withFiber:fiberItem];
                    break;
                default:
                    break;
            }
        }else{
            [self fillMiddleFieldWithSGResult:resultItem withSGFiberItem:fiberItem];
            [self fillOdfFieldWithSGResult:resultItem withSGFiberItem:fiberItem];
        }
  
        [retList addObject:resultItem];
        
        //如果是跳纤再找出Group对应的数据
        if (self.cableType == CABLETYPE2) {
            
            _findGroupRecord = YES;
            SGResult *resultItem   = [[SGResult alloc] init];
            [self fillTypeFieldWithSGResult  :resultItem withSGFiberItem:fiberItem];
            [self fillDeviceFieldWithSGResult:resultItem withSGFiberItem:fiberItem];
            [self fillPortFieldWithSGResult  :resultItem withSGFiberItem:fiberItem];
            
            fiberItem.cable_id = self.cableId;
            [self fillMiddleFieldForType2WithResultItem:resultItem withFiber:fiberItem];
            
            [retList addObject:resultItem];
            _findGroupRecord = NO;
            
            if ([[resultItem.port1 lowercaseString] rangeOfString:@"tx"].location!=NSNotFound) {
                retList = [[[retList reverseObjectEnumerator] allObjects] mutableCopy];
             }
        }
        
    }];
 
    
    return retList;
//    return [self buildXMLForResultSet:retList];
}

-(void)fillMiddleFieldForType2WithResultItem:(SGResult*)resultItem withFiber:(SGFiberItem*)fiber{
    
    NSString* cableName = [(SGInfoSetItem*)[[SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetCableName(fiber.cable_id)] withEntity:@"SGInfoSetItem"] objectAtIndex:0] type];
    resultItem.middle = cableName;
}

/*－－－－－－－－－－－－－－－－－
 获取中间列
 －－－－－－－－－－－－－－－－－*/
-(void)fillMiddleFieldWithSGResult:(SGResult*)resultItem withSGFiberItem:(SGFiberItem*)fiberItem{
    
    if (self.cableType == CABLETYPE1 || self.cableType == CABLETYPE2) {
        resultItem.middle = [NSString stringWithFormat:@"%@",fiberItem.index];
    } else if (self.cableType == CABLETYPE0){
        NSString* color;
        switch ([fiberItem.fiber_color integerValue]) {
            case 0:
                color = @"蓝";break;
            case 1:
                color = @"橙";break;
            case 2:
                color = @"绿";break;
            case 3:
                color = @"棕";break;
            case 4:
                color = @"灰";break;
            case 5:
                color = @"本";break;
            case 6:
                color = @"红";break;
            case 7:
                color = @"黑";break;
            case 8:
                color = @"黄";break;
            case 9:
                color = @"紫";break;
            case 10:
                color = @"粉红";break;
            case 11:
                color = @"青绿";break;
            default:
                break;
        }
        resultItem.middle = [NSString stringWithFormat:@"%@:%@",
                             fiberItem.index,
                             color];
    }
}
/*－－－－－－－－－－－－－－－－－
 获取ODF列
 －－－－－－－－－－－－－－－－－*/
-(void)fillOdfFieldWithSGResult:(SGResult*)resultItem withSGFiberItem:(SGFiberItem*)fiberItem{
    
    NSArray* desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetODFInfo(fiberItem.port1_id)]
                                          withEntity:@"SGInfoSetItem"];
    if ([desc count]) {
        resultItem.odf1 = [(SGInfoSetItem*)[desc objectAtIndex:0] name];
    }
    
    desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetODFInfo(fiberItem.port2_id)]
                                 withEntity:@"SGInfoSetItem"];
    
    if ([desc count]) {
        resultItem.odf2 = [(SGInfoSetItem*)[desc objectAtIndex:0] name];
    }
}

/*－－－－－－－－－－－－－－－－－
 获取TX列
 －－－－－－－－－－－－－－－－－*/
-(void)fillTXFieldWithSGResult:(SGResult*)resultItem withSGFiberItem:(SGFiberItem*)fiberItem{
    
    NSArray* desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetTXInfo([self.portList objectAtIndex:0],fiberItem.port1_id)] withEntity:@"SGInfoSetItem"];
    
    if (desc.count) {
            resultItem.tx1 = [[desc objectAtIndex:0] description];
        }else{
            desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetTXInfo([self.portList objectAtIndex:0],fiberItem.port2_id)]
                                         withEntity:@"SGInfoSetItem"];
            if (desc.count) {
                resultItem.tx1 = [[desc objectAtIndex:0] description];
            }
        }
    
    
    
    
    
    desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetTXInfo([self.portList objectAtIndex:1],fiberItem.port2_id)]
                                 withEntity:@"SGInfoSetItem"];
    
        if (desc.count){
            resultItem.tx2 = [[desc objectAtIndex:0] description];
        }else{
            desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetTXInfo([self.portList objectAtIndex:1],fiberItem.port1_id)]
                                         withEntity:@"SGInfoSetItem"];
            if (desc.count) {
                resultItem.tx2 = [[desc objectAtIndex:0] description];
            }
        }

}

/*－－－－－－－－－－－－－－－－－
 获取Port
 －－－－－－－－－－－－－－－－－*/
-(void)fillPortFieldWithSGResult:(SGResult*)resultItem withSGFiberItem:(SGFiberItem*)fiberItem{

    NSArray* desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetPortInfo([self.portList objectAtIndex:0])]
                                          withEntity:@"SGInfoSetItem"];
    resultItem.port1 = [(SGInfoSetItem*)[desc objectAtIndex:0] description];
    
    desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetPortInfo([self.portList objectAtIndex:1])]
                                          withEntity:@"SGInfoSetItem"];
    resultItem.port2 = [(SGInfoSetItem*)[desc objectAtIndex:0] description];
}



/*－－－－－－－－－－－－－－－－－
 获取Device
 －－－－－－－－－－－－－－－－－*/
-(void)fillDeviceFieldWithSGResult:(SGResult*)resultItem withSGFiberItem:(SGFiberItem*)fiberItem{
    
    NSArray* desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetDeviceInfo([self.portList objectAtIndex:0])]
                                          withEntity:@"SGInfoSetItem"];
    
    if (desc.count) {
        if (![[[desc objectAtIndex:0] description] isEqualToString:@""]) {
            resultItem.device1 = [[desc objectAtIndex:0] description];
        }else{
            desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetDeviceInfoForOdf([self.portList objectAtIndex:0])]
                                         withEntity:@"SGInfoSetItem"];
            if (desc.count) {
                resultItem.device1 = [[desc objectAtIndex:0] description];
            }
        }
    }
    
    
    desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetDeviceInfo([self.portList objectAtIndex:1])]
                                 withEntity:@"SGInfoSetItem"];
    
    if (desc.count) {
        if (![[[desc objectAtIndex:0] description] isEqualToString:@""]) {
            resultItem.device2 = [[desc objectAtIndex:0] description];
        }else{
            desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetDeviceInfoForOdf([self.portList objectAtIndex:1])]
                                         withEntity:@"SGInfoSetItem"];
            if (desc.count) {
                resultItem.device2 = [[desc objectAtIndex:0] description];
            }
        }
    }
}

-(void)resortPortList{
 
    NSArray* desc = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetCubicleIdWithPort(self.currentFiber.port1_id)]
                                          withEntity:@"SGFiberItem"];
    if (desc.count) {
        SGFiberItem* fiberItem = desc[0];
        if (!([fiberItem.port1_id integerValue] == self.cubicleId)) {
            self.portList = [[[self.portList reverseObjectEnumerator] allObjects] copy];
        }
    }
}

/*－－－－－－－－－－－－－－－－－
 获取Type
 －－－－－－－－－－－－－－－－－*/
-(BOOL)fillTypeFieldWithSGResult:(SGResult*)resultItem withSGFiberItem:(SGFiberItem*)fiberItem{
    
    self.portList = [NSMutableArray array];
    self.typePortList = [NSMutableArray array];
    self.cachedSet = [NSMutableDictionary dictionary];
    
    //如果是备用
    if ([fiberItem.reserve isEqualToString:@"1"]) {
        resultItem.type1 = @"备用";
        resultItem.type2 = resultItem.type1;
        return NO;
    }else{
        
        switch (self.cableType) {
                
                //如果是光缆
            case CABLETYPE0:
                self.portList = [[SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetAnotherTwoPorts(fiberItem.port1_id,fiberItem.port2_id)]
                                                       withEntity:@"SGFiberItem"] copy];
                
                
                
                self.portList = [NSMutableArray arrayWithObjects:[[self.portList objectAtIndex:0] port1_id],
                                                                 [[self.portList objectAtIndex:1] port1_id],nil];
                
                if ([self checkPortListOrderWithSGFiberItem:fiberItem]) {
                    
                    self.portList = [[[self.portList reverseObjectEnumerator] allObjects] copy];
                }
                
                self.typePortList = [self.portList mutableCopy];
                break;
                
                //如果是尾缆
            case CABLETYPE1:
                self.portList = [NSMutableArray arrayWithObjects:fiberItem.port1_id,fiberItem.port2_id, nil];
                [self getNonOdfPortsForWLWithSGFiberItem:fiberItem];
                break;
                
                //如果是跳纤
            case CABLETYPE2:

                if (_findGroupRecord) {
                    self.portList = [NSMutableArray arrayWithObjects:fiberItem.port1_id,fiberItem.port2_id, nil];
                    [self getNewPairPortsByGroupForType2];
                    
                    fiberItem = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetFiberItems(self.portList[0])]
                                                       withEntity:@"SGFiberItem"][0];
                    self.cableId = fiberItem.cable_id;
                    self.portList = [NSMutableArray arrayWithObjects:fiberItem.port1_id,fiberItem.port2_id, nil];
                    [self getNonOdfPortsForWLWithSGFiberItem:fiberItem];
                    
                 }else{
                    self.portList = [NSMutableArray arrayWithObjects:fiberItem.port1_id,fiberItem.port2_id, nil];
                    [self getNonOdfPortsForWLWithSGFiberItem:fiberItem];
                }
                break;
        }
        
        [self resortPortList];
            if ([self.typePortList count]) {
                NSArray* infoSetList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetInfoSetList([self.typePortList objectAtIndex:0],
                                                                                                                      [self.typePortList objectAtIndex:1])]
                                                             withEntity:@"SGInfoSetItem"];
                //用这两个端口遍历infoset表的顺序链
                for(SGInfoSetItem* infosetItem in infoSetList){
                    //两个端口匹配顺序链
                    if ([self checkInfoSetChainWithInfoSetItem:infosetItem withPorts:self.typePortList]) {
                        NSMutableString* type = [[NSMutableString alloc] init];
                        BOOL flag = [self checkIfSwFieldAllZeroWithInfoSetItem:infosetItem];
                        switch ([infosetItem.type integerValue]) {
                            case 0:
                                break;
                            case 1:
                                [type appendString:@"GOOSE"];
                                if (flag) {[type appendString:@"直跳"];}
                                break;
                            case 2:
                                [type appendString:@"SV"];
                                if (flag) {[type appendString:@"直采"];}
                                break;
                            case 3:
                                [type appendString:@"TIME"];
                                break;
                            case 4:
                                [type appendString:@"GOOSE/SV"];
                                if (flag) {[type appendString:@"直连"];}
                                break;
                        }
                        
                        resultItem.type1 = type;
                        resultItem.type2 = type;
                        resultItem.portId1 = self.typePortList[0];
                        resultItem.portId2 = self.typePortList[1];
                    };
                }
        }}
    return YES;
}

/*－－－－－－－－－－－－－－－－－
 如果是跳纤 根据group找出port
 －－－－－－－－－－－－－－－－－*/
-(void)getNewPairPortsByGroupForType2{
    
    NSArray* tmp = [self.portList copy];
//    self.portList = [NSMutableArray array];
    
    for(NSString* port in tmp){
        NSArray* portInfo = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetTLGroupPort(port)]
                                                  withEntity:@"SGFiberItem"];
        if ([portInfo count]) {
            [self.portList addObject:[(SGFiberItem*)[portInfo objectAtIndex:0]
                                      port1_id]];
        }
    }
}

/*－－－－－－－－－－－－－－－－－
 递归找出非ODF port
 －－－－－－－－－－－－－－－－－*/
-(void)getNonOdfPortsForWLWithSGFiberItem:(SGFiberItem*)fiberItem{

    //两个端口都找到返回
    if ([self.typePortList count]==2) {
        return;
    }
    NSArray* ports = [NSArray arrayWithObjects:fiberItem.port1_id,fiberItem.port2_id,nil];
    for(NSString* port in ports){
        
        //处理过此端口返回
        if ([self.cachedSet.allKeys containsObject:port]) {
            continue;
        }
        NSArray* portInfo = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetODFInfo(port)]
                                                  withEntity:@"SGInfoSetItem"];
        if ([portInfo count]) {
            
            //如果Type!=2添加
            if(![[(SGInfoSetItem*)[portInfo objectAtIndex:0] type] isEqualToString:@"2"]){

                if (!self.typePortList) {
                    self.typePortList = [NSMutableArray array];
                }
                
                if (![self.typePortList containsObject:port]) {
                    [self.typePortList addObject:port];
                }
                
            //Type为2即ODF继续查找
            }else{
                
                //添加处理过的Port
                if (!self.cachedSet) {
                    self.cachedSet = [NSMutableDictionary dictionary];
                }
                [self.cachedSet setObject:port forKey:port];
                NSArray* fibers = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetFiberItems(port)]
                                                        withEntity:@"SGFiberItem"];
                for(SGFiberItem* fiberItem in fibers){
                    [self getNonOdfPortsForWLWithSGFiberItem:fiberItem];
                }
            }
        }
    }
}


-(BOOL)checkPortListOrderWithSGFiberItem:(SGFiberItem*)fiberItem{
    
    NSArray* retList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_CheckPortOrder([self.portList objectAtIndex:0], fiberItem.port1_id)]
                          withEntity:@"SGFiberItem"];
    if (retList) {
        if ([retList count]) {
            return NO;
        }
    }
    return YES;
}


-(BOOL)checkInfoSetChainWithInfoSetItem:(SGInfoSetItem*)infoSetItem withPorts:(NSArray*)ports{
    
    NSString* port1 = [ports objectAtIndex:0];
    NSString* port2 = [ports objectAtIndex:1];
    NSString* tmpValue;
    NSInteger index = [self getIndexOfPortInInfoSetChainWithPort:port1 withInfoSetItem:infoSetItem];
    NSInteger indexTmp = index;
    
    while (indexTmp>=0) {
        indexTmp--;
        if (indexTmp>=0) {
             tmpValue = [infoSetItem valueForKey:[self.infoSetOrder objectAtIndex:indexTmp]];
            if ([tmpValue isEqualToString:port2]) {
                return YES;
            }
        }
    }
    indexTmp = index;
    while (indexTmp<[self.infoSetOrder count]) {
        indexTmp++;
        if (indexTmp<[self.infoSetOrder count]) {
            tmpValue = [infoSetItem valueForKey:[self.infoSetOrder objectAtIndex:indexTmp]];
            if ([tmpValue isEqualToString:port2]) {
                return YES;
            }
        }
    }
    return NO;
}

/*－－－－－－－－－－－－－－－－－
 获取Port在InfoSet连接顺序中的索引
 －－－－－－－－－－－－－－－－－*/
-(NSInteger)getIndexOfPortInInfoSetChainWithPort:(NSString*)port withInfoSetItem:(SGInfoSetItem*)infoSetItem{
    unsigned int outCount;
    NSString* property;
    objc_property_t *properties;
    properties = class_copyPropertyList([SGInfoSetItem class], &outCount);
    
    for(int i = 0; i < outCount;i++){
        property = [NSString stringWithUTF8String:property_getName(properties[i])];
        
        if ([[infoSetItem valueForKey:property] isEqualToString:port] && ![property isEqualToString:@"type"] && ![property isEqualToString:@"infoset_id"]&& ![property isEqualToString:@"group"]) {
            return [self.infoSetOrder indexOfObject:property];
        }
    }
    return -1;
}

/*－－－－－－－－－－－－－－－－－
 检查Infoset表Sw是否都为0
 －－－－－－－－－－－－－－－－－*/
-(BOOL)checkIfSwFieldAllZeroWithInfoSetItem:(SGInfoSetItem*)infoSetItem{
    
    return ([infoSetItem.switch1_rxport_id isEqualToString:@"0"]&&[infoSetItem.switch1_txport_id isEqualToString:@"0"]&&
            [infoSetItem.switch2_rxport_id isEqualToString:@"0"]&&[infoSetItem.switch2_txport_id isEqualToString:@"0"]&&
            [infoSetItem.switch3_rxport_id isEqualToString:@"0"]&&[infoSetItem.switch3_txport_id isEqualToString:@"0"]&&
            [infoSetItem.switch4_rxport_id isEqualToString:@"0"]&&[infoSetItem.switch4_txport_id isEqualToString:@"0"]);
}

/*－－－－－－－－－－－－－－－－－
 根据RESULT LIST 生成XML
 －－－－－－－－－－－－－－－－－*/
-(NSString*)buildXMLForResultSet:(NSArray*)resultList{
    
    NSMutableString* xMLString = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><root>"];
    
    [resultList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SGResult* resultItem = (SGResult*)obj;
        [xMLString appendString:@"<fiberitem>"];
        unsigned int outCount;
        objc_property_t *properties;
        NSString* property;
        
        properties = class_copyPropertyList([SGResult class], &outCount);
        
        for(int i = 0; i < outCount;i++){
            property = [NSString stringWithUTF8String:property_getName(properties[i])];
            
            if (self.cableType!=CABLETYPE0) {
                if ([property rangeOfString:@"tx"].location != NSNotFound ||
                    [property rangeOfString:@"odf"].location != NSNotFound) {
                    continue;
                }
            }
            
            [xMLString appendString:[NSString stringWithFormat:@"<%@>%@</%@>",
                                     property,
                                     [resultItem valueForKey:property],
                                     property]];
        }
        [xMLString appendString:@"</fiberitem>"];
    }];

    [xMLString appendString:@"</root>"];
    return xMLString;
}

@end
