//
//  SGPortPageBussiness.m
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGPortPageBussiness.h"
#import "SGPortPageDataModel.h"



/*－－－－－－－－－－－－－－－－－
 根据两个端口号 获取InfoSet表信息
 －－－－－－－－－－－－－－－－－*/
#define FP_GetInfoSetList0(p) [NSString stringWithFormat:@"select infoset_id,name,description,type,[group],txiedport_id,switch1_rxport_id,switch1_txport_id,txied_id,rxied_id,\
           switch2_rxport_id,switch2_txport_id,switch3_rxport_id,switch3_txport_id,switch4_rxport_id,switch4_txport_id,rxiedport_id from infoset \
            where  switch1_rxport_id = %@   \
                                    or switch2_rxport_id = %@ or switch3_rxport_id = %@ or switch4_rxport_id = %@ \
                                    or rxiedport_id = %@",p,p,p,p,p]


#define FP_GetInfoSetList1(p) [NSString stringWithFormat:@"select infoset_id,name,description,type,[group],txiedport_id,switch1_rxport_id,switch1_txport_id,txied_id,rxied_id,\
switch2_rxport_id,switch2_txport_id,switch3_rxport_id,switch3_txport_id,switch4_rxport_id,switch4_txport_id,rxiedport_id from infoset \
where txiedport_id = %@  or switch1_txport_id = %@  \
or switch2_txport_id = %@ \
or switch3_txport_id = %@ or switch4_txport_id = %@",p,p,p,p,p]


#define FP_GetVterminalList(d) [NSString stringWithFormat:@"select vterminal_id,device_id,type,direction,vterminal_no,pro_desc from vterminal where device_id = %@",d]

#define FP_GetVterminalItem(v) [NSString stringWithFormat:@"select vterminal_id,device_id,type,direction,vterminal_no,pro_desc from vterminal where vterminal_id = %@",v]

#define FP_GetVterminalConnection(c) [NSString stringWithFormat:@"select rxvterminal_id,txvterminal_id,straight from vterminal_connection where %@",c]


#define FP_GetPortInfo(p) [NSString stringWithFormat:@"select type,direction from port where port_id = %@",p]

#define FP_GetDeviceInfo(d) [NSString stringWithFormat:@"select description from device where device_id = %@",d]

#define FP_GetGroupInfo(g,i) [NSString stringWithFormat:@"select infoset_id,name,description,type,[group],txiedport_id,switch1_rxport_id,switch1_txport_id,txied_id,rxied_id,\
switch2_rxport_id,switch2_txport_id,switch3_rxport_id,switch3_txport_id,switch4_rxport_id,switch4_txport_id,rxiedport_id from infoset where [group] = %@ and infoset_id!=%@",g,i]

#define FP_GetInfoSetList2(d1,d2,t)  [NSString stringWithFormat:@"select infoset_id,name,description,type,[group],txiedport_id,switch1_rxport_id,switch1_txport_id,txied_id,rxied_id,\
switch2_rxport_id,switch2_txport_id,switch3_rxport_id,switch3_txport_id,switch4_rxport_id,switch4_txport_id,rxiedport_id from infoset \
where (switch1_id == 0 and switch1_txport_id == 0 and switch1_rxport_id == 0 and switch2_id == 0 and switch2_txport_id == 0 and switch2_rxport_id == 0 and switch3_id == 0 and  switch3_txport_id == 0 and switch3_rxport_id == 0 and  switch4_id == 0 and switch4_txport_id == 0 and switch4_rxport_id == 0) and (type == %d or type == 4) and ((txied_id == %@ and rxied_id == %@) or (rxied_id == %@ and txied_id == %@))",t,d1,d2,d1,d2]


#define FP_GetInfoSetList3(d1,d2,t)  [NSString stringWithFormat:@"select infoset_id,name,description,type,[group],txiedport_id,switch1_rxport_id,switch1_txport_id,txied_id,rxied_id,\
switch2_rxport_id,switch2_txport_id,switch3_rxport_id,switch3_txport_id,switch4_rxport_id,switch4_txport_id,rxiedport_id from infoset \
where (switch1_id != 0 or switch1_txport_id != 0 or switch1_rxport_id != 0 or switch2_id != 0 or switch2_txport_id != 0 or switch2_rxport_id != 0 or switch3_id != 0 or  switch3_txport_id != 0 or switch3_rxport_id != 0 or switch4_id != 0 or  switch4_txport_id != 0 or switch4_rxport_id != 0) and (type == %d or type == 4) and ((txied_id == %@ and rxied_id == %@) or (rxied_id == %@ and txied_id == %@))",t,d1,d2,d1,d2]

