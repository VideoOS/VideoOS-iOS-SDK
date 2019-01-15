//
//  VPUPSHAUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPSHAUtil.h"
#import "vpup_hash_encode.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation VPUPSHAUtil

+ (NSString *)sha1HashString:(NSString *)string {
    unsigned char *hashStr = (unsigned char *)malloc(sizeof(unsigned char) * (CC_SHA1_DIGEST_LENGTH * 2 + 1));
    vpup_sha1_encryption((char *)[string UTF8String], hashStr);
    
    NSString *hashString = [NSString stringWithUTF8String:(char *)hashStr];
    
    free(hashStr);
    
    return hashString;
}

+ (NSString *)sha256HashString:(NSString *)string {
    unsigned char *hashStr = (unsigned char *)malloc(sizeof(unsigned char) * (CC_SHA256_DIGEST_LENGTH * 2 + 1));
    vpup_sha256_encryption((char *)[string UTF8String], hashStr);
    NSString *hashString = [NSString stringWithUTF8String:(char *)hashStr];
    
    free(hashStr);
    
    return hashString;
}

+ (NSString *)hmac_sha1HashString:(NSString *)string key:(NSString *)hmacKey {
    unsigned char *hashStr = (unsigned char *)malloc(sizeof(unsigned char) * (CC_SHA1_DIGEST_LENGTH * 2 + 1));
    
    vpup_hmac_sha1_hex_encryption((char *)[hmacKey UTF8String], (char *)[string UTF8String], hashStr);
    
    NSString *hashString = [NSString stringWithUTF8String:(char *)hashStr];
    
    free(hashStr);
    
    return hashString;
}

@end
