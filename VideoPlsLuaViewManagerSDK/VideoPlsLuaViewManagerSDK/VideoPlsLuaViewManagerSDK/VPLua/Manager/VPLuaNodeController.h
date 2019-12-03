//
//  VPLuaNodeController.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/8/30.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaVideoPlayerSize.h"

@class VPLuaBaseNode;
@class VPLuaNetworkManager;
@class VPLuaVideoInfo;
@class VPLuaVideoPlayerSize;

@protocol VPLuaNodeControllerLoadDelegate <NSObject>

- (void)loadLuaError:(NSString *)error;

@end

@protocol VPLuaNodeControllerAppletDelegate <NSObject>

- (void)showRetryPage:(NSString *)retryMessage retryData:(id)data nodeId:(NSString *)nodeId;
- (void)showErrorPage:(NSString *)errorMessage;

- (BOOL)canGoBack;
- (void)goBack;
- (void)closeView;

@end

@interface VPLuaNodeController : NSObject


+ (void)saveLuaFileWithUrl:(NSString *)url md5:(NSString *)md5;

//+ (VPLuaNodeController *)getControllerWithLuaViewCore:(id)luaViewCore native:(id)nativeBridge;

@property (nonatomic) VPLuaVideoInfo *videoInfo;

@property (nonatomic, weak) id<VPLuaNodeControllerLoadDelegate> luaDelegate;

@property (nonatomic, weak) id<VPLuaNodeControllerAppletDelegate> appletDelegate;

@property (nonatomic, assign, readonly, getter=isPortrait) BOOL portrait;
@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;
@property (nonatomic, assign) VPLuaVideoPlayerOrientation currentOrientation;

//- (instancetype)initWithViewFrame:(CGRect)frame videoRect:(CGRect)videoRect;


/**
 *  初始化生成LuaController
 *
 *  @param frame 区域大小
 *  @param videoRect 视频尺寸
 *  @param networkManager 网络管理者, 内含业务相关使用的http, image等
 *  @param videoInfo 和本视频相关信息
 *  @return LuaController
 */
- (instancetype)initWithViewFrame:(CGRect)frame
                        videoRect:(CGRect)videoRect
                   networkManager:(VPLuaNetworkManager *)networkManager
                        videoInfo:(VPLuaVideoInfo *)videoInfo NS_DESIGNATED_INITIALIZER;

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))userInfoBlock;

@property (nonatomic, readonly) UIView *rootView;


@property (nonatomic ,readonly, copy) NSString *destinationPath;

@property (nonatomic, strong) VPLuaVideoPlayerSize *videoPlayerSize;

- (void)changeDestinationPath:(NSString *)destinationPath;

- (void)updateFrame:(CGRect)frame isPortrait:(BOOL)isPortrait isFullScreen:(BOOL)isFullScreen;

- (void)updateData:(id)data;

/**
 *  加载lua
 *  @param luaUrl lua文件所在url, 可为网络http也可为本地file
 *  @param data lua文件所需data
 */
- (void)loadLua:(NSString *)luaUrl data:(id)data;

- (void)callLuaMethod:(NSString *)method data:(id)data;

- (void)callLuaMethod:(NSString *)method nodeId:(NSString *)nodeId data:(id)data;

- (void)removeNodeWithNodeId:(NSString *)nodeId;

- (void)removeLastNode;

- (VPLuaBaseNode*)createNode;

- (void)removeNode:(VPLuaBaseNode *)node;

- (void)releaseLuaView;

- (void)closeActionWebViewForAd:(NSString *)adId;

- (void)playVideoAd;

- (void)closeInfoView;

@end
