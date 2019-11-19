//
//  VPLuaHolderView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaHolderView.h"
#import "VideoPlsUtilsPlatformSDK.h"
#import "VideoPlsLuaViewSDK.h"
//#import "VPLuaServiceManager.h"
#import "VPUPRSAUtil.h"
#import "VPLuaSDK.h"
#import "VPLuaPlayer.h"
#import "VPLuaHolderContainer.h"
#import "VPHolderLandscapeContainer.h"
#import "VPLuaHolderLandscapeContainer.h"
#import "VPHybirdHolderLandscapeContainer.h"
#import "VPLuaOSView.h"
#import "VPLuaHolderRequest.h"

@interface VPLuaHolderView () <VPLuaHolderContainerDelegate>

@property (nonatomic, weak) VPLuaNetworkManager *networkManager;

@property (nonatomic) NSMutableDictionary<NSString *, id<VPLuaHolderContainer>> *containers;

@property (nonatomic,   copy) NSString *luaPath;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL isPortrait;

@property (nonatomic, assign) BOOL isStartLoading;
@property (nonatomic, assign) BOOL isOpenConfig;
@property (nonatomic, assign) BOOL configIsFullScreen;

@end

@implementation VPLuaHolderView

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
        [self initNetworkManager];
//        [VPLuaServiceManager startService];
        self.luaPath = [VPUPPathUtil luaHolderPath];
        
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
    
//    [self.luaController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
    //TODO: containers update frame
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
    
    if (self.isPortrait) {
        [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPLuaHolderContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.type == VPLuaHolderContainerTypeLandscape) {
                [obj hide];
            }
        }];
    } else {
        [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPLuaHolderContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.type == VPLuaHolderContainerTypeLandscape) {
                [obj show];
            }
        }];
    }
//    self.luaController.currentOrientation = type;
//    [self.luaController updateFrame:self.bounds isPortrait:self.isPortrait isFullScreen:self.isFullScreen];
    
    //TODO: containers update orientation
    
}

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))getUserInfoBlock {
    _getUserInfoBlock = getUserInfoBlock;
    
//    [self.luaController setGetUserInfoBlock:getUserInfoBlock];
    //TODO: containers set userinfoblock
}

- (void)startLoading {
    self.isStartLoading = YES;
    if (!self.videoInfo) {
        self.videoInfo = [[VPLuaVideoInfo alloc] init];
    }
//    [self initLuaView];
}

- (void)stop {
    [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPLuaHolderContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
        obj.containerDelegate = nil;
        [obj destroyView];
    }];
    
    [self.containers removeAllObjects];
}

- (void)closeActionWebViewForAd:(NSString *)adId {
//    [self.luaController closeActionWebViewForAd:adId];
}

- (void)pauseVideoAd {
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaPauseVideoPlayerNotification object:nil];
}

- (void)playVideoAd {
//    [self.luaController playVideoAd];
}

- (void)closeInfoView {
//    [self.luaController closeInfoView];
}

#pragma mark - private

- (void)initNetworkManager {
    self.networkManager = [VPLuaNetworkManager Manager];
}

//跳转小程序   LuaView://holder?holderId=xxxx&type=x(type: 1横屏,2竖屏)&appType=x(appType: 1 lua,2 h5)
//容器内部跳转 LuaView://holder?holderId=xxxx&template=xxxx.lua&id=xxxx&priority=x
- (void)loadHolderWithID:(NSString *)holderID data:(id)data {
    if (self.isStartLoading) {
        if (!self.containers) {
            self.containers = [NSMutableDictionary dictionary];
        }
        
        NSDictionary *queryParams = [data objectForKey:VPUPRouteQueryParamsKey];
        
        if ([queryParams objectForKey:@"type"] != nil) {
            //新建流程
            NSInteger typeInt = [[queryParams objectForKey:@"type"] integerValue];
            VPLuaHolderContainerType type;
            if (typeInt > 0 && typeInt < 3) {
                type = typeInt;
            } else {
                type = VPLuaHolderContainerTypeLandscape;
            }
            
            [self createNewContainerWithType:type holderID:holderID queryParams:queryParams data:data];
            
        } else {
            //容器内部跳转
            [self pushLuaWithHolderID:holderID queryParams:queryParams data:data];
        }
    }
}

