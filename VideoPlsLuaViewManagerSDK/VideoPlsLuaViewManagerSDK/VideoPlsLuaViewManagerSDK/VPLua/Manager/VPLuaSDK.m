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
#import "VPUPGeneralInfo.h"

//NSString *const VPLuaScriptServerUrl = @"http://dev-videopublicapi.videojj.com/videoos-api/api/fileVersion";
NSString *const VPLuaServerHost = @"http://os-open.videojj.com/videoos-api";
NSString *const VPLuaScriptServerUrl = @"http://os-open.videojj.com/videoos-api/api/fileVersion";
//NSString *const VPLuaScriptServerUrl = @"http://videopublicapi.videojj.com/videoos-api/api/fileVersion";

@interface VPLuaSDK ()<VPLuaScriptManagerDelegate>

@property (nonatomic, strong) VPLuaScriptManager *luaScriptManager;
@property (nonatomic, copy) NSString *luaVersion;
@property (nonatomic, assign) VPLuaOSType type;

@end

@implementation VPLuaSDK

+ (instancetype)sharedSDK {
    static VPLuaSDK *_sharedSDK = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSDK = [[self alloc] init];
    });
    return _sharedSDK;
}

+ (void)initSDK {
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

+ (void)checkLuaFiles {
    NSString *mainLuaPath = [[VPUPPathUtil luaOSPath] stringByAppendingString:@"/main.lua"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:mainLuaPath]) {
        NSBundle *videoplsBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"VideoPlsResources" withExtension:@"bundle"]];
        NSString *bundleLuaPath = [[videoplsBundle bundlePath] stringByAppendingPathComponent:@"lua"];
        NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleLuaPath error:nil];
        NSError *error = nil;
        for (NSString *file in array) {
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
