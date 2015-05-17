//
//  SGCablePageBussiness.m
//  SGClient
//
//  Created by JY on 14-5-19.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import "SGCablePageBussiness.h"
#import "SGFiberPageBussiness.h"

#import <objc/message.h>

@implementation SGCPConnectionItem
@end

@implementation SGCPDataBaseRowItem
@end

@implementation SGCPDataItem

-(instancetype)initWithCableId:(NSString*)cableId withCableName:(NSString*)cableName
       withCableType:(NSString*)cableType
       withCubicleId:(NSString*)cubicleId
     withCubicleName:(NSString*)cubicleName
        withDrawFlag:(NSString *)drawFlag{
    
    if (self = [super init]) {
        _cable_id = cableId;
        _cable_name = cableName;
        _cable_type = cableType;
        _cubicle_id = cubicleId;
        _cubicle_name = cubicleName;
        _drawFlag = drawFlag;
    }
    return self;
}
@end

@interface SGCablePageBussiness()

@property(nonatomic,strong) NSArray *connectionList;
@property(nonatomic,strong) NSArray *cableOfType0List;
@property(nonatomic,strong) NSArray *cableOfType1List;
@property(nonatomic,strong) NSArray *connectionOrder;

@property(nonatomic,strong) NSMutableDictionary* cached;
@property(nonatomic,strong) NSMutableArray* gllist;
@property(nonatomic,strong) NSMutableArray* gllistFinal;
@property(nonatomic,assign) NSUInteger cubicleId;


@end

#define CABLETYPE0 0
#define CABLETYPE1 1
#define CABLETYPE2 2

/*－－－－－－－－－－－－－－－－－
 SQL 根据Cubicleidid
 
 获取Connection表信息
 －－－－－－－－－－－－－－－－－*/
#define CP_GetCubicleConnect(v) [NSString stringWithFormat:@"select use_odf1,use_odf2,connection_id,cubicle1_id,passcubicle1_id,cubicle2_id,passcubicle2_id\
                                                 from cubicle_connection where cubicle1_id = %d or cubicle2_id = %d or \
                                                      passcubicle1_id = %d or passcubicle2_id = %d",v,v,v,v]

/*－－－－－－－－－－－－－－－－－
 SQL 根据Cubicleidid 和 CableTyoe
 
 获取该Id相关的Cable信息
 －－－－－－－－－－－－－－－－－*/
#define CP_GetCablelist(v,t) [NSString stringWithFormat:@"select cable_id,cubicle1_id,cubicle2_id,name as cable_name,cable_type,\
                           (select name from cubicle where cable.cubicle1_id =cubicle.cubicle_id) as cubicle1_name, \
                           (select name from cubicle where cable.cubicle2_id =cubicle.cubicle_id) as cubicle2_name \
                            from cable where (cubicle1_id in ( \
                            select * from ( select cubicle1_id from cubicle_connection \
                            where cubicle1_id = %d or cubicle2_id = %d or \
                            passcubicle1_id = %d or passcubicle2_id = %d union \
                            select passcubicle1_id  from cubicle_connection \
                            where cubicle1_id = %d or cubicle2_id = %d or \
                            passcubicle1_id = %d or passcubicle2_id = %d union \
                            select passcubicle2_id  from cubicle_connection \
                            where cubicle1_id = %d or cubicle2_id = %d or\
                            passcubicle1_id = %d or passcubicle2_id = %d union \
                            select cubicle2_id from cubicle_connection \
                            where cubicle1_id = %d or cubicle2_id = %d or \
                            passcubicle1_id = %d or passcubicle2_id = %d \
                            )) or cubicle2_id in ( \
                            select * from (select cubicle1_id from cubicle_connection\
                            where cubicle1_id = %d or cubicle2_id = %d or\
                            passcubicle1_id = %d or passcubicle2_id = %d union\
                            select passcubicle1_id  from cubicle_connection\
                            where cubicle1_id = %d or cubicle2_id = %d or\
                            passcubicle1_id = %d or passcubicle2_id = %d union \
                            select passcubicle2_id  from cubicle_connection \
                            where cubicle1_id = %d or cubicle2_id = %d or \
                            passcubicle1_id = %d or passcubicle2_id = %d union \
                            select cubicle2_id from cubicle_connection \
                            where cubicle1_id = %d or cubicle2_id = %d or \
                            passcubicle1_id = %d or passcubicle2_id = %d\
                            ))) and cable.cable_type = %d",v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,t]

/*－－－－－－－－－－－－－－－－－
 SQL 根据Cubicleid
 
 获取Cable信息  type = 2
 －－－－－－－－－－－－－－－－－*/
#define CP_GetCubicleItem(v,t) [NSString stringWithFormat:@"select cable.cable_id,cable.cable_type,cable.name as cable_name,%d as cubicle_id,\
                                          (select name from cubicle where cubicle_id = %d) as cubicle_name from cable where \
                                          (cable.cubicle1_id = %d  and cable.cubicle2_id = %d)   \
                                            and cable_type = %d",v,v,v,v,t]



/*－－－－－－－－－－－－－－－－－
 SQL 根据cableId
 
 获取Cable信息
 －－－－－－－－－－－－－－－－－*/
#define CP_GetCableInfo(c) [NSString stringWithFormat:@"select cable_id,cable_type,cable.name as cable_name from cable where cable_id = %d",c]



@implementation SGCablePageBussiness

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGCablePageBussiness)

-(id)init{
    if (self = [super init]) {
        //连接顺序
        _connectionOrder = [NSArray arrayWithObjects:
                            @"cubicle1_id",
                            @"passcubicle1_id",
                            @"passcubicle2_id",
                            @"cubicle2_id", nil];
    }
    return self;
}

-(SGCPDataItem*)queryCalbleInfoWithCableId:(NSInteger)cableId{
    
    return [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:CP_GetCableInfo(cableId)]
                                 withEntity:@"SGCPDataItem"][0];
}

/*－－－－－－－－－－－－－－－－－－－－－
 根据请求CubicleId返回XML STRING
 
 1.光缆连接  2.尾缆连接 3.跳缆连接
 绘制光缆连接时 如有光缆连接 则也需画出尾缆连接
 －－－－－－－－－－－－－－－－－－－－－*/
-(NSDictionary*)queryCablelistWithCubicleId:(NSInteger)cubicleId{

//    NSLog(@"%@",CP_GetCablelist(cubicleId,CABLETYPE0));
//    NSLog(@"%@",CP_GetCubicleConnect(cubicleId));
    
    _cached = [NSMutableDictionary dictionary];
    _gllist = [NSMutableArray array];
    _gllistFinal = [NSMutableArray array];
    self.cubicleId = cubicleId;
    //光缆列表
    self.cableOfType0List = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:CP_GetCablelist(cubicleId,CABLETYPE0)]
                                             withEntity:@"SGCPDataBaseRowItem"];
    //尾缆列表
    self.cableOfType1List = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:CP_GetCablelist(cubicleId,CABLETYPE1)]
                                             withEntity:@"SGCPDataBaseRowItem"];
    //连接关系列表
    self.connectionList   = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:CP_GetCubicleConnect(cubicleId)]
                                             withEntity:@"SGCPConnectionItem"];
    
    NSArray* type0List;
//    = [self requestListWithCubicleId:cubicleId WithType:CABLETYPE0];
    NSArray* type1List = [self requestListWithCubicleId:cubicleId WithType:CABLETYPE1];
    
    NSArray* type2List = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:CP_GetCubicleItem(cubicleId, CABLETYPE2)]
                                          withEntity:@"SGCPDataItem"];
//    type0List = [self verifyType0ListWithCubicleId:cubicleId withList:type0List];
    
    [self handleType0list];
  
    type0List = self.gllistFinal;
    NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:type0List,@"type0",
                            type1List,@"type1",
                            type2List,@"type2",
                            nil];
    return result;
//    return [self buildXMLForResultSet:result];
}


/*－－－－－－－－－－－－－－－－－
 请求Cubicle直连的左右两边光缆 
 如有重复只需绘制一次
 
 如直连的左右两边没有光缆 删除此条记录
 －－－－－－－－－－－－－－－－－*/
-(NSArray*)verifyType0ListWithCubicleId:(NSInteger)cubicleId withList:(NSArray*)list{
    
    NSMutableDictionary* cachedSet = [NSMutableDictionary dictionary];
    NSMutableArray* _list = [list mutableCopy];
    NSString* key;
    NSInteger index;
    SGCPDataItem* tmpItem1;
    SGCPDataItem* tmpItem2;
    BOOL flag = NO;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cubicle_id == %@",
                              [NSString stringWithFormat:@"%d",cubicleId]];
    for(NSArray* connection in [NSArray arrayWithArray:_list]){
        NSArray* tmp = [connection filteredArrayUsingPredicate:predicate];
        index = [connection indexOfObject:tmp[0]];
 
        if ((index-1)>=0) {
            
            tmpItem1 = connection[index-1];
            key = [NSString stringWithFormat:@"%@##%d",tmpItem1.cubicle_id,cubicleId];
            if ([tmpItem1.cable_type integerValue] == 0) {
                flag = YES;
            } else { flag = NO;}

            if ([cachedSet valueForKey:key]) {
                [(SGCPDataItem*)connection[index-1] setValue:@"0" forKey:@"drawFlag"];
            } else {
                [cachedSet setObject:@"Y" forKey:key];
            }
        }
        if ((index+1)<[connection count]) {
            tmpItem2 = connection[index+1];
            key = [NSString stringWithFormat:@"%d##%@",cubicleId,
                   tmpItem2.cubicle_id];
            if ([tmpItem2.cable_type integerValue] == 0) {
                flag = YES;
            } else { flag = NO;}
            
            if ([cachedSet valueForKey:key]) {
                [tmpItem2 setValue:@"0" forKey:@"drawFlag"];
            } else {
                [cachedSet setObject:@"Y" forKey:key];
            }
        }
        if (!flag) {
            [_list removeObject:connection];
        }
    }

    return _list;
}

