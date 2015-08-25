//
//  SGEntity.h
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGEntity : NSObject

@end

@interface SGInfoSetItem : NSObject

@property(nonatomic,strong) NSString* infoset_id;
@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSString* description;
@property(nonatomic,strong) NSString* type;
@property(nonatomic,strong) NSString* group;
@property(nonatomic,strong) NSString* txiedport_id;
@property(nonatomic,strong) NSString* switch1_rxport_id;
@property(nonatomic,strong) NSString* switch1_txport_id;
@property(nonatomic,strong) NSString* switch2_rxport_id;
@property(nonatomic,strong) NSString* switch2_txport_id;
@property(nonatomic,strong) NSString* switch3_rxport_id;
@property(nonatomic,strong) NSString* switch3_txport_id;


@property(nonatomic,strong) NSString* switch4_rxport_id;
@property(nonatomic,strong) NSString* switch4_txport_id;


@property(nonatomic,strong) NSString* rxiedport_id;
@property(nonatomic,strong) NSString* rxied_id;
@property(nonatomic,strong) NSString* txied_id;

@property(nonatomic,strong) NSString* switch1_id;
@property(nonatomic,strong) NSString* switch2_id;
@property(nonatomic,strong) NSString* switch3_id;
@property(nonatomic,strong) NSString* switch4_id;



@end

@interface SGVterminal : NSObject
@property(nonatomic,strong) NSString* vterminal_id;
@property(nonatomic,strong) NSString* device_id;
@property(nonatomic,strong) NSString* type;
@property(nonatomic,strong) NSString* direction;
@property(nonatomic,strong) NSString* vterminal_no;
@property(nonatomic,strong) NSString* pro_desc;
@end

@interface SGVterminalConnection : NSObject
@property(nonatomic,strong) NSString* txvterminal_id;
@property(nonatomic,strong) NSString* rxvterminal_id;
@property(nonatomic,strong) NSString* straight;
@end

@interface SGPortInfo : NSObject
@property(nonatomic,strong) NSString* type;
@property(nonatomic,strong) NSString* group;
@property(nonatomic,strong) NSString* port_id;
@property(nonatomic,strong) NSString* board_id;
@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSString* direction;
@end

@interface SGDeviceInfo : NSObject
@property(nonatomic,strong) NSString* description;
@end
