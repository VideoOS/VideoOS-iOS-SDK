//
//  VPLuaDesktopView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaDesktopView.h"
#import "VideoPlsUtilsPlatformSDK.h"
#import "VideoPlsLuaViewSDK.h"
#import "VPLuaCapacityManager.h"
#import "VPUPRSAUtil.h"
#import "VPLuaSDK.h"
#import "VPLuaPlayer.h"
#import <objc/message.h>
#import "VPLuaConstant.h"

@interface VPLuaDesktopView () <VPLuaScriptManagerDelegate>

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

@implementation VPLuaDesktopView

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
    self.frame = [UIScreen mainScreen].bounds;
    switch (type) {
        case VPLuaVideoPlayerOrientationPortraitSmallScreen:
            self.isFullScreen = NO;
            self.isPortrait = YES;
            break;
        case VPLuaVideoPlayerOrientationPortraitFullScreen:
            self.isFullScreen = YES;
            self.isPortrait = YES;
            break;
        case VPLuaVideoPlayerOrientationLandscapeFullScreen:
            self.isFullScreen = YES;
            self.isPortrait = NO;
            break;
            
        default:
            break;
    }
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
}

- (void)stop {
    [self.luaController releaseLuaView];
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
}

- (void)loadLua:(NSString *)luaUrl data:(id)data {
    if (self.isStartLoading) {
        [self.luaController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.luaController loadLua:luaUrl data:data];
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