/*－－－－－－－－－－－－－－－－－
 根据端口号 获取port board信息
 －－－－－－－－－－－－－－－－－*/
#define FP_GetPortDesc(p) [NSString stringWithFormat:@"select  board.position||'/'||port.name as  description  from port inner join board on board.board_id = port.board_id where port.port_id = %@",p]

#define FP_GetFiberInfo(p) [NSString stringWithFormat:@"select port1_id as port_id,port2_id as direction from fiber where port1_id = %@ or port2_id = %@",p,p]



/*－－－－－－－－－－－－－－－－－－－－－－－－－－－
 根据device.name board.postion port.name 获取port_id
 －－－－－－－－－－－－－－－－－－－－－－－－－－－*/
#define FP_GetPortIdByInfo(d,b,p) [NSString stringWithFormat:@"select port.port_id from port where port.board_id = (SELECT  board.board_id  FROM board inner join device on board.device_id = device.device_id where device.name = '%@' and board.position = '%@')  and  port.name = '%@'",d,b,p]

@interface SGPortPageBussiness()

@property (nonatomic,strong) SGPortPageDataModel *dataModel0;
@property (nonatomic,strong) SGPortPageDataModel *dataModel1;

@property (nonatomic,strong) SGInfoSetItem *selectedInfoset;
@property (nonatomic,strong) SGInfoSetItem *groupInfoset;
@property (nonatomic,strong) NSArray *tmpInfoSetLists;
@property (nonatomic,strong) NSString* direction;

@property (nonatomic,strong) NSString* mainPortId;




@property (nonatomic,strong) NSString* cntedDeviceId;
@property (nonatomic,strong) NSString* cntedDeviceName;
@property (nonatomic,strong) NSString* cntedPortId;
@property (nonatomic,copy) finishBlock completeBlock;



@property (nonatomic,assign) NSInteger multiIndex;
@property (nonatomic,strong) NSMutableDictionary *cache;
@end

@implementation SGPortPageBussiness

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGPortPageBussiness)



-(NSString*)queryPortIdByDeviceName:(NSString*)deviceName boardPostion:(NSString*)boardPostion portName:(NSString*)portName{
    
    NSArray* a = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetPortIdByInfo(deviceName,boardPostion,portName)]
                                       withEntity:@"SGPortInfo"];
    if (a.count) {
        SGPortInfo* item = a[0];
        return item.port_id;
    }
    
    return @"0";
}

//获取设备名称
-(NSString*)getDeviceInfoById:(NSString*)deviceId{
    
    SGDeviceInfo* portInfo = [[SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetDeviceInfo(deviceId)] withEntity:@"SGDeviceInfo"] objectAtIndex:0];
    return portInfo.description;
}

-(void)queryResultWithDeviceId:(NSString *)deviceId complete:(finishBlock)finish{
    
    self.dataModel0 = [SGPortPageDataModel new];
    self.dataModel0.type = @"0";
    self.dataModel0.mainDeviceId = deviceId;
    self.dataModel0.mainDeviceName = [self getDeviceInfoById:deviceId];

    self.dataModel1 = [SGPortPageDataModel new];
    self.dataModel1.type = @"1";
    self.dataModel1.mainDeviceId = deviceId;
    self.dataModel1.mainDeviceName = [self getDeviceInfoById:deviceId];
    self.completeBlock = finish;
    NSArray* ret = [self queryAllSub];
    finish(ret);
}

