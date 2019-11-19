//
//  VPUPPathUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/8/18.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPPathUtil.h"

@implementation VPUPPathUtil

+ (NSString *)path {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    path = [path stringByAppendingPathComponent:@"videopls"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

+ (NSString *)reportPath {
   return [self pathByPlaceholder:@"report"];
}

+ (NSString *)cytronPath {
    return [self pathByPlaceholder:@"cytron"];
}

+ (NSString *)livePath {
    return [self pathByPlaceholder:@"live"];
}

+ (NSString *)imagePath {
    return [self pathByPlaceholder:@"com.hackemist.SDWebImageCache.videopls"];
}

+ (NSString *)videoModePath {
    return [self pathByPlaceholder:@"videoMode"];
}

+ (NSString *)subPathOfVideoMode:(NSString *)placeholder {
    NSString *path = [self videoModePath];
    path = [path stringByAppendingPathComponent:placeholder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)luaPath {
    return [self pathByPlaceholder:@"lua"];
}

+ (NSString *)luaOSPath {
    return [VPUPPathUtil subPathOfLua:@"os"];
}

+ (NSString *)luaHolderPath {
    return [VPUPPathUtil subPathOfLua:@"holder"];
}

+ (NSString *)subPathOfLuaHolder:(NSString *)placeholder {
    NSString *path = [self luaHolderPath];
    path = [path stringByAppendingPathComponent:placeholder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)subPathOfLua:(NSString *)placeholder {
    NSString *path = [self luaPath];
    path = [path stringByAppendingPathComponent:placeholder];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)goodsPath {
    return [self pathByPlaceholder:@"goods"];
}


+ (NSString *)pathByPlaceholder:(NSString *)placeholder {
    NSString *path = [self path];
    
    path = [path stringByAppendingPathComponent:placeholder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}


@end
