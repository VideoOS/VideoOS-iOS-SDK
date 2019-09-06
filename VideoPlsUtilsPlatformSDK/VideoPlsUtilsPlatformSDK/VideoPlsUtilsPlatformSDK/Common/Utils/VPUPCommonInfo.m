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

static NSMutableDictionary *_commonParam;

@implementation VPUPCommonInfo

+ (NSMutableDictionary *)commonParam {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _commonParam = [NSMutableDictionary dictionaryWithCapacity:0];
        [_commonParam setObject:[VPUPGeneralInfo appBundleVersion] forKey:@"VERSION"];
        [_commonParam setObject:[VPUPGeneralInfo platformSDKVersion] forKey:@"SDK_VERSION"];
        [_commonParam setObject:[VPUPGeneralInfo appDeviceSystemVersion] forKey:@"OS_VERSION"];
        [_commonParam setObject:[VPUPGeneralInfo userIdentity] forKey:@"UD_ID"];
        [_commonParam setObject:[VPUPGeneralInfo IDFA] forKey:@"IDFA"];
        [_commonParam setObject:[VPUPGeneralInfo appDeviceLanguage] forKey:@"LANGUAGE"];
        [_commonParam setObject:[VPUPGeneralInfo iPhoneDeviceType] forKey:@"PHONE_MODEL"];
        [_commonParam setObject:[VPUPDeviceUtil phoneCarrier] forKey:@"PHONE_PROVIDER"];
    });
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    [_commonParam setObject:timeSp forKey:@"SYSTEM_TIME"];
    [_commonParam setObject:[[VPUPNetworkReachabilityManager sharedManager] currentReachabilityStatusString] forKey:@"NETWORK"];
    [_commonParam setObject:[VPUPIPAddressUtil currentIpAddress] forKey:@"IP"];
    [_commonParam setObject:[VPUPGeneralInfo mainVPSDKAppKey] forKey:@"APP_KEY"];
    return [_commonParam copy];
}

@end
