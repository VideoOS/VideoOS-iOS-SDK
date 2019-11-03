//
//  VPLuaOSView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 05/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaOSView.h"
#import "VideoPlsUtilsPlatformSDK.h"
#import "VideoPlsLuaViewSDK.h"
#import "VPLuaCapacityManager.h"
#import "VPUPRSAUtil.h"
#import "VPLuaSDK.h"
#import "VPLuaPlayer.h"
#import <objc/message.h>
#import "VPUPInterfaceDataServiceManager.h"

NSString *const VPOSLuaEndNotification = @"VPOSLuaEndNotification";
NSString *const VPLuaOSLoadCompleteNotification = @"VPLuaOSLoadCompleteNotification";

@interface VPLuaOSView () <VPLuaScriptManagerDelegate>

@property (nonatomic, weak) VPLuaNetworkManager *networkManager;
@property (nonatomic, strong) VPLuaScriptManager *luaScriptManager;
@property (nonatomic, strong) VPLuaNodeController *luaController;

@property (nonatomic,   copy) NSString *luaPath;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL isPortrait;

@property (nonatomic, assign) BOOL downloadFinished;
@property (nonatomic, assign) BOOL isStartLoading;
@property (nonatomic, assign) BOOL isOpenConfig;
@property (nonatomic, assign) BOOL configIsFullScreen;

@property (nonatomic, assign) BOOL useUpdateVersion;

@end

@implementation VPLuaOSView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame platformId:nil videoId:nil];
}

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId {
    return [self initWithFrame:frame platformId:platformId videoId:videoId extendInfo:nil];
}

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId extendInfo:(NSDictionary *)extendInfo
 {
    self = [super initWithFrame:frame];
    if (self) {
        [VPLuaCapacityManager startService];
        self.useUpdateVersion = YES;
        self.luaPath = [VPUPPathUtil luaOSPath];
        
        NSLog(@"%@",self.luaPath);

        self.videoInfo = [[VPLuaVideoInfo alloc] init];
        self.videoInfo.platformID = platformId;
        self.videoInfo.nativeID = videoId;
        if ([extendInfo objectForKey:@"category"]) {
            self.videoInfo.category = [extendInfo objectForKey:@"category"];
        }
        if (extendInfo) {
            self.videoInfo.extendJSONString = VPUP_DictionaryToJson(extendInfo);
        }
        [VPLuaSDK sharedSDK].videoInfo = self.videoInfo;
        SEL checkLuaFiles = NSSelectorFromString(@"checkLuaFiles");
        Class sdkClass = NSClassFromString(@"VPLuaSDK");
        
        ((BOOL(*)(id,SEL, id,id))objc_msgSend)(sdkClass, checkLuaFiles, nil, nil);

//        [self prefetchLua];
        if(!self.networkManager) {
            [self initNetworkManager];
        }
    }
    
    return self;
}

- (void)updateFrame:(CGRect)frame videoRect:(CGRect)videoRect isFullScreen:(BOOL)isFullScreen {
    self.frame = frame;
    self.isFullScreen = isFullScreen;
    if (frame.size.width > frame.size.height) {
        self.isPortrait = NO;
    } else {
        self.isPortrait = YES;
    }
    [self.luaController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
}

- (void)updateVideoPlayerOrientation:(VPLuaVideoPlayerOrientation)type {
    
    VPUPVideoPlayerSize *videoPlayerSize = [VPUPInterfaceDataServiceManager videoPlayerSize];
    
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    if (videoPlayerSize && videoPlayerSize.portraitFullScreenHeight > 0) {
        switch (type) {
            case VPLuaVideoPlayerOrientationPortraitSmallScreen:
                viewWidth = videoPlayerSize.portraitFullScreenWidth;
                viewHeight = videoPlayerSize.portraitFullScreenHeight;
                self.isFullScreen = NO;
                self.isPortrait = YES;
                break;
            case VPLuaVideoPlayerOrientationPortraitFullScreen:
                viewWidth = videoPlayerSize.portraitFullScreenWidth;
                viewHeight = videoPlayerSize.portraitFullScreenHeight;
                self.isFullScreen = YES;
                self.isPortrait = YES;
                break;
            case VPLuaVideoPlayerOrientationLandscapeFullScreen:
                viewWidth = videoPlayerSize.portraitFullScreenHeight;
                viewHeight = videoPlayerSize.portraitFullScreenWidth;
                self.isFullScreen = YES;
                self.isPortrait = NO;
                break;
                
            default:
                break;
        }
    }
    else {
        CGFloat portraitFullScreenWidth = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        CGFloat portraitFullScreenHeight = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        switch (type) {
            case VPLuaVideoPlayerOrientationPortraitSmallScreen:
                viewWidth = portraitFullScreenWidth;
                viewHeight = portraitFullScreenWidth * 9.0 / 16.0;
                self.isFullScreen = NO;
                self.isPortrait = YES;
                break;
            case VPLuaVideoPlayerOrientationPortraitFullScreen:
                viewWidth = portraitFullScreenWidth;
                viewHeight = portraitFullScreenHeight;
                self.isFullScreen = YES;
                self.isPortrait = YES;
                break;
            case VPLuaVideoPlayerOrientationLandscapeFullScreen:
                viewWidth = portraitFullScreenHeight;
                viewHeight = portraitFullScreenWidth;
                self.isFullScreen = YES;
                self.isPortrait = NO;
                break;
                
            default:
                break;
        }
    }
    
    CGRect rect = self.frame;
    rect.size.width = viewWidth;
    rect.size.height = viewHeight;
    self.frame = rect;
    
    self.luaController.currentOrientation = type;
    [self.luaController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
}

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))getUserInfoBlock {
    _getUserInfoBlock = getUserInfoBlock;
    [self.luaController setGetUserInfoBlock:getUserInfoBlock];
}