/*－－－－－－－－－－－－－－－－－
 连接是否已添加
 －－－－－－－－－－－－－－－－－*/
-(BOOL)checkConnectionExistsWithList:(NSArray*)list withSubList:(NSArray*)slist{
    
    NSArray* idlist1;
    NSArray* slistId = [slist valueForKeyPath:@"@distinctUnionOfObjects.cubicle_id"];
    BOOL flag = YES;
    for(NSArray* cubicles in list){
        idlist1 = [cubicles valueForKeyPath:@"@distinctUnionOfObjects.cubicle_id"];
        
        flag = YES;
        if ([idlist1 count] == [slistId count]) {
            for(NSString* cubicleId in idlist1){
                if (![slistId containsObject:cubicleId]) {
                    flag = NO;
                }
            }
            if (flag) {
                return YES;
            }
        }
    }
    return NO;
  
}

/*－－－－－－－－－－－－－－－－－
 根据CubicleId Type 获取List
 
 －－－－－－－－－－－－－－－－－*/
-(NSArray*)requestListWithCubicleId:(NSInteger)cubicleId WithType:(NSInteger)type{
    
    NSInteger indexInOrderList;
    NSInteger indexInOrderListTmp;
    NSString* tmpValue;
    
    NSMutableArray* connection;
    NSMutableArray* connectionCubicles;
    NSMutableArray* retList;
    NSArray* cableItem;
    NSMutableDictionary* kvPairs;
    
    BOOL isContainsGLConn = NO;   //连接关系是否连有光缆
    
    retList = [NSMutableArray array];
    NSMutableSet* set = [NSMutableSet set];

    //遍历连接关系表
    for(SGCPConnectionItem* connectionItem in self.connectionList){
        isContainsGLConn = NO;
        //use_odf1=1 OR use_odf2=1 则必包含光缆连接
        if ([connectionItem.use_odf1 integerValue]||[connectionItem.use_odf2 integerValue]) {
            isContainsGLConn = YES;
        }
        
        connection = [NSMutableArray array];
        kvPairs    = [NSMutableDictionary dictionary];
        
        //获取主CubicleId在连接顺序表中的位置
        indexInOrderList = [self getIndexOfCurrentCubicleWithConnItem:connectionItem
                                                               withId:cubicleId];
      
        indexInOrderListTmp = indexInOrderList;
        //关系链向前查询
        while (indexInOrderListTmp>=0) {
            indexInOrderListTmp--;
            if (indexInOrderListTmp>=0) {
                tmpValue = [connectionItem valueForKey:self.connectionOrder[indexInOrderListTmp]];
                //值不等于cubicleId不等于0
                if ([tmpValue integerValue] != cubicleId && ![tmpValue isEqualToString:@"0"]) {
                    //添加目标cubicleId到数组
                    [connection addObject:tmpValue];
                    [kvPairs setValue:self.connectionOrder[indexInOrderListTmp]
                               forKey:tmpValue];
                }
            }
        }
        
        //调整数据顺序
        connection = [[[connection reverseObjectEnumerator] allObjects] mutableCopy];
        
        //添加主cubicleId
        [connection addObject:[NSString stringWithFormat:@"%d",cubicleId]];
        [kvPairs setValue:self.connectionOrder[indexInOrderList]
                   forKey:[NSString stringWithFormat:@"%d",cubicleId]];
        
        indexInOrderListTmp = indexInOrderList;
        
        //关系链向后查询
        while (indexInOrderListTmp<=[self.connectionOrder count]-1) {
            indexInOrderListTmp++ ;
            if (indexInOrderListTmp<=[self.connectionOrder count]-1) {
                tmpValue = [connectionItem valueForKey:self.connectionOrder[indexInOrderListTmp]];
                if ([tmpValue integerValue] != cubicleId && ![tmpValue isEqualToString:@"0"]) {
                    [connection addObject:tmpValue];
                    [kvPairs setValue:self.connectionOrder[indexInOrderListTmp]
                               forKey:tmpValue];
                }
            }
        }
        //调整连接方向 如在尾部，把请求Cubicle置于开始
        //如果请求Cubicle不在首尾，其左侧绘制同序Cubicle 右侧绘制不同序Cubicle
        connection = [[self resortConnectionOrderWithArray:connection
                                                 withPairs:kvPairs
                                             withCubicleId:cubicleId] mutableCopy];

        //有和指定Cubicle连接的
        NSMutableArray *n = [NSMutableArray array];
        connectionCubicles = [NSMutableArray array];
        
        
        if (YES) {
            [self getType0listWithlist:connection item:connectionItem dic:kvPairs];
        }
        
        
        if (type == CABLETYPE1) {
            
        if ([connection count] > 1) {
            if (type == CABLETYPE0) {
                if (!isContainsGLConn) {
                    continue;
                }
            }

            
            //两两检查Cubicle的光缆连接情况
            
            for(int i = 0; i < [connection count]-1; i++){
                
                //获取光缆
                cableItem = [self getConnectedCubicleInfoWithTmpId:[connection[i] integerValue]
                                                         withTmpId:[connection[i + 1] integerValue]
                                                         withPairs:kvPairs
                                                          withType:(NSInteger)type
                                                       withUseOdf1:[connectionItem.use_odf1 integerValue]
                                                       withUseOdf2:[connectionItem.use_odf2 integerValue]];
                
                if (cableItem) {
                    [n addObject:cableItem];
                }
                
                if (cableItem.count) {
                } else { break;}
            }
        }
        
        
            if (n.count == 1) {
                for(int i = 0;i<[n[0] count];i++){
                    NSMutableArray *tmp = [NSMutableArray array];
                    [tmp addObject:n[0][i][0]];
                    [tmp addObject:n[0][i][1]];
                    [connectionCubicles addObject:tmp];
                }
            }
            
            
            if (n.count == 2) {
                
                for(int i = 0;i<[n[0] count];i++){
                    for(int j = 0; j < [n[1] count];j++){
                        
                        NSMutableArray *tmp = [NSMutableArray array];
                        [tmp addObject:n[0][i][0]];
                        [tmp addObject:n[0][i][1]];
                        [tmp addObject:n[1][j][1]];
                        [connectionCubicles addObject:tmp];
                    }
                }
            }
            
            if (n.count == 3) {
                for(int i = 0;i<[n[0] count];i++){
                    for(int j = 0; j < [n[1] count];j++){
                        for(int m = 0; m < [n[2] count]; m++){
                            NSMutableArray *tmp = [NSMutableArray array];
                            [tmp addObject:n[0][i][0]];
                            [tmp addObject:n[0][i][1]];
                            [tmp addObject:n[1][j][1]];
                            [tmp addObject:n[2][m][1]];
                            [connectionCubicles addObject:tmp];
                        }
                    }
                }
            }
        }

        for(int i = 0; i < connectionCubicles.count;i++){
 
            
            if (YES) {
                NSArray* c = connectionCubicles[i];
 
                //尾缆调整顺序 如请求Cubicle在尾部 倒转顺序
                if (type == CABLETYPE1) {
                    SGCPDataItem* cubicle = c[c.count-1];
                    if ([cubicle.cubicle_id integerValue] == cubicleId) {
                        
                        SGCPDataItem* tmp;
                        c = [[[c reverseObjectEnumerator] allObjects] mutableCopy];
                        
                        for(int i = 0; i<c.count-1;i++){
                            SGCPDataItem* cubicle1 = c[i];
                            SGCPDataItem* cubicle2 = c[i+1];
                            SGCPDataItem* _tmp;
                            
                            if (!i) {_tmp = cubicle1;} else {_tmp = tmp;}
                            
                            tmp = cubicle2;
                            cubicle2.cable_id   = _tmp.cable_id;
                            cubicle2.cable_type = _tmp.cable_type;
                            cubicle2.cable_name = _tmp.cable_name;
                        }
                        tmp = c[0];
                        tmp.cable_type = @"";
                        tmp.cable_name = @"";
                        tmp.cable_id   = @"";
                    }
                }
                
                NSMutableString* s = [NSMutableString new];
                for(int j = 0; j<c.count; j++){
                    SGCPDataItem* item = c[j];
                    [s appendString:[NSString stringWithFormat:@"<%@#%@>",item.cable_id,item.cubicle_id]];
                }
                if ([set containsObject:s]) {
                    continue;
                }else{
                    [set addObject:s];
                }
                
                [retList addObject:c];
            }
        }
    }
    return retList;
}


