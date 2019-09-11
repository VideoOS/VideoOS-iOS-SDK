//
//  VPAppletLandscapeContainer.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPAppletLandscapeContainer.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPLuaAppletRequest.h"
#import "VPLuaNodeController.h"
#import "VPUPRoutes.h"
#import "VPUPHexColors.h"
#import "VPUPEncryption.h"
#import "VPLuaAppletObject.h"
#import "VPLuaLoader.h"
#import "UIButton+VPUPFillColor.h"
#import "VPUPViewScaleUtil.h"
#import "VPUPPathUtil.h"


@interface VPAppletLandscapeContainer()<VPLuaAppletContainerNetworkDelegate, VPAppletNavigationBarDelegate>

@end

@implementation VPAppletLandscapeContainer
@synthesize containerDelegate;

- (instancetype)initWithAppletID:(NSString *)appletID
                  networkManager:(VPLuaNetworkManager *)networkManager
                       videoInfo:(VPLuaVideoInfo *)videoInfo
                         luaPath:(NSString *)luaPath
                            data:(id)data {
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect containerFrame = frame;
    containerFrame.size.width = MAX(frame.size.width, frame.size.height);
    containerFrame.size.height = MIN(frame.size.width, frame.size.height);
    
    return [self initWithFrame:containerFrame appletID:appletID networkManager:networkManager videoInfo:videoInfo luaPath:luaPath data:data];
}

- (instancetype)initWithFrame:(CGRect)frame
                     appletID:(NSString *)appletID
               networkManager:(VPLuaNetworkManager *)networkManager
                    videoInfo:(VPLuaVideoInfo *)videoInfo
                      luaPath:(NSString *)luaPath
                         data:(id)data {
    
    self = [super initWithFrame:frame];
    if (self) {
        _networkManager = networkManager;
        _appletID = appletID;
        _videoInfo = videoInfo;
        _luaPath = luaPath;
        if (_appletID != nil && ![_appletID isEqualToString:@""]) {
            _appletPath = [VPUPPathUtil subPathOfLuaApplets:_appletID];
        }
        _rootData = data;
        _type = VPLuaAppletContainerTypeLandscape;
        [self requestApplet];
        [self initView];
    }
    return self;
}

- (void)showInSuperview:(UIView *)superview {
    
    if (_isShowing || _isShowed) {
        return;
    }
    if (self.superview) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [superview addSubview:self];
        [self startAppearAnimation];
    });
    
}

- (void)requestApplet {
    __weak typeof(self) weakSelf = self;
    if (_appletID == nil || [_appletID isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 直接显示错误
            [weakSelf showErrorView];
            [weakSelf.errorView changeErrorMessage:@"小程序服务不可用，换个标签再试"];
        });
        return;
    }
    [[VPLuaAppletRequest request] requestWithAppletID:_appletID apiManager:_networkManager.httpManager complete:^(VPLuaAppletObject *luaObject, NSError *error) {
        //有object进入prefetch,error显示重试页面
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (error.code == 1002) {
                    [weakSelf showErrorView];
                    [weakSelf.errorView changeErrorMessage:@"小程序服务不可用，换个标签再试"];
                    return;
                }
                //retry or error,看错误详情
                [weakSelf showRetryView];
                [weakSelf.retryView changeNetworkMessage:@"小程序加载失败，请重试"];
                return;
            }
            
            weakSelf.applet = luaObject;
            [weakSelf loadContainView];
        });
    }];
    
}

- (void)initView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
    UITapGestureRecognizer *backTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllContainer)];
    [backgroundView addGestureRecognizer:backTapGesture];
    
    [self addSubview:backgroundView];
    
    _mainView = [[UIView alloc] init];
    CGRect mainFrame = CGRectZero;
    mainFrame.size.height = self.frame.size.height;
    mainFrame.size.width = self.frame.size.height / 375 * 230;
    mainFrame.origin.x = self.frame.size.width - mainFrame.size.width;
    mainFrame.origin.y = 0;
    _mainView.frame = mainFrame;
    _mainView.backgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"3C4049"];
    
    [self addSubview:_mainView];
    
    [self initNavigationBar];
    [_mainView addSubview:_naviBar];
    
    _containFrame = CGRectZero;
    _containFrame.size.width = _mainView.bounds.size.width;
    _containFrame.size.height = _mainView.bounds.size.height - _naviBar.bounds.size.height;
    _containFrame.origin.x = 0;
    _containFrame.origin.y = _naviBar.bounds.size.height;
    
    [self initContainView];
    [self updateContainUserInfo];
    
    [self showLoadingView];
}

