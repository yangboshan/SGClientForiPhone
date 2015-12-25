//
//  SGDbBussiness.m
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGMainPageBussiness.h"
#import "SGDataBase.h"
#import "FMDatabase.h"


@implementation SGDataBaseRowItem

@end


@implementation SGMainPageBussiness

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGMainPageBussiness)

/*－－－－－－－－－－－－－－－－－
 SQL 获得指定ROOM ID 的DEVICE列表
 INPUT: ROOM_ID (INT)
 －－－－－－－－－－－－－－－－－*/
#define MP_GetDevicelistForRoom  "select room.room_id as roomid,room.name as roomname,cubicle.cubicle_id as cubicleid,cubicle.name as cubiclename,device.device_id as deviceid,device.description as devicename from device,cubicle,room where room.room_id = cubicle.room_id and device.cubicle_id = cubicle.cubicle_id and cubicle.room_id = ?  and device.device_type !=2 order by room.number, cubicle.number, device.cubicle_pos"

/*－－－－－－－－－－－－－－－－－
 SQL 获得所有室内ROOM的DEVICE列表
 INPUT: NULL
 －－－－－－－－－－－－－－－－－*/
#define MP_GetDevicelistForAllInnerRoom  "select room.number as roomnumber,room.room_id as roomid,room.name as roomname,cubicle.cubicle_id as cubicleid,cubicle.name as cubiclename,cubicle.number as cubiclenumber,device.device_id as deviceid,device.description as devicename from device,cubicle,room where room.room_id = cubicle.room_id and device.cubicle_id = cubicle.cubicle_id and device.device_type !=2 order by roomnumber, cubiclenumber, device.cubicle_pos"


/*－－－－－－－－－－－－－－－－－
 SQL 获得ROOM ID ＝ 0 设备列表
 INPUT: NULL
 －－－－－－－－－－－－－－－－－*/
#define MP_GetDevicelistForOuterRoom  "select 'Z99' as roomnumber, 9999 as roomid, '户外' as roomname, cubicle.cubicle_id as cubicleid,cubicle.name as cubiclename, cubicle.number as cubiclenumber,device.device_id as deviceid,device.description as devicename from device,cubicle where device.cubicle_id = cubicle.cubicle_id and cubicle.room_id = 0 and device.device_type !=2 order by cubiclenumber, device.cubicle_pos"

#pragma mark - Query
/*－－－－－－－－－－－－－－－－－
 获得指定ROOM ID 的DEVICE列表
－－－－－－－－－－－－－－－－－*/
-(NSString*)queryDevicelistForRoomWithRoomId:(NSInteger)roomId{

    FMResultSet * fmResultSet = [self.dataBase executeQuery:@MP_GetDevicelistForRoom,
                                 [NSNumber numberWithInteger:roomId]];

    NSArray* resultList = [self getResultlistForFMSet:fmResultSet];

    return [self buildXMLForResultSet:resultList];
}



/*－－－－－－－－－－－－－－－－－
 获得ALL INNER ROOM DEVICE列表
 －－－－－－－－－－－－－－－－－*/
-(NSString*)queryDevicelistForAllInnerRoom{
    
    FMResultSet * fmResultSet = [self.dataBase executeQuery:@MP_GetDevicelistForAllInnerRoom];

    NSArray* tmp1 = [self getResultlistForFMSet:fmResultSet];
    
    fmResultSet = [self.dataBase executeQuery:@MP_GetDevicelistForOuterRoom];
    NSArray *tmp2 = [self getResultlistForFMSet:fmResultSet];
    
    NSArray* resultList = [tmp1 arrayByAddingObjectsFromArray:tmp2];

    return [self buildXMLForResultSet:resultList];
}



/*－－－－－－－－－－－－－－－－－
 获得ROOM ID ＝ 0 DEVICE列表
 －－－－－－－－－－－－－－－－－*/
-(NSString*)queryDevicelistForOuterRoom{
    
    FMResultSet * fmResultSet = [self.dataBase executeQuery:@MP_GetDevicelistForOuterRoom];
    
    NSArray* resultList = [self getResultlistForFMSet:fmResultSet];
    
    return [self buildXMLForResultSet:resultList];
}

-(NSArray*)queryAllList{
    return nil;
}

#pragma mark -



#pragma mark - buildXML
/*－－－－－－－－－－－－－－－－－
 根据FMRESULT 生成ARRAY
 －－－－－－－－－－－－－－－－－*/
-(NSArray*)getResultlistForFMSet:(FMResultSet*)fmResultSet{
    NSMutableArray* resultList = [NSMutableArray array];
    while ([fmResultSet next]) {
        SGDataBaseRowItem* resultItem = [[SGDataBaseRowItem alloc] init];
        
        for(int i = 0; i < [fmResultSet columnCount];i++){
            [resultItem setValue:[fmResultSet stringForColumn:[fmResultSet columnNameForIndex:i]]
                          forKey:[fmResultSet columnNameForIndex:i]];}
        [resultList addObject:resultItem];}
    return resultList;
}




