//
//  VPHolderLandscapeContainer.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLuaHolderObject.h"
#import "VPLuaNetworkManager.h"
#import "VPLuaVideoInfo.h"
#import "VPLuaHolderContainerDelegate.h"
#import "VPLuaHolderContainer.h"
#import "VPLuaHolderContainerLoadingView.h"
#import "VPLuaHolderContainerNetworkView.h"
#import "VPLuaHolderContainerErrorView.h"
#import "VPHolderLandscapeNavigationBar.h"


@interface VPHolderLandscapeContainer : UIView<VPLuaHolderContainer>

@property (nonatomic) NSString *holderID;
@property (nonatomic, assign) VPLuaHolderContainerType type;
@property (nonatomic, copy) NSDictionary *(^getUserInfoBlock)(void);
@property (nonatomic) NSDictionary *rootData;

@property (nonatomic, weak) VPLuaNetworkManager *networkManager;
@property (nonatomic) VPLuaVideoInfo *videoInfo;

@property (nonatomic) NSString *luaPath;
@property (nonatomic) NSString *holderPath;
@property (nonatomic, assign) BOOL retryLuaFiles;

@property (nonatomic) VPLuaHolderObject *holder;

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isShowed;

@property (nonatomic) UIView *mainView;

@property (nonatomic) VPHolderLandscapeNavigationBar *naviBar;

@property (nonatomic) VPLuaHolderContainerLoadingView *loadingView;
@property (nonatomic) VPLuaHolderContainerNetworkView *retryView;
@property (nonatomic) VPLuaHolderContainerErrorView *errorView;

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

