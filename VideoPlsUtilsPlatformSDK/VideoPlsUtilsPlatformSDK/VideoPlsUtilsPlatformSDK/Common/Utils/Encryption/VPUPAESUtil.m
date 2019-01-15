//
//  VPUPAESUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPAESUtil.h"
#import <CommonCrypto/CommonCrypto.h>
#import "vpup_aes.h"
#import "VPUPBase64Util.h"
#import "VPUPCipherOperation.h"

@implementation VPUPAESUtil

+ (NSString *)aesEncryptString:(NSString *)string {
    unsigned char *init_vector = (unsigned char *)malloc(sizeof(unsigned char) * 17);
    vpup_aesInitVector(init_vector);
    
    unsigned char *key = (unsigned char *)malloc(sizeof(unsigned char) * 17);
    vpup_aesDefaultKey(key);
    
    NSString *initVectorString = [NSString stringWithUTF8String:(char *)init_vector];
    NSString *keyString = [NSString stringWithUTF8String:(char *)key];
    
    NSString *finalString = [self aesEncryptString:string key:keyString initVector:initVectorString];
    
    free(init_vector);
    free(key);
    
    return finalString;
}

+ (NSString *)aesEncryptString:(NSString *)string key:(NSString *)key initVector:(NSString *)initVector {
    NSData *contentData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *initVectorData = [initVector dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *resultData = [VPUPCipherOperation vpup_aesEncryptWithContent:contentData key:keyData initVector:initVectorData];
    
    NSString *aesString = [VPUPBase64Util base64EncodingData:resultData];
    
    return aesString;
}

+ (NSString *)aesDecryptString:(NSString *)string {
    unsigned char *init_vector = (unsigned char *)malloc(sizeof(unsigned char) * 17);
    vpup_aesInitVector(init_vector);
    
    unsigned char *key = (unsigned char *)malloc(sizeof(unsigned char) * 33);
    vpup_aesDefaultKey(key);
    
    NSString *initVectorString = [NSString stringWithUTF8String:(char *)init_vector];
    NSString *keyString = [NSString stringWithUTF8String:(char *)key];
    
    NSString *finalString = [self aesDecryptString:string key:keyString initVector:initVectorString];
    
    free(init_vector);
    free(key);
    
    return finalString;
}

+ (NSString *)aesDecryptString:(NSString *)string key:(NSString *)key initVector:(NSString *)initVector {
    NSData *contentData = [VPUPBase64Util dataBase64DecodeFromString:string];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *initVectorData = [initVector dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *resultData = [VPUPCipherOperation vpup_aesDecryptWithContent:contentData key:keyData initVector:initVectorData];
    
    NSString *decryptString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    return decryptString;
}

@end
