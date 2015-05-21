//
//  SGAPPConfig.m
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGAPPConfig.h"
#import "SGUtility.h"


@interface SGAPPConfig()

@property(nonatomic,strong) NSUserDefaults *userDefaults;
@end

@implementation SGAPPConfig

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SGAPPConfig)

static NSString *SETTING_FIRST_TIME_RUN = @"SETTING_FIRST_TIME_RUN";

/*－－－－－－－－－－－－－－－－－
 配置
 检测第一次运行配置环境
 复制SQLite
 初始化变量
 －－－－－－－－－－－－－－－－－*/
- (id)init
{
    if (self = [super init])
    {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
 
        /*－－－－－－－－－－－－－－－
         APP是否初次运行 做一些配置
         －－－－－－－－－－－－－－－*/
        NSObject *setting = [self.userDefaults objectForKey:SETTING_FIRST_TIME_RUN];
        if (setting == nil)
        {
            [self.userDefaults setObject:[NSNumber numberWithInt:1] forKey:SETTING_FIRST_TIME_RUN];
            [SGUtility setCurrentDB:NSLocalizedString(@"DB_NAME", nil)];
            /*－－－－－－－－－－－－－－－－－－－－－－－－－－－
             初次运行判断沙盒下是否存在Sqlite 文件，如无则复制之。
  
             －－－－－－－－－－－－－－－－－－－－－－－－－－－*/
            if (![[NSFileManager defaultManager] fileExistsAtPath:[SGUtility dataBasePath]]) {
                
                NSError *error;
                
                NSString *srcPath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"DB_NAME", nil)
                                                                    ofType:nil];
                
                if(![[NSFileManager defaultManager] copyItemAtPath:srcPath
                                                            toPath:[SGUtility dataBasePath]
                                                             error:&error]){
                    NSLog(@"%@",[error description]);
                }
            }
            [self.userDefaults synchronize];
        }
    }
    return self;
}

@end
