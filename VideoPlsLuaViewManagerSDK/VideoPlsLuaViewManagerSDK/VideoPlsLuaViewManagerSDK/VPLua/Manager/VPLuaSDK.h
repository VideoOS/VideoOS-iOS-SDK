//
//  VPLuaSDK.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/8/31.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaVideoInfo.h"

extern NSString *const VPLuaServerHost;
extern NSString *const VPLuaScriptServerUrl;

typedef NS_ENUM(NSUInteger, VPLuaOSType) {
    VPLuaOSTypeDefault          = 0,
    VPLuaOSTypeVideoOS          = 1,        //点播
    VPLuaOSTypeLiveOS           = 2,        //直播
};

@interface VPLuaSDK : NSObject

@property (nonatomic, readonly, copy) NSString *luaVersion;
@property (nonatomic, readonly, assign) VPLuaOSType type;
@property (nonatomic, readonly, copy) NSString *appKey;
@property (nonatomic, readonly, copy) NSString *appSecret;
@property (nonatomic, weak) VPLuaVideoInfo *videoInfo;
@property (nonatomic, readonly, assign) BOOL appDev;

+ (instancetype)sharedSDK;

+ (void)initSDK;

+ (void)setIDFA:(NSString *)IDFA;

+ (void)setIdentity:(NSString *)identity;

+ (void)updateLuaVersion:(NSString *)version;

+ (void)setOSType:(VPLuaOSType)type;

+ (void)setAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;

+ (void)setAppDevEnable:(BOOL)enable;

@end
