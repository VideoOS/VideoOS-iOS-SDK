//
//  VPUPAESUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPAESUtil : NSObject

+ (NSString *)aesEncryptString:(NSString *)string;
+ (NSString *)aesEncryptString:(NSString *)string key:(NSString *)key initVector:(NSString *)initVector;

+ (NSString *)aesDecryptString:(NSString *)string;
+ (NSString *)aesDecryptString:(NSString *)string key:(NSString *)key initVector:(NSString *)initVector;

@end
