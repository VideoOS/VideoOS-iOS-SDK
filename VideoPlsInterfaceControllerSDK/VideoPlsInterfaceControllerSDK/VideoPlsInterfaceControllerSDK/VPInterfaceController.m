/*
 ---------------------------------------------------------------------------
 VideoOS - A Mini-App platform base on video player
 http://videojj.com/videoos/
 Copyright (C) 2019  Shanghai Ji Lian Network Technology Co., Ltd
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 ---------------------------------------------------------------------------
 */
//
//  VPInterfaceController.m
//  VideoPlsInterfaceViewSDK
//
//  Created by Zard1096 on 2017/6/25.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPInterfaceController.h"
#import "VPInterfaceClickThroughView.h"

#import "VPLOSView.h"
#import "VPLMPView.h"
#import "VPLBubbleView.h"
#import "VPLMedia.h"
#import "VPLVideoInfo.h"
#import "VPLTopView.h"
#import "VPLPage.h"
#import "VPLNativeBridge.h"
#import "VPLSDK.h"
#import "VPLScriptManager.h"

#import "VideoPlsUtilsPlatformSDK.h"
#import "VPUPInterfaceDataServiceManager.h"
#import "VPUPRoutes.h"
#import "VPUPRoutesConstants.h"
#import "VPUPPathUtil.h"

#import "VPInterfaceStatusNotifyDelegate.h"
#import "VPIUserLoginInterface.h"
#import "VPIUserInfo.h"
#import "VPLServiceAd.h"
#import "VPIError.h"
#import "VPLServiceManager.h"
#import "VPUPJsonUtil.h"

@interface VPInterfaceController()<VPUPInterfaceDataServiceManagerDelegate, VPLServiceManagerDelegate>

@end

@interface VPInterfaceController()

@property (nonatomic, strong) VPLOSView *osView;

@property (nonatomic, strong) VPLMPView *mpView;

@property (nonatomic, strong) VPLBubbleView *bubbleView;

@property (nonatomic, strong) VPLTopView *topView;

@property (nonatomic, readwrite, strong) VPInterfaceControllerConfig *config;

@property (nonatomic, assign) VPIVideoPlayerOrientation orientationType;

@property (nonatomic, strong) VPIVideoPlayerSize *videoPlayerSize;

@property (nonatomic, strong) NSDictionary *openUrlActionDict;

@property (nonatomic, strong) VPLServiceManager *serviceManager;

@property (nonatomic, strong) VPLVideoInfo *videoInfo;

@end

@implementation VPInterfaceController {
    BOOL _canSet;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void)startVideoPls {

}

+ (void)stopVideoPls {

}

+ (void)switchToDebug:(BOOL)isDebug {
    if(isDebug) {
        [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateTest];
    }
    else {
        [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateOnline];
    }
}

- (VPLServiceManager *)serviceManager {
    if (!_serviceManager) {
        _serviceManager = [[VPLServiceManager alloc] init];
    }
    return _serviceManager;
}