/*－－－－－－－－－－－－－－－－－
 获取CubicleId在连接顺序中的索引
 －－－－－－－－－－－－－－－－－*/
-(NSInteger)getIndexOfCurrentCubicleWithConnItem:(SGCPConnectionItem*)item
                                          withId:(NSInteger)cubcleId{
    unsigned int outCount;
    NSString* property;
    objc_property_t *properties;
    properties = class_copyPropertyList([SGCPConnectionItem class], &outCount);
    
    for(int i = 0; i < outCount;i++){
        property = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ([property isEqualToString:@"use_odf1"]||[property isEqualToString:@"use_odf2"]||[property isEqualToString:@"connection_id"]) {
            continue;
        }
        if ([[item valueForKey:property] integerValue] == cubcleId) {
            return [self.connectionOrder indexOfObject:property];
        }
    }
    return -1;
}

/*－－－－－－－－－－－－－－－－－
 判断两个Field之间的光缆类型
 Or
 排序时判断是否同一边
 －－－－－－－－－－－－－－－－－*/
-(NSInteger)getCableTypeBetweenField1:(NSString*)field1
                               field2:(NSString*)field2
                          withUseOdf1:(NSInteger)useOdf1
                          withUseOdf2:(NSInteger)useOdf2{
    if (!useOdf1 && !useOdf2) {
        return 1;
    }
    
    if (([field1 isEqualToString:@"cubicle1_id"] && [field2 isEqualToString:@"passcubicle1_id"]) ||
        ([field1 isEqualToString:@"passcubicle1_id"] && [field2 isEqualToString:@"cubicle1_id"]) ||
        ([field1 isEqualToString:@"cubicle2_id"] && [field2 isEqualToString:@"passcubicle2_id"]) ||
        ([field1 isEqualToString:@"passcubicle2_id"] && [field2 isEqualToString:@"cubicle2_id"])){
        return 1;
    }
    return 0;
}

