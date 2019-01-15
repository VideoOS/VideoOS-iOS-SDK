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

#import <VideoPlsLuaViewManagerSDK/VPLuaOSView.h>
#import <VideoPlsLuaViewManagerSDK/VPLuaMedia.h>
#import <VideoPlsLuaViewManagerSDK/VPLuaVideoInfo.h>
#import <VideoPlsLuaViewManagerSDK/VPLuaPage.h>
#import <VideoPlsLuaViewManagerSDK/VPLuaNativeBridge.h>
#import <VideoPlsLuaViewManagerSDK/VPLuaSDK.h>

#import <VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>
#import <VideoPlsUtilsPlatformSDK/VPUPInterfaceDataServiceManager.h>
#import <VideoPlsUtilsPlatformSDK/VPUPRoutes.h>
#import <VideoPlsUtilsPlatformSDK/VPUPRoutesConstants.h>

#import "VPInterfaceStatusNotifyDelegate.h"
#import "VPIUserLoginInterface.h"
#import "VPIUserInfo.h"

@interface VPInterfaceController()<VPUPInterfaceDataServiceManagerDelegate>

@end

@interface VPInterfaceController()

@property (nonatomic) VPLuaOSView *osView;

@property (nonatomic, readwrite, strong) VPInterfaceControllerConfig *config;

@property (nonatomic, assign) VPIVideoPlayerOrientation orientationType;

@property (nonatomic, strong) VPIVideoPlayerSize *videoPlayerSize;

@property (nonatomic, strong) NSDictionary *openUrlActionDict;;

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

- (instancetype)initWithFrame:(CGRect)frame
                       config:(VPInterfaceControllerConfig *)config
{
    return [self initWithFrame:frame config:config videoPlayerSize:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                   config:(VPInterfaceControllerConfig *)config
          videoPlayerSize:(VPIVideoPlayerSize *)size {
    NSAssert(config, @"config不能为空");
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
    _view = [[VPInterfaceClickThroughView alloc] initWithFrame:frame];
    [self initOSViewWithFrame:frame];
}

- (void)initOSViewWithFrame:(CGRect)frame {

    __weak typeof(self) weakSelf = self;
    NSString *platformId = nil;
    NSString *videoId = nil;

    platformId = _config.platformID;
    videoId = _config.identifier;
    if (_config.types & VPInterfaceControllerTypeVideoOS) {
        [VPLuaSDK setOSType:VPLuaOSTypeVideoOS];
    }
    else {
        [VPLuaSDK setOSType:VPLuaOSTypeLiveOS];
    }
    _osView = [[VPLuaOSView alloc] initWithFrame:frame platformId:platformId videoId:videoId extendInfo:_config.extendDict];
    VPLuaVideoPlayerSize *vpSize = [[VPLuaVideoPlayerSize alloc] init];
    vpSize.portraitSmallScreenHeight = self.videoPlayerSize.portraitSmallScreenHeight;
    vpSize.portraitFullScreenWidth = self.videoPlayerSize.portraitFullScreenWidth;
    vpSize.portraitFullScreenHeight = self.videoPlayerSize.portraitFullScreenHeight;
    vpSize.portraitSmallScreenOriginY = self.videoPlayerSize.portraitSmallScreenOriginY;
    _osView.videoPlayerSize = vpSize;
    [_osView setGetUserInfoBlock:^NSDictionary *(void) {
        return [weakSelf getUserInfoDictionary];
    }];
    [_view addSubview:_osView];
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

    if (!_osView) {
        [self initOSViewWithFrame:self.view.bounds];
    }
    if (_osView) {
        [_osView startLoading];
    }

    [self registerStatusNotification];
}

- (void)updateFrame:(CGRect)frame videoRect:(CGRect)videoRect isFullScreen:(BOOL)isFullScreen {
    _view.frame = frame;
}

- (void)notifyVideoScreenChanged:(VPIVideoPlayerOrientation)type {
    
    if (_orientationType == type) {
        return;
    }
    _orientationType = type;

    if (_osView) {
        [_osView updateVideoPlayerOrientation:(VPLuaVideoPlayerOrientation)type];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaMediaPlayerSizeNotification object:nil userInfo:dict];
    
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
    
    _canSet = YES;
}

- (void)platformCloseActionWebView {
    [_osView closeActionWebViewForAd:[self.openUrlActionDict objectForKey:@"adID"]];
}

- (void)closeInfoView {
    if (_osView) {
        [_osView closeInfoView];
    }
}

#pragma mark - Notification
- (void)registerStatusNotification {

    if(_osView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceLoadComplete:) name:VPLuaOSLoadCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyUserLogined:) name:VPLuaNotifyUserLoginedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyRequireLogin:) name:VPLuaRequireLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyScreenChange:) name:VPLuaScreenChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceActionNewNotify:) name:VPLuaActionNotification object:nil];
    }

}