- (instancetype)initWithFrame:(CGRect)frame
                       config:(VPInterfaceControllerConfig *)config
{
    return [self initWithFrame:frame config:config videoPlayerSize:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                   config:(VPInterfaceControllerConfig *)config
          videoPlayerSize:(VPIVideoPlayerSize *)size {
    NSAssert(config, @"config不能为空");
    NSAssert(config.identifier && config.episode && config.title, @"config identifier,episode,title 不能为空");
    if (!config) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _canSet = YES;
        _orientationType = -1;
        self.videoPlayerSize = size;
        [self initViewWithFrame:frame config:config];
        [VPUPInterfaceDataServiceManager managerWithVPUPDataServiceManagerDelegate:self];
        [self registerRoutes];
    }
    return self;
}

- (void)initViewWithFrame:(CGRect)frame
                           config:(VPInterfaceControllerConfig *)config {
    _config = config;
    _videoInfo = [self interfaceControllerConfigToVideoInfo:config];
    _view = [[VPInterfaceClickThroughView alloc] initWithFrame:frame];
    
    if (_config.types & VPInterfaceControllerTypeVideoOS) {
        [VPLSDK setOSType:VPLOSTypeVideoOS];
    }
    else {
        [VPLSDK setOSType:VPLOSTypeLiveOS];
    }
    
    [self initOSViewWithFrame:frame];
    [self initMPViewWithFrame:frame];
    [self initBubbleViewWithFrame:frame];
    [self initTopViewWithFrame:frame];
}

- (void)initOSViewWithFrame:(CGRect)frame {
    
    _osView = [[VPLOSView alloc] initWithFrame:frame videoInfo:_videoInfo];
    VPLVideoPlayerSize *vpSize = [[VPLVideoPlayerSize alloc] init];
    vpSize.portraitSmallScreenHeight = self.videoPlayerSize.portraitSmallScreenHeight;
    vpSize.portraitFullScreenWidth = self.videoPlayerSize.portraitFullScreenWidth;
    vpSize.portraitFullScreenHeight = self.videoPlayerSize.portraitFullScreenHeight;
    vpSize.portraitSmallScreenOriginY = self.videoPlayerSize.portraitSmallScreenOriginY;
    _osView.videoPlayerSize = vpSize;
    __weak typeof(self) weakSelf = self;
    [_osView setGetUserInfoBlock:^NSDictionary *(void) {
        return [weakSelf getUserInfoDictionary];
    }];
    [_view addSubview:_osView];
}

- (void)initMPViewWithFrame:(CGRect)frame {
    
    _mpView = [[VPLMPView alloc] initWithFrame:frame videoInfo:_videoInfo];
    VPLVideoPlayerSize *vpSize = [[VPLVideoPlayerSize alloc] init];
    vpSize.portraitSmallScreenHeight = self.videoPlayerSize.portraitSmallScreenHeight;
    vpSize.portraitFullScreenWidth = self.videoPlayerSize.portraitFullScreenWidth;
    vpSize.portraitFullScreenHeight = self.videoPlayerSize.portraitFullScreenHeight;
    vpSize.portraitSmallScreenOriginY = self.videoPlayerSize.portraitSmallScreenOriginY;
    _mpView.videoPlayerSize = vpSize;
    __weak typeof(self) weakSelf = self;
    [_mpView setGetUserInfoBlock:^NSDictionary *(void) {
        return [weakSelf getUserInfoDictionary];
    }];
    [_view addSubview:_mpView];
}

- (void)initBubbleViewWithFrame:(CGRect)frame {
    
    _bubbleView = [[VPLBubbleView alloc] initWithFrame:frame videoInfo:_videoInfo];
    VPLVideoPlayerSize *vpSize = [[VPLVideoPlayerSize alloc] init];
    vpSize.portraitSmallScreenHeight = self.videoPlayerSize.portraitSmallScreenHeight;
    vpSize.portraitFullScreenWidth = self.videoPlayerSize.portraitFullScreenWidth;
    vpSize.portraitFullScreenHeight = self.videoPlayerSize.portraitFullScreenHeight;
    vpSize.portraitSmallScreenOriginY = self.videoPlayerSize.portraitSmallScreenOriginY;
    _bubbleView.videoPlayerSize = vpSize;
    __weak typeof(self) weakSelf = self;
    [_bubbleView setGetUserInfoBlock:^NSDictionary *(void) {
        return [weakSelf getUserInfoDictionary];
    }];
    [_view addSubview:_bubbleView];
    [_view bringSubviewToFront:_bubbleView];
}

- (void)initTopViewWithFrame:(CGRect)frame {

    _topView = [[VPLTopView alloc] initWithFrame:frame videoInfo:_videoInfo];
    VPLVideoPlayerSize *vpSize = [[VPLVideoPlayerSize alloc] init];
    vpSize.portraitSmallScreenHeight = self.videoPlayerSize.portraitSmallScreenHeight;
    vpSize.portraitFullScreenWidth = self.videoPlayerSize.portraitFullScreenWidth;
    vpSize.portraitFullScreenHeight = self.videoPlayerSize.portraitFullScreenHeight;
    vpSize.portraitSmallScreenOriginY = self.videoPlayerSize.portraitSmallScreenOriginY;
    _topView.videoPlayerSize = vpSize;
    __weak typeof(self) weakSelf = self;
    [_topView setGetUserInfoBlock:^NSDictionary *(void) {
        return [weakSelf getUserInfoDictionary];
    }];
    [_view addSubview:_topView];
    [_view bringSubviewToFront:_topView];
}

- (VPLVideoInfo *)interfaceControllerConfigToVideoInfo:(VPInterfaceControllerConfig *)config {
    if (!config) {
        return nil;
    }
    VPLVideoInfo *videoInfo = [[VPLVideoInfo alloc] init];
    videoInfo.nativeID = config.identifier;
    videoInfo.platformID = config.platformID;
    videoInfo.episode = config.episode;
    videoInfo.title = config.title;
    videoInfo.extendDict = config.extendDict;
    return videoInfo;
}

- (BOOL)validateSetAttribute {
    if(!_canSet) {
        //TODO: already start loading, could not set
        return NO;
    }
    
    if(!_view) {
        //TODO: Assert use wrong init method
        return NO;
    }
    
    return YES;
}

#pragma mark Interface loading and control
//需要支持重新加载，start需要对有些数据初始化
- (void)start {
    
    NSAssert(_view, @"使用错误的init方法, view不存在");
    
    if(!_canSet) {
        return;
    }
    
    _orientationType = -1;
    _canSet = NO;
    
    if (_config.identifier != _videoInfo.nativeID) {
        _videoInfo = [self interfaceControllerConfigToVideoInfo:_config];
    }

    if (!_osView) {
        [self initOSViewWithFrame:self.view.bounds];
    }
    if (_osView) {
        [_osView startLoading];
    }
    if (!_mpView) {
        [self initMPViewWithFrame:self.view.bounds];
    }
    if (_mpView) {
        [_mpView startLoading];
    }
    if (!_bubbleView) {
        [self initBubbleViewWithFrame:self.view.bounds];
    }
    if (_bubbleView) {
        [_bubbleView startLoading];
    }
    if (!_topView) {
        [self initTopViewWithFrame:self.view.bounds];
    }
    if (_topView) {
        [_topView startLoading];
    }
    [self registerStatusNotification];
}

- (void)updateFrame:(CGRect)frame videoRect:(CGRect)videoRect isFullScreen:(BOOL)isFullScreen {
    _view.frame = frame;
}

- (void)notifyVideoScreenChanged:(VPIVideoPlayerOrientation)type {
    
    _orientationType = type;

    if (_osView) {
        [_osView updateVideoPlayerOrientation:(VPLVideoPlayerOrientation)type];
    }
    if (_mpView) {
        [_mpView updateVideoPlayerOrientation:(VPLVideoPlayerOrientation)type];
    }
    if (_bubbleView) {
        [_bubbleView updateVideoPlayerOrientation:(VPLVideoPlayerOrientation)type];
    }
    if (_topView) {
        [_topView updateVideoPlayerOrientation:(VPLVideoPlayerOrientation)type];
    }
    CGFloat width = 0;
    CGFloat height = 0;
    
    CGFloat viewWidth = 0;
    CGFloat viewHeight = 0;
    
    switch (type) {
        case VPIVideoPlayerOrientationPortraitSmallScreen:
            width = self.videoPlayerSize.portraitFullScreenWidth;
            height = self.videoPlayerSize.portraitSmallScreenHeight;
            viewWidth = self.videoPlayerSize.portraitFullScreenWidth;
            viewHeight = self.videoPlayerSize.portraitFullScreenHeight;
            break;
        case VPIVideoPlayerOrientationPortraitFullScreen:
            width = self.videoPlayerSize.portraitFullScreenWidth;
            height = self.videoPlayerSize.portraitFullScreenHeight;
            viewWidth = self.videoPlayerSize.portraitFullScreenWidth;
            viewHeight = self.videoPlayerSize.portraitFullScreenHeight;
            break;
        case VPIVideoPlayerOrientationLandscapeFullScreen:
            width = self.videoPlayerSize.portraitFullScreenHeight;
            height = self.videoPlayerSize.portraitFullScreenWidth;
            viewWidth = self.videoPlayerSize.portraitFullScreenHeight;
            viewHeight = self.videoPlayerSize.portraitFullScreenWidth;
            break;
            
        default:
            break;
    }
    CGRect rect = _view.frame;
    rect.size.width = viewWidth;
    rect.size.height = viewHeight;
    _view.frame = rect;
    NSDictionary *dict = @{
                           @"width":@(width),
                           @"height":@(height),
                           @"orientation":@(type)
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLMediaPlayerSizeNotification object:nil userInfo:dict];
    
}

//需要支持重新加载，stop需要对有些数据清空
- (void)stop {
    
    if(_canSet) {
        return;
    }
    
    [self unregisterStatusNotification];
    
    if (_osView) {
        [_osView stop];
        [_osView removeFromSuperview];
        _osView = nil;
    }
    
    if (_mpView) {
        [_mpView stop];
        [_mpView removeFromSuperview];
        _mpView = nil;
    }
    
    if (_bubbleView) {
        [_bubbleView stop];
        [_bubbleView removeFromSuperview];
        _bubbleView = nil;
    }
    
    if (_topView) {
        [_topView stop];
        [_topView removeFromSuperview];
        _topView = nil;
    }
    
    _canSet = YES;
}

- (void)platformCloseActionWebView {
    if (_osView) {
        [_osView closeActionWebViewForAd:[self.openUrlActionDict objectForKey:@"adID"]];
    }
    if (_topView) {
        [_topView closeActionWebViewForAd:[self.openUrlActionDict objectForKey:@"adID"]];
    }
}

- (void)pauseVideoAd {
    if (_osView) {
        [_osView pauseVideoAd];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(VPLOSActionTypePause), @"osActionType",
                              @(VPLEventTypeOSAction), @"eventType",nil];
        [_osView callLMethod:@"event" data:dict];
    }
    if (_topView) {
        [_topView pauseVideoAd];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(VPLOSActionTypePause), @"osActionType",
                              @(VPLEventTypeOSAction), @"eventType",nil];
        [_topView callLMethod:@"event" data:dict];
    }
}

