//
//  VPLuaBubbleView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VPLuaVideoPlayerSize.h"
#import "VPLuaVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPLuaBubbleView : UIView

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

- (void)callLuaMethod:(NSString *)method data:(id)data;

- (void)callLuaMethod:(NSString *)method nodeId:(NSString *)nodeId data:(id)data;

- (void)removeViewWithNodeId:(NSString *)nodeId;

- (void)stop;

- (void)closeActionWebViewForAd:(NSString *)adId;

- (void)pauseVideoAd;

- (void)playVideoAd;

- (void)closeInfoView;

@end

NS_ASSUME_NONNULL_END