/*－－－－－－－－－－－－－－－－－
 根据RESULT LIST 生成XML
 －－－－－－－－－－－－－－－－－*/
-(NSString*)buildXMLForResultSet:(NSArray*)resultList{
    
    __block NSPredicate* predicate;
    NSMutableString* xMLString = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><root>"];
    
    [[[resultList valueForKeyPath:@"@distinctUnionOfObjects.roomnumber"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        predicate = [NSPredicate predicateWithFormat:@"roomnumber == %@",
                     (NSString*)obj];
        NSArray* firstClasslist = [resultList filteredArrayUsingPredicate:predicate];
        [xMLString appendString:[NSString stringWithFormat:@"<room id=\"%@\" name=\"%@\">",
                                 [(SGDataBaseRowItem*)[firstClasslist objectAtIndex:0] roomid],
                                 [(SGDataBaseRowItem*)[firstClasslist objectAtIndex:0] roomname]]];
        
        [[[firstClasslist valueForKeyPath:@"@distinctUnionOfObjects.cubiclenumber"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            predicate = [NSPredicate predicateWithFormat:@"cubiclenumber == %@",
                         (NSString*)obj];
            NSArray* secondClasslist = [firstClasslist filteredArrayUsingPredicate:predicate];
            [xMLString appendString:[NSString stringWithFormat:@"<cubicle id=\"%@\" name=\"%@\">",
                                     [(SGDataBaseRowItem*)[secondClasslist objectAtIndex:0] cubicleid],
                                     [(SGDataBaseRowItem*)[secondClasslist objectAtIndex:0] cubiclename]]];
            
            [secondClasslist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [xMLString appendString:@"<device><deviceid>"];
                [xMLString appendString:[(SGDataBaseRowItem*)obj deviceid]];
                [xMLString appendString:@"</deviceid><devicename>"];
                [xMLString appendString:[(SGDataBaseRowItem*)obj devicename]];
                [xMLString appendString:@"</devicename></device>"];}];
                [xMLString appendString:@"</cubicle>"];}];
                [xMLString appendString:@"</room>"];}];
                [xMLString appendString:@"</root>"];
    
    return xMLString;
}


/*－－－－－－－－－－－－－－－－－
 根据RESULT LIST 生成JSON
 －－－－－－－－－－－－－－－－－*/
-(NSString*)buildJSONForResultSet:(NSArray*)resultList{
    
    __block NSPredicate* predicate;
    NSMutableString* jsonString = [NSMutableString stringWithString:@"{\"Data\":["];
    
    NSArray* resultListArray = [resultList valueForKeyPath:@"@distinctUnionOfObjects.roomnumber"];
    [[resultListArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        predicate = [NSPredicate predicateWithFormat:@"roomnumber == %@",
                     (NSString*)obj];
        NSArray* firstClasslist = [resultList filteredArrayUsingPredicate:predicate];
        [jsonString appendString:[NSString stringWithFormat:@"{\"roomid\":\"%@\",\"roomname\":\"%@\",\"cubicles\":[",
                                  [(SGDataBaseRowItem*)[firstClasslist objectAtIndex:0] roomid],
                                  [(SGDataBaseRowItem*)[firstClasslist objectAtIndex:0] roomname]]];
        
        
        NSArray* firstClasslistArray = [firstClasslist valueForKeyPath:@"@distinctUnionOfObjects.cubiclenumber"];
        [[firstClasslistArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            predicate = [NSPredicate predicateWithFormat:@"cubiclenumber == %@",
                         (NSString*)obj];
            NSArray* secondClasslist = [firstClasslist filteredArrayUsingPredicate:predicate];
            [jsonString appendString:[NSString stringWithFormat:@"{\"cubicleid\":\"%@\",\"cubiclename\":\"%@\",\"devices\":[",
                                      [(SGDataBaseRowItem*)[secondClasslist objectAtIndex:0] cubicleid],
                                      [(SGDataBaseRowItem*)[secondClasslist objectAtIndex:0] cubiclename]]];
            
            [secondClasslist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [jsonString appendString:@"{\"deviceid\":\""];
                [jsonString appendString:[(SGDataBaseRowItem*)obj deviceid]];
                [jsonString appendString:@"\",\"devicename\":\""];
                [jsonString appendString:[(SGDataBaseRowItem*)obj devicename]];
                [jsonString appendString:@"\"}"];
                
                if (idx!=[secondClasslist count]-1)     {[jsonString appendString:@","];
                }else{[jsonString appendString:@"]}"];}}];
            
                if (idx!=[firstClasslistArray count]-1) {[jsonString appendString:@","];
                }else{[jsonString appendString:@"]"];}}];
        
                if (idx!=[resultListArray count]-1)     {[jsonString appendString:@","];
                }else{[jsonString appendString:@"}"];}}];
    
    [jsonString appendString:@"]}"];
    return jsonString;
}
#pragma mark -

@end