- (void)playVideoAd {
    if (_osView) {
        [_osView playVideoAd];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(VPLOSActionTypeResume),@"osActionType",
                              @(VPLEventTypeOSAction), @"eventType",nil];
        [_osView callLMethod:@"event" data:dict];
    }
    if (_topView) {
        [_topView playVideoAd];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(VPLOSActionTypeResume),@"osActionType",
                              @(VPLEventTypeOSAction), @"eventType",nil];
        [_topView callLMethod:@"event" data:dict];
    }
}

- (void)closeInfoView {
    if (_osView) {
        [_osView closeInfoView];
    }
    if (_topView) {
        [_topView closeInfoView];
    }
}

#pragma mark - Notification
- (void)registerStatusNotification {

    if(_osView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceLoadComplete:) name:VPLOSLoadCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyUserLogined:) name:VPLNotifyUserLoginedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyRequireLogin:) name:VPLRequireLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyScreenChange:) name:VPLScreenChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceActionNewNotify:) name:VPLActionNotification object:nil];
    }

}

- (void)unregisterStatusNotification {

    if(_osView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLOSLoadCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLNotifyUserLoginedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLRequireLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLScreenChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLActionNotification object:nil];
    }

}



- (NSDictionary *)getUserInfoDictionary {
    VPIUserInfo * userInfo = nil;
    if (self.userDelegate && [self.userDelegate respondsToSelector:@selector(vp_getUserInfo)]) {
        userInfo = [self.userDelegate vp_getUserInfo];
    }
    if (!userInfo) {
        return nil;
    }
    
    return [userInfo dictionaryForUser];
}

