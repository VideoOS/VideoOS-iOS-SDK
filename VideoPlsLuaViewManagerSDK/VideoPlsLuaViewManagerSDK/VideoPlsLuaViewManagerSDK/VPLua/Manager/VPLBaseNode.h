//
//  VPLBaseNode.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/8/29.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VPLNodeController;
@class LuaViewCore;
@class VPLBaseView;
@class VPLNetworkManager;
@class VPLVideoInfo;
@class VPLVideoPlayerSize;

@interface VPLBaseNode : NSObject

@property (nonatomic, weak, readonly) VPLBaseView *rootView;
@property (nonatomic, weak, readonly) LuaViewCore *lvCore;

@property (nonatomic, weak) VPLNodeController *nodeController;
@property (nonatomic, weak) id nativeBridge;
@property (nonatomic) NSString *lFile;

@property (nonatomic, weak) VPLNetworkManager *networkManager;
@property (nonatomic, weak) VPLVideoInfo *videoInfo;
@property (nonatomic, strong) NSString *developerUserId;
@property (nonatomic, strong) NSString *mpID;

@property (nonatomic, weak) NSDictionary *(^getUserInfoBlock)(void);


@property (nonatomic, copy) void (^renderCompletionHandler)(UIView *rootView);

@property (nonatomic, strong) VPLVideoPlayerSize *videoPlayerSize;

@property (nonatomic, copy) NSString *nodeId;

@property (nonatomic, assign) NSInteger priority;


- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame baseView:(NSString*)baseViewClass;

- (void)updateFrame:(CGRect)frame isPortrait:(BOOL)isPortraitScreen isFullScreen:(BOOL)isFullScreen;

- (void)updateData:(id)data;

- (NSString *)runLuaFile:(NSString *)filePath data:(id)data;
- (NSString *)callMethod:(NSString *)method data:(id)data;

//无需手动调用
- (UIView *)builRootView;

- (void)destroyView;


@end
