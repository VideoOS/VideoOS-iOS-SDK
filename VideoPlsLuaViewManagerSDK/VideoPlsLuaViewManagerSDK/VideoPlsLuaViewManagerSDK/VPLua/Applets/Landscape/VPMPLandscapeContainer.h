//
//  VPMPLandscapeContainer.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLMPObject.h"
#import "VPLNetworkManager.h"
#import "VPLVideoInfo.h"
#import "VPMPContainerDelegate.h"
#import "VPMPContainer.h"
#import "VPMPContainerLoadingView.h"
#import "VPMPContainerNetworkView.h"
#import "VPMPContainerErrorView.h"
#import "VPMPLandscapeNavigationBar.h"


@interface VPMPLandscapeContainer : UIView<VPMPContainer>

@property (nonatomic) NSString *mpID;
@property (nonatomic, assign) VPMPContainerType type;
@property (nonatomic, assign) VPMPContainerAppType appType;
@property (nonatomic, copy) NSDictionary *(^getUserInfoBlock)(void);
@property (nonatomic) NSMutableDictionary *rootData;

@property (nonatomic, weak) VPLNetworkManager *networkManager;
@property (nonatomic) VPLVideoInfo *videoInfo;

@property (nonatomic) NSString *lPath;
@property (nonatomic) NSString *mpPath;
@property (nonatomic, assign) BOOL retryLFiles;

@property (nonatomic) VPLMPObject *mpObject;

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isShowed;

@property (nonatomic) UIView *mainView;

@property (nonatomic) VPMPLandscapeNavigationBar *naviBar;

@property (nonatomic) VPMPContainerLoadingView *loadingView;
@property (nonatomic) VPMPContainerNetworkView *retryView;
@property (nonatomic) VPMPContainerErrorView *errorView;

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

