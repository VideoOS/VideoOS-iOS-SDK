//
//  VPUPSHAUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPSHAUtil : NSObject

+ (NSString *)sha1HashString:(NSString *)string;
+ (NSString *)sha256HashString:(NSString *)string;
+ (NSString *)hmac_sha1HashString:(NSString *)string key:(NSString *)hmacKey;

@end
