//
//  SGFiberViewController.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/17.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseDrawViewController.h"
#import "SGGenerateCubicleSvg.h"

@interface SGFiberViewController : SGBaseDrawViewController

@property(nonatomic,strong) NSString* cubicleId;
@property(nonatomic,strong) NSString *cableId;
@property(nonatomic,strong) NSString *cableName;
@property(nonatomic,assign) NSInteger cableType;

@property (nonatomic,strong) NSArray* type0listSorted;
@property (nonatomic,strong) NSArray* type1list;
@property (nonatomic,strong) NSArray* type2list;
@property (nonatomic,strong) NSArray* mergedCubicles;
@property (nonatomic,strong) NSDictionary* cubicleData;

@end
