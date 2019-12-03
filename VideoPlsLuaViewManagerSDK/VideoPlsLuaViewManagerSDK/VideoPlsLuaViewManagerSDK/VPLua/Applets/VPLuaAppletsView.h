//
//  VPLuaAppletsView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLuaVideoPlayerSize.h"
#import "VPLuaVideoInfo.h"

@interface VPLuaAppletsView : UIView

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

- (void)loadAppletWithID:(NSString *)appletID data:(id)data;

- (BOOL)checkContainerExistWithAppletID:(NSString *)appletID;

- (void)stop;

- (void)closeInfoView;


@end