- (void)notifyScreenChange:(NSNotification *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(vp_interfaceScreenChangedNotify:)]) {
        NSDictionary *dic = sender.userInfo;
        if (dic && [dic objectForKey:@"orientation"]) {
            [self.delegate vp_interfaceScreenChangedNotify:dic];
        }
    }
}

- (void)notifyUserLogined:(NSNotification *)sender {
    if (self.userDelegate && [self.userDelegate respondsToSelector:@selector(vp_userLogined:)]) {
        NSDictionary *dic = sender.userInfo;
        if (dic) {
            VPIUserInfo *userInfo = [[VPIUserInfo alloc] init];
            if(![dic objectForKey:@"uid"]) {
                return;
            }
            userInfo.uid = [dic objectForKey:@"uid"];
            
            if([dic objectForKey:@"nickName"]) {
                userInfo.nickName = [dic objectForKey:@"nickName"];
            }
            if([dic objectForKey:@"token"]) {
                userInfo.token = [dic objectForKey:@"token"];
            }
            if([dic objectForKey:@"phoneNum"]) {
                userInfo.phoneNum = [dic objectForKey:@"phoneNum"];
            }
            if ([dic objectForKey: @"userName"]) {
                userInfo.userName = [dic objectForKey:@"userName"];
            }
            
            [self.userDelegate vp_userLogined:userInfo];
        }
    }
}

- (void)notifyRequireLogin:(NSNotification *)sender {
    if (self.userDelegate) {
        NSDictionary *dic = sender.userInfo;
        if (dic && [dic objectForKey:@"completeBlock"]) {
            __block void (^blockCompleteBlock)(NSDictionary *userInfo) = [[dic objectForKey:@"completeBlock"] copy];
            
            void (^completeBlock)(VPIUserInfo *userInfo) = ^(VPIUserInfo *userInfo) {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                if(!userInfo.uid) {
                    blockCompleteBlock(nil);
                    return;
                }
                
                [dictionary setObject:userInfo.uid forKey:@"uid"];
                
                if(userInfo.token) {
                    [dictionary setObject:userInfo.token forKey:@"token"];
                }
                if(userInfo.nickName) {
                    [dictionary setObject:userInfo.nickName forKey:@"nickName"];
                }
                if(userInfo.userName) {
                    [dictionary setObject:userInfo.userName forKey:@"userName"];
                }
                if(userInfo.phoneNum) {
                    [dictionary setObject:userInfo.phoneNum forKey:@"phoneNum"];
                }
                
                blockCompleteBlock(dictionary);
            };
            
            if ([self.userDelegate respondsToSelector:@selector(vp_requireLogin:)]) {
                [self.userDelegate vp_requireLogin:completeBlock];
            }
        }
    }
}

- (void)notifyLuaEnd:(NSNotification *)sender {
//    if (self.delegate) {
//        if([self.delegate respondsToSelector:@selector(vp_interfaceEnjoyEnd)]) {
//            [self.delegate vp_interfaceEnjoyEnd];
//        }
//    }
}

