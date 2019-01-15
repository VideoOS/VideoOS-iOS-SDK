//
//  VPUPBase64Util.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VPUPBase64Util : NSObject

+ (NSString *)base64EncryptionString:(NSString *)originalString;
+ (NSString *)base64DecryptionString:(NSString *)base64String;

+ (NSString *)base64EncodingData:(NSData *)data;
+ (NSData *)dataBase64DecodeFromString:(NSString *)encodedString;

+ (UIImage *)imageFromBase64String:(NSString *)encodedString;

@end
