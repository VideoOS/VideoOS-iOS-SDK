//
//  VPLuaSDK.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/8/31.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const VPLuaServerHost;
extern NSString *const VPLuaScriptServerUrl;

@class VPLuaVideoInfo;

typedef NS_ENUM(NSUInteger, VPLuaOSType) {
    VPLuaOSTypeDefault          = 0,
    VPLuaOSTypeVideoOS          = 1,        //点播
    VPLuaOSTypeLiveOS           = 2,        //直播
};

@interface VPLuaSDK : NSObject

@property (nonatomic, readonly, copy) NSString *luaVersion;
@property (nonatomic, readonly, assign) VPLuaOSType type;
@property (nonatomic, weak) VPLuaVideoInfo *videoInfo;

+ (instancetype)sharedSDK;

+ (void)initSDK;

+ (void)setIDFA:(NSString *)IDFA;

+ (void)setIdentity:(NSString *)identity;

+ (void)updateLuaVersion:(NSString *)version;

+ (void)setOSType:(VPLuaOSType)type;

@end