- (void)notifyChangeToPortrait:(NSNotification *)sender {
//    if (self.delegate) {
//        if([self.delegate respondsToSelector:@selector(vp_interfaceEnjoyChangeToPortrait:)]) {
//            BOOL toPortrait = [sender.userInfo objectForKey:@"portrait"];
//            [self.delegate vp_interfaceEnjoyChangeToPortrait:toPortrait];
//        }
//    }
}

- (void)interfaceLoadComplete:(NSNotification *)sender {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_interfaceLoadComplete:)]) {
            if(_osView) {
                [self.delegate vp_interfaceLoadComplete:nil];
            }
        }
    }
}

- (void)interfaceLoadError:(NSNotification *)sender {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_interfaceLoadError:)]) {
            NSDictionary *userInfo = sender.userInfo;
            if([userInfo objectForKey:@"ErrorState"]) {
                NSInteger errorState = [[userInfo objectForKey:@"ErrorState"] integerValue];
                NSString *errorString = nil;
                
                //详见 VPCytronViewLoadErrorState 和 LDSDKIVAViewLoadErrorState ,两者一致
                switch (errorState) {
                    case 0:
                        //已经不常见
                        errorString = @"错误的地址";
                        break;
                    case 1:
                        //已经不常见
                        errorString = @"错误的地址格式或为本地文件";
                        break;
                    case 2:
                        //可能由于本地网络不稳定,也有可能服务器网络不稳定
                        errorString = @"连接服务器出错";
                        break;
                    case 3:
                        //连接超时
                        errorString = @"网络连接超时";
                        break;
                    case 4:
                        //
                        errorString = @"无效AppKey";
                        break;
                    case 5:
                        //
                        errorString = @"Appkey与bundleID不匹配";
                        break;
                    case 6:
                        //
                        errorString = @"网络连接取消";
                        break;
                    default:
                        errorString = @"未知错误";
                        break;
                }
                
                [self.delegate vp_interfaceLoadError:errorString];
            }
        }
    }
}

- (void)interfaceActionNewNotify:(NSNotification *)sender {
    
    NSLog(@"%@",sender);
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_interfaceActionNotify:)]) {
            NSDictionary *userInfo = sender.userInfo;
            NSMutableDictionary *actionDict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            
            if ([[actionDict objectForKey:@"actionType"] integerValue] == VPIActionTypeOpenUrl) {
                self.openUrlActionDict = actionDict;
            }
            
            [self.delegate vp_interfaceActionNotify:actionDict];
            
            if ([[actionDict objectForKey:@"eventType"] integerValue] == VPIEventTypeClose && self.serviceManager.serviceDict.count > 0) {
                NSNumber *closeServiceKey = nil;
                for (NSNumber *key in self.serviceManager.serviceDict.allKeys) {
                    VPLService *service = [self.serviceManager.serviceDict objectForKey:key];
                    if (service && [service.serviceId isEqualToString:[actionDict objectForKey:@"adID"]]) {
                        if (self.serviceDelegate && [self.serviceDelegate respondsToSelector:@selector(vp_didCompleteForService:)]) {
                            [self.serviceDelegate vp_didCompleteForService:(VPIServiceType)service.type];
                        }
                        closeServiceKey = key;
                    }
                }
                if (closeServiceKey) {
                    [self.serviceManager stopService:(VPLServiceType)[closeServiceKey integerValue]];
                }
            }
        }
    }
}

- (void)interfaceVideoAdBackNotify:(NSNotification *)sender {
//    if ([self.delegate respondsToSelector:@selector(vp_interfaceVideoAdBack)]) {
//        [self.delegate vp_interfaceVideoAdBack];
//    }
}

- (BOOL)isString:(NSString *)string containsString:(NSString *)insideString {
    if(([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)) {
        return [string containsString:insideString];
    }
    else {
        return [string rangeOfString:insideString].location != NSNotFound;
    }
}

- (void)pauseInterfaceView:(BOOL)isPause {

}

- (void)dealloc {
    [self stop];
    [VPUPInterfaceDataServiceManager deallocManager];
    [self unregisterRoutes];
}

- (void)videoPlayerDidStartVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLMediaStartNotification object:nil];
}

- (void)videoPlayerDidPlayVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLMediaPlayNotification object:nil];
}

/// Tells the delegate that the video player has paused video.
- (void)videoPlayerDidPauseVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLMediaPauseNotification object:nil];
}

/// Tells the delegate that the video player's video playback has ended.
- (void)videoPlayerDidStopVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLMediaEndNotification object:nil];
}

- (NSDictionary*)getUserInfo {
    return [self getUserInfoDictionary];
}

- (NSTimeInterval)videoPlayerCurrentItemAssetDuration {
    if (self.videoPlayerDelegate && [self.videoPlayerDelegate respondsToSelector:@selector(videoPlayerCurrentItemAssetDuration)]) {
        return [self.videoPlayerDelegate videoPlayerCurrentItemAssetDuration];
    }
    return 0;
}

