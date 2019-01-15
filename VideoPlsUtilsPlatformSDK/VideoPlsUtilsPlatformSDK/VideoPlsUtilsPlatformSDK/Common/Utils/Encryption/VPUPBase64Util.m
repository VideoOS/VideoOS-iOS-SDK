//
//  VPUPBase64Util.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPBase64Util.h"
#import "VPUPValidator.h"
#import <UIKit/UIKit.h>

@implementation VPUPBase64Util

+ (NSString *)base64EncryptionString:(NSString *)originalString {
    if(!VPUP_IsExist(originalString)) {
        return nil;
    }
    NSData *data = [originalString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encryptoString = [data base64EncodedStringWithOptions:0];
    return encryptoString;
}

+ (NSString *)base64DecryptionString:(NSString *)base64String {
    if(!VPUP_IsExist(base64String)) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *decodeString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return decodeString;
}

+ (NSString *)base64EncodingData:(NSData *)data {
    if(!VPUP_IsExist(data)) {
        return nil;
    }
    return [data base64EncodedStringWithOptions:0];
}

+ (NSData *)dataBase64DecodeFromString:(NSString *)encodedString {
    if(!VPUP_IsExist(encodedString)) {
        return nil;
    }
    return [[NSData alloc] initWithBase64EncodedString:encodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

+ (UIImage *)imageFromBase64String:(NSString *)encodedString {
    NSData *data = [self dataBase64DecodeFromString:encodedString];
    if(!data) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

@end
