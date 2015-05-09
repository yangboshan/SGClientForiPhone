//
//  SGBaseBussiness.h
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGGCDSingleton.h"
#import "SGDataBase.h"
#import "FMDatabase.h"
#import "SGEntity.h"

@interface SGBaseBussiness : NSObject

@property (nonatomic,strong) FMDatabase* dataBase;

@end