- (NSTimeInterval)videoPlayerCurrentTime {
    if (self.videoPlayerDelegate && [self.videoPlayerDelegate respondsToSelector:@selector(videoPlayerCurrentTime)]) {
        return [self.videoPlayerDelegate videoPlayerCurrentTime];
    }
    return 0;
}

- (VPUPVideoPlayerSize *)videoPlayerSize {
    if (self.videoPlayerDelegate && [self.videoPlayerDelegate respondsToSelector:@selector(videoPlayerSize)]) {
        VPIVideoPlayerSize *vpiSize = [self.videoPlayerDelegate videoPlayerSize];
        VPUPVideoPlayerSize *vpupSize = [[VPUPVideoPlayerSize alloc] init];
        vpupSize.portraitFullScreenWidth = vpiSize.portraitFullScreenWidth;
        vpupSize.portraitFullScreenHeight = vpiSize.portraitFullScreenHeight;
        vpupSize.portraitSmallScreenHeight = vpiSize.portraitSmallScreenHeight;
        vpupSize.portraitSmallScreenOriginY = vpiSize.portraitSmallScreenOriginY;
        return vpupSize;
    }
    
    CGFloat portraitFullScreenWidth = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.height);
    CGFloat portraitFullScreenHeight = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.height);
    VPUPVideoPlayerSize *vpupSize = [[VPUPVideoPlayerSize alloc] init];
    vpupSize.portraitFullScreenWidth = portraitFullScreenWidth;
    vpupSize.portraitFullScreenHeight = portraitFullScreenHeight;
    vpupSize.portraitSmallScreenHeight = portraitFullScreenWidth * 9 / 16;
    vpupSize.portraitSmallScreenOriginY = 0;
    return vpupSize;
}

- (CGRect)videoFrame {
    if (self.videoPlayerDelegate && [self.videoPlayerDelegate respondsToSelector:@selector(videoFrame)]) {
        return [self.videoPlayerDelegate videoFrame];
    }
    return self.view.frame;
}

- (BOOL)acrDelegateEnable{
    if (self.acrDelegate) {
        return YES;
    }else{
        return NO;
    }
}

- (int)acrRecordStart{
    if (self.acrDelegate && [self.acrDelegate respondsToSelector:@selector(acrRecordStart)]) {
        [self.acrDelegate acrRecordStart];
        return 1;
    }else{
        return 0;
    }
}

- (void)acrRecordEndAndcallback:(VPUPACRResourcesCallback)resourcesCallback{
    
    if (self.acrDelegate && [self.acrDelegate respondsToSelector:@selector(acrRecordEndAndcallback:)]) {
        [self.acrDelegate acrRecordEndAndcallback:^(NSString * musicPath) {
            resourcesCallback(musicPath);
        }];
    }
}

- (void)registerRoutes {
    [self registerLViewRoutes];
}

- (BOOL)canSet {
    return _canSet;
}

