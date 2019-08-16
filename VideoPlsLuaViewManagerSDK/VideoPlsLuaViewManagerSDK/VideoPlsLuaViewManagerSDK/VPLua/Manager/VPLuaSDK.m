//
//  VPLuaSDK.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/8/31.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaSDK.h"
#import "VPLuaScriptManager.h"
#import "VPUPPathUtil.h"
#import "VPLuaNetworkManager.h"
#import "VPUPSDKInfo.h"
#import "VPUPGeneralInfo.h"
#import "VPLuaCommonInfo.h"
#import <AdSupport/AdSupport.h>

//NSString *const VPLuaScriptServerUrl = @"http://dev-videopublicapi.videojj.com/videoos-api/api/fileVersion";
NSString *const VPLuaServerHost = @"https://os-saas.videojj.com/os-api-saas";
NSString *const VPLuaScriptServerUrl = @"https://os-saas.videojj.com/os-api-saas/api/detailedFileVersion";
//NSString *const VPLuaScriptServerUrl = @"http://videopublicapi.videojj.com/videoos-api/api/fileVersion";

@interface VPLuaSDK ()<VPLuaScriptManagerDelegate>

@property (nonatomic, strong) VPLuaScriptManager *luaScriptManager;
@property (nonatomic, copy) NSString *luaVersion;
@property (nonatomic, assign) VPLuaOSType type;
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;

@end

@implementation VPLuaSDK

+ (instancetype)sharedSDK {
    static VPLuaSDK *_sharedSDK = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSDK = [[self alloc] init];
        _sharedSDK.appSecret = VPLuaRequestPublicKey;
    });
    return _sharedSDK;
}

+ (void)initSDK {
    if (![VPUPGeneralInfo IDFA]) {
        [VPLuaSDK setIDFA:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    }
    [VPLuaSDK checkLuaFiles];
    [[VPLuaSDK sharedSDK] luaScriptManager];
}

+ (void)setIDFA:(NSString *)IDFA {
    [VPUPGeneralInfo setIDFA:IDFA];
}

+ (void)setIdentity:(NSString *)identity {
    [VPUPGeneralInfo setUserIdentity:identity];
}

+ (void)updateLuaVersion:(NSString *)version {
    [VPLuaSDK sharedSDK].luaVersion = version;
}

+ (void)setOSType:(VPLuaOSType)type {
    [VPLuaSDK sharedSDK].type = type;
}

+ (void)setAppKey:(NSString *)appKey appSecret:(NSString *)appSecret {
    [VPLuaSDK sharedSDK].appKey = appKey;
    [VPLuaSDK sharedSDK].appSecret = appSecret;
    VPUPSDKInfo *sdkinfo = [[VPUPSDKInfo alloc] init];
    sdkinfo.mainVPSDKAppKey = appKey;
//    VPUPSDKInfo *sdkinfo = [VPUPSDKInfo initSDKInfoWithSDKType:VPUPMainSDKTypeVideoOS SDKVersion:[VPLuaSDK  sharedSDK].luaVersion appKey:appKey];
    [VPUPGeneralInfo setSDKInfo:sdkinfo];
}

+ (void)checkLuaFiles {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        NSString *cacheLuaVersionPath = [[VPUPPathUtil luaOSPath] stringByAppendingString:@"/lua_version.json"];
        NSDictionary *cacheLuaVersionDict = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheLuaVersionPath]) {
            cacheLuaVersionDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:cacheLuaVersionPath] options:NSJSONReadingMutableContainers error:nil];
        }
        
        
        NSBundle *videoplsBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"VideoPlsResources" withExtension:@"bundle"]];
        NSString *bundleLuaPath = [[videoplsBundle bundlePath] stringByAppendingPathComponent:@"lua"];
        NSString *luaVersionPath = [bundleLuaPath stringByAppendingString:@"/lua_version.json"];
        NSDictionary *luaVersionDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:luaVersionPath] options:NSJSONReadingMutableContainers error:nil];
        
        if (![[luaVersionDict objectForKey:@"version"] isEqualToString:[cacheLuaVersionDict objectForKey:@"version"]]) {
            
            NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleLuaPath error:nil];
            NSError *error = nil;
            for (NSString *file in array) {
                [[NSFileManager defaultManager] removeItemAtPath:[[VPUPPathUtil luaOSPath] stringByAppendingPathComponent:file] error:nil];
                
                [[NSFileManager defaultManager] copyItemAtPath:[bundleLuaPath stringByAppendingPathComponent:file] toPath:[[VPUPPathUtil luaOSPath] stringByAppendingPathComponent:file] error:&error];
                if (error) {
                    break;
                }
            }
            if (error) {
                NSArray *paths = [[NSFileManager defaultManager] subpathsAtPath:[VPUPPathUtil luaOSPath]];
                for (NSString *path in paths) {
                    NSString *filePath = [[VPUPPathUtil luaOSPath] stringByAppendingPathComponent:path];
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
            }
        }
    });
}

- (VPLuaScriptManager* )luaScriptManager {
    if (!_luaScriptManager) {
        _luaScriptManager = [[VPLuaScriptManager alloc] initWithLuaStorePath:[VPUPPathUtil luaOSPath] apiManager:[VPLuaNetworkManager Manager].httpManager versionUrl:VPLuaScriptServerUrl nativeVersion:@"1.0"];
        _luaScriptManager.delegate = self;
        
    }
    return _luaScriptManager;
}

#pragma mark - VPLuaScriptManager
- (void)scriptManager:(VPLuaScriptManager *)manager error:(NSError *)error errorType:(VPLuaScriptManagerErrorType)type {
    switch (type) {
        case VPLuaScriptManagerErrorTypeGetVersion:
        case VPLuaScriptManagerErrorTypeDownloadFile:
            //TODO: 网络错误
            break;
            
        case VPLuaScriptManagerErrorTypeUnzip:
        case VPLuaScriptManagerErrorTypeWriteVersionFile:
            //TODO: 代码错误
            
        default:
            break;
    }
}

- (void)scriptManager:(VPLuaScriptManager *)manager downloadSuccessed:(BOOL)success {
    NSLog(@"scriptManager downloadSuccessed");
}

@end
