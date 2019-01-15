//
//  VPUPCommonEncryption.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPCommonEncryption : NSObject

#pragma mark Base64
+ (NSString *)base64EncryptionString:(NSString *)originalString;
+ (NSString *)base64DecryptionString:(NSString *)base64String;

#pragma mark Hash
//return 32bit md5
+ (NSString *)md5HashString:(NSString *)string;
//return 16bit md5
+ (NSString *)md5BriefHashString:(NSString *)string;
+ (NSString *)sha1HashString:(NSString *)string;
+ (NSString *)sha256HashString:(NSString *)string;
+ (NSString *)hmac_sha1HashString:(NSString *)string key:(NSString *)hmacKey;

#pragma mark Cipher
//AES 128
+ (NSString *)aesEncryptString:(NSString *)string;
+ (NSString *)aesEncryptString:(NSString *)string key:(NSString *)key initVector:(NSString *)initVector;

+ (NSString *)aesDecryptString:(NSString *)string;
+ (NSString *)aesDecryptString:(NSString *)string key:(NSString *)key initVector:(NSString *)initVector;

#pragma mark netowrk relative
+ (NSString *)tokenEncryptionWithJson:(NSDictionary *)jsonDictionary;
+ (NSString *)mqttEncryptionWithData:(NSString *)dataString key:(NSString *)key;

@end
