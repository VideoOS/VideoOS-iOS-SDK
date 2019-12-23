//
//  VPUPPathUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/8/18.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPPathUtil : NSObject

+ (NSString *)path;

+ (NSString *)reportPath;

+ (NSString *)cytronPath;

+ (NSString *)livePath;

+ (NSString *)imagePath;

+ (NSString *)videoModePath;

+ (NSString *)subPathOfVideoMode:(NSString *)placeholder;

+ (NSString *)lPath;

+ (NSString *)lOSPath;

+ (NSString *)subPathOfLOSPath:(NSString *)placeholder;

+ (NSString *)lmpPath;

+ (NSString *)subPathOfLMP:(NSString *)placeholder;

+ (NSString *)appDevPath;

+ (NSString *)appDevConfigPath;

+ (NSString *)subPathOfLua:(NSString *)placeholder;

+ (NSString *)goodsPath;

+ (NSString *)localStoragePath;

+ (NSString *)pathByPlaceholder:(NSString *)placeholder;



@end