//入口
-(void)queryResultWithType:(NSInteger)type portId:(NSString*)portId complete:(finishBlock)finish{
    
    self.dataModel0 = [SGPortPageDataModel new];
    self.dataModel1 = [SGPortPageDataModel new];
    self.dataModel0.type = @"0";
    self.dataModel1.type = @"1";
    self.completeBlock = finish;
    
    //设置查询端口号 如果type为2找出非2端口
    [self setMainId:portId];
    if (type == 1) {
        if ([self.cache valueForKey:self.mainPortId]) {
            self.multiFlag = YES;
        }else{
            self.multiFlag = NO;
        }
    }
    
    NSArray* ret;
    
    //设定主设备ID NAME等
    if ([self getCenterDeviceId]) {
        
        //type 0 非全部 1全部
        switch (type) {
            case 0:
                return;
                //获取非全部列表
//                ret = [self queryByIdSub];
                break;
            case 1:
                //获取全部列表
                ret = [self queryAllSub];
                break;
        }
    }
    finish(ret);
}
//设置查询端口号 如果type为2找出非2端口
-(void)setMainId:(NSString*)portId{
    
    SGPortInfo* portInfo = [[SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetPortInfo(portId)] withEntity:@"SGPortInfo"] objectAtIndex:0];
    if ([portInfo.type isEqualToString:@"2"]) {
        
        NSArray* list = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetFiberInfo(portId)] withEntity:@"SGPortInfo"];
        NSMutableArray* plist = [NSMutableArray array];
        for(SGPortInfo *p in list){
            [plist addObject:p.port_id];
            [plist addObject:p.direction];
        }
        
        for(NSString* p in plist){
            SGPortInfo* portInfo = [[SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetPortInfo(p)] withEntity:@"SGPortInfo"] objectAtIndex:0];
            if (![portInfo.type isEqualToString:@"2"]) {
                self.mainPortId = p;
            }
        }
    }else{
        self.mainPortId = portId;
    }
}



