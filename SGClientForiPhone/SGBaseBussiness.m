//
//  SGBaseBussiness.m
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseBussiness.h"
#import "SGAPPConfig.h"

@implementation SGBaseBussiness

#pragma mark - init

-(id)init{
    if (self = [super init]) {
    }
    return self;
}

-(FMDatabase*)dataBase{

    return [[SGDataBase sharedSGDataBase] dataBase];
}

#pragma mark -

@end
