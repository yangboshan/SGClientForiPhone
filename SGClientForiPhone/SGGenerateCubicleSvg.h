//
//  SGGenerateCubicleSvg.h
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGMacro.h"

@interface SGGenerateCubicleSvg : NSObject

@property (nonatomic,strong) NSArray* type0listSorted;
@property (nonatomic,strong) NSArray* type1list;
@property (nonatomic,strong) NSArray* type2list;
@property (nonatomic,strong) NSArray* mergedCubicles;
@property (nonatomic,strong) NSDictionary* cubicleData;
@property (nonatomic) BOOL isForFiberPage;

-(NSString*)getCubicleSvgStr;

@end

@interface SGCableTmpItem : NSObject

@property (nonatomic,strong) NSString* cableId;
@property (nonatomic,strong) NSString* cableName;
@property (nonatomic,strong) NSString* cubicleId;
@property (nonatomic,strong) NSString* cubicleName;
@property (nonatomic,assign) NSUInteger count;
@end