- (void)registerLViewRoutes {
    __weak typeof(self) weakSelf = self;
    [[VPUPRoutes routesForScheme:VPUPRoutesSDKLView] addRoute:@"/defaultLuaView" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        
        if (!weakSelf) {
            return NO;
        }
        __strong typeof(self) strongSelf = weakSelf;
        //判定osView是否存在，若不存在，先创建
        if (!strongSelf.osView) {
            [strongSelf initOSViewWithFrame:strongSelf.view.bounds];
            //TODO MQTT,如果_liveView不存在情况怎么处理
            
            if(!strongSelf.canSet) {
                [strongSelf.osView startLoading];
            }
        }
        
        id data = [[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"];
        if (!data) {
            data = [parameters objectForKey:VPUPRouteUserInfoKey];
        }
    
        NSDictionary *queryParams = [parameters objectForKey:VPUPRouteQueryParamsKey];
        NSString *lFile = [queryParams objectForKey:@"template"];
        if (!lFile) {
            lFile = [data objectForKey:@"template"];
        }
        
        NSString *miniAppId = [queryParams objectForKey:@"miniAppId"];
        if (!miniAppId) {
            miniAppId = [[data objectForKey:@"miniAppInfo"] objectForKey:@"miniAppId"];
        }
        
        NSString *lFilePath = nil;
        if (miniAppId) {
            lFilePath = [miniAppId stringByAppendingPathComponent:lFile];
        }
        else {
            lFilePath = lFile;
        }
        
        [strongSelf.osView loadLFile:lFilePath data:parameters];
        return YES;
    }];
    
    //跳转小程序   LuaView://applets?appletId=xxxx&type=x(type: 1横屏,2竖屏)&appType=x(appType: 1 lua,2 h5)
    //容器内部跳转 LuaView://applets?appletId=xxxx&template=xxxx.lua&id=xxxx&priority=x
    [[VPUPRoutes routesForScheme:VPUPRoutesSDKLView] addRoute:@"/applets" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        
        if (!weakSelf) {
            return NO;
        }
        __strong typeof(self) strongSelf = weakSelf;
        //判定osView是否存在，若不存在，先创建
        if (!strongSelf.mpView) {
            [strongSelf initMPViewWithFrame:strongSelf.view.bounds];
            
            if(!strongSelf.canSet) {
                [strongSelf.mpView startLoading];
            }
        }
        
        NSDictionary *queryParams = [parameters objectForKey:VPUPRouteQueryParamsKey];
        NSString *mpID = [queryParams objectForKey:@"appletId"];
        if (!mpID) {
            return NO;
        }
        id type = [queryParams objectForKey:@"type"];
        id template = [queryParams objectForKey:@"template"];
        
        if (!type && !template) {
            //都不存在
            return NO;
        }
        
        if (!type && template) {
            //没有type有入口
            if (![strongSelf.mpView checkContainerExistWithMPID:mpID]) {
                //没有对应的容器
                return NO;
            }
        }
        
        [strongSelf.mpView loadMPWithID:mpID data:parameters];
    
        return YES;
    }];
    
    [[VPUPRoutes routesForScheme:VPUPRoutesSDKLView] addRoute:@"/desktopLuaView" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        
        if (!weakSelf) {
            return NO;
        }
        __strong typeof(self) strongSelf = weakSelf;
        //判定osView是否存在，若不存在，先创建
        if (!strongSelf.bubbleView) {
            [strongSelf initBubbleViewWithFrame:strongSelf.view.bounds];
            //TODO MQTT,如果_liveView不存在情况怎么处理
            
            if(!strongSelf.canSet) {
                [strongSelf.bubbleView startLoading];
            }
        }
        
        id data = [[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"];
        if (!data) {
            data = [parameters objectForKey:VPUPRouteUserInfoKey];
        }
        
        NSDictionary *queryParams = [parameters objectForKey:VPUPRouteQueryParamsKey];
        NSString *lFile = [queryParams objectForKey:@"template"];
        if (!lFile) {
            lFile = [data objectForKey:@"template"];
        }
        
        NSString *miniAppId = [queryParams objectForKey:@"miniAppId"];
        if (!miniAppId) {
            miniAppId = [[data objectForKey:@"miniAppInfo"] objectForKey:@"miniAppId"];
        }
        
        NSString *lFilePath = nil;
        if (miniAppId) {
            lFilePath = [miniAppId stringByAppendingPathComponent:lFile];
        }
        else {
            lFilePath = lFile;
        }
        [strongSelf.bubbleView loadLFile:lFilePath data:parameters];
        return YES;
    }];
    
    [[VPUPRoutes routesForScheme:VPUPRoutesSDKLView] addRoute:@"/topLuaView" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        
        if (!weakSelf) {
            return NO;
        }
        __strong typeof(self) strongSelf = weakSelf;
        //判定osView是否存在，若不存在，先创建
        if (!strongSelf.topView) {
            [strongSelf initTopViewWithFrame:strongSelf.view.bounds];
            //TODO MQTT,如果_liveView不存在情况怎么处理
            
            if(!strongSelf.canSet) {
                [strongSelf.topView startLoading];
            }
        }
        
        id data = [[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"];
        if (!data) {
            data = [parameters objectForKey:VPUPRouteUserInfoKey];
        }
        
        NSDictionary *queryParams = [parameters objectForKey:VPUPRouteQueryParamsKey];
        NSString *lFile = [queryParams objectForKey:@"template"];
        if (!lFile) {
            lFile = [data objectForKey:@"template"];
        }
        
        NSString *miniAppId = [queryParams objectForKey:@"miniAppId"];
        if (!miniAppId) {
            miniAppId = [[data objectForKey:@"miniAppInfo"] objectForKey:@"miniAppId"];
        }
        
        NSString *lFilePath = nil;
        if (miniAppId) {
            lFilePath = [miniAppId stringByAppendingPathComponent:lFile];
        }
        else {
            lFilePath = lFile;
        }
        
        [strongSelf.topView loadLFile:lFilePath data:parameters];
        return YES;
    }];
}

- (void)unregisterRoutes {
    [self unregisterLViewRoutes];
}

- (void)unregisterLViewRoutes {
    [VPUPRoutes unregisterRouteScheme:VPUPRoutesSDKLView];
}

#pragma mark - view controller life cycle
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLPageWillAppearNotification object:nil userInfo:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLPageDidAppearNotification object:nil userInfo:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLPageWillDisappearNotification object:nil userInfo:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLPageDidDisappearNotification object:nil userInfo:nil];
}

