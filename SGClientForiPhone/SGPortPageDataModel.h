//
//  SGPortPageDataModel.h
//  SGClient
//
//  Created by yangboshan on 14-8-4.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGPortPageDataModel : NSObject

@property (nonatomic,strong) NSString* type; // 0  OR  1
@property (nonatomic,strong) NSString* mainDeviceId; //主设备ID
@property (nonatomic,strong) NSString* mainDeviceName;// 主设备名称
@property (nonatomic,strong) NSString* mainPortId;//主端口号

//@property (nonatomic,strong) NSString* sendPort;     //右侧发送端口
//@property (nonatomic,strong) NSString* sendPortCnted;//右侧发送目的端口
//@property (nonatomic,strong) NSString* recvPort;     //左侧接收端口
//@property (nonatomic,strong) NSString* recvPortCnted;//左侧接收源端口


@property (nonatomic,strong) NSMutableArray* leftChilds; //左边连接list
@property (nonatomic,strong) NSMutableArray* rightChilds; //右边连接list

@end

@interface SGPortPageChildData : NSObject

@property (nonatomic,strong) NSString* cntedDeviceId; //与之连接的设备ID
@property (nonatomic,strong) NSString* cntedDeviceName;//与之连接的设备名称

@property (nonatomic,strong) NSMutableArray* cntedProDes;//与之连接的prodes list
@property (nonatomic,strong) NSMutableArray* mainProDes; //主prodes list

@property (nonatomic,strong) NSString* centerPortId;
@property (nonatomic,strong) NSString* cntedPortId;


@end