/*－－－－－－－－－－－－－－－－－
 根据cubicleid1 cubicleid2 type 
 
 获取Cable信息
 －－－－－－－－－－－－－－－－－*/
-(NSArray*)getConnectedCubicleInfoWithTmpId:(NSInteger)tid1
                                  withTmpId:(NSInteger)tid2
                                  withPairs:(NSDictionary*)dic
                                   withType:(NSInteger)_type
                                withUseOdf1:(NSInteger)useOdf1
                                withUseOdf2:(NSInteger)useOdf2{
    
    NSString* stid1 = [NSString stringWithFormat:@"%d",tid1];
    NSString* stid2 = [NSString stringWithFormat:@"%d",tid2];
    
    NSInteger type = [self getCableTypeBetweenField1:[dic valueForKey:stid1]
                                              field2:[dic valueForKey:stid2]
                                         withUseOdf1:useOdf1
                                         withUseOdf2:useOdf2];
    
    //如果是只绘制尾缆 跳过光缆
    if (_type == CABLETYPE1) {
        if (type!=_type) {
            return nil;
        }
    }
    
    SGCPDataBaseRowItem * cableRowItem;
    SGCPDataItem* basicItem;
    NSMutableArray* retList;
    NSString* cubicleName;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(cubicle1_id == %@ and cubicle2_id == %@) or \
                              (cubicle2_id == %@ and cubicle1_id == %@)",stid1,stid2,stid1,stid2];
    
    NSArray* filteredList;
    
    switch (type) {
            //光缆
        case CABLETYPE0:
            filteredList = [self.cableOfType0List filteredArrayUsingPredicate:predicate];
            break;
            //尾缆
        case CABLETYPE1:
            filteredList = [self.cableOfType1List filteredArrayUsingPredicate:predicate];
            break;
        default:
            break;
    }

    retList = [NSMutableArray array];
    
    for(int i = 0; i < filteredList.count; i++){
        
        NSMutableArray* tmp = [NSMutableArray array];
        
        cableRowItem = filteredList[i];
        
        cubicleName = ([stid1 isEqualToString:cableRowItem.cubicle1_id])? cableRowItem.cubicle1_name:
        cableRowItem.cubicle2_name;
        basicItem = [[SGCPDataItem alloc] initWithCableId:@""
                                            withCableName:@""
                                            withCableType:@""
                                            withCubicleId:stid1
                                          withCubicleName:cubicleName
                                             withDrawFlag:@""];
        [tmp addObject:basicItem];
        
        cubicleName = ([stid2 isEqualToString:cableRowItem.cubicle1_id])? cableRowItem.cubicle1_name:
        cableRowItem.cubicle2_name;
        basicItem = [[SGCPDataItem alloc] initWithCableId:cableRowItem.cable_id
                                            withCableName:cableRowItem.cable_name
                                            withCableType:cableRowItem.cable_type
                                            withCubicleId:stid2
                                          withCubicleName:cubicleName
                                             withDrawFlag:@"1"];
        [tmp addObject:basicItem];
        [retList addObject:tmp];
    }
    
//    if (filteredList) {
//        if ([filteredList count]>0) {
//            cableRowItem = filteredList[0];
//            retList = [NSMutableArray array];
//            if (cableRowItem) {
//                
//                cubicleName = ([stid1 isEqualToString:cableRowItem.cubicle1_id])? cableRowItem.cubicle1_name:
//                cableRowItem.cubicle2_name;
//                basicItem = [[SGCPDataItem alloc] initWithCableId:@""
//                                                    withCableName:@""
//                                                    withCableType:@""
//                                                    withCubicleId:stid1
//                                                  withCubicleName:cubicleName
//                                                     withDrawFlag:@""];
//                [retList addObject:basicItem];
//                
//                cubicleName = ([stid2 isEqualToString:cableRowItem.cubicle1_id])? cableRowItem.cubicle1_name:
//                cableRowItem.cubicle2_name;
//                basicItem = [[SGCPDataItem alloc] initWithCableId:cableRowItem.cable_id
//                                                    withCableName:cableRowItem.cable_name
//                                                    withCableType:cableRowItem.cable_type
//                                                    withCubicleId:stid2
//                                                  withCubicleName:cubicleName
//                                                     withDrawFlag:@"1"];
//                [retList addObject:basicItem];
//            }
//        }
//    }
    return retList;
}

