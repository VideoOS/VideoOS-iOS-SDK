//
//  VPMPLandscapeContainer.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPMPLandscapeContainer.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPLMPRequest.h"
#import "VPLNodeController.h"
#import "VPUPRoutes.h"
#import "VPUPHexColors.h"
#import "VPUPEncryption.h"
#import "VPLMPObject.h"
#import "VPLDownloader.h"
#import "UIButton+VPUPFillColor.h"
#import "VPUPViewScaleUtil.h"
#import "VPUPPathUtil.h"
#import "VPLSDK.h"
#import "VPUPValidator.h"


@interface VPMPLandscapeContainer()<VPMPContainerNetworkDelegate, VPMPNavigationBarDelegate>

@end

@implementation VPMPLandscapeContainer
@synthesize containerDelegate;
@synthesize currentOrientation;

- (instancetype)initWithMPID:(NSString *)mpID
              networkManager:(VPLNetworkManager *)networkManager
                   videoInfo:(VPLVideoInfo *)videoInfo
                       lPath:(NSString *)lPath
                        data:(id)data {
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect containerFrame = frame;
    containerFrame.size.width = MAX(frame.size.width, frame.size.height);
    containerFrame.size.height = MIN(frame.size.width, frame.size.height);
    
    return [self initWithFrame:containerFrame mpID:mpID networkManager:networkManager videoInfo:videoInfo lPath:lPath data:data];
}

- (instancetype)initWithFrame:(CGRect)frame
                     mpID:(NSString *)mpID
               networkManager:(VPLNetworkManager *)networkManager
                    videoInfo:(VPLVideoInfo *)videoInfo
                      lPath:(NSString *)lPath
                         data:(id)data {
    
    self = [super initWithFrame:frame];
    if (self) {
        _networkManager = networkManager;
        _mpID = mpID;
        _videoInfo = videoInfo;
        _lPath = lPath;
        if (_mpID != nil && ![_mpID isEqualToString:@""]) {
            _mpPath = [VPUPPathUtil subPathOfLMP:_mpID];
        }
        _rootData = [NSMutableDictionary dictionaryWithDictionary:data];
        _type = VPMPContainerTypeLandscape;
        [self requestApplet];
        [self initView];
    }
    return self;
}

- (void)setCurrentOrientation:(VPMPContainerOrientation)orientation {
    currentOrientation = orientation;
    if (currentOrientation == VPMPContainerOrientationPortriat) {
        [self hide];
    } else {
        [self show];
    }
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
    if (![VPLSDK sharedSDK].appDev) {
        //normal use
        __weak typeof(self) weakSelf = self;
        if (_mpID == nil || [_mpID isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 直接显示错误
                [weakSelf showErrorView];
                [weakSelf.errorView changeErrorMessage:@"小程序服务不可用，换个标签再试"];
            });
            return;
        }
        [[VPLMPRequest request] requestWithMPID:_mpID apiManager:_networkManager.httpManager complete:^(VPLMPObject *mpObject, NSError *error) {
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
                
                weakSelf.mpObject = mpObject;
                if (weakSelf.rootData != nil && [weakSelf.rootData isKindOfClass:[NSMutableDictionary class]]) {
                    [weakSelf.rootData setValue:[mpObject.miniAppInfo dictionaryValue] forKey:@"miniAppInfo"];
                }
                [weakSelf loadContainView];
            });
        }];
        
    } else {
        //mini app develop mode
        NSString *filePath = [VPUPPathUtil appDevConfigPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSLog(@"配置文件不存在,请检查文件路径或校验json格式");
            [self showErrorView];
            [self.errorView changeErrorMessage:@"配置文件不存在"];
            return;
        }
        NSDictionary *mpDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:nil];
        
        if (!mpDict) {
            NSLog(@"配置文件错误,请校验json格式");
            [self showErrorView];
            [self.errorView changeErrorMessage:@"配置文件格式错误"];
            return;
        }
        
        VPLMPObject *object = [VPLMPObject initWithResponseDictionary:mpDict];
        
        if (self.appType == VPMPContainerAppTypeLScript && !VPUP_IsStrictExist(object.miniAppInfo.template)) {
            NSLog(@"配置文件错误,lua小程序没有lua入口文件");
            [self showErrorView];
            [self.errorView changeErrorMessage:@"配置文件缺失lua入口"];
            return;
        }
        
        if (self.appType == VPMPContainerAppTypeHybird && !VPUP_IsStrictExist(object.h5Url)) {
            NSLog(@"配置文件错误,H5小程序没有H5入口");
            [self showErrorView];
            [self.errorView changeErrorMessage:@"配置文件缺失H5入口"];
            return;
        }
        
        object.miniAppInfo.mpID = _mpID;
        self.mpObject = object;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadContainView];
        });
    }
    
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
    _naviBar = [[VPMPLandscapeNavigationBar alloc] initWithFrame:CGRectMake(0, 0, _mainView.bounds.size.width, itemHeight)];
    _naviBar.delegate = self;
}

- (void)updateNavi {
    if (!self.mpObject.naviSetting) {
        return;
    }
    [_naviBar updateNavi:self.mpObject.naviSetting];
    
    //不显示导航栏,更新cotainFrame
    if (!self.mpObject.naviSetting.naviShow) {
        _containFrame.size.height = _mainView.bounds.size.height;
        _containFrame.origin.y = 0;
    }
    [self updateContainView];
}

- (void)initContainView {
    
}

- (void)updateContainView {

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

- (void)loadLFile:(NSString *)luaUrl data:(id)data {
    
}

- (void)refreshContainerWithData:(id)data {
    
}

- (void)destroyView {
    [self removeFromSuperview];
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(deleteContainerWithMPID:)]) {
        [self.containerDelegate deleteContainerWithMPID:self.mpID];
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
        _loadingView = [[VPMPContainerLoadingView alloc] initWithFrame:_containFrame];
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
        _retryView = [[VPMPContainerNetworkView alloc] initWithFrame:_containFrame];
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
        _errorView = [[VPMPContainerErrorView alloc] initWithFrame:_containFrame];
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
