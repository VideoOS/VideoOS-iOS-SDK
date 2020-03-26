//
//  VPUPCommonInfo.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096-videojj on 2019/9/6.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPUPCommonInfo.h"
#import "VPUPIPAddressUtil.h"
#import "VPUPDeviceUtil.h"
#import "VPUPNetworkReachabilityManager.h"
#import "VPUPGeneralInfo.h"
#import <UIKit/UIKit.h>

static NSMutableDictionary *_commonParam;

@implementation VPUPCommonInfo

+ (NSMutableDictionary *)commonParam {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _commonParam = [NSMutableDictionary dictionaryWithCapacity:0];
        [_commonParam setObject:[VPUPGeneralInfo appName] forKey:@"APP_NAME"];
        [_commonParam setObject:[VPUPGeneralInfo appBundleID] forKey:@"BUNDLE_ID"];
        //os 0:未知 1:Android 2:iOS 3:Windows Phone
        [_commonParam setObject:@"2" forKey:@"OS_TYPE"];
        [_commonParam setObject:[NSString stringWithFormat:@"%d", [VPUPDeviceUtil phoneCarrierType]] forKey:@"CARRIER"];
        [_commonParam setObject:[VPUPGeneralInfo appBundleVersion] forKey:@"VERSION"];
        [_commonParam setObject:[VPUPGeneralInfo platformSDKVersion] forKey:@"SDK_VERSION"];
        [_commonParam setObject:[VPUPGeneralInfo appDeviceSystemVersion] forKey:@"OS_VERSION"];
        [_commonParam setObject:[VPUPGeneralInfo userIdentity] forKey:@"UD_ID"];
        [_commonParam setObject:[VPUPGeneralInfo IDFA] forKey:@"IDFA"];
        [_commonParam setObject:[VPUPGeneralInfo appDeviceLanguage] forKey:@"LANGUAGE"];
        [_commonParam setObject:[VPUPGeneralInfo iPhoneDeviceType] forKey:@"PHONE_MODEL"];
        [_commonParam setObject:@"Apple" forKey:@"PHONE_PROVIDER"];
        int maxSize = (int)MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) * [UIScreen mainScreen].scale;
        int minSize = (int)MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) * [UIScreen mainScreen].scale;
        [_commonParam setObject:[NSString stringWithFormat:@"%d", maxSize] forKey:@"PHONE_HEIGHT"];
        [_commonParam setObject:[NSString stringWithFormat:@"%d", minSize] forKey:@"PHONE_WIDTH"];
        [_commonParam setObject:[UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"2" : @"1" forKey:@"DEVICE_TYPE"];
    });
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    [_commonParam setObject:timeSp forKey:@"SYSTEM_TIME"];
    [_commonParam setObject:[NSString stringWithFormat:@"%ld", [[VPUPNetworkReachabilityManager sharedManager] currentReachabilityStatus]] forKey:@"NETWORK"];
    [_commonParam setObject:[VPUPIPAddressUtil currentIpAddress] forKey:@"IP"];
    [_commonParam setObject:[VPUPGeneralInfo mainVPSDKAppKey] forKey:@"APP_KEY"];
    return [_commonParam copy];
}

@end