- (void)unregisterStatusNotification {

    if(_osView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaOSLoadCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaNotifyUserLoginedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaRequireLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaScreenChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaActionNotification object:nil];
    }

}



- (NSDictionary *)getUserInfoDictionary {
    VPIUserInfo * userInfo = [self.userDelegate vp_getUserInfo];
    if (!userInfo) {
        return nil;
    }
    
    return [userInfo dictionaryForUser];
}

- (void)notifyScreenChange:(NSNotification *)sender {
    if (self.delegate) {
        NSDictionary *dic =  sender.userInfo;
        if (dic && [dic objectForKey:@"orientation"]) {
            [self.delegate vp_interfaceScreenChangedNotify:dic];
        }
    }
}

- (void)notifyUserLogined:(NSNotification *)sender {
    if (self.userDelegate) {
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
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_interfaceActionNotify:)]) {
            NSDictionary *userInfo = sender.userInfo;
            NSMutableDictionary *actionDict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            
            if ([[actionDict objectForKey:@"actionType"] integerValue] == VPIActionTypeOpenUrl) {
                self.openUrlActionDict = actionDict;
            }
            
            [self.delegate vp_interfaceActionNotify:actionDict];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaMediaStartNotification object:nil];
}

- (void)videoPlayerDidPlayVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaMediaPlayNotification object:nil];
}

/// Tells the delegate that the video player has paused video.
- (void)videoPlayerDidPauseVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaMediaPauseNotification object:nil];
}

/// Tells the delegate that the video player's video playback has ended.
- (void)videoPlayerDidStopVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaMediaEndNotification object:nil];
}

- (NSDictionary*)getUserInfo {
    return [self getUserInfoDictionary];
}

- (NSTimeInterval)videoPlayerCurrentItemAssetDuration {
    return [self.videoPlayerDelegate videoPlayerCurrentItemAssetDuration];
}

- (NSTimeInterval)videoPlayerCurrentTime {
    return [self.videoPlayerDelegate videoPlayerCurrentTime];
}

- (VPUPVideoPlayerSize *)videoPlayerSize {
    VPIVideoPlayerSize *vpiSize = [self.videoPlayerDelegate videoPlayerSize];
    VPUPVideoPlayerSize *vpupSize = [[VPUPVideoPlayerSize alloc] init];
    vpupSize.portraitFullScreenWidth = vpiSize.portraitFullScreenWidth;
    vpupSize.portraitFullScreenHeight = vpiSize.portraitFullScreenHeight;
    vpupSize.portraitSmallScreenHeight = vpiSize.portraitSmallScreenHeight;
    vpupSize.portraitSmallScreenOriginY = vpiSize.portraitSmallScreenOriginY;
    return vpupSize;
}

- (void)registerRoutes {
    [self registerLuaViewRoutes];
}

- (BOOL)canSet {
    return _canSet;
}

- (void)registerLuaViewRoutes {
    __weak typeof(self) weakSelf = self;
    [[VPUPRoutes routesForScheme:VPUPRoutesSDKLuaView] addRoute:@"/defaultLuaView" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        
        //判定osView是否存在，若不存在，先创建
        if (!weakSelf.osView) {
            [weakSelf initOSViewWithFrame:weakSelf.view.bounds];
            //TODO MQTT,如果_liveView不存在情况怎么处理
            
            if(!weakSelf.canSet) {
                [weakSelf.osView startLoading];
            }
        }
        
        id data = [[parameters objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"];
        if (!data) {
            data = [parameters objectForKey:VPUPRouteUserInfoKey];
        }
    
        NSDictionary *queryParams = [parameters objectForKey:VPUPRouteQueryParamsKey];
        NSString *luaFile = [queryParams objectForKey:@"template"];
        if (!luaFile) {
            luaFile = [data objectForKey:@"template"];
        }
        [weakSelf.osView loadLua:luaFile data:parameters];
        return YES;
    }];
}

- (void)unregisterRoutes {
    [self unregisterLuaViewRoutes];
}

- (void)unregisterLuaViewRoutes {
    [VPUPRoutes unregisterRouteScheme:VPUPRoutesSDKLuaView];
}

#pragma mark - view controller life cycle
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaPageWillAppearNotification object:nil userInfo:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaPageDidAppearNotification object:nil userInfo:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaPageWillDisappearNotification object:nil userInfo:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaPageDidDisappearNotification object:nil userInfo:nil];
}

- (void)launchData {
    [self navigationWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://defaultLuaView?template=main.lua&id=main",VPUPRoutesSDKLuaView]] data:nil];
}

- (void)navigationWithURL:(NSURL *)url data:(NSDictionary *)dict {
    [VPUPRoutes routeURL:url withParameters:dict completion:^(id  _Nonnull result) {
        
    }];
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
