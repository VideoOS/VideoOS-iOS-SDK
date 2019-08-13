//
//  VPLuaOSView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 05/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLuaVideoPlayerSize.h"
#import "VPLuaVideoInfo.h"

extern NSString *const VPOSLuaEndNotification;
extern NSString *const VPLuaOSLoadCompleteNotification;


/**
 *  事件处理通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPLuaAdEventType) {
    VPLuaAdEventTypeNone = 0,
    VPLuaAdEventTypeAction,
};

/**
 *  事件处理通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPLuaAdActionType) {
    VPLuaAdActionTypeNone = 0,     //
    VPLuaAdActionTypeResume,         // 播放Ad
    VPLuaAdActionTypePause,        // 暂停Ad
};

@interface VPLuaOSView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId;

- (instancetype)initWithFrame:(CGRect)frame platformId:(NSString *)platformId videoId:(NSString *)videoId extendInfo:(NSDictionary *)extendInfo;

@property (nonatomic, copy) NSDictionary *(^getUserInfoBlock)(void);
@property (nonatomic, strong) VPLuaVideoPlayerSize *videoPlayerSize;
@property (nonatomic, strong) VPLuaVideoInfo *videoInfo;

- (void)updateFrame:(CGRect)frame
          videoRect:(CGRect)videoRect
       isFullScreen:(BOOL)isFullScreen;

- (void)updateVideoPlayerOrientation:(VPLuaVideoPlayerOrientation)type;

- (void)startLoading;

- (void)loadLua:(NSString *)luaUrl data:(id)data;

- (void)callLuaMethood:(NSString *)method data:(id)data;

- (void)callLuaMethood:(NSString *)method nodeId:(NSString *)nodeId data:(id)data;

- (void)removeViewWithNodeId:(NSString *)nodeId;

- (void)stop;

- (void)closeActionWebViewForAd:(NSString *)adId;

- (void)pauseVideoAd;

- (void)playVideoAd;

- (void)closeInfoView;

@end
