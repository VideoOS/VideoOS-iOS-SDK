//
//  VPLNodeController.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/8/30.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLVideoPlayerSize.h"

@class VPLBaseNode;
@class VPLNetworkManager;
@class VPLVideoInfo;
@class VPLVideoPlayerSize;

@protocol VPLNodeControllerLoadDelegate <NSObject>

- (void)loadLFileError:(NSString *)error;

@end

@protocol VPLNodeControllerMPDelegate <NSObject>

- (void)showRetryPage:(NSString *)retryMessage retryData:(id)data nodeId:(NSString *)nodeId;
- (void)showErrorPage:(NSString *)errorMessage;

- (BOOL)canGoBack;
- (void)goBack;
- (void)closeView;

@end

@interface VPLNodeController : NSObject


+ (void)saveLFileWithUrl:(NSString *)url md5:(NSString *)md5;

//+ (VPLNodeController *)getControllerWithLuaViewCore:(id)luaViewCore native:(id)nativeBridge;

@property (nonatomic) VPLVideoInfo *videoInfo;

@property (nonatomic, weak) id<VPLNodeControllerLoadDelegate> nodeDelegate;

@property (nonatomic, weak) id<VPLNodeControllerMPDelegate> mpDelegate;

@property (nonatomic, assign, readonly, getter=isPortrait) BOOL portrait;
@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;
@property (nonatomic, assign) VPLVideoPlayerOrientation currentOrientation;

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
                   networkManager:(VPLNetworkManager *)networkManager
                        videoInfo:(VPLVideoInfo *)videoInfo NS_DESIGNATED_INITIALIZER;

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))userInfoBlock;

@property (nonatomic, readonly) UIView *rootView;


@property (nonatomic ,readonly, copy) NSString *destinationPath;

@property (nonatomic, strong) VPLVideoPlayerSize *videoPlayerSize;

- (void)changeDestinationPath:(NSString *)destinationPath;

- (void)updateFrame:(CGRect)frame isPortrait:(BOOL)isPortrait isFullScreen:(BOOL)isFullScreen;

- (void)updateData:(id)data;

/**
 *  加载lua
 *  @param luaUrl lua文件所在url, 可为网络http也可为本地file
 *  @param data lua文件所需data
 */
- (void)loadLFile:(NSString *)luaUrl data:(id)data;

- (void)callLMethod:(NSString *)method data:(id)data;

- (void)callLMethod:(NSString *)method nodeId:(NSString *)nodeId data:(id)data;

- (void)removeNodeWithNodeId:(NSString *)nodeId;

- (void)removeLastNode;

- (VPLBaseNode*)createNode;

- (void)removeNode:(VPLBaseNode *)node;

- (void)releaseLuaView;

- (void)closeActionWebViewForAd:(NSString *)adId;

- (void)playVideoAd;

- (void)closeInfoView;

@end
