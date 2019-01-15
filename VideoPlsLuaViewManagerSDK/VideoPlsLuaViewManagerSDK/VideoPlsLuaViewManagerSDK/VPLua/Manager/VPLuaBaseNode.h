//
//  VPLuaBaseNode.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/8/29.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VPLuaNodeController;
@class LuaViewCore;
@class VPLuaBaseView;
@class VPLuaNetworkManager;
@class VPLuaVideoInfo;
@class VPLuaVideoPlayerSize;

@interface VPLuaBaseNode : NSObject

@property (nonatomic, weak, readonly) VPLuaBaseView *rootView;
@property (nonatomic, weak, readonly) LuaViewCore *lvCore;

@property (nonatomic, weak) VPLuaNodeController *luaController;
@property (nonatomic, weak) id nativeBridge;
@property (nonatomic) NSString *luaFile;

@property (nonatomic, weak) VPLuaNetworkManager *networkManager;
@property (nonatomic, weak) VPLuaVideoInfo *videoInfo;

@property (nonatomic, weak) NSDictionary *(^getUserInfoBlock)(void);


@property (nonatomic, copy) void (^renderCompletionHandler)(UIView *rootView);

@property (nonatomic, strong) VPLuaVideoPlayerSize *videoPlayerSize;

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
