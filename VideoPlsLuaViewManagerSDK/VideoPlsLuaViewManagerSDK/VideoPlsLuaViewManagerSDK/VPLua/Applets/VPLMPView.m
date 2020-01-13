//
//  VPLMPView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLMPView.h"
#import "VideoPlsUtilsPlatformSDK.h"
#import "VideoPlsLuaViewSDK.h"
//#import "VPLServiceManager.h"
#import "VPUPRSAUtil.h"
#import "VPLSDK.h"
#import "VPLPlayer.h"
#import "VPMPContainer.h"
#import "VPMPLandscapeContainer.h"
#import "VPLMPLandscapeContainer.h"
#import "VPHMPLandscapeContainer.h"
#import "VPLOSView.h"
#import "VPLMPRequest.h"
#import "VPLMPAddRecent.h"

@interface VPLMPView () <VPMPContainerDelegate>

@property (nonatomic, weak) VPLNetworkManager *networkManager;

@property (nonatomic) NSMutableDictionary<NSString *, id<VPMPContainer>> *containers;

@property (nonatomic) NSMutableArray *currentMPIDs;

@property (nonatomic,   copy) NSString *lPath;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL isPortrait;

@property (nonatomic, assign) BOOL isStartLoading;
@property (nonatomic, assign) BOOL isOpenConfig;
@property (nonatomic, assign) BOOL configIsFullScreen;

@end

@implementation VPLMPView

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
        videoInfo.extendJSONString = VPUP_DictionaryToJson(extendInfo);
    }
    return [self initWithFrame:frame videoInfo:videoInfo];
}

- (instancetype)initWithFrame:(CGRect)frame videoInfo:(VPLVideoInfo *)videoInfo {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initNetworkManager];
        self.lPath = [VPUPPathUtil lmpPath];
        self.videoInfo = videoInfo;
        [VPLSDK sharedSDK].videoInfo = self.videoInfo;
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
    
//    [self.nodeController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
    //TODO: containers update frame
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
    
    [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPMPContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
        obj.currentOrientation = self.isPortrait ? VPMPContainerOrientationPortriat : VPMPContainerOrientationLandScape;
    }];
    
//    if (self.isPortrait) {
//        [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPMPContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
//            if (obj.type == VPMPContainerTypeLandscape) {
//                [obj hide];
//            }
//        }];
//    } else {
//        [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPMPContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
//            if (obj.type == VPMPContainerTypeLandscape) {
//                [obj show];
//            }
//        }];
//    }
//    self.nodeController.currentOrientation = type;
//    [self.nodeController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
    
    //TODO: containers update orientation
    
}

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))getUserInfoBlock {
    _getUserInfoBlock = getUserInfoBlock;
    
//    [self.nodeController setGetUserInfoBlock:getUserInfoBlock];
    //TODO: containers set userinfoblock
}

- (void)startLoading {
    self.isStartLoading = YES;
    if (!self.videoInfo) {
        self.videoInfo = [[VPLVideoInfo alloc] init];
    }
//    [self initLuaView];
}

- (void)stop {
    [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPMPContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
        obj.containerDelegate = nil;
        [obj destroyView];
    }];
    
    [self.containers removeAllObjects];
}

- (void)closeActionWebViewForAd:(NSString *)adId {
//    [self.nodeController closeActionWebViewForAd:adId];
}

- (void)pauseVideoAd {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLPauseVideoPlayerNotification object:nil];
}

- (void)playVideoAd {
//    [self.nodeController playVideoAd];
}

- (void)closeInfoView {
//    [self.nodeController closeInfoView];
}

#pragma mark - private

- (void)initNetworkManager {
    self.networkManager = [VPLNetworkManager Manager];
}

//跳转小程序   LuaView://applets?appletId=xxxx&type=x(type: 1横屏,2竖屏)&appType=x(appType: 1 lua,2 h5)
//容器内部跳转 LuaView://applets?appletId=xxxx&template=xxxx.lua&id=xxxx&priority=x
- (void)loadMPWithID:(NSString *)mpID data:(id)data {
    if (self.isStartLoading) {
        if (!self.containers) {
            self.containers = [NSMutableDictionary dictionary];
        }
        if (!self.currentMPIDs) {
            self.currentMPIDs = [NSMutableArray array];
        }
        
        NSDictionary *queryParams = [data objectForKey:VPUPRouteQueryParamsKey];
        
        if ([queryParams objectForKey:@"type"] != nil) {
            //新建流程
            NSInteger typeInt = [[queryParams objectForKey:@"type"] integerValue];
            VPMPContainerType type;
            if (typeInt > 0 && typeInt < 3) {
                type = typeInt;
            } else {
                type = VPMPContainerTypeLandscape;
            }
            
            [self createNewContainerWithType:type mpID:mpID queryParams:queryParams data:data];
            
        } else {
            //容器内部跳转
            [self pushLWithMPID:mpID queryParams:queryParams data:data];
        }
    }
}

