//
//  VPLMPView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLVideoPlayerSize.h"
#import "VPLVideoInfo.h"

@interface VPLMPView : UIView

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

- (void)loadMPWithID:(NSString *)mpID data:(id)data;

- (BOOL)checkContainerExistWithMPID:(NSString *)mpID;

- (void)stop;

- (void)closeInfoView;


@end