/*－－－－－－－－－－－－－－－－－
 重新排序
 －－－－－－－－－－－－－－－－－*/
-(NSArray*)resortConnectionOrderWithArray:(NSArray*)array
                                withPairs:(NSDictionary*)pair
                            withCubicleId:(NSInteger)cubicleId{
    
    NSString* scubicleId = [NSString stringWithFormat:@"%d",cubicleId];
    NSInteger index = [array indexOfObject:scubicleId];
    
    if (index == 0) {
    } else if (index==[array count]-1){
        return [[array reverseObjectEnumerator] allObjects];
    } else {
        
        NSString* field1 = [pair valueForKey:scubicleId];
        NSString* field2 = [pair valueForKey:array[index - 1]];
        
        if (![self getCableTypeBetweenField1:field1
                                      field2:field2
                                 withUseOdf1:1
                                 withUseOdf2:1]) {
            
            return [[array reverseObjectEnumerator] allObjects];
        }
    }
    return array;
}




#define FP_GetFiberItemList(cableId) [NSString stringWithFormat:@"select fiber_id,cable_id,port1_id,port2_id, \
[index],fiber_color,pipe_color,reserve from fiber where cable_id = %@ order by [index]",cableId]

#define FP_GetAnotherTwoPorts(p1,p2) [NSString stringWithFormat:@"select a.port1_id from(\
select port1_id  as port1_id  from fiber   where port1_id = %@ or port2_id = %@ union \
select port2_id  as port1_id  from fiber   where port1_id = %@ or port2_id = %@ union \
select port1_id  as port1_id  from fiber   where port1_id = %@ or port2_id = %@ union \
select port2_id  as port1_id  from fiber   where port1_id = %@ or port2_id = %@  ) a  \
where a.port1_id not in (%@,%@)",p1,p1,p1,p1,p2,p2,p2,p2,p1,p2]

#define FP_CheckPortOrder(p1,p2) [NSString stringWithFormat:@"select fiber_id,cable_id,port1_id,port2_id, \
[index],fiber_color,pipe_color,reserve from fiber where (port1_id = %@ and port2_id = %@) or (port2_id = %@  and port1_id = %@)",p1,p2,p1,p2]

#define FP_GetCubicleIdWithPort(p) [NSString stringWithFormat:@"select device.cubicle_id as port1_id from device \
inner join board on device.device_id=board.device_id inner join port on board.board_id=port.board_id \
where port.port_id = %@",p]

#define FP_GetTXInfo(p1,p2) [NSString stringWithFormat:@"select cable.cable_id,cable.name as cable_name,cable.cable_type from cable \
inner join fiber on cable.cable_id = fiber.cable_id \
where (fiber.port1_id = %@ and fiber.port2_id = %@) or (fiber.port2_id = %@ and fiber.port1_id = %@)",p1,p2,p1,p2]

#define FP_GetCubicleId(p) [NSString stringWithFormat:@"select cubicle.cubicle_id,cubicle.name as cubicle_name from device \
inner join board on device.device_id=board.device_id inner join port on board.board_id=port.board_id inner join cubicle on cubicle.cubicle_id = device.cubicle_id  \
 where port.port_id = %@",p]

