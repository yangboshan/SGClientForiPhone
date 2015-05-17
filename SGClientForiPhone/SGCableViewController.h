//
//  SGCableViewController.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/17.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseDrawViewController.h"

@interface SGCableViewController : SGBaseDrawViewController

@property (nonatomic,strong) NSDictionary *cubicleData;

@property (nonatomic,assign) NSInteger scannedCubicleId;
@property (nonatomic,assign) NSInteger scannedCableId;

-(instancetype)initWithCubicleData:(NSDictionary*)cubicleData withCubicleId:(NSInteger)cubicleId withCableId:(NSInteger)cableId;



@end
