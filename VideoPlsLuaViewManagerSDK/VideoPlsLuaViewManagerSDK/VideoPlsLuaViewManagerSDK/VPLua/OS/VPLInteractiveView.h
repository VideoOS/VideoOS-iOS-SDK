//
//  VPLInteractiveView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/10/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLVideoPlayerSize.h"
#import "VPLVideoInfo.h"

extern NSString *const VPOSLuaEndNotification;
extern NSString *const VPLOSLoadCompleteNotification;


/**
 *  事件处理通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPLEventType) {
    VPLEventTypeTypeNone = 0,
    VPLEventTypeOSAction,
    VPLEventTypeMPAction
};

/**
 *  AD事件处理通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPLOSActionType) {
    VPLOSActionTypeNone = 0,     //
    VPLOSActionTypeResume,         // 播放Ad
    VPLOSActionTypePause,        // 暂停Ad
};

typedef NS_ENUM(NSUInteger, VPLMPActionType) {
    VPLMPActionTypeNone = 0,     //
    VPLMPActionTypeRetry,         // 网络重试
    VPLMPActionTypeRefresh        // 刷新页面
};

@class VPLNodeController;

@interface VPLInteractiveView : UIView

@property (nonatomic, strong) VPLNodeController *nodeController;

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId;

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId extendInfo:(NSDictionary *)extendInfo;

- (instancetype)initWithFrame:(CGRect)frame videoInfo:(VPLVideoInfo *)videoInfo;

@property (nonatomic, copy) NSDictionary *(^getUserInfoBlock)(void);
@property (nonatomic, strong) VPLVideoPlayerSize *videoPlayerSize;
@property (nonatomic, strong) VPLVideoInfo *videoInfo;

- (void)updateFrame:(CGRect)frame
          videoRect:(CGRect)videoRect
       isFullScreen:(BOOL)isFullScreen;

- (void)updateVideoPlayerOrientation:(VPLVideoPlayerOrientation)type;

- (void)startLoading;

- (void)initLuaView;

- (void)loadLFile:(NSString *)luaUrl data:(id)data;

- (void)callLMethod:(NSString *)method data:(id)data;

- (void)callLMethod:(NSString *)method nodeId:(NSString *)nodeId data:(id)data;

- (void)removeViewWithNodeId:(NSString *)nodeId;

- (void)stop;

- (void)closeActionWebViewForAd:(NSString *)adId;

- (void)pauseVideoAd;

- (void)playVideoAd;

- (void)closeInfoView;

@end
