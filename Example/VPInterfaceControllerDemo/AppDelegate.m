//
//  AppDelegate.m
//  VPInterfaceViewDemo
//
//  Created by 李少帅 on 2017/7/10.
//  Copyright © 2017年 李少帅. All rights reserved.
//

#import "AppDelegate.h"
#import <VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>
#import <UMMobClick/MobClick.h>
#import <Bugly/Bugly.h>
#import <VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Bugly startWithAppId:@"6852325c36"];
    UMConfigInstance.appKey = @"590b0212f5ade40dae001161";
    [MobClick startWithConfigure:UMConfigInstance];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    version = [version stringByAppendingString:@"_"];
    version = [version stringByAppendingString: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *) kCFBundleVersionKey]];
    [MobClick setAppVersion:version];
    [VPIConfigSDK setAppKey:@"e3095ad4-5927-40eb-b6e5-a43b7f1e966b" appSecret:@"b28a1f82e6c147d8"];
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateTest];
    [VPIConfigSDK initSDK];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
