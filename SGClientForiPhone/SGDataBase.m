//
//  SGDataBase.m
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGDataBase.h"
#import "SGAPPConfig.h"


@implementation SGDataBase

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGDataBase)

static FMDatabase *db = nil;

#pragma mark - init dataBase

-(FMDatabase*)dataBase
{
    if (db&&![SGUtility getDBChangeFlag]) {
        return db;
    }
    db = [FMDatabase databaseWithPath:[SGUtility dataBasePath]];
    
    if (![db open]) {
        NSLog(@"failed open db!");
        
        return nil;
    }
    
    [SGUtility restoreDBChangeFlag];
    return db;
}
@end