- (void)createNewContainerWithType:(VPLuaHolderContainerType)type
                          holderID:(NSString *)holderID
                       queryParams:(NSDictionary *)queryParams
                              data:(id)data {
    
    switch (type) {
        case VPLuaHolderContainerTypeLandscape:
        {
            if (self.isPortrait) {
                //通知改横屏
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
                //1是横屏切竖屏,2是横屏切竖屏
                [dict setObject:@(2) forKey:@"orientation"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaScreenChangeNotification object:nil userInfo:dict];
                });
            }
            if ([self checkContainerExistWithHolderID:holderID]) {
                if ([queryParams objectForKey:@"template"] != nil) {
                    [self pushLuaWithHolderID:holderID queryParams:queryParams data:data];
                } else {
                    //存在? 也没有跳转入口
                    //刷新lua
                    [self refereshContainerWithHolderID:holderID data:data];
                    return;
                }
            }
            
            VPHolderContainerAppType appType = VPHolderContainerAppTypeLua;
            if ([queryParams objectForKey:@"appType"] != nil) {
                NSInteger typeInt = [[queryParams objectForKey:@"appType"] integerValue];
                if (typeInt > 0 && typeInt < 3) {
                    appType = typeInt;
                }
            }
            VPHolderLandscapeContainer *container;
            if (appType == VPHolderContainerAppTypeLua) {
                container = [[VPLuaHolderLandscapeContainer alloc] initWithHolderID:holderID networkManager:self.networkManager videoInfo:self.videoInfo luaPath:self.luaPath data:data];
            } else {
                container = [[VPHybirdHolderLandscapeContainer alloc] initWithHolderID:holderID networkManager:self.networkManager videoInfo:self.videoInfo luaPath:self.luaPath data:data];
            }
            container.containerDelegate = self;
            
            [self.containers setObject:container forKey:holderID];
            
            [container showInSuperview:self];
            
            //track holderId
            [[VPLuaHolderRequest request] trackWithHolderID:holderID apiManager:self.networkManager.httpManager];
            
            break;
        }
        case VPLuaHolderContainerTypePortrait:
        {
            
            break;
        }
        default:
            break;
    }
}

- (void)pushLuaWithHolderID:(NSString *)holderID
            queryParams:(NSDictionary *)queryParams
                       data:(id)data {
    
    if (![self checkContainerExistWithHolderID:holderID]) {
        //理论不会发生,外面已经check过
        return;
    }
    if (![queryParams objectForKey:@"template"]) {
        //理论不会发生,已经check过
        return;
    }
    id<VPLuaHolderContainer> container = [self.containers objectForKey:holderID];
    NSString *luaUrl = [queryParams objectForKey:@"template"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [container loadLua:luaUrl data:data];
    });
}

- (void)refereshContainerWithHolderID:(NSString *)holderID
                                 data:(id)data {
    if (![self checkContainerExistWithHolderID:holderID]) {
        //理论不会发生,外面已经check过
        return;
    }
    
    id<VPLuaHolderContainer> container = [self.containers objectForKey:holderID];
    if ([container isKindOfClass:[UIView class]]) {
        [self bringSubviewToFront:(UIView *)container];
    }
    [container refreshContainerWithData:data];
    
    //track holderId
    [[VPLuaHolderRequest request] trackWithHolderID:holderID apiManager:self.networkManager.httpManager];
}

- (BOOL)checkContainerExistWithHolderID:(NSString *)holderID {
    if (!self.containers) {
        return NO;
    }
    if ([self.containers objectForKey:holderID]) {
        return YES;
    }
    return NO;
}

- (void)closeAllContainers {
    [self.containers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<VPLuaHolderContainer>  _Nonnull obj, BOOL * _Nonnull stop) {
        
        obj.containerDelegate = nil;
        [obj closeContainer];
    }];
    [self.containers removeAllObjects];
}

- (void)deleteContainerWithHolderID:(NSString *)holderID {
    if ([self checkContainerExistWithHolderID:holderID]) {
        [self.containers removeObjectForKey:holderID];
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
//    [VPLuaServiceManager stopService];
    [VPLuaNetworkManager releaseManaer];
}


@end
