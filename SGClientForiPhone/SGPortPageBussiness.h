//
//  SGPortPageBussiness.h
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseBussiness.h"
#import "SGSelectViewController.h"

typedef void(^finishBlock)(NSArray* result);



@interface SGPortPageBussiness : SGBaseBussiness<SGPortPageBussinessDelegate>

+(SGPortPageBussiness*)sharedSGPortPageBussiness;


-(void)queryResultWithType:(NSInteger)type portId:(NSString*)portId complete:(finishBlock)finish;
-(NSString*)queryPortIdByDeviceName:(NSString*)deviceName boardPostion:(NSString*)boardPostion portName:(NSString*)portName;

@property (nonatomic,weak) UIViewController* controller;
@property (nonatomic,assign) BOOL multiFlag;
@property (nonatomic,strong) NSString* cableType;

@end