-(BOOL)getCenterDeviceId{
    
    SGPortInfo* portInfo = [[SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetPortInfo(self.mainPortId)] withEntity:@"SGPortInfo"] objectAtIndex:0];
    
    self.direction = portInfo.direction;
    
    if ([portInfo.direction isEqualToString:@"0"]) {
        
        self.tmpInfoSetLists = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetInfoSetList0(self.mainPortId)] withEntity:@"SGInfoSetItem"];
        
        NSMutableArray* t = [NSMutableArray array];
        NSMutableArray* ls = [NSMutableArray array];
        
        for(SGInfoSetItem* item in self.tmpInfoSetLists){
            
            NSString* deviceName = [self getDeviceInfoById:item.rxied_id];
            if (![t containsObject:[NSString stringWithFormat:@"%@****%@",item.rxied_id,deviceName]]) {
                [t addObject:[NSString stringWithFormat:@"%@****%@",item.rxied_id,deviceName]];
                [ls addObject:[NSString stringWithFormat:@"%@****%@****%@",item.rxied_id,deviceName,item.infoset_id]];
            }            
        }
        
        t = [t valueForKeyPath:@"@distinctUnionOfObjects.self"];
        
        
        if (t.count == 1||self.multiFlag) {
            
            NSMutableArray* t = [NSMutableArray array];
            for(int i = 0; i < self.tmpInfoSetLists.count; i++){
                
                self.dataModel0 = [SGPortPageDataModel new];
                self.dataModel1 = [SGPortPageDataModel new];
                self.dataModel0.type = @"0";
                self.dataModel1.type = @"1";
                
                
                self.selectedInfoset = self.tmpInfoSetLists[i];
                if (self.multiFlag) {
                    self.selectedInfoset = self.tmpInfoSetLists[self.multiIndex];
                }
                
                NSArray* glist = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetGroupInfo(self.selectedInfoset.group,self.selectedInfoset.infoset_id)] withEntity:@"SGInfoSetItem"];
                if (glist.count>0) {
                    self.groupInfoset = glist[0];
                }else{
                    self.groupInfoset = nil;
                }
                
                
                self.dataModel0.mainDeviceId = self.selectedInfoset.rxied_id;
                self.dataModel0.mainDeviceName = [self getDeviceInfoById:self.dataModel0.mainDeviceId];
                self.dataModel0.mainPortId = self.mainPortId;
                
                
                self.dataModel1.mainDeviceId = self.selectedInfoset.rxied_id;
                self.dataModel1.mainDeviceName = [self getDeviceInfoById:self.dataModel1.mainDeviceId];
                self.dataModel1.mainPortId = self.mainPortId;
 
                self.cntedDeviceId = self.selectedInfoset.txied_id;
                
                [t addObject:[self queryByIdSub]];
            }
            
            SGPortPageDataModel* d0 = t[0][0];
            SGPortPageDataModel* d1 = t[0][1];
            
            NSMutableArray* l1 = [NSMutableArray array];
            NSMutableArray* r1 = [NSMutableArray array];
            NSMutableArray* l2 = [NSMutableArray array];
            NSMutableArray* r2 = [NSMutableArray array];
            
            for(int i = 0; i < t.count; i++){
                
                SGPortPageDataModel* d0 = t[i][0];
                SGPortPageDataModel* d1 = t[i][1];
                
                [l1 addObjectsFromArray:d0.leftChilds];
                [r1 addObjectsFromArray:d0.rightChilds];
                [l2 addObjectsFromArray:d1.leftChilds];
                [r2 addObjectsFromArray:d1.rightChilds];
            }
            d0.leftChilds = l1;d0.rightChilds = r1;
            d1.leftChilds = l2; d1.rightChilds = r2;
            self.completeBlock(@[d0,d1]);
            

        }else{
            
            
            SGSelectViewController* select = [SGSelectViewController new];
            [select setDelegate:self];
            select.dataSource = ls;
            [self.controller presentViewController:select animated:YES completion:nil];
            return NO;
            
        }
    }
    if ([portInfo.direction isEqualToString:@"1"]) {
        self.tmpInfoSetLists = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetInfoSetList1(self.mainPortId)] withEntity:@"SGInfoSetItem"];
        
        NSMutableArray* t = [NSMutableArray array];
        NSMutableArray* ls = [NSMutableArray array];
        
        for(SGInfoSetItem* item in self.tmpInfoSetLists){
            
            NSString* deviceName = [self getDeviceInfoById:item.txied_id];
            if (![t containsObject:[NSString stringWithFormat:@"%@****%@",item.txied_id,deviceName]]) {
                [t addObject:[NSString stringWithFormat:@"%@****%@",item.txied_id,deviceName]];
                [ls addObject:[NSString stringWithFormat:@"%@****%@****%@",item.txied_id,deviceName,item.infoset_id]];
            }
        }
        
        t = [t valueForKeyPath:@"@distinctUnionOfObjects.self"];
        
        if (t.count == 1||self.multiFlag) {
            
            NSMutableArray* t = [NSMutableArray array];
            for(int i = 0; i < self.tmpInfoSetLists.count; i++){
                
                self.dataModel0 = [SGPortPageDataModel new];
                self.dataModel1 = [SGPortPageDataModel new];
                self.dataModel0.type = @"0";
                self.dataModel1.type = @"1";
                
                self.selectedInfoset = self.tmpInfoSetLists[i];
                
                if (self.multiFlag) {
                    self.selectedInfoset = self.tmpInfoSetLists[self.multiIndex];
                }
                
                NSArray* glist = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetGroupInfo(self.selectedInfoset.group,self.selectedInfoset.infoset_id)] withEntity:@"SGInfoSetItem"];
                if (glist.count>0) {
                    self.groupInfoset = glist[0];
                }else{
                    self.groupInfoset = nil;
                }
                
                
                self.dataModel0.mainDeviceId = self.selectedInfoset.txied_id;
                self.dataModel0.mainDeviceName = [self getDeviceInfoById:self.dataModel0.mainDeviceId];
                self.dataModel0.mainPortId = self.mainPortId;
                
                
                
                
                self.dataModel1.mainDeviceId = self.selectedInfoset.txied_id;
                self.dataModel1.mainDeviceName = [self getDeviceInfoById:self.dataModel1.mainDeviceId];
                self.dataModel1.mainPortId = self.mainPortId;
                
                
                self.cntedDeviceId = self.selectedInfoset.rxied_id;
                
                [t addObject:[self queryByIdSub]];
            }
            
            SGPortPageDataModel* d0 = t[0][0];
            SGPortPageDataModel* d1 = t[0][1];
            
            NSMutableArray* l1 = [NSMutableArray array];
            NSMutableArray* r1 = [NSMutableArray array];
            NSMutableArray* l2 = [NSMutableArray array];
            NSMutableArray* r2 = [NSMutableArray array];
            
            for(int i = 0; i < t.count; i++){
                
                SGPortPageDataModel* d0 = t[i][0];
                SGPortPageDataModel* d1 = t[i][1];
                
                [l1 addObjectsFromArray:d0.leftChilds];
                [r1 addObjectsFromArray:d0.rightChilds];
                [l2 addObjectsFromArray:d1.leftChilds];
                [r2 addObjectsFromArray:d1.rightChilds];
            }
            d0.leftChilds = l1;d0.rightChilds = r1;
            d1.leftChilds = l2; d1.rightChilds = r2;
            self.completeBlock(@[d0,d1]);
 
            

        }else{
            
            SGSelectViewController* select = [SGSelectViewController new];
            [select setDelegate:self];
            select.dataSource = ls;
            [self.controller presentViewController:select animated:YES completion:nil];
            return NO;
            
        }
    }
    return YES;
}


