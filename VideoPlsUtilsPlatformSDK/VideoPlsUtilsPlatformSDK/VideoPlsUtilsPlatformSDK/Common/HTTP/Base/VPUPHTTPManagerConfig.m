//
//  VPUPHTTPManagerConfig.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPManagerConfig.h"
#import "VPUPHTTPAPIEnum.h"

NSString * VPUPHTTPDefaultGeneralErrorString            = @"服务器连接错误，请稍候重试";
NSString * VPUPHTTPDefaultFrequentRequestErrorString    = @"Request send too fast, please try again later";
NSString * VPUPHTTPDefaultNetworkNotReachableString     = @"网络不可用，请稍后重试";

@implementation VPUPHTTPManagerConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.generalErrorTypeStr                  = VPUPHTTPDefaultGeneralErrorString;
        self.frequentRequestErrorStr              = VPUPHTTPDefaultFrequentRequestErrorString;
        self.networkNotReachableErrorStr          = VPUPHTTPDefaultNetworkNotReachableString;
        //default is NO
        self.isNetworkingActivityIndicatorEnabled = NO;
        self.isErrorCodeDisplayEnabled            = YES;
        self.maxHttpConnectionPerHost             = VPUP_MAX_HTTP_CONNECTION_PER_HOST;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    VPUPHTTPManagerConfig *config       = [[VPUPHTTPManagerConfig allocWithZone:zone] init];
    config.generalErrorTypeStr          = self.generalErrorTypeStr;
    config.frequentRequestErrorStr      = self.frequentRequestErrorStr;
    config.networkNotReachableErrorStr  = self.networkNotReachableErrorStr;
    config.isErrorCodeDisplayEnabled    = self.isErrorCodeDisplayEnabled;
    config.baseUrlStr                   = self.baseUrlStr;
    config.userAgent                    = self.userAgent;
    config.maxHttpConnectionPerHost     = self.maxHttpConnectionPerHost;
    return config;
}

@end
