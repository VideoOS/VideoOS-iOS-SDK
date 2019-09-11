//
//  VPAppletLandscapeContainer.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLuaAppletObject.h"
#import "VPLuaNetworkManager.h"
#import "VPLuaVideoInfo.h"
#import "VPLuaAppletContainerDelegate.h"
#import "VPLuaAppletContainer.h"
#import "VPLuaAppletContainerLoadingView.h"
#import "VPLuaAppletContainerNetworkView.h"
#import "VPLuaAppletContainerErrorView.h"
#import "VPAppletLandscapeNavigationBar.h"


@interface VPAppletLandscapeContainer : UIView<VPLuaAppletContainer>

@property (nonatomic) NSString *appletID;
@property (nonatomic, assign) VPLuaAppletContainerType type;
@property (nonatomic, copy) NSDictionary *(^getUserInfoBlock)(void);
@property (nonatomic) NSDictionary *rootData;

@property (nonatomic, weak) VPLuaNetworkManager *networkManager;
@property (nonatomic) VPLuaVideoInfo *videoInfo;

@property (nonatomic) NSString *luaPath;
@property (nonatomic) NSString *appletPath;
@property (nonatomic, assign) BOOL retryLuaFiles;

@property (nonatomic) VPLuaAppletObject *applet;

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isShowed;

@property (nonatomic) UIView *mainView;

@property (nonatomic) VPAppletLandscapeNavigationBar *naviBar;

@property (nonatomic) VPLuaAppletContainerLoadingView *loadingView;
@property (nonatomic) VPLuaAppletContainerNetworkView *retryView;
@property (nonatomic) VPLuaAppletContainerErrorView *errorView;

@property (nonatomic) CGRect containFrame;

- (void)showLoadingView;
- (void)closeLoadingView;
- (void)showRetryView;
- (void)closeRetryView;
- (void)showErrorView;
- (void)closeErrorView;

- (void)updateNavi;

- (void)retryNetwork;

@end