-(void)userDidSelectItem:(NSInteger)index{

    self.cache = [NSMutableDictionary dictionary];
    [self.cache setValue:@"YES" forKey:self.mainPortId];
    
    for(int i = 0; i < self.tmpInfoSetLists.count; i++){
        SGInfoSetItem* item = self.tmpInfoSetLists[i];
        if ([item.infoset_id integerValue] == index) {
            self.multiIndex = i;
            self.selectedInfoset = self.tmpInfoSetLists[i];
            break;
        }
    }
    
    if ([self.direction isEqualToString:@"0"]) {
        
        NSArray* glist = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetGroupInfo(self.selectedInfoset.group,self.selectedInfoset.infoset_id)] withEntity:@"SGInfoSetItem"];
        if (glist.count>0) {
            self.groupInfoset = glist[0];
        }else{
            self.groupInfoset = nil;
        }
        
        
        self.dataModel0.mainDeviceId = self.selectedInfoset.rxied_id;
        self.dataModel0.mainDeviceName = [self getDeviceInfoById:self.dataModel0.mainDeviceId];
        self.dataModel0.mainPortId = self.mainPortId;
        
        
        self.dataModel1.mainDeviceId = self.selectedInfoset.rxied_id;
        self.dataModel1.mainDeviceName = [self getDeviceInfoById:self.dataModel1.mainDeviceId];
        self.dataModel1.mainPortId = self.mainPortId;
        self.cntedDeviceId = self.selectedInfoset.txied_id;
    }
    if ([self.direction isEqualToString:@"1"]) {

        NSArray* glist = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetGroupInfo(self.selectedInfoset.group,self.selectedInfoset.infoset_id)] withEntity:@"SGInfoSetItem"];
        if (glist.count>0) {
            self.groupInfoset = glist[0];
        }else{
            self.groupInfoset = nil;
        }

        self.dataModel0.mainDeviceId = self.selectedInfoset.txied_id;
        self.dataModel0.mainDeviceName = [self getDeviceInfoById:self.dataModel0.mainDeviceId];
        self.dataModel0.mainPortId = self.mainPortId;

        self.dataModel1.mainDeviceId = self.selectedInfoset.txied_id;
        self.dataModel1.mainDeviceName = [self getDeviceInfoById:self.dataModel1.mainDeviceId];
        self.dataModel1.mainPortId = self.mainPortId;
        
        
        self.cntedDeviceId = self.selectedInfoset.rxied_id;
    }
    
    NSArray* ret = [self queryByIdSub];
    self.completeBlock(ret);
}


