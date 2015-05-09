//
//  SGDataBase.h
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGGCDSingleton.h"
#import "FMDatabase.h"
#import "SGUtility.h"

@interface SGDataBase : NSObject

+(SGDataBase*)sharedSGDataBase;

-(FMDatabase*)dataBase;

@end