-(NSInteger)queryFiberCountWithCableId:(NSString*)cableId{
    
    NSArray* fiberList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetFiberItemList(cableId)]
                                               withEntity:@"SGFiberItem"];
    
    return fiberList.count;
}
-(void)handleType0list{
    

    for(NSMutableArray* a in self.gllist){
        

        NSArray* fiberList = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetFiberItemList([a[1] valueForKey:@"cable_id"])]
                                                   withEntity:@"SGFiberItem"];
        
        BOOL flag = NO;
        BOOL swapped = NO;
        for(SGFiberItem* fiberItem in fiberList){
            
            NSMutableArray* tmp = [NSMutableArray array];
            for(SGCPDataItem* item in a){
                [tmp addObject:[[SGCPDataItem alloc] initWithCableId:item.cable_id withCableName:item.cable_name withCableType:item.cable_type withCubicleId:item.cubicle_id withCubicleName:item.cubicle_name withDrawFlag:nil]];
            }
            
            BOOL flag1 = NO;
            BOOL flag2 = NO;
            if ([fiberItem.reserve isEqualToString:@"1"]) {
                continue;
            }
            
            NSArray* portList = [[SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetAnotherTwoPorts(fiberItem.port1_id,fiberItem.port2_id)]
                                                   withEntity:@"SGFiberItem"] copy];
            portList = [NSMutableArray arrayWithObjects:[[portList objectAtIndex:0] port1_id],
                             [[portList objectAtIndex:1] port1_id],nil];
            
            NSArray* desc1 = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_CheckPortOrder([portList objectAtIndex:0], fiberItem.port1_id)]
                                                     withEntity:@"SGFiberItem"];
            if (!desc1.count) {
                portList = [[[portList reverseObjectEnumerator] allObjects] copy];
//                swapped = YES;
            }
            
            NSArray *desc2 = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetCubicleIdWithPort(fiberItem.port1_id)]
                                                  withEntity:@"SGFiberItem"];
            if (desc2.count) {
                SGFiberItem* fiberItem2 = desc2[0];
                if (!([fiberItem2.port1_id integerValue] == self.cubicleId)) {
                    
                    NSString* tmp = fiberItem.port1_id;
                    fiberItem.port1_id = fiberItem.port2_id;
                    fiberItem.port2_id = tmp;
                    
                    portList = [[[portList reverseObjectEnumerator] allObjects] copy];
//                    swapped = YES;
                }
            }
            
            NSMutableArray* c = [NSMutableArray arrayWithArray:tmp];
            
            NSArray *desc3 = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetTXInfo([portList objectAtIndex:0],fiberItem.port1_id)] withEntity:@"SGCPDataItem"];
            if (desc3.count) {
                if ([[desc3[0] valueForKey:@"cable_type"] isEqualToString:@"1"]) {
                    flag1 = YES;
                    flag = YES;
                    NSArray* cu =  [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetCubicleId([portList objectAtIndex:0])] withEntity:@"SGCPDataItem"];
                    if (YES) {
                        
                        if (YES) {
                            SGCPDataItem* item = c[0];
                            item.cable_id = [desc3[0] valueForKey:@"cable_id"];
                            item.cable_name = [desc3[0] valueForKey:@"cable_name"];
                            
                            [c insertObject:cu[0] atIndex:0];
                            
                        }else{
                            
//                            SGCPDataItem* item = cu[0];
//                            item.cable_id = [desc[0] valueForKey:@"cable_id"];
//                            item.cable_name = [desc[0] valueForKey:@"cable_name"];
//                            
//                            
//                            [c insertObject:item atIndex:c.count];
                        }
                        
                        

                    }
                }
            }
            
            NSArray *desc4 = [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetTXInfo([portList objectAtIndex:1],fiberItem.port2_id)] withEntity:@"SGCPDataItem"];
            if (desc4.count) {
                
                if ([[desc4[0] valueForKey:@"cable_type"] isEqualToString:@"1"]) {
                    flag2 = YES;
                    flag = YES;
                    NSArray* cu =  [SGUtility getResultlistForFMSet:[self.dataBase executeQuery:FP_GetCubicleId([portList objectAtIndex:1])] withEntity:@"SGCPDataItem"];
                    if (YES) {
                        if (YES) {
                            SGCPDataItem* item = cu[0];
                            item.cable_id = [desc4[0] valueForKey:@"cable_id"];
                            item.cable_name = [desc4[0] valueForKey:@"cable_name"];
                            
                            
                            [c insertObject:item atIndex:c.count];
                            
                        }else{
//                            SGCPDataItem* item = c[0];
//                            item.cable_id = [desc[0] valueForKey:@"cable_id"];
//                            item.cable_name = [desc[0] valueForKey:@"cable_name"];
//                            
//                            [c insertObject:cu[0] atIndex:0];

                        }

                        
                    }
                }
            }

            if (flag1||flag2) {
               [self.gllistFinal addObject:c];
            }
            
            if (!flag) {
                [self.gllistFinal addObject:a];
            }
            
        }

    }
    NSLog(@"test");
}



-(void)getType0listWithlist:(NSArray*)list item:(SGCPConnectionItem*)item dic:(NSDictionary*)dic{
    
    NSUInteger type = 0;
    
    SGCPDataItem* basicItem;
    NSString* cubicleName;
    
    for(int i = 0;i<list.count-1;i++){
        
        type = [self getCableTypeBetweenField1:dic[[NSString stringWithFormat:@"%@",list[i]]]
                                        field2:dic[[NSString stringWithFormat:@"%@",list[i+1]]]
                                   withUseOdf1:[item.use_odf1 integerValue]
                                   withUseOdf2:[item.use_odf2 integerValue]];
        
        if (type == 0) {
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(cubicle1_id == %@ and cubicle2_id == %@) or \
                                      (cubicle2_id == %@ and cubicle1_id == %@)",list[i],list[i+1],list[i],list[i+1]];
            
            NSArray* filteredList;
            filteredList = [self.cableOfType0List filteredArrayUsingPredicate:predicate];
            for(SGCPDataBaseRowItem * cableRowItem in filteredList){
                
                if (![self.cached valueForKey:cableRowItem.cable_id]) {
                    
                    if ([list[i] integerValue] == self.cubicleId || [list[i+1] integerValue] == self.cubicleId) {
                        NSMutableArray* a = [NSMutableArray array];
                        cubicleName = ([list[i] isEqualToString:cableRowItem.cubicle1_id])? cableRowItem.cubicle1_name:
                        cableRowItem.cubicle2_name;
                        basicItem = [[SGCPDataItem alloc] initWithCableId:@""
                                                            withCableName:@""
                                                            withCableType:@""
                                                            withCubicleId:list[i]
                                                          withCubicleName:cubicleName
                                                             withDrawFlag:@""];
                        [a addObject:basicItem];
                        
                        cubicleName = ([list[i+1] isEqualToString:cableRowItem.cubicle1_id])? cableRowItem.cubicle1_name:
                        cableRowItem.cubicle2_name;
                        basicItem = [[SGCPDataItem alloc] initWithCableId:cableRowItem.cable_id
                                                            withCableName:cableRowItem.cable_name
                                                            withCableType:cableRowItem.cable_type
                                                            withCubicleId:list[i+1]
                                                          withCubicleName:cubicleName
                                                             withDrawFlag:@"1"];
                        [a addObject:basicItem];
                        [self.gllist addObject:a];
                    }
                    
                    [self.cached setValue:@"#" forKey:cableRowItem.cable_id];
                }
            }
        }
    }
}


/*－－－－－－－－－－－－－－－－－
 根据RESULT LIST 生成XML
 －－－－－－－－－－－－－－－－－*/
-(NSString*)buildXMLForResultSet:(NSDictionary*)resultList{
    
    NSMutableString* xMLString = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><root>"];
    [resultList.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [xMLString appendString:[NSString stringWithFormat:@"<%@>",(NSString*)obj]];
        
        if (![obj isEqualToString:@"type2"]) {

            NSArray* connList = [resultList valueForKey:(NSString*)obj];
            [connList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [xMLString appendString:@"<connection>"];
                NSArray* connItem = (NSArray*)obj;
                [connItem enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    [xMLString appendString:@"<cubicle>"];
                    SGCPDataItem* cubicle = (SGCPDataItem*)obj;
                    unsigned int outCount;
                    objc_property_t *properties;
                    NSString* property;
                    
                    properties = class_copyPropertyList([SGCPDataItem class], &outCount);
                    
                    for(int i = 0; i < outCount;i++){
                        property = [NSString stringWithUTF8String:property_getName(properties[i])];
                        
                        [xMLString appendString:[NSString stringWithFormat:@"<%@>%@</%@>",
                                                 property,
                                                 [cubicle valueForKey:property],
                                                 property]];
                    }
                    
                    [xMLString appendString:@"</cubicle>"];}];
                    [xMLString appendString:@"</connection>"];}];
            
        }else {
            
            NSArray* connList = [resultList valueForKey:(NSString*)obj];
            if (connList.count) {
                SGCPDataItem* dataItem = connList[0];
                [xMLString appendString:[NSString stringWithFormat:@"<cubicle id = \"%@\" name = \"%@\">",dataItem.cubicle_id,dataItem.cubicle_name]];
                [connList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    SGCPDataItem* dataItem = (SGCPDataItem*)obj;
                    [xMLString appendString:[NSString stringWithFormat:@"<cable id = \"%@\" type =\"%@\">%@</cable>",
                                             dataItem.cable_id,
                                             dataItem.cable_type,
                                             dataItem.cable_name]];
                }];[xMLString appendString:@"</cubicle>"];
            }}
               [xMLString appendString:[NSString stringWithFormat:@"</%@>",(NSString*)obj]];}];
               [xMLString appendString:@"</root>"];
    
    return xMLString;
}
@end
