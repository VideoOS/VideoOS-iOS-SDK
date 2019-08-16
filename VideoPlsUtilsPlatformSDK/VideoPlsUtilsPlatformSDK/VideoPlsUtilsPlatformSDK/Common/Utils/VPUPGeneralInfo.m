//
//  VPUPGeneralInfo.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPGeneralInfo.h"
#import <UIKit/UIKit.h>
#import "VPUPSDKInfo.h"
#import "VPUPServerUTCDate.h"
#import "VPUPRandomUtil.h"
#import "VPUPNotificationCenter.h"
#import <sys/utsname.h>

NSString * const VideoPlsUtilsPlatformSDKVersion = @"1.3.2";
NSString * const VPUPGeneralInfoSDKChangedNotification = @"VPUPGeneralInfoSDKChangedNotification";

static NSString *IDFA = nil;

static VPUPSDKInfo *_currentSDKInfo = nil;
static NSString *_userIdentity = nil;

@implementation VPUPGeneralInfo

+ (void)setSDKInfo:(VPUPSDKInfo *)sdkInfo {
    [VPUPServerUTCDate date];
    [self userIdentity];
    if(sdkInfo && _currentSDKInfo != sdkInfo) {
        //确保不重复设置sdkInfo
        if(_currentSDKInfo) {
            [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPGeneralInfoSDKChangedNotification object:nil];
        }
        _currentSDKInfo = sdkInfo;
    }
}

+ (VPUPSDKInfo *)getCurrentSDKInfo {
    return _currentSDKInfo;
}

+ (BOOL)isEqualToSDKInfo:(VPUPSDKInfo *)sdkInfo {
    if(!_currentSDKInfo) {
        return NO;
    }
    return (_currentSDKInfo == sdkInfo);
}


+ (NSString *)appBundleID {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)appBundleName {
    return [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey];
}

+ (NSString *)appBundleVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey];
}


+ (NSString *)appDeviceName {
    return [UIDevice currentDevice].name;
}

+ (NSString *)appDeviceModel {
    return [UIDevice currentDevice].model;
}

+ (NSString *)appDeviceSystemName {
    return [UIDevice currentDevice].systemName;
}

+ (NSString *)appDeviceSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)appDeviceLanguage {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
}

+ (NSString *)iPhoneDeviceType {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    return platform;
}


+ (NSString *)platformSDKVersion {
    return VideoPlsUtilsPlatformSDKVersion;
}

+ (NSString *)mainVPSDKName {
    if(_currentSDKInfo) {
        return _currentSDKInfo.mainVPSDKName;
    }
    return @"VideoOS";
}

+ (NSString *)mainVPSDKVersion {
    if(_currentSDKInfo) {
        return _currentSDKInfo.mainVPSDKVersion;
    }
    return nil;
}

+ (NSString *)mainVPSDKServiceVersion {
    if(_currentSDKInfo) {
        return _currentSDKInfo.mainVPSDKServiceVersion;
    }
    return nil;
}

+ (NSString *)mainVPSDKAppKey {
    if(_currentSDKInfo) {
        return _currentSDKInfo.mainVPSDKAppKey;
    }
    return nil;
}

+ (NSString *)mainVPSDKPlatformID {
    if(_currentSDKInfo) {
        return _currentSDKInfo.mainVPSDKPlatformID;
    }
    return nil;
}

+ (NSString *)IDFA {
    return IDFA;
}

+ (void)setIDFA:(NSString *)idfaString {
    if(idfaString && ![idfaString isEqualToString:@""]) {
        IDFA = idfaString;
    }
    else {
        IDFA = @"00000000-0000-0000-0000-000000000000";
    }
}

+ (NSString *)userIdentity {
    if(_userIdentity) {
        return _userIdentity;
    }
    
    NSString *identity = [[NSUserDefaults standardUserDefaults] objectForKey:@"VPUPUserIdentity"];
    if(identity) {
        _userIdentity = identity;
        return _userIdentity;
    }
    
    NSString *randomString = [VPUPRandomUtil randomMKTempStringByLength:8];
    
    NSTimeInterval timeStamp = [VPUPServerUTCDate currentUnixTimeMillisecond];
    NSString *timeStapStr = [NSString stringWithFormat:@"%.0f",timeStamp];
    identity = [NSString stringWithFormat:@"%@%@",timeStapStr,randomString];
    [[NSUserDefaults standardUserDefaults] setValue:identity forKey:@"VPUPUserIdentity"];
    _userIdentity = identity;
    return _userIdentity;
}

+ (void)setUserIdentity:(NSString *)identity {
    if (identity && identity.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:identity forKey:@"VPUPUserIdentity"];
        _userIdentity = identity;
    }
}

@end
