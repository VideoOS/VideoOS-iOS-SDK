//
//  VPLSDK.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/8/31.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLVideoInfo.h"

extern NSString *const VPLServerHost;
extern NSString *const VPLScriptServerUrl;

typedef NS_ENUM(NSUInteger, VPLOSType) {
    VPLOSTypeDefault          = 0,
    VPLOSTypeVideoOS          = 1,        //点播
    VPLOSTypeLiveOS           = 2,        //直播
};

@interface VPLSDK : NSObject

@property (nonatomic, readonly, copy) NSString *luaVersion;
@property (nonatomic, readonly, assign) VPLOSType type;
@property (nonatomic, readonly, copy) NSString *appKey;
@property (nonatomic, readonly, copy) NSString *appSecret;
@property (nonatomic, weak) VPLVideoInfo *videoInfo;
@property (nonatomic, readonly, assign) BOOL appDev;

+ (instancetype)sharedSDK;

+ (void)initSDK;

+ (void)setIDFA:(NSString *)IDFA;

+ (void)setIdentity:(NSString *)identity;

+ (void)updateLuaVersion:(NSString *)version;

+ (void)setOSType:(VPLOSType)type;

+ (void)setAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;

+ (void)setAppDevEnable:(BOOL)enable;

@end
