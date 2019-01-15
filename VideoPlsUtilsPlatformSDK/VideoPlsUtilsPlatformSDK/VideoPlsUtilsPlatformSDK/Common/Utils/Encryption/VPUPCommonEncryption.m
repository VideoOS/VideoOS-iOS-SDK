//
//  VPUPCommonEncryption.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPCommonEncryption.h"
#import "VPUPBase64Util.h"
#import "VPUPMD5Util.h"
#import "VPUPSHAUtil.h"
#import "VPUPAESUtil.h"
#import "VPUPSecurityEncode.h"

@implementation VPUPCommonEncryption

+ (NSString *)base64EncryptionString:(NSString *)originalString {
    return [VPUPBase64Util base64EncryptionString:originalString];
}

+ (NSString *)base64DecryptionString:(NSString *)base64String {
    return [VPUPBase64Util base64DecryptionString:base64String];
}


+ (NSString *)md5HashString:(NSString *)string {
    return  [VPUPMD5Util md5HashString:string];
}

+ (NSString *)md5BriefHashString:(NSString *)string {
    return  [VPUPMD5Util md5_16bitHashString:string];
}

+ (NSString *)sha1HashString:(NSString *)string {
    return [VPUPSHAUtil sha1HashString:string];
}

+ (NSString *)sha256HashString:(NSString *)string {
    return [VPUPSHAUtil sha256HashString:string];
}

+ (NSString *)hmac_sha1HashString:(NSString *)string key:(NSString *)hmacKey {
    return [VPUPSHAUtil hmac_sha1HashString:string key:hmacKey];
}


+ (NSString *)aesEncryptString:(NSString *)string {
    return [VPUPAESUtil aesEncryptString:string];
}

+ (NSString *)aesEncryptString:(NSString *)string key:(NSString *)key initVector:(NSString *)initVector {
    return [VPUPAESUtil aesEncryptString:string key:key initVector:initVector];
}

+ (NSString *)aesDecryptString:(NSString *)string {
    return [VPUPAESUtil aesDecryptString:string];
}

+ (NSString *)aesDecryptString:(NSString *)string key:(NSString *)key initVector:(NSString *)initVector {
    return [VPUPAESUtil aesDecryptString:string key:key initVector:initVector];
}


+ (NSString *)tokenEncryptionWithJson:(NSDictionary *)jsonDictionary {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    json = [json stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    return [VPUPSecurityEncode tokenEncode:json];
}

+ (NSString *)mqttEncryptionWithData:(NSString *)dataString key:(NSString *)key {
    return [VPUPSecurityEncode mqttEncode:dataString key:key];
}

@end
