//
//  VPLuaAppletLandscapeContainer.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaAppletLandscapeContainer.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPLuaAppletRequest.h"
#import "VPLuaNodeController.h"
#import "VPUPRoutes.h"
#import "VPUPHexColors.h"
#import "VPLuaMacroDefine.h"
#import "VPUPEncryption.h"
#import "VPLuaAppletObject.h"
#import "VPLuaLoader.h"
#import "VPUPHexColors.h"
#import "UIButton+VPUPFillColor.h"
#import "VPUPViewScaleUtil.h"
#import "VPLuaAppletContainerLoadingView.h"
#import "VPLuaAppletContainerNetworkView.h"
#import "VPLuaAppletContainerErrorView.h"
#import "VPUPPathUtil.h"

@interface VPLuaAppletLandscapeContainer() <VPLuaAppletContainerNetworkDelegate, VPLuaNodeControllerLoadDelegate, VPLuaNodeControllerAppletDelegate>

@property (nonatomic) NSString *appletID;
@property (nonatomic, assign) VPLuaAppletContainerType type;
@property (nonatomic, copy) NSDictionary *(^getUserInfoBlock)(void);
@property (nonatomic) NSDictionary *rootData;

@property (nonatomic, weak) VPLuaNetworkManager *networkManager;
@property (nonatomic) VPLuaVideoInfo *videoInfo;
//@property (nonatomic) NSString *requestID;
@property (nonatomic) NSString *luaPath;
@property (nonatomic) NSString *appletPath;
@property (nonatomic, assign) BOOL retryLuaFiles;

@property (nonatomic) VPLuaAppletObject *applet;
@property (nonatomic) VPLuaNodeController *luaController;
//node的栈,从第二个开始算,root不存放在栈中
@property (nonatomic) NSMutableArray *nodeStack;

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isShowed;

@property (nonatomic) UIView *mainView;

@property (nonatomic) UIView *naviView;
@property (nonatomic) UIView *naviBackView;
@property (nonatomic) UIButton *naviBackButton;
@property (nonatomic) UIButton *naviCloseButton;
@property (nonatomic) UILabel *naviLabel;

@property (nonatomic) VPLuaAppletContainerLoadingView *loadingView;

@property (nonatomic) VPLuaAppletContainerNetworkView *retryView;

@property (nonatomic) VPLuaAppletContainerErrorView *errorView;

@property (nonatomic) CGRect luaContainFrame;

//applet
@property (nonatomic, assign) BOOL isAppletRetry;
@property (nonatomic) NSString *tempRetryNodeId;
@property (nonatomic) id tempRetryData;
@property (nonatomic, assign) BOOL isAppletError;

@end

NSString *const kContainerBackImage = @"iVBORw0KGgoAAAANSUhEUgAAAFgAAABYCAYAAABxlTA0AAAAAXNSR0IArs4c6QAAAhtJREFUeAHt2TFLw0AYh3Grgoub4OLg4qyTS0e34uSqUBxcXBX8Ak7i7EewuCr0E/gBxFUXwQ4KgoIURJT6HDRyiIPQ0+Tic/AnbyO9vvdrSNI4NuZQQAEFFFBAAQUUUEABBRRQQAEFFFBAAQUUUEABBRRQQAEFFFBAAQUUUEABBRRQQAEFFFBAgboINHJZyGAwGKfXVui30Wh0c+k7iz7BnSanpBirWTROk5NVbxTReXo8I4tV7zW7/sBtkvvisB1uD7JbSBUbBrNNXiLcULer2GtWPYE4Tg4i2FCGo7iZ1UKq2CyIXy9mAfeShPOwYxSBgDjEZPM5wp3D9Cjz+l4EQPz2Ysb+cO/rGEUAxFpfzEr9JQduuOXai76gPvUJ6UX7UpTXTNLhF+AgxWRZzAHuOvnLsVEGjOe4X1Yv7RTBoRs++5DsRmt8oj4mD9G+FOX/O0UUakBvk7foXPFIvVL83W0CAUBb5DlCfqXeTDC1UxQCgC6RXoQcyn1S2mms6K02WzDnyAWJR4cXU7VZZNkLATM8j+jGwtTnZKbs3mrz+WBOkCMSjyteLNRmkVVYCKA75D1SfqD2sWXKLwfQNdKPkG+oK/+vrpQGvz4XoMvkboh8y9Y7i9TqoM6SLeLD99S4zqeAAgoooIACCiiggAIKKKCAAgoooIACCiiggAIKKKCAAgoooIACCiiggAIKKKCAAgoooIACPxL4AH/PI5IQavh7AAAAAElFTkSuQmCC";
NSString *const kContainerCloseImage = @"iVBORw0KGgoAAAANSUhEUgAAAFgAAABYCAYAAABxlTA0AAAAAXNSR0IArs4c6QAAActJREFUeAHt2UtugzAQANCom64j9T7cf1W1h+g16ExFKhJhiHEjBfeNZBERzwSeJ+TD6SQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECDwhwLjOJ5jDDFeW8tmjanWubVWF/mBkbhfMTLeY7ztPbHMnWrE5qcm5IAYUmMWn/G4GjlzYmTuPIa9i9VNXmjkWzo7dx5VyJG4hJs1my85XUAXgD5y/9YJFnKrFmjrNbp4vgC1ijzl5Jx5wC11RCgtvdUXkae5cEuYpf0FuCvke+aU6tsfAmuAa8/BqxBYgby9LFx1d8VLmFpAjt2/Abe1TYIyP/huuzaFD4H70gog/8ACK92bHZxxiC5+yiUIvKVLQ4LeXi4g167gCm6il+A3f1bXHkeX8+8BvGdOlzitJ1UDVzO39bi6yN8DtienC6zak2iBasmtPc5Dzg+gpT/cq74ZFJD94Z4dEThDjHlU4V66KgosfbtwyyhgzjHc9Lx0yiO2E/IQ2+Z7aFkjRtZyR/kRi6UmAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAgX8s8A3p5fDJQkOt8AAAAABJRU5ErkJggg==";


