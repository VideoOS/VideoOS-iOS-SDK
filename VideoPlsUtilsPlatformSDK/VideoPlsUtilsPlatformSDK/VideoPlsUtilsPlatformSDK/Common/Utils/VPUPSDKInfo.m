//
//  VPUPSDKInfo.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPSDKInfo.h"
#import <UIKit/UIKit.h>
#import "VPUPGeneralInfo.h"
#import "VPUPServerUTCDate.h"

static VPUPSDKInfo *sharedInfo = nil;

@implementation VPUPSDKInfo

- (VPUPSDKInfo *)initSDKInfoWithSDKType:(VPUPMainSDKType)sdkType
                             SDKVersion:(NSString *)sdkVersion
                                 appKey:(NSString *)appKey {
    return [self initSDKInfoWithSDKType:sdkType
                             SDKVersion:sdkVersion
                                 appKey:appKey
                             enableWebP:NO];
}

- (VPUPSDKInfo *)initSDKInfoWithSDKType:(VPUPMainSDKType)sdkType
                             SDKVersion:(NSString *)sdkVersion
                                 appKey:(NSString *)appKey
                             enableWebP:(BOOL)webP {
    self = [super init];
    if(self) {
        [self setMainSDKNameByType:sdkType];
        [self setMainVPSDKVersion:sdkVersion];
        [self setMainVPSDKAppKey:appKey];
        [self setEnableWebP:webP];
    }
    return self;
}

- (void)setMainSDKNameByType:(VPUPMainSDKType)sdkType {
    _mainVPSDKType = sdkType;
    //异常值默认为0, VideoOS
    if (_mainVPSDKType > 2) {
        _mainVPSDKType = 0;
    }
    NSString *sdkName = @"";
    switch (_mainVPSDKType) {
        case VPUPMainSDKTypeVideoOS:
            sdkName = @"VideoOS";
            break;
        case VPUPMainSDKTypeLiveOS:
            sdkName = @"LiveOS";
            break;
        case VPUPMainSDKTypeVideojj:
            sdkName = @"Videojj";
            break;
        default:
            break;
    }
    [self setMainSDKName:sdkName];
}

- (void)setMainSDKName:(NSString *)sdkName {
    if(sdkName) {
        _mainVPSDKName = sdkName;
    }
}

- (void)setMainVPSDKVersion:(NSString *)sdkVersion {
    if(sdkVersion) {
        _mainVPSDKVersion = sdkVersion;
    }
}

- (void)setMainVPSDKServiceVersion:(NSString *)serviceVersion {
    if(serviceVersion) {
        _mainVPSDKServiceVersion = serviceVersion;
    }
}

- (void)setMainVPSDKAppKey:(NSString *)appKey {
    if(appKey) {
        _mainVPSDKAppKey = appKey;
    }
}

- (void)setMainVPSDKAppSecret:(NSString *)appSecret {
    if(appSecret) {
        _mainVPSDKAppSecret = appSecret;
    }
}

- (void)setMainVPSDKPlatformID:(NSString *)platformID {
    if(platformID) {
        _mainVPSDKPlatformID = platformID;
    }
}

- (void)setEnableWebP:(BOOL)webP {
    _webP = webP;
}

@end