- (void)initNavigationBar {
    CGFloat itemHeight = 36 * VPUPViewScale;
    _naviBar = [[VPAppletLandscapeNavigationBar alloc] initWithFrame:CGRectMake(0, 0, _mainView.bounds.size.width, itemHeight)];
    _naviBar.delegate = self;
}

- (void)updateNavi {
    if (!self.applet.naviSetting) {
        return;
    }
    [_naviBar updateNavi:self.applet.naviSetting];
}

- (void)initContainView {
    
}

- (void)updateContainUserInfo {
    
}

- (void)loadContainView {
    
}

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))getUserInfoBlock {
    _getUserInfoBlock = getUserInfoBlock;
    [self updateContainUserInfo];
}

- (void)closeContainer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startDisappearAnimation];
    });
}

- (id)getInitData {
    NSDictionary *data = nil;
    if ([[self.rootData objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"]) {
        data = [[self.rootData objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerData"];
    }
    else if ([[self.rootData objectForKey:VPUPRouteUserInfoKey] objectForKey:@"ActionManagerSender"]) {
        data = nil;
    }
    else {
        //不是从sendAction来的数据
        data = [self.rootData objectForKey:VPUPRouteUserInfoKey];
    }
    
    return data;
}

- (void)loadLua:(NSString *)luaUrl data:(id)data {
    
}

- (void)refreshContainerWithData:(id)data {
    
}

- (void)destroyView {
    [self removeFromSuperview];
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(deleteContainerWithAppletID:)]) {
        [self.containerDelegate deleteContainerWithAppletID:self.appletID];
    }
    self.containerDelegate = nil;
}

- (void)naviBackButtonTapped {

}

- (void)naviCloseButtonTapped {
    [self closeContainer];
}

- (void)closeAllContainer {
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(closeAllContainers)]) {
        [self.containerDelegate closeAllContainers];
    }
}

- (void)startAppearAnimation {
    _isShowing = YES;
    CGFloat translateX = _mainView.bounds.size.width;
    _mainView.transform = CGAffineTransformMakeTranslation(translateX, 0);
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.isShowed = YES;
        self.isShowing = NO;
    }];
}

- (void)startDisappearAnimation {
    CGFloat translateX = _mainView.bounds.size.width;
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.transform = CGAffineTransformMakeTranslation(translateX, 0);
    } completion:^(BOOL finished) {
        [self destroyView];
    }];
}

- (void)showLoadingView {
    if (!_loadingView) {
        _loadingView = [[VPLuaAppletContainerLoadingView alloc] initWithFrame:_containFrame];
        [_mainView addSubview:_loadingView];
    }
    
    [self closeErrorView];
    [self closeRetryView];
    
    [_mainView bringSubviewToFront:_loadingView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoading];
    });
    _loadingView.hidden = NO;
}

- (void)closeLoadingView {
    [_loadingView stopLoading];
    [_loadingView setHidden:YES];
}

- (void)showRetryView {
    if (!_retryView) {
        _retryView = [[VPLuaAppletContainerNetworkView alloc] initWithFrame:_containFrame];
        _retryView.networkDelegate = self;
        [_mainView addSubview:_retryView];
    }
    
    [self closeErrorView];
    [self closeLoadingView];
    
    [_mainView bringSubviewToFront:_retryView];
    _retryView.hidden = NO;
}

- (void)closeRetryView {
    [_retryView setHidden:YES];
}

- (void)showErrorView {
    if (!_errorView) {
        _errorView = [[VPLuaAppletContainerErrorView alloc] initWithFrame:_containFrame];
        [_mainView addSubview:_errorView];
    }
    
    [self closeLoadingView];
    [self closeRetryView];
    
    [_mainView bringSubviewToFront:_errorView];
    _errorView.hidden = NO;
}

- (void)closeErrorView {
    [_errorView setHidden:YES];
}

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

#pragma mark - delegate
//network
- (void)retryNetwork {
    [self showLoadingView];
    [self requestApplet];
}


@end