@implementation VPLuaAppletLandscapeContainer
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
            [weakSelf loadLuaFiles];
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
    mainFrame.size.width = self.frame.size.height / 375 * 222;
    mainFrame.origin.x = self.frame.size.width - mainFrame.size.width;
    mainFrame.origin.y = 0;
    _mainView.frame = mainFrame;
    
    [self addSubview:_mainView];
    
    [self initNavigationBar];
    [_mainView addSubview:_naviView];
    
    _luaContainFrame = CGRectZero;
    _luaContainFrame.size.width = _mainView.bounds.size.width;
    _luaContainFrame.size.height = _mainView.bounds.size.height - _naviView.bounds.size.height;
    _luaContainFrame.origin.x = 0;
    _luaContainFrame.origin.y = _naviView.bounds.size.height;
    
    self.luaController = [[VPLuaNodeController alloc] initWithViewFrame:_luaContainFrame videoRect:CGRectZero networkManager:self.networkManager videoInfo:self.videoInfo];
    [self.luaController changeDestinationPath:self.appletPath];
    self.luaController.luaDelegate = self;
    self.luaController.appletDelegate = self;
    [_mainView addSubview:self.luaController.rootView];
    
    if (self.getUserInfoBlock) {
        [self.luaController setGetUserInfoBlock:self.getUserInfoBlock];
    }
    
    [self showLoadingView];
//    [self startAppearAnimation];
}

- (void)initNavigationBar {
    _naviView = [[UIView alloc] init];
    CGFloat itemHeight = 36 * VPUPViewScale;
    _naviView.frame = CGRectMake(0, 0, _mainView.bounds.size.width, itemHeight);
    
    _naviBackView = [[UIView alloc] initWithFrame:_naviView.bounds];
    _naviBackView.backgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"48505A"];
    _naviBackView.alpha = 0.9;
    [_naviView addSubview:_naviBackView];
    
    _naviBackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemHeight, itemHeight)];
    [_naviBackButton setImage:[VPUPBase64Util imageFromBase64String:kContainerBackImage] forState:UIControlStateNormal];
    [_naviBackButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _naviBackButton.hidden = YES;
    [_naviView addSubview:_naviBackButton];
    
    _naviCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(_naviView.bounds.size.width - itemHeight, 0, itemHeight, itemHeight)];
    [_naviCloseButton setImage:[VPUPBase64Util imageFromBase64String:kContainerCloseImage] forState:UIControlStateNormal];
    [_naviCloseButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_naviView addSubview:_naviCloseButton];
    
    _naviLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemHeight, 0, _naviView.bounds.size.width - itemHeight * 2, itemHeight)];
    _naviLabel.textColor = [UIColor whiteColor];
    _naviLabel.textAlignment = NSTextAlignmentCenter;
    _naviLabel.font = [UIFont systemFontOfSize:12 * VPUPFontScale];
    [_naviView addSubview:_naviLabel];
}

- (void)updateNavi {
    if (!self.applet.naviSetting) {
        return;
    }
    VPLuaAppletContainerNaviSetting * setting = self.applet.naviSetting;
    
    _naviLabel.text = setting.naviTitle;
    _naviBackView.backgroundColor = setting.navibackgroundColor;
    _naviBackView.alpha = setting.naviAlpha;
    _naviLabel.textColor = setting.naviTitleColor;
    [_naviBackButton vpup_fillImageWithColor:setting.naviButtonColor];
    [_naviCloseButton vpup_fillImageWithColor:setting.naviButtonColor];
}

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))getUserInfoBlock {
    _getUserInfoBlock = getUserInfoBlock;
    [self.luaController setGetUserInfoBlock:getUserInfoBlock];
}