- (void)startLoading {
    self.isStartLoading = YES;
    [self initLuaView];
    [self openMainPage];
}

- (void)stop {
    [self.luaController releaseLuaView];
    [self deregisterLuaActionNotification];
}

- (void)closeActionWebViewForAd:(NSString *)adId {
    [self.luaController closeActionWebViewForAd:adId];
}

- (void)pauseVideoAd {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaPauseVideoPlayerNotification object:nil];
}

- (void)playVideoAd {
    [self.luaController playVideoAd];
}

- (void)closeInfoView {
    [self.luaController closeInfoView];
}

#pragma mark - private
- (void)prefetchLua {
    if(!self.networkManager) {
        [self initNetworkManager];
    }
    
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"VideoPlsOSResources" withExtension:@"bundle"];
    if (bundleURL) {
        self.luaPath = bundleURL.relativePath;
        self.useUpdateVersion = NO;
        self.downloadFinished = YES;
    }

    if (self.useUpdateVersion) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            VPLuaScriptManager *manager = [[VPLuaScriptManager alloc] initWithLuaStorePath:self.luaPath apiManager:self.networkManager.httpManager versionUrl:VPLuaScriptServerUrl nativeVersion:@"1.0"];
            self.luaScriptManager = manager;
            manager.delegate = self;
        });
    }
}

- (void)initNetworkManager {
    self.networkManager = [VPLuaNetworkManager Manager];
}

- (void)initLuaView {
    
    //    NSString *path = [NSBundle mainBundle].bundlePath;
    if (!self.videoInfo) {
        self.videoInfo = [[VPLuaVideoInfo alloc] init];
    }
    
    self.luaController = [[VPLuaNodeController alloc] initWithViewFrame:self.bounds videoRect:self.bounds networkManager:self.networkManager videoInfo:self.videoInfo];
    self.luaController.videoPlayerSize = self.videoPlayerSize;
    [self.luaController changeDestinationPath:self.luaPath];
    [self addSubview:self.luaController.rootView];
    
    if (self.getUserInfoBlock) {
        [self.luaController setGetUserInfoBlock:self.getUserInfoBlock];
    }
    
    
    [self registerLuaActionNotification];
}

- (void)openMainPage {
    [self loadLua:@"main.lua" data:nil];
}

- (void)loadLua:(NSString *)luaUrl data:(id)data {
    if (self.isStartLoading) {
        [self.luaController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.luaController loadLua:luaUrl data:data];
            if ([luaUrl isEqualToString:@"main.lua"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaOSLoadCompleteNotification object:nil];
            }
        });
    }
}

- (void)callLuaMethod:(NSString *)method data:(id)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.luaController callLuaMethod:method data:data];
    });
}

- (void)callLuaMethod:(NSString *)method nodeId:(NSString *)nodeId data:(id)data {
    if (nodeId == nil) {
        [self callLuaMethod:method data:data];
    }
    else {
        [self.luaController callLuaMethod:method nodeId:nodeId data:data];
    }
}

- (void)removeViewWithNodeId:(NSString *)nodeId {
    [self.luaController removeNodeWithNodeId:nodeId];
}

- (void)registerLuaActionNotification {
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(luaEnd:) name:VPUPLuaEndNotification object:_luaController];
}

- (void)deregisterLuaActionNotification {
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPLuaEndNotification object:_luaController];
}

- (void)luaEnd:(NSNotification *)notification {
    NSString *name = [notification.userInfo objectForKey:@"name"];
    if ([name isEqualToString:@"main.lua"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VPOSLuaEndNotification object:nil];
    }
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
    self.downloadFinished = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self openMainPage];
    });
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

- (void)dealloc {
    [self.luaController releaseLuaView];
    [VPLuaCapacityManager stopService];
    [VPLuaNetworkManager releaseManaer];
}


@end
