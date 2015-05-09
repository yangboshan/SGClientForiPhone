//
//  AppDelegate.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "AppDelegate.h"
#import "SGHelper.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    sleep(3);
    
    UITabBarController* tabBar = [UITabBarController new];
    
    UINavigationController* nav1 = [[UINavigationController alloc] initWithRootViewController:[NSClassFromString(@"SGCubicleViewController") new]];
    nav1.tabBarItem.image = [UIImage imageNamed:@"tabbar_icon1_selected"];
    nav1.tabBarItem.title = @"屏柜";
    
    UINavigationController* nav2 = [[UINavigationController alloc] initWithRootViewController:[NSClassFromString(@"SGScanViewController") new]];
    nav2.tabBarItem.image = [UIImage imageNamed:@"tabbar_icon2_selected"];
    nav2.tabBarItem.title = @"扫描";

    
    UINavigationController* nav3 = [[UINavigationController alloc] initWithRootViewController:[NSClassFromString(@"SGSettingViewController") new]];
    nav3.tabBarItem.image = [UIImage imageNamed:@"tabbar_icon3_selected"];
    nav3.tabBarItem.title = @"设置";

    
    tabBar.viewControllers = @[nav1,nav2,nav3];
    
    self.window.rootViewController = tabBar;
    [self.window makeKeyAndVisible];
    
    [self initialSetup];

    
    return YES;
}


- (void)initialSetup{
    
    [self customizeAppearance];
 
}

- (void)customizeAppearance{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:NavBarColorAlpha(0.9)] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:1.0],NSFontAttributeName:Lantinghei(22.0)}];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UIBarButtonItem appearance].tintColor = [UIColor whiteColor];
    
    
    [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:RGBA(247, 247, 247,0.9)]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:RGB(146, 146, 146),NSFontAttributeName:Lantinghei(10.0)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:NavBarColorAlpha(1.0),NSFontAttributeName:Lantinghei(10.0)} forState:UIControlStateSelected];
    [UITabBar appearance].tintColor = NavBarColorAlpha(1.0);

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