-(NSArray*)queryByIdSub{
    
    self.cntedDeviceName = [self getDeviceInfoById:self.cntedDeviceId];
    
    NSArray* vterminalList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetVterminalList(self.dataModel0.mainDeviceId)] withEntity:@"SGVterminal"];
    
    if (YES) {
        
        NSArray* type0list = [vterminalList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == '0'"]];
        NSArray* type1list = [vterminalList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == '1'"]];
        [@[type0list,type1list] enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
            
            NSArray* d0list;
            NSArray* d1list;
            
            if (idx1 == 0) {
                d0list = [type0list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"direction == '0'"]];
                d1list = [type0list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"direction == '1'"]];
            }else{
                d0list = [type1list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"direction == '0'"]];
                d1list = [type1list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"direction == '1'"]];
            }
            
            [@[d0list,d1list] enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
        
                
                SGPortPageChildData* child = [SGPortPageChildData new];
                
                
                child.cntedDeviceId = self.cntedDeviceId;
                child.cntedDeviceName = self.cntedDeviceName;
                
                for(SGVterminal* vterminalItem in obj2){
                    
                    
                    NSString* conditions;
                    if (idx2 == 0) {
                        conditions = [NSString stringWithFormat:@"rxvterminal_id = %@ and straight == 0",vterminalItem.vterminal_id];
                    }else {
                        conditions = [NSString stringWithFormat:@"txvterminal_id = %@ and straight == 0",vterminalItem.vterminal_id];
                    }
                    
                    NSString* condition2 = @"";
                    if ([self.cableType rangeOfString:@"GOOSE直"].location!=NSNotFound) {
                        if(idx1 == 0){
                            condition2 = [NSString stringWithFormat:@"%@%@",conditions,@" and straight == 1"];
                        }
                    }
                    if ([self.cableType rangeOfString:@"SV直"].location!=NSNotFound) {
                        if (idx1 == 1) {
                            condition2 = [NSString stringWithFormat:@"%@%@",conditions,@" and straight == 1"];
                        }
                    }
                    
                    NSArray* tmpConnection = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetVterminalConnection(([condition2 isEqualToString:@""])? conditions:condition2
)] withEntity:@"SGVterminalConnection"];
                    
                    if (!tmpConnection.count) {
                        if (![condition2 isEqualToString:@""]) {
                            tmpConnection = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetVterminalConnection(conditions)] withEntity:@"SGVterminalConnection"];
                        }
                    }
                    
                    for(SGVterminalConnection* connection in tmpConnection){
                        
                        NSString* vid1;
                        NSString* vid2;
                        
                        if ([vterminalItem.direction isEqualToString:@"1"]) {
                            vid1 = connection.rxvterminal_id;
                            vid2 = connection.txvterminal_id;
                        } else {
                            vid1 = connection.txvterminal_id;
                            vid2 = connection.rxvterminal_id;
                        }
                        
                        NSArray* tmpVterminal = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetVterminalItem(vid1)] withEntity:@"SGVterminal"];
                        
                        if ([tmpVterminal count]) {
                            
                            SGVterminal* item = tmpVterminal[0];
                            
                            if ([item.device_id isEqualToString:self.cntedDeviceId]) {
                                
                                [child.mainProDes addObject:vterminalItem.pro_desc];
                                
                                [child.cntedProDes addObject:item.pro_desc];
                                
                                if (idx2 == 0) {
                                    if ([self.direction isEqualToString:@"0"]) {
                                        child.centerPortId = [self getPortDesc:self.selectedInfoset.rxiedport_id];
                                        child.cntedPortId = [self getPortDesc:self.selectedInfoset.txiedport_id];
                                    }else{
                                        child.centerPortId = [self getPortDesc:self.groupInfoset.rxiedport_id];
                                        child.cntedPortId = [self getPortDesc:self.groupInfoset.txiedport_id];
                                    }
                                }
                                if (idx2 == 1) {
                                    if ([self.direction isEqualToString:@"1"]) {
                                        child.centerPortId = [self getPortDesc:self.selectedInfoset.txiedport_id];
                                        child.cntedPortId = [self getPortDesc:self.selectedInfoset.rxiedport_id];
                                    }else{
                                        child.centerPortId = [self getPortDesc:self.groupInfoset.txiedport_id];
                                        child.cntedPortId = [self getPortDesc:self.groupInfoset.rxiedport_id];
                                    }
                                }
                                
                            }
                            
                            
                        }
                    }
                }
                switch (idx1) {
                    case 0:
                        switch (idx2) {
                            case 0:
                                [self.dataModel0.leftChilds addObject:child];
                                break;
                            case 1:
                                [self.dataModel0.rightChilds addObject:child];
                                break;
                        }
                        
                        break;
                    case 1:
                        switch (idx2) {
                            case 0:
                                [self.dataModel1.leftChilds addObject:child];
                                break;
                            case 1:
                                [self.dataModel1.rightChilds addObject:child];
                                break;
                        }
                        
                        
                        break;
                }
            }];
        }];
    }
    return @[self.dataModel0,self.dataModel1];

}



-(NSArray*)queryInfosetForAllWithDeviceId1:(NSString*)deviceId1 deviceId2:(NSString*)deviceId2 type:(NSString*)type straight:(NSString*)straight{
    
    NSInteger _type = [type integerValue] + 1;
    
    NSArray* infosetList;
    
    if ([straight isEqualToString:@"1"]) {
        infosetList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetInfoSetList2(deviceId1, deviceId2, _type)] withEntity:@"SGInfoSetItem"];
    }
    if ([straight isEqualToString:@"0"]) {
        infosetList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetInfoSetList3(deviceId1, deviceId2, _type)] withEntity:@"SGInfoSetItem"];
        
        if (!infosetList.count) {
            infosetList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetInfoSetList2(deviceId1, deviceId2, _type)] withEntity:@"SGInfoSetItem"];
        }
    }
    return infosetList;
}

