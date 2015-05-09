//
//  SGUtility.h
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "FMDatabase.h"

@interface SGUtility : NSObject

+ (NSURL *)applicationDocumentsDirectory;
+ (NSString *)dataBasePath;

+ (NSArray*)getResultlistForFMSet:(FMResultSet*)fmResultSet
                       withEntity:(NSString*)entity;

+(NSString*)getCurrentDB;
+(void)setCurrentDB:(NSString*)db;

+(BOOL)getDBChangeFlag;
+(void)restoreDBChangeFlag;
@end
