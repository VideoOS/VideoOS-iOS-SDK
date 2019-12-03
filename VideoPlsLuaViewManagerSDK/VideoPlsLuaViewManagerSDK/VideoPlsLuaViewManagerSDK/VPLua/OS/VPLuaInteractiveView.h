//
//  VPLuaInteractiveView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/10/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLuaVideoPlayerSize.h"
#import "VPLuaVideoInfo.h"

extern NSString *const VPOSLuaEndNotification;
extern NSString *const VPLuaOSLoadCompleteNotification;


/**
 *  事件处理通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPLuaEventType) {
    VPLuaEventTypeTypeNone = 0,
    VPLuaEventTypeOSAction,
    VPLuaEventTypeAppletAction
};

/**
 *  AD事件处理通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPLuaOSActionType) {
    VPLuaOSActionTypeNone = 0,     //
    VPLuaOSActionTypeResume,         // 播放Ad
    VPLuaOSActionTypePause,        // 暂停Ad
};

typedef NS_ENUM(NSUInteger, VPLuaAppletActionType) {
    VPLuaAppletActionTypeNone = 0,     //
    VPLuaAppletActionTypeRetry,         // 网络重试
    VPLuaAppletActionTypeRefresh        // 刷新页面
};

@class VPLuaNodeController;

@interface VPLuaInteractiveView : UIView

@property (nonatomic, strong) VPLuaNodeController *luaController;

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId;

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId extendInfo:(NSDictionary *)extendInfo;

- (instancetype)initWithFrame:(CGRect)frame videoInfo:(VPLuaVideoInfo *)videoInfo;

@property (nonatomic, copy) NSDictionary *(^getUserInfoBlock)(void);
@property (nonatomic, strong) VPLuaVideoPlayerSize *videoPlayerSize;
@property (nonatomic, strong) VPLuaVideoInfo *videoInfo;

- (void)updateFrame:(CGRect)frame
          videoRect:(CGRect)videoRect
       isFullScreen:(BOOL)isFullScreen;

- (void)updateVideoPlayerOrientation:(VPLuaVideoPlayerOrientation)type;

- (void)startLoading;

- (void)initLuaView;

- (void)loadLua:(NSString *)luaUrl data:(id)data;

- (void)callLuaMethod:(NSString *)method data:(id)data;

- (void)callLuaMethod:(NSString *)method nodeId:(NSString *)nodeId data:(id)data;

- (void)removeViewWithNodeId:(NSString *)nodeId;

- (void)stop;

- (void)closeActionWebViewForAd:(NSString *)adId;

- (void)pauseVideoAd;

- (void)playVideoAd;

- (void)closeInfoView;

@end
