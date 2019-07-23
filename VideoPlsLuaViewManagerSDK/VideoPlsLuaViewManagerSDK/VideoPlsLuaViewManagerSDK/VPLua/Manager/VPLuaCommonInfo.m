//
//  VPLuaCommonInfo.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/8/24.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaCommonInfo.h"
#import "VPUPIPAddressUtil.h"
#import "VPUPDeviceUtil.h"
#import "VPUPNetworkReachabilityManager.h"
#import "VPUPGeneralInfo.h"

NSString *const VPLuaRequestPublicKey = @"inekcndsaqwertyi";//@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCBlxdQe+B3bCL3+km31ABB23sXUB0A3owEBodWlPeikgfEw/JfbZXuiKFoIqAbjmzpDvAE4PYAU4wBjE01wRNLg4KLJyorGLkx6I6gHE67mZqLryepxZdwd8MwzQCsoN3+PAQYUJz54Flc6e14l/LVDyggw/HN/OD9iXC027IVDQIDAQAB";

static NSMutableDictionary *_commonParam;

@implementation VPLuaCommonInfo

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
        NSDate *datenow = [NSDate date];
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
        [_commonParam setObject:timeSp forKey:@"SYSTEM_TIME"];
    });
    [_commonParam setObject:[[VPUPNetworkReachabilityManager sharedManager] currentReachabilityStatusString] forKey:@"NETWORK"];
    [_commonParam setObject:[VPUPIPAddressUtil currentIpAddress] forKey:@"IP"];
    return [_commonParam copy];
}

@end