-(NSString*)getPortDesc:(NSString*)portId{
    NSArray* list = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetPortDesc(portId)] withEntity:@"SGInfoSetItem"];
    if (list.count) {
        SGInfoSetItem* item = list[0];
        return item.description;
    }
    return nil;
}


-(NSArray*)queryAllSub{
 
    NSMutableDictionary* type0LeftCache = [NSMutableDictionary dictionary];
    NSMutableDictionary* type0RightCache = [NSMutableDictionary dictionary];
    NSMutableDictionary* type1LeftCache = [NSMutableDictionary dictionary];
    NSMutableDictionary* type1RightCache = [NSMutableDictionary dictionary];
    
    self.dataModel0.leftChilds = [NSMutableArray array];
    self.dataModel0.rightChilds = [NSMutableArray array];
    self.dataModel1.leftChilds = [NSMutableArray array];
    self.dataModel1.rightChilds = [NSMutableArray array];
    
    NSArray* vterminalList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetVterminalList(self.dataModel0.mainDeviceId)] withEntity:@"SGVterminal"];
    
    if (YES) {
        
        NSArray* type0list = [vterminalList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == '0'"]];
        NSArray* type1list = [vterminalList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == '1'"]];
        [@[type0list,type1list] enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
            
            NSArray* d0list;
            NSArray* d1list;
            
            if (idx1 == 0) {
                d0list = [type0list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"direction == '0'"]];
                d1list = [type0list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"direction == '1'"]];
            }else{
                d0list = [type1list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"direction == '0'"]];
                d1list = [type1list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"direction == '1'"]];
            }
            
            [@[d0list,d1list] enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {

                for(SGVterminal* vterminalItem in obj2){
                    
                    
                    NSString* conditions;
                    if (idx2 == 0) {
                        conditions = [NSString stringWithFormat:@"rxvterminal_id = %@",vterminalItem.vterminal_id];
                    }else {
                        conditions = [NSString stringWithFormat:@"txvterminal_id = %@",vterminalItem.vterminal_id];
                    }
                    
                    NSArray* tmpConnection = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetVterminalConnection(conditions)] withEntity:@"SGVterminalConnection"];
                    
                    
                    for(SGVterminalConnection* connection in tmpConnection){
                        
                        NSString* vid1;
                        NSString* vid2;
                        
                        if ([vterminalItem.direction isEqualToString:@"1"]) {
                            vid1 = connection.rxvterminal_id;
                            vid2 = connection.txvterminal_id;
                        } else {
                            vid1 = connection.txvterminal_id;
                            vid2 = connection.rxvterminal_id;
                        }
                        
                        NSArray* tmpVterminal = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetVterminalItem(vid1)] withEntity:@"SGVterminal"];
                        
                        if ([tmpVterminal count]) {
                            
                            SGVterminal* item = tmpVterminal[0];
                            
                            if ([item.device_id isEqualToString:@"56"]) {
                                NSLog(@"AAA");
                            }
                            
                            NSArray* list = [self queryInfosetForAllWithDeviceId1:item.device_id deviceId2:vterminalItem.device_id type:vterminalItem.type straight:connection.straight];
                            NSMutableArray* tmpList = [NSMutableArray array];
                            
                            for(SGInfoSetItem* infosetItem in list){
                                if ([vterminalItem.direction isEqualToString:@"1"]) {
                                    if ([infosetItem.txied_id isEqualToString:self.dataModel0.mainDeviceId]) {
                                        [tmpList addObject:infosetItem];
                                    }
                                }
                                if ([vterminalItem.direction isEqualToString:@"0"]) {
                                    if ([infosetItem.rxied_id isEqualToString:self.dataModel0.mainDeviceId]) {
                                        [tmpList addObject:infosetItem];
                                     }
                                }
                            }
                            
                            for(SGInfoSetItem* infoset in tmpList){
                                
                                if (idx1 == 0) {
                                    
                                    if ([self.dataModel0.mainDeviceId isEqualToString:infoset.txied_id]) {
                                        if (![type0RightCache valueForKey:infoset.rxied_id]) {
                                            
                                            SGPortPageChildData* child = [SGPortPageChildData new];
                                            child.cntedDeviceId = infoset.rxied_id;
                                            child.cntedDeviceName = [self getDeviceInfoById:child.cntedDeviceId];

                                            child.cntedPortId = [self getPortDesc:infoset.rxiedport_id];
                                            child.centerPortId = [self getPortDesc:infoset.txiedport_id];
                                            
                                            
                                            [child.cntedProDes addObject:item.pro_desc];
                                            [child.mainProDes addObject:vterminalItem.pro_desc];
                                            
                                            [type0RightCache setValue:child forKey:infoset.rxied_id];
                                            [self.dataModel0.rightChilds addObject:child];
                                        }else{
                                            SGPortPageChildData* child = [type0RightCache valueForKey:infoset.rxied_id];
                                            [child.cntedProDes addObject:item.pro_desc];
                                            [child.mainProDes addObject:vterminalItem.pro_desc];
                                        }
                                    }
                                    
                                    if ([self.dataModel0.mainDeviceId isEqualToString:infoset.rxied_id]) {
                                        if (![type0LeftCache valueForKey:infoset.txied_id]) {
                                            SGPortPageChildData *child = [SGPortPageChildData new];
                                            child.cntedDeviceId = infoset.txied_id;
                                            child.cntedDeviceName = [self getDeviceInfoById:child.cntedDeviceId];
                                            
                                            child.cntedPortId = [self getPortDesc:infoset.txiedport_id];
                                            child.centerPortId = [self getPortDesc:infoset.rxiedport_id];
                                            
                                            
                                            [child.cntedProDes addObject:item.pro_desc];
                                            [child.mainProDes addObject:vterminalItem.pro_desc];
                                            
                                            [type0LeftCache setValue:child forKey:infoset.txied_id];
                                            [self.dataModel0.leftChilds addObject:child];
                                        }else{
                                            SGPortPageChildData* child = [type0LeftCache valueForKey:infoset.txied_id];
                                            [child.cntedProDes addObject:item.pro_desc];
                                            [child.mainProDes addObject:vterminalItem.pro_desc];
                                        }
                                    }
                                    
                                } else {
                                    
                                    if ([self.dataModel1.mainDeviceId isEqualToString:infoset.txied_id]) {
                                        if (![type1RightCache valueForKey:infoset.rxied_id]) {
                                            
                                            SGPortPageChildData* child = [SGPortPageChildData new];
                                            child.cntedDeviceId = infoset.rxied_id;
                                            child.cntedDeviceName = [self getDeviceInfoById:child.cntedDeviceId];
                                            
                                            child.cntedPortId = [self getPortDesc:infoset.rxiedport_id];
                                            child.centerPortId = [self getPortDesc:infoset.txiedport_id];
                                            
                                            
                                            [child.cntedProDes addObject:item.pro_desc];
                                            [child.mainProDes addObject:vterminalItem.pro_desc];
                                            
                                            [type1RightCache setValue:child forKey:infoset.rxied_id];
                                            [self.dataModel1.rightChilds addObject:child];
                                        }else{
                                            SGPortPageChildData* child = [type1RightCache valueForKey:infoset.rxied_id];
                                            [child.cntedProDes addObject:item.pro_desc];
                                            [child.mainProDes addObject:vterminalItem.pro_desc];
                                        }
                                    }
                                    
                                    if ([self.dataModel1.mainDeviceId isEqualToString:infoset.rxied_id]) {
                                        if (![type1LeftCache valueForKey:infoset.txied_id]) {
                                            SGPortPageChildData *child = [SGPortPageChildData new];
                                            child.cntedDeviceId = infoset.txied_id;
                                            child.cntedDeviceName = [self getDeviceInfoById:child.cntedDeviceId];
                                            
                                            child.cntedPortId = [self getPortDesc:infoset.txiedport_id];
                                            child.centerPortId = [self getPortDesc:infoset.rxiedport_id];
                                            
                                            [child.cntedProDes addObject:item.pro_desc];
                                            [child.mainProDes addObject:vterminalItem.pro_desc];
                                            
                                            [type1LeftCache setValue:child forKey:infoset.txied_id];
                                            [self.dataModel1.leftChilds addObject:child];
                                        }else{
                                            SGPortPageChildData* child = [type1LeftCache valueForKey:infoset.txied_id];
                                            [child.cntedProDes addObject:item.pro_desc];
                                            [child.mainProDes addObject:vterminalItem.pro_desc];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }];
        }];
    }
    return @[self.dataModel0,self.dataModel1];
}


@end