- (void)launchData {
    [self navigationWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://defaultLuaView?template=main.lua&id=main",VPUPRoutesSDKLView]] data:nil];
}

- (void)navigationWithURL:(NSURL *)url data:(NSDictionary *)dict {
    [VPUPRoutes routeURL:url withParameters:dict completion:^(id  _Nonnull result) {
        
    }];
}
    
- (void)startService:(VPIServiceType )type config:(VPIServiceConfig *)config {
    VPLServiceConfig *serviceConfig = [[VPLServiceConfig alloc] init];
    if (config.identifier) {
        serviceConfig.identifier = config.identifier;
    }
    else {
        serviceConfig.identifier = self.config.identifier;
    }
    serviceConfig.type = (VPLServiceType)config.type;
    serviceConfig.duration = (VPIVideoAdTimeType)config.duration;
    serviceConfig.videoModeType = (VPLVideoModeType)config.videoModeType;
    serviceConfig.eyeOriginPoint = config.eyeOriginPoint;
    
    self.serviceManager.osView = self.osView;
    self.serviceManager.bubbleView = self.bubbleView;
    self.serviceManager.topView = self.topView;
    self.serviceManager.delegate = self;
    
    [self.serviceManager startService:(VPLServiceType)type config:serviceConfig];
    
//    if (type == VPIServiceTypePreAdvertising || type == VPIServiceTypePostAdvertising || type == VPIServiceTypePauseAd) {
//        VPLServiceAd *adService = [[VPLServiceAd alloc] init];
//        VPLServiceConfig *serviceConfig = [[VPLServiceConfig alloc] init];
//        serviceConfig.type = (VPLServiceType)config.type;
//        serviceConfig.duration = (VPIVideoAdTimeType)config.duration;
//        [self.serviceDict setObject:adService forKey:@(VPIServiceTypePreAdvertising)];
//        __weak typeof(self) weakSelf = self;
//        [adService startServiceWithConfig:serviceConfig complete:^(NSError *error) {
//            if (!weakSelf) {
//                return;
//            }
//
//            if (error) {
//                if (self.serviceDelegate && [self.serviceDelegate respondsToSelector:@selector(vp_didFailToCompleteForService:error:)]) {
//                    [self.serviceDelegate vp_didFailToCompleteForService:(VPIServiceType)type error:error];
//                }
//                weakSelf.serviceDict[@(type)] = nil;
//            }
//        }];
//    }
}
 
- (void)resumeService:(VPIServiceType )type {
    [self.serviceManager resumeService:(VPLServiceType)type];
//    VPLService *service = [self.serviceDict objectForKey:@(type)];
//    if (service && _osView) {
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                              @(VPLAdActionTypePause), @"ActionType",
//                              @(VPLAdEventTypeAction), @"EventType",nil];
//        [_osView callLMethod:@"event" nodeId:service.serviceId data:dict];
//    }
}
    
- (void)pauseService:(VPIServiceType )type {
    [self.serviceManager pauseService:(VPLServiceType)type];
//    VPLService *service = [self.serviceDict objectForKey:@(type)];
//    if (service && _osView) {
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                              @(VPLAdActionTypeResume), @"ActionType",
//                              @(VPLAdEventTypeAction), @"EventType",nil];
//        [_osView callLMethod:@"event" nodeId:service.serviceId data:dict];
//    }
}
    
- (void)stopService:(VPIServiceType)type {
    [self.serviceManager stopService:(VPLServiceType)type];
//    VPLService *service = [self.serviceDict objectForKey:@(type)];
//    if (service && _osView) {
//        [_osView removeViewWithNodeId:service.serviceId];
//    }
}

#pragma mark - VPLServiceManagerDelegate

- (void)vp_didCompleteForService:(VPLServiceType )type {
    if (self.serviceDelegate && [self.serviceDelegate respondsToSelector:@selector(vp_didCompleteForService:)]) {
        [self.serviceDelegate vp_didCompleteForService:(VPIServiceType)type];
    }
}


- (void)vp_didFailToCompleteForService:(VPLServiceType )type error:(NSError *)error {
    if (self.serviceDelegate && [self.serviceDelegate respondsToSelector:@selector(vp_didFailToCompleteForService:error:)]) {
        [self.serviceDelegate vp_didFailToCompleteForService:(VPIServiceType)type error:error];
    }
}


#pragma mark - Unused API

- (BOOL)videoAdsIsPlaying {
    return NO;
}

- (void)pauseVideoAd:(BOOL)isPause {
    
}

- (void)openEnjoyConfigPage:(BOOL)isFullScreen {
    
}

- (void)openGoodsList {
    
}

- (void)updateCurrentPlaybackTime:(NSTimeInterval)milliSecond {
    
}

- (void)closeAllInfoLayer {
    
}

@end
