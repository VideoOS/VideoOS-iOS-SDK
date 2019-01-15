//
//  VPUPSecurityEncode.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPSecurityEncode.h"
#import "VPUPBase64Util.h"
#import "VPUPGeneralInfo.h"
#import "vpup_security_encode.h"

@implementation VPUPSecurityEncode

+ (NSString *)tokenEncode:(NSString *)json {
    if(!json || ![VPUPGeneralInfo mainVPSDKAppKey]) {
        return @"";
    }
    unsigned char *finalStr = (unsigned char *)malloc(sizeof(unsigned char) * 100);
    
    NSString *appKey = [[VPUPGeneralInfo mainVPSDKAppKey] copy];
    if(!appKey) {
        appKey = @"";
    }
    NSString *copyJson = [json copy];
    if(!copyJson) {
        copyJson = @"";
    }
    NSString *bundleID = [[VPUPGeneralInfo appBundleID] copy];
    if(!bundleID) {
        bundleID = @"";
    }
    
    
    vpup_token_encryption((char *)finalStr, appKey.UTF8String, copyJson.UTF8String, bundleID.UTF8String);
    
    NSString *finalString = [NSString stringWithUTF8String:(char *)finalStr];
    
    free(finalStr);
    
    return finalString;
}

+ (NSString *)mqttEncode:(NSString *)encodeString key:(NSString *)key {
    
    if(!key || !encodeString) {
        return nil;
    }
    
    unsigned char *cMQTT = (unsigned char *)malloc(sizeof(unsigned char) * 21);
    vpup_mqtt_encryption(cMQTT, [key UTF8String], [encodeString UTF8String]);
    
    NSData *useData = [NSData dataWithBytes:cMQTT length:20];
    NSString *finalString = [VPUPBase64Util base64EncodingData:useData];
    
    free(cMQTT);
    return finalString;
}

@end
