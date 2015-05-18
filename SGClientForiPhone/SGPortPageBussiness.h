//
//  SGPortPageBussiness.h
//  SGClient
//
//  Created by JY on 14-6-14.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import "SGBaseBussiness.h"
#import "SGSelectViewController.h"

typedef void(^finishBlock)(NSArray* result);



@interface SGPortPageBussiness : SGBaseBussiness<SGPortPageBussinessDelegate>

+(SGPortPageBussiness*)sharedSGPortPageBussiness;

-(void)queryResultWithType:(NSInteger)type portId:(NSString*)portId complete:(finishBlock)finish;


@property (nonatomic,strong) UIViewController* controller;
@property (nonatomic,assign) BOOL multiFlag;

@end
