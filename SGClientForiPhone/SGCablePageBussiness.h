//
//  SGCablePageBussiness.h
//  SGClient
//
//  Created by JY on 14-5-19.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import "SGBaseBussiness.h"

@class SGCPDataItem;

@interface SGCablePageBussiness : SGBaseBussiness

+(SGCablePageBussiness*)sharedSGCablePageBussiness;

/*－－－－－－－－－－－－－－－－－
 根据CubicleId获取光缆 尾缆 跳缆的连接
 －－－－－－－－－－－－－－－－－*/
-(NSDictionary*)queryCablelistWithCubicleId:(NSInteger)cubicleId;

-(SGCPDataItem*)queryCalbleInfoWithCableId:(NSInteger)cableId;

-(NSInteger)queryFiberCountWithCableId:(NSString*)cableId;
@end


@interface SGCPConnectionItem : NSObject

@property(nonatomic,strong) NSString *use_odf1;
@property(nonatomic,strong) NSString *use_odf2;
@property(nonatomic,strong) NSString *connection_id;
@property(nonatomic,strong) NSString *cubicle1_id;
@property(nonatomic,strong) NSString *cubicle2_id;
@property(nonatomic,strong) NSString *passcubicle1_id;
@property(nonatomic,strong) NSString *passcubicle2_id;

@end

@interface SGCPDataItem : NSObject

@property(nonatomic,strong) NSString *cable_id;
@property(nonatomic,strong) NSString *cable_name;
@property(nonatomic,strong) NSString *cable_type;
@property(nonatomic,strong) NSString *cubicle_id;
@property(nonatomic,strong) NSString *cubicle_name;
@property(nonatomic,strong) NSString *drawFlag;


-(id)initWithCableId:(NSString*)cableId
       withCableName:(NSString*)cableName
       withCableType:(NSString*)cableType
       withCubicleId:(NSString*)cubicleId
     withCubicleName:(NSString*)cubicleName
        withDrawFlag:(NSString*)drawFlag;

@end

@interface SGCPDataBaseRowItem : NSObject

@property(nonatomic,strong) NSString *cable_id;
@property(nonatomic,strong) NSString *cable_name;
@property(nonatomic,strong) NSString *cable_type;
@property(nonatomic,strong) NSString *cubicle1_id;
@property(nonatomic,strong) NSString *cubicle1_name;
@property(nonatomic,strong) NSString *cubicle2_id;
@property(nonatomic,strong) NSString *cubicle2_name;
@end