- (void)loadLuaFiles {
    __weak typeof(self) weakSelf = self;
    
    [[VPLuaLoader sharedLoader] checkAndDownloadFilesList:_applet.luaList resumePath:self.appletPath complete:^(NSError * error, VPUPTrafficStatisticsList *trafficList) {
       //已回到主线程
        if (trafficList) {
            [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeRealTime];
        }
        
        if (error) {
            weakSelf.retryLuaFiles = YES;
            [weakSelf showRetryView];
            [weakSelf.retryView changeNetworkMessage:@"小程序加载失败，请重试"];
            return;
        }
        
        [weakSelf updateNavi];
        [weakSelf loadRootLua];
    }];
}

- (void)loadRootLua {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeLoadingView];
        [self.luaController loadLua:self.applet.templateLua data:self.rootData];
    });
}

- (void)loadLua:(NSString *)luaUrl data:(NSDictionary *)data {
    if (!_nodeStack) {
        _nodeStack = [NSMutableArray array];
    }
    NSDictionary *queryParams = [data objectForKey:VPUPRouteQueryParamsKey];
    NSString *nodeId = [queryParams objectForKey:@"id"];
    if (![_nodeStack containsObject:nodeId]) {
        [_nodeStack addObject:nodeId];
    }
    
    if(_nodeStack.count > 0) {
        _naviBackButton.hidden = NO;
    }
    
    [self.luaController loadLua:luaUrl data:data];
}

- (void)closeContainer {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self startDisappearAnimation];
    });
}

- (void)destroyView {
    [self.luaController releaseLuaView];
    [self removeFromSuperview];
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(deleteContainerWithAppletID:)]) {
        [self.containerDelegate deleteContainerWithAppletID:self.appletID];
    }
    self.containerDelegate = nil;
}

- (void)backButtonTapped {
    if ([_nodeStack count] > 0) {
        [_nodeStack removeLastObject];
        if ([_nodeStack count] == 0) {
            _naviBackButton.hidden = YES;
        }
        if (_errorView.hidden == NO) {
            [self closeErrorView];
            //小程序唤起的错误页,需要移除node;lua加载引发的错误页,不需要移除node
            if (_isAppletError) {
                _isAppletError = NO;
                [_luaController removeLastNode];
            }
        } else {
            if (_retryView.hidden == NO) {
                //当前页面没有重试就回退了,置空所有参数
                if (_isAppletError) {
                    _isAppletError = NO;
                    _tempRetryNodeId = nil;
                    _tempRetryData = nil;
                }
                [self closeRetryView];
            }
            [_luaController removeLastNode];
        }
    } else {
        _naviBackButton.hidden = YES;
    }
}

- (void)closeButtonTapped {
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
        _loadingView = [[VPLuaAppletContainerLoadingView alloc] initWithFrame:_luaContainFrame];
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
        _retryView = [[VPLuaAppletContainerNetworkView alloc] initWithFrame:_luaContainFrame];
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
        _errorView = [[VPLuaAppletContainerErrorView alloc] initWithFrame:_luaContainFrame];
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
    if (!_isAppletRetry) {
        [self showLoadingView];
        if (self.retryLuaFiles) {
            self.retryLuaFiles = false;
            [self loadLuaFiles];
        } else {
            [self requestApplet];
        }
    } else {
        _isAppletRetry = NO;
        [self closeRetryView];
        if (_tempRetryNodeId) {
            [self.luaController callLuaMethod:@"retry" nodeId:_tempRetryNodeId data:_tempRetryData];
        }
        _tempRetryNodeId = nil;
        _tempRetryData = nil;
    }
    
}

//lua node controller
- (void)loadLuaError:(NSString *)error {
    [self showErrorView];
    if (_nodeStack.count == 0) {
        [_errorView useDefaultMessage];
    } else {
        [_errorView changeErrorMessage:@"小程序崩溃了"];
    }
}

- (void)showRetryPage:(NSString *)retryMessage retryData:(id)data nodeId:(NSString *)nodeId {
    [self showRetryView];
    if (retryMessage != nil && ![retryMessage isEqualToString:@""]) {
        [_retryView changeNetworkMessage:retryMessage];
    } else {
        [_retryView useDefaultMessage];
    }
    _isAppletRetry = YES;
    _tempRetryData = data;
    _tempRetryNodeId = nodeId;
}

- (void)showErrorPage:(NSString *)errorMessage {
    _isAppletError = YES;
    [self showErrorView];
    if (errorMessage != nil && ![errorMessage isEqualToString:@""]) {
        [_errorView changeErrorMessage:errorMessage];
    } else {
        [_errorView useDefaultMessage];
    }
}

@end
