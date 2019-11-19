//
//  AppDelegate.m
//  VPInterfaceViewDemo
//
//  Created by 李少帅 on 2017/7/10.
//  Copyright © 2017年 李少帅. All rights reserved.
//

#import "AppDelegate.h"
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>
#import <UMMobClick/MobClick.h>
#import <Bugly/Bugly.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>

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

    
    //    [VPIConfigSDK setAppKey:@"550ec7d2-6cb0-4f46-b2df-2a1505ec82d8" appSecret:@"d0bf7873f7fa42a6"];
    //    [VPIConfigSDK setAppKey:@"c21d0393-5946-4104-b291-6334147cc45d" appSecret:@"36b1e5f6d94441f0"];
    //    [VPIConfigSDK setAppKey:@"bd2b301d-36d4-45ee-8762-db03672c23e0" appSecret:@"2a258aa1c44e41d5"];
    //    [VPIConfigSDK setAppKey:@"ca39f6b6-4626-4036-8518-59387636da60" appSecret:@"8e9db127a2644fba"];
    //    [VPIConfigSDK setAppKey:@"93db5ef3-7fbc-485a-97b0-fc9f4e7209f5" appSecret:@"74f251d40a49468a"];
    //    [VPIConfigSDK setAppKey:@"d1af1f73-7b60-4141-8261-2d9ad20b2a23" appSecret:@"97154eab13424013"];
    //    [VPIConfigSDK setAppKey:@"7a741182-c30e-4edf-9eaa-ae8974093214" appSecret:@"8940b66d7052437b"];
//    [VPIConfigSDK setAppKey:@"73d5a8f8-3682-4080-ad7c-996c4e19fc1e" appSecret:@"c276b70aba84491a"];
    
    [VPIConfigSDK setAppKey:@"66c9bafa-abd0-4aa9-8066-3deaf9dc7f71" appSecret:@"bcfee675bca844bd"];
    
    //    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateDevelop];
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateTest];
    //    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateOnline];
    
#ifdef VIDEOOS_DEVAPP
        NSLog(@"this current tag is VIDEOOS_DEVAPP");
        application.statusBarStyle = UIStatusBarStyleLightContent;
        [VPIConfigSDK setAppDevEnable:true];
#else
        NSLog(@"this current tag is VPInterfaceControllerDemo");
#endif
    
    
    
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
