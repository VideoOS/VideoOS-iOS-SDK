//
//  VPLSDK.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/8/31.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLSDK.h"
#import "VPLScriptManager.h"
#import "VPUPPathUtil.h"
#import "VPLNetworkManager.h"
#import "VPUPSDKInfo.h"
#import "VPUPGeneralInfo.h"
#import "VPUPCommonInfo.h"
#import <AdSupport/AdSupport.h>
#import "VPUPReport.h"

NSString *const VPLServerHost = @"https://os-saas.videojj.com/os-api-saas";
NSString *const VPLScriptServerUrl = @"https://os-saas.videojj.com/os-api-saas/api/v2/preloadLuaFileInfo";

NSString *const VPLRequestPublicKey = @"inekcndsaqwertyi";

@interface VPLSDK ()<VPLScriptManagerDelegate>

@property (nonatomic, strong) VPLScriptManager *lScriptManager;
@property (nonatomic, copy) NSString *luaVersion;
@property (nonatomic, assign) VPLOSType type;
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, assign) BOOL appDev;

@end

@implementation VPLSDK

+ (instancetype)sharedSDK {
    static VPLSDK *_sharedSDK = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSDK = [[self alloc] init];
        _sharedSDK.appSecret = VPLRequestPublicKey;
        _sharedSDK.appDev = NO;
        [VPUPReport sharedReport];
    });
    return _sharedSDK;
}

+ (void)initSDK {
    if (![VPUPGeneralInfo IDFA]) {
        [VPLSDK setIDFA:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    }
    
    [VPLSDK checkLuaFiles];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[VPLSDK sharedSDK] lScriptManager];
    });
    
}

+ (void)setIDFA:(NSString *)IDFA {
    [VPUPGeneralInfo setIDFA:IDFA];
}

+ (void)setIdentity:(NSString *)identity {
    [VPUPGeneralInfo setUserIdentity:identity];
}

+ (void)updateLuaVersion:(NSString *)version {
    [VPLSDK sharedSDK].luaVersion = version;
}

+ (void)setOSType:(VPLOSType)type {
    [VPLSDK sharedSDK].type = type;
}

+ (void)setAppKey:(NSString *)appKey appSecret:(NSString *)appSecret {
    [VPLSDK sharedSDK].appKey = appKey;
    [VPLSDK sharedSDK].appSecret = appSecret;
    VPUPSDKInfo *sdkinfo = [[VPUPSDKInfo alloc] init];
    sdkinfo.mainVPSDKAppKey = appKey;
    sdkinfo.mainVPSDKAppSecret = appSecret;
//    VPUPSDKInfo *sdkinfo = [VPUPSDKInfo initSDKInfoWithSDKType:VPUPMainSDKTypeVideoOS SDKVersion:[VPLSDK  sharedSDK].luaVersion appKey:appKey];
    [VPUPGeneralInfo setSDKInfo:sdkinfo];
}

+ (void)setAppDevEnable:(BOOL)enable {
    [VPLSDK sharedSDK].appDev = enable;
}

+ (void)checkLuaFiles {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        NSString *cacheLuaVersionPath = [[VPUPPathUtil lOSPath] stringByAppendingString:@"/lua_version.json"];
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
                [[NSFileManager defaultManager] removeItemAtPath:[[VPUPPathUtil lOSPath] stringByAppendingPathComponent:file] error:nil];
                
                [[NSFileManager defaultManager] copyItemAtPath:[bundleLuaPath stringByAppendingPathComponent:file] toPath:[[VPUPPathUtil lOSPath] stringByAppendingPathComponent:file] error:&error];
                if (error) {
                    break;
                }
            }
            if (error) {
                NSArray *paths = [[NSFileManager defaultManager] subpathsAtPath:[VPUPPathUtil lOSPath]];
                for (NSString *path in paths) {
                    NSString *filePath = [[VPUPPathUtil lOSPath] stringByAppendingPathComponent:path];
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
            }
        }
    });
}

- (VPLScriptManager* )lScriptManager {
    if (!_lScriptManager) {
        _lScriptManager = [[VPLScriptManager alloc] initWithLuaStorePath:[VPUPPathUtil lOSPath] apiManager:[VPLNetworkManager Manager].httpManager versionUrl:VPLScriptServerUrl nativeVersion:@"1.0"];
        _lScriptManager.delegate = self;
        
    }
    return _lScriptManager;
}

#pragma mark - VPLScriptManager
- (void)scriptManager:(VPLScriptManager *)manager error:(NSError *)error errorType:(VPLScriptManagerErrorType)type {
    switch (type) {
        case VPLScriptManagerErrorTypeGetVersion:
        case VPLScriptManagerErrorTypeDownloadFile:
            //TODO: 网络错误
            break;
            
        case VPLScriptManagerErrorTypeUnzip:
        case VPLScriptManagerErrorTypeWriteVersionFile:
            //TODO: 代码错误
            
        default:
            break;
    }
}

- (void)scriptManager:(VPLScriptManager *)manager downloadSuccessed:(BOOL)success {
    NSLog(@"scriptManager downloadSuccessed");
}

@end
