//
//  VPUPSecurityEncode.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPSecurityEncode : NSObject

+ (NSString *)tokenEncode:(NSString *)json;

+ (NSString *)mqttEncode:(NSString *)encodeString key:(NSString *)key;

@end