- (void)createNewContainerWithType:(VPMPContainerType)type
                          mpID:(NSString *)mpID
                       queryParams:(NSDictionary *)queryParams
                              data:(id)data {
    
    switch (type) {
        case VPMPContainerTypeLandscape:
        {
            if (self.isPortrait) {
                //通知改横屏
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
                //1是横屏切竖屏,2是竖屏切横屏
                [dict setObject:@(2) forKey:@"orientation"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [[NSNotificationCenter defaultCenter] postNotificationName:VPLScreenChangeNotification object:nil userInfo:dict];
                });
            }
            if ([self checkContainerExistWithMPID:mpID]) {
                if ([queryParams objectForKey:@"template"] != nil) {
                    [self pushLWithMPID:mpID queryParams:queryParams data:data];
                } else {
                    //存在? 也没有跳转入口
                    //刷新lua
                    [self refereshContainerWithMPID:mpID data:data];
                    return;
                }
            }
            
            VPMPContainerAppType appType = VPMPContainerAppTypeLScript;
            if ([queryParams objectForKey:@"appType"] != nil) {
                NSInteger typeInt = [[queryParams objectForKey:@"appType"] integerValue];
                if (typeInt > 0 && typeInt < 3) {
                    appType = typeInt;
                }
            }
            VPMPLandscapeContainer *container;
            if (appType == VPMPContainerAppTypeLScript) {
                container = [[VPLMPLandscapeContainer alloc] initWithMPID:mpID networkManager:self.networkManager videoInfo:self.videoInfo lPath:self.lPath data:data];
                container.appType = VPMPContainerAppTypeLScript;
            } else {
                container = [[VPHMPLandscapeContainer alloc] initWithMPID:mpID networkManager:self.networkManager videoInfo:self.videoInfo lPath:self.lPath data:data];
                container.appType = VPMPContainerAppTypeHybird;
            }
            container.containerDelegate = self;
            
            [self.containers setObject:container forKey:mpID];
            
            [container showInSuperview:self];
            
            //track appletId
//            [[VPLMPRequest request] trackWithMPID:mpID apiManager:self.networkManager.httpManager];
            [VPLMPAddRecent addRecentWithMPID:mpID];
            //send close & open applet
            [self checkAndAddNewMPTrack:mpID];
            
            break;
        }
        case VPMPContainerTypePortrait:
        {
            
            break;
        }
        default:
            break;
    }
}

- (void)pushLWithMPID:(NSString *)mpID
            queryParams:(NSDictionary *)queryParams
                       data:(id)data {
    
    if (![self checkContainerExistWithMPID:mpID]) {
        //理论不会发生,外面已经check过
        return;
    }
    if (![queryParams objectForKey:@"template"]) {
        //理论不会发生,已经check过
        return;
    }
    id<VPMPContainer> container = [self.containers objectForKey:mpID];
    NSString *luaUrl = [queryParams objectForKey:@"template"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [container loadLFile:luaUrl data:data];
    });
}

- (void)refereshContainerWithMPID:(NSString *)mpID
                                 data:(id)data {
    if (![self checkContainerExistWithMPID:mpID]) {
        //理论不会发生,外面已经check过
        return;
    }
    
    id<VPMPContainer> container = [self.containers objectForKey:mpID];
    if ([container isKindOfClass:[UIView class]]) {
        [self bringSubviewToFront:(UIView *)container];
    }
    [container refreshContainerWithData:data];
    
    //track appletId
//    [[VPLMPRequest request] trackWithMPID:mpID apiManager:self.networkManager.httpManager];
    [VPLMPAddRecent addRecentWithMPID:mpID];
    //send close & open applet
    [self checkAndAddNewMPTrack:mpID];
}

- (BOOL)checkContainerExistWithMPID:(NSString *)mpID {
    if (!self.containers) {
        return NO;
    }
    if ([self.containers objectForKey:mpID]) {
        return YES;
    }
    return NO;
}

- (void)closeAllContainers {
    [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPMPContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
        
        obj.containerDelegate = nil;
        [obj closeContainer];
    }];
    [self.containers removeAllObjects];
    
    //移除发送关闭
    if (self.currentMPIDs.count > 0) {
        [self closeMPTrack:[self.currentMPIDs lastObject]];
        [self.currentMPIDs removeAllObjects];
    }
}

- (void)deleteContainerWithMPID:(NSString *)mpID {
    if ([self checkContainerExistWithMPID:mpID]) {
        [self.containers removeObjectForKey:mpID];
        
        //移除单个发送单个关闭
        [self checkAndCloseLastMPTrack:mpID];
    }
}

- (void)closeMPTrack:(NSString *)mpID {
    [[VPUPCommonTrack shared] sendTrackWithType:VPUPCommonTrackTypeCloseMP dataDict:@{@"appletId": mpID}];
}

- (void)openMPTrack:(NSString *)mpID {
    [[VPUPCommonTrack shared] sendTrackWithType:VPUPCommonTrackTypeOpenMP dataDict:@{@"appletId": mpID}];
}

- (void)checkAndAddNewMPTrack:(NSString *)newMPID {
    //打开新的，如果存在旧的则关闭旧的，如果是最后一个是当前小程序则什么都不发
    if (self.currentMPIDs.count > 0) {
        if ([[self.currentMPIDs lastObject] isEqualToString:newMPID]) {
            return;
        }
        [self closeMPTrack:[self.currentMPIDs lastObject]];
    }
    
    [self openMPTrack:newMPID];
    
    if ([self.currentMPIDs containsObject:newMPID]) {
        [self.currentMPIDs removeObject:newMPID];
    }
    
    [self.currentMPIDs addObject:newMPID];
}

- (void)checkAndCloseLastMPTrack:(NSString *)closeMPID {
    //先关闭当前
    [self closeMPTrack:closeMPID];
    [self.currentMPIDs removeObject:closeMPID];
    //再检测有没有需要打开的
    if (self.currentMPIDs.count > 0) {
        [self openMPTrack:[self.currentMPIDs lastObject]];
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

- (void)dealloc {
    [self stop];
//    [VPLServiceManager stopService];
    [VPLNetworkManager releaseManaer];
}


@end
