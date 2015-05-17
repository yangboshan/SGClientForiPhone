//
//  SGFiberPageBussiness.h
//  SGClient
//
//  Created by JY on 14-6-3.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import "SGBaseBussiness.h"

@interface SGFiberPageBussiness : SGBaseBussiness

/*－－－－－－－－－－－－－－－－－
 根据CableId 获取纤芯信息列表
 －－－－－－－－－－－－－－－－－*/
-(NSArray*)queryFiberInfoWithCableId:(NSInteger)cableId withCubicleId:(NSInteger)cubicleId;

+(SGFiberPageBussiness*)sharedSGFiberPageBussiness;

@end

@interface SGFiberItem : NSObject

@property(nonatomic,strong) NSString* fiber_id;
@property(nonatomic,strong) NSString* cable_id;
@property(nonatomic,strong) NSString* port1_id;
@property(nonatomic,strong) NSString* port2_id;
@property(nonatomic,strong) NSString* index;
@property(nonatomic,strong) NSString* fiber_color;
@property(nonatomic,strong) NSString* pipe_color;
@property(nonatomic,strong) NSString* reserve;

@end


//@interface SGInfoSetItem : NSObject
//
//@property(nonatomic,strong) NSString* infoset_id;
//@property(nonatomic,strong) NSString* name;
//@property(nonatomic,strong) NSString* description;
//@property(nonatomic,strong) NSString* type;
//@property(nonatomic,strong) NSString* group;
//@property(nonatomic,strong) NSString* txiedport_id;
//@property(nonatomic,strong) NSString* switch1_rxport_id;
//@property(nonatomic,strong) NSString* switch1_txport_id;
//@property(nonatomic,strong) NSString* switch2_rxport_id;
//@property(nonatomic,strong) NSString* switch2_txport_id;
//@property(nonatomic,strong) NSString* switch3_rxport_id;
//@property(nonatomic,strong) NSString* switch3_txport_id;
//@property(nonatomic,strong) NSString* rxiedport_id;
//
//@end

@interface SGResult : NSObject

@property(nonatomic,strong) NSString* type1;
@property(nonatomic,strong) NSString* device1;
@property(nonatomic,strong) NSString* port1;
@property(nonatomic,strong) NSString* tx1;
@property(nonatomic,strong) NSString* odf1;
@property(nonatomic,strong) NSString* middle;
@property(nonatomic,strong) NSString* type2;
@property(nonatomic,strong) NSString* device2;
@property(nonatomic,strong) NSString* port2;
@property(nonatomic,strong) NSString* tx2;
@property(nonatomic,strong) NSString* odf2;

@property(nonatomic,strong) NSString* portId1;
@property(nonatomic,strong) NSString* portId2;

@end
