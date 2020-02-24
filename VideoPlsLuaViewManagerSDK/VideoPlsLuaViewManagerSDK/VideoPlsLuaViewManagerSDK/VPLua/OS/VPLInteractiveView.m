//
//  VPLInteractiveView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/10/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLInteractiveView.h"
#import "VideoPlsUtilsPlatformSDK.h"
#import "VideoPlsLuaViewSDK.h"
#import "VPLCapacityManager.h"
#import "VPUPRSAUtil.h"
#import "VPLSDK.h"
#import "VPLPlayer.h"
#import <objc/message.h>
#import "VPLConstant.h"
#import "VPUPInterfaceDataServiceManager.h"

NSString *const VPOSLuaEndNotification = @"VPOSLuaEndNotification";
NSString *const VPLOSLoadCompleteNotification = @"VPLOSLoadCompleteNotification";

@interface VPLInteractiveView ()

@property (nonatomic, weak) VPLNetworkManager *networkManager;
@property (nonatomic, strong) VPLScriptManager *lScriptManager;
//@property (nonatomic, strong) VPLNodeController *nodeController;

@property (nonatomic,   copy) NSString *lPath;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL isPortrait;

@property (nonatomic, assign) BOOL downloadFinished;
@property (nonatomic, assign) BOOL isStartLoading;
@property (nonatomic, assign) BOOL isOpenConfig;
@property (nonatomic, assign) BOOL configIsFullScreen;

@property (nonatomic, assign) BOOL useUpdateVersion;

@end

@implementation VPLInteractiveView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame platformId:nil videoId:nil];
}

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId {
    return [self initWithFrame:frame platformId:platformId videoId:videoId extendInfo:nil];
}

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId extendInfo:(NSDictionary *)extendInfo
{
    VPLVideoInfo *videoInfo = [[VPLVideoInfo alloc] init];
    videoInfo.platformID = platformId;
    videoInfo.nativeID = videoId;
    if ([extendInfo objectForKey:@"category"]) {
        videoInfo.category = [extendInfo objectForKey:@"category"];
    }
    if (extendInfo) {
        videoInfo.extendDict = extendInfo;
    }
    return [self initWithFrame:frame videoInfo:videoInfo];
}

- (instancetype)initWithFrame:(CGRect)frame videoInfo:(VPLVideoInfo *)videoInfo {
    self = [super initWithFrame:frame];
    if (self) {
        [VPLCapacityManager startService];
        self.useUpdateVersion = YES;
        self.lPath = [VPUPPathUtil lOSPath];
        
        NSLog(@"%@",self.lPath);
        
        self.videoInfo = videoInfo;
        
        [VPLSDK sharedSDK].videoInfo = self.videoInfo;
        
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
    [self.nodeController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
}

- (void)updateVideoPlayerOrientation:(VPLVideoPlayerOrientation)type {
    
    VPUPVideoPlayerSize *videoPlayerSize = [VPUPInterfaceDataServiceManager videoPlayerSize];
    
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    if (videoPlayerSize && videoPlayerSize.portraitFullScreenHeight > 0) {
        switch (type) {
            case VPLVideoPlayerOrientationPortraitSmallScreen:
                viewWidth = videoPlayerSize.portraitFullScreenWidth;
                viewHeight = videoPlayerSize.portraitFullScreenHeight;
                self.isFullScreen = NO;
                self.isPortrait = YES;
                break;
            case VPLVideoPlayerOrientationPortraitFullScreen:
                viewWidth = videoPlayerSize.portraitFullScreenWidth;
                viewHeight = videoPlayerSize.portraitFullScreenHeight;
                self.isFullScreen = YES;
                self.isPortrait = YES;
                break;
            case VPLVideoPlayerOrientationLandscapeFullScreen:
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
            case VPLVideoPlayerOrientationPortraitSmallScreen:
                viewWidth = portraitFullScreenWidth;
                viewHeight = portraitFullScreenWidth * 9.0 / 16.0;
                self.isFullScreen = NO;
                self.isPortrait = YES;
                break;
            case VPLVideoPlayerOrientationPortraitFullScreen:
                viewWidth = portraitFullScreenWidth;
                viewHeight = portraitFullScreenHeight;
                self.isFullScreen = YES;
                self.isPortrait = YES;
                break;
            case VPLVideoPlayerOrientationLandscapeFullScreen:
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
    
    self.nodeController.currentOrientation = type;
    [self.nodeController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
}

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))getUserInfoBlock {
    _getUserInfoBlock = getUserInfoBlock;
    [self.nodeController setGetUserInfoBlock:getUserInfoBlock];
}

- (void)startLoading {
    self.isStartLoading = YES;
    [self initLuaView];
}

- (void)stop {
    [self.nodeController releaseLuaView];
}

- (void)closeActionWebViewForAd:(NSString *)adId {
    [self.nodeController closeActionWebViewForAd:adId];
}

- (void)pauseVideoAd {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLPauseVideoPlayerNotification object:nil];
}

- (void)playVideoAd {
    [self.nodeController playVideoAd];
}

- (void)closeInfoView {
    [self.nodeController closeInfoView];
}

- (void)initNetworkManager {
    self.networkManager = [VPLNetworkManager Manager];
}

- (void)initLuaView {
    
    //    NSString *path = [NSBundle mainBundle].bundlePath;
    if (!self.videoInfo) {
        self.videoInfo = [[VPLVideoInfo alloc] init];
    }
    
    self.nodeController = [[VPLNodeController alloc] initWithViewFrame:self.bounds videoRect:self.bounds networkManager:self.networkManager videoInfo:self.videoInfo];
    self.nodeController.videoPlayerSize = self.videoPlayerSize;
    [self.nodeController changeDestinationPath:self.lPath];
    [self addSubview:self.nodeController.rootView];
    
    if (self.getUserInfoBlock) {
        [self.nodeController setGetUserInfoBlock:self.getUserInfoBlock];
    }
}

- (void)loadLFile:(NSString *)luaUrl data:(id)data {
    if (self.isStartLoading) {
        [self.nodeController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nodeController loadLFile:luaUrl data:data];
            if ([luaUrl isEqualToString:@"main.lua"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:VPLOSLoadCompleteNotification object:nil];
            }
        });
    }
}

- (void)callLMethod:(NSString *)method data:(id)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nodeController callLMethod:method data:data];
    });
}

- (void)callLMethod:(NSString *)method nodeId:(NSString *)nodeId data:(id)data {
    if (nodeId == nil) {
        [self callLMethod:method data:data];
    }
    else {
        [self.nodeController callLMethod:method nodeId:nodeId data:data];
    }
}

- (void)removeViewWithNodeId:(NSString *)nodeId {
    [self.nodeController removeNodeWithNodeId:nodeId];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

- (void)dealloc {
    [self.nodeController releaseLuaView];
    [VPLCapacityManager stopService];
    [VPLNetworkManager releaseManaer];
}

@end
