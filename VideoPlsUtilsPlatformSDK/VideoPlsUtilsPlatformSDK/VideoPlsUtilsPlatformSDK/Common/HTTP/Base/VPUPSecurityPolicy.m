//
//  VPUPSecurityPolicy.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPSecurityPolicy.h"

@interface VPUPSecurityPolicy ()

@property (readwrite, nonatomic, assign) VPUPSSLPinningMode SSLPinningMode;

@end

@implementation VPUPSecurityPolicy

+ (instancetype)policyWithPinningMode:(VPUPSSLPinningMode)pinningMode {
    VPUPSecurityPolicy *securityPolicy = [[VPUPSecurityPolicy alloc] init];
    if (securityPolicy) {
        securityPolicy.SSLPinningMode           = pinningMode;
        securityPolicy.allowInvalidCertificates = NO;
        securityPolicy.validatesDomainName      = YES;
    }
    return securityPolicy;
}

@end
