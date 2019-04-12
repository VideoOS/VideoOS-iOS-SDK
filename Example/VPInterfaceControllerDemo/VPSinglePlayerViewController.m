//
//  VPSinglePlayerViewController.m
//  VPInterfaceControllerDemo
//
//  Created by Zard1096 on 2017/7/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPSinglePlayerViewController.h"
#import "VPAVPlayerController.h"
#import "VPMediaControlView.h"
#import "PrivateConfig.h"
#import <VideoOS-iOS-SDK/VideoPlsInterfaceControllerSDK/VPInterfaceController.h>
#import <VideoOS-iOS-SDK/VideoPlsInterfaceControllerSDK/VPIUserInfo.h>
#import <VideoOS-iOS-SDK/VideoPlsInterfaceControllerSDK/VPIUserLoginInterface.h>
#import "sys/utsname.h"

#import <VideoOS-iOS-SDK/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>

#import <Masonry/Masonry.h>
#import "VPVideoSettingView.h"
#import "VPWebViewController.h"
#import "VPLoginViewController.h"
#import <VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>

@interface VPSinglePlayerViewController() <VPInterfaceStatusNotifyDelegate, UITableViewDataSource,
#ifdef VP_MALL
VPIPubWebViewCloseDelegate,
#endif
VPIUserLoginInterface,VPVideoPlayerDelegate,VPIVideoPlayerDelegate> {
    NSString *_urlString;
    NSString *_platformUserID;
    BOOL _isLive;
    VPInterfaceControllerType _type;
    
    BOOL _isFullScreen;
    
    BOOL _videoClipOpen;
    BOOL _needToPlay;
    
    VPAVPlayerController *_player;
    VPMediaControlView *_mediaControlView;
    UIView *_gestureView;
    
    VPInterfaceController *_interfaceController;
    
    NSTimer *_refreshInterfaceTimer;
    
    UITableView *_tableView;
    
    NSMutableArray *_sources;
    
    UIView *_webViewContent;
#ifdef VP_MALL
    VPIPubWebView *_goodsListWebView;
#endif
    UIButton *_goodListEntranceButton;
    UIButton *_shelfButton;
    UIButton *_orderButton;
    
    UIButton *_enjoyConfigButton;
    
    VPIUserInfo *_userInfo;
    
    VPIVideoPlayerOrientation _currentPlayerOrientationType;
}


@property (nonatomic, weak) UIButton *settingButton;
@property (nonatomic, weak) UIButton *videoButton;
@property (nonatomic, weak) UIButton *mallButton;
@property (nonatomic, weak) UIButton *closeInfoViewButton;
@property (nonatomic, weak) VPVideoSettingView *settingView;

@end

@implementation VPSinglePlayerViewController

- (instancetype)initWithUrlString:(NSString *)urlString platformUserID:(NSString *)platformUserID isLive:(BOOL)isLive {
    VPInterfaceControllerType type;
    if (isLive) {
        if ([PrivateConfig shareConfig].anchor) {
            type = VPInterfaceControllerTypeEnjoy;
        } else {
            type = VPInterfaceControllerTypeLiveOS;
        }
    }
    else {
        type = VPInterfaceControllerTypeVideoOS;
    }
    return [self initWithUrlString:urlString platformUserID:platformUserID type:type];
}

- (instancetype)initWithUrlString:(NSString *)urlString platformUserID:(NSString *)platformUserID type:(NSInteger)type
{
    self = [super init];
    if (self) {
        _urlString = urlString;
        _platformUserID = platformUserID;
        if (type == -1) {
            //传入null, 根据privateConfig进行配置
            type = [PrivateConfig shareConfig].cytron ? VPInterfaceControllerTypeVideoOS : 0;
            type = [PrivateConfig shareConfig].live ? type | VPInterfaceControllerTypeLiveOS : type;
            type = [PrivateConfig shareConfig].mall ? type | VPInterfaceControllerTypeMall : type;
            type = [PrivateConfig shareConfig].enjoy ? type | VPInterfaceControllerTypeEnjoy : type;
            
            _type = type;
        }
        else {
            _type = type;
        }
        
        if (_type == VPInterfaceControllerTypeLiveOS) {
            _isLive = YES;
        }
        else {
            _isLive = NO;
        }
        
        //监听挂起程序
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        //监听回到程序
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        
        //在需要使用互动层页面开始时调用startVideoPls
        //TODO: 如果有navigationController需要打开多个视频页不在这里开启
    }
    return self;
}



- (void)becomeActive:(NSNotification *)sender {
    
}

- (void)resignActive:(NSNotification *)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    if(!_urlString) {
        return;
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if(UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation)) {
        _isFullScreen = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
//        _isFullScreen = YES;
    }
    else {
        _isFullScreen = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
//        _isFullScreen = YES;
    }
    
    
    [self initPlayer];
    [self initMediaControlView];
    [self initGestureView];
    
    //goodsList 入口
//    if(_type == VPInterfaceControllerTypeMall) {
//        [self initGoodsListEntrance];
//    }
    
    if ((_type & VPInterfaceControllerTypeMall) == VPInterfaceControllerTypeMall) {
        [self initGoodsListEntrance];
    }
    
    
//    if ((_type == VPInterfaceControllerTypeLiveOS && [PrivateConfig shareConfig].anchor) || _type == VPInterfaceControllerTypeEnjoy) {
//        [self initEnjoyConfigButton];
//    }
    
    if ((_type & VPInterfaceControllerTypeEnjoy) == VPInterfaceControllerTypeEnjoy && [PrivateConfig shareConfig].anchor) {
        [self initEnjoyConfigButton];
    }
    
    [self initInterfaceController];
    
    [self.view addSubview:_player.view];
    //手势层置于互动层下方
    [self.view addSubview:_gestureView];
    
    //商城入口应该加载mediaControlView上,这儿偷懒了
    if ((_type & VPInterfaceControllerTypeMall) == VPInterfaceControllerTypeMall) {
        [self.view addSubview:_goodListEntranceButton];
        [self.view addSubview:_shelfButton];
        [self.view addSubview:_orderButton];
    }
    
    if ((_type & VPInterfaceControllerTypeEnjoy) == VPInterfaceControllerTypeEnjoy && [PrivateConfig shareConfig].anchor) {
        [self.view addSubview:_enjoyConfigButton];
    }
    
    [self.view addSubview:_interfaceController.view];
    //控制栏没有全屏幕手势放在最上方
    [self.view addSubview:_mediaControlView];
    
    if ([PrivateConfig shareConfig].cytron == YES) {
        [self initSettingButton];
    }
    
    [self registerDeviceOrientationNotification];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_interfaceController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_interfaceController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_interfaceController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_interfaceController viewDidDisappear:animated];
}

- (void)pause {
    [_mediaControlView playButtonTapped:nil];
}

- (void)dealloc {
    
}

- (void)initPlayer {
    _player = [[VPAVPlayerController alloc] initWithContentURLString:_urlString];
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //[_player updateFrame:self.view.bounds];
//    [self deviceOrientationChange:nil];
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if(UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation)) {
        _isFullScreen = UIDeviceOrientationIsLandscape(orientation);
    }
    else {
        _isFullScreen = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    }
    
    if (_isFullScreen || [PrivateConfig shareConfig].verticalFullScreen) {
        [_player updateFrame:self.view.bounds];
    }
    else {
        float y = 0;
        if ([VPSinglePlayerViewController isIPHONEX]) {
            y = 44.0;
        }
        [_player updateFrame:CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.width*9.0/16.0)];
    }
    
    
    [self registerPlayerNotification];
    [_player prepareToPlay];
    _player.videoPlayerDelagate = self;
}

- (void)initMediaControlView {
    _mediaControlView = [VPMediaControlView mediaControlViewWithNib];
    [_mediaControlView setFrame:_player.view.frame];
    [_mediaControlView setAVPlayerController:_player];
    
    __weak typeof(self) weakSelf = self;
    [_mediaControlView setBackButtonTappedToDo:^{
        [weakSelf dismissPlayerViewController];
    }];
    
    _mediaControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)initSettingButton {
    
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:[UIImage imageNamed:@"button_set"] forState:UIControlStateNormal];
    [self.view addSubview:settingButton];
    [settingButton addTarget:self action:@selector(settingButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *whiteImage = [UIImage imageNamed:@"button_white"];
    UIButton *mallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mallButton setImage:whiteImage forState:UIControlStateNormal];
    [self.view addSubview:mallButton];
    [mallButton addTarget:self action:@selector(mallButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mallButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [mallButton setTitle:@"模拟" forState:UIControlStateNormal];
    mallButton.titleEdgeInsets = UIEdgeInsetsMake(0, -whiteImage.size.width, 0, 0);
    self.mallButton = mallButton;
    
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoButton setImage:whiteImage forState:UIControlStateNormal];
    [videoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [videoButton setTitle:@"点播" forState:UIControlStateNormal];
    videoButton.titleEdgeInsets = UIEdgeInsetsMake(0, -whiteImage.size.width, 0, 0);
    [self.view addSubview:videoButton];
    [videoButton addTarget:self action:@selector(videoButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.videoButton = videoButton;
    
    UIButton *closeInfoViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeInfoViewButton setImage:whiteImage forState:UIControlStateNormal];
    [closeInfoViewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeInfoViewButton setTitle:@"关闭" forState:UIControlStateNormal];
    closeInfoViewButton.titleEdgeInsets = UIEdgeInsetsMake(0, -whiteImage.size.width, 0, 0);
    [self.view addSubview:closeInfoViewButton];
    [closeInfoViewButton addTarget:self action:@selector(closeInfoViewButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeInfoViewButton = closeInfoViewButton;
    
    [settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-40);
    }];
    
    [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(whiteImage.size.width);
        make.height.mas_equalTo(whiteImage.size.height);
        make.centerX.equalTo(settingButton.mas_centerX);
        make.bottom.equalTo(settingButton.mas_top).with.offset(10);
    }];
    
    [mallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(whiteImage.size.width);
        make.height.mas_equalTo(whiteImage.size.height);
        make.centerX.equalTo(settingButton.mas_centerX);
        make.bottom.equalTo(videoButton.mas_top).with.offset(-10);
    }];
    
    [closeInfoViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(whiteImage.size.width);
        make.height.mas_equalTo(whiteImage.size.height);
        make.centerX.equalTo(settingButton.mas_centerX);
        make.bottom.equalTo(mallButton.mas_top).with.offset(-10);
    }];
    
    videoButton.hidden = YES;
    mallButton.hidden = YES;
    closeInfoViewButton.hidden = YES;
}

- (void)settingButtonDidClicked:(id)sender {
    if (self.mallButton.hidden == YES) {
        self.mallButton.hidden = NO;
        self.videoButton.hidden = NO;
        self.closeInfoViewButton.hidden = NO;
    }
    else {
        self.mallButton.hidden = YES;
        self.videoButton.hidden = YES;
        self.closeInfoViewButton.hidden = YES;
    }
}

- (void)mallButtonDidClicked:(id)sender {
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"adInfo" ofType:@"json"];
    NSDictionary *adInfo = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
    
    [_interfaceController navigationWithURL:[NSURL URLWithString:@"LuaView://defaultLuaView?template=os_red_envelope_hotspot.lua&id=5aa5fa5133edbf375fe43fff4"] data:[[adInfo objectForKey:@"launchInfoList"] objectAtIndex:1]];
    
//    [_interfaceController navigationWithURL:[NSURL URLWithString:@"LuaView://defaultLuaView?template=os_bubble.lua&id=5aa5fa5133edbf375fe43fff4"] data:[[adInfo objectForKey:@"launchInfoList"] objectAtIndex:3]];
    
//    [_interfaceController navigationWithURL:[NSURL URLWithString:@"LuaView://defaultLuaView?template=os_wedge.lua&id=5aa5fa5133edbf375fe43fff4"] data:[[adInfo objectForKey:@"launchInfoList"] objectAtIndex:0]];
    return;
    int index = rand() % 2;
    if (index == 0) {
        [_interfaceController navigationWithURL:[NSURL URLWithString:@"LuaView://defaultLuaView?template=os_cloud.lua&id=cd0d5140-4922-442a-87f6-af3aa74c5a5e"] data:[[adInfo objectForKey:@"launchInfoList"] objectAtIndex:index]];
    }
    else {
        [_interfaceController navigationWithURL:[NSURL URLWithString:@"LuaView://defaultLuaView?template=os_wedge.lua&id=fdcc4b0a-03a7-4697-b64f-9c93b7d55409"] data:[[adInfo objectForKey:@"launchInfoList"] objectAtIndex:index]];
    }
}

- (void)videoButtonDidClicked:(id)sender {
    VPVideoSettingView *settingView = [[VPVideoSettingView alloc] initWithFrame:self.view.bounds data:self.mockConfigData];
    [self.view addSubview:settingView];
    [settingView.applyButton addTarget:self action:@selector(settingViewApplyButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    self.settingView = settingView;
}

- (void)closeInfoViewButtonDidClicked:(id)sender {
    [_interfaceController closeInfoView];
}

- (void)settingViewApplyButtonDidClicked:(id)sender {
    if (self.settingView.urlTextField.text.length > 0) {
        if (self.settingView.platformIdTextField.text && self.settingView.platformIdTextField.text.length > 0) {
            [PrivateConfig shareConfig].creativeName = self.settingView.platformIdTextField.text;
        }
        else {
            [PrivateConfig shareConfig].creativeName = nil;
        }
        [PrivateConfig shareConfig].identifier = self.settingView.urlTextField.text;
        [PrivateConfig shareConfig].environment = self.settingView.environmentControl.selectedSegmentIndex;
        [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:[PrivateConfig shareConfig].environment];
        [self reloadVideoInfo];
    }
    [self.settingView.platformIdTextField resignFirstResponder];
    [self.settingView.urlTextField resignFirstResponder];
    [self.settingView removeFromSuperview];
    self.settingView = nil;
}

- (void)reloadVideoInfo {
    [_interfaceController stop];
    [_player changeContentURLString:[PrivateConfig shareConfig].identifier];
    if ([PrivateConfig shareConfig].creativeName) {
        _interfaceController.config.extendDict = @{@"creativeName":[PrivateConfig shareConfig].creativeName};
    }
    _interfaceController.config.identifier = [PrivateConfig shareConfig].identifier;
    _mediaControlView.hidden = NO;
    [_interfaceController start];
    [self deviceOrientationChange:nil];
}

-(id)userLogin {
    
    VPIUserInfo *userInfo = [[VPIUserInfo alloc] init];
    //    userInfo.uid = @"120078661";
    if ([PrivateConfig shareConfig].userID.length > 0) {
        userInfo.uid = [PrivateConfig shareConfig].userID;
    } else {
        return nil;
    }
    userInfo.nickName = @"arthur";
    userInfo.userName = @"videolive";
    userInfo.token = @"adbsdefs";
    userInfo.phoneNum = @"12123";
    userInfo.type = [PrivateConfig shareConfig].anchor ? VPIUserTypeAnchor : VPIUserTypeUser;
    _userInfo = userInfo;
    return userInfo;
}

- (id)vp_getUserInfo {
    
    VPIUserInfo *userInfo = [[VPIUserInfo alloc] init];
//    userInfo.uid = @"120078661";
    if ([PrivateConfig shareConfig].userID.length > 0) {
        userInfo.uid = [PrivateConfig shareConfig].userID;
    } else {
        return nil;
    }
    userInfo.nickName = @"arthur";
    userInfo.userName = @"videolive";
    userInfo.token = @"adbsdefs";
    userInfo.phoneNum = @"12123";
    userInfo.type = [PrivateConfig shareConfig].anchor ? VPIUserTypeAnchor : VPIUserTypeUser;
    return userInfo;
}

- (void)vp_userLogined:(VPIUserInfo *) userInfo {
//    NSLog(@"%@",userInfo.uid);
}

- (void)vp_notifyScreenChange:(NSString *)url {
#ifdef VP_MALL
//    NSLog(@"%@", url);
    [self createWebView];
    [_webViewContent setHidden:NO];
    [_goodsListWebView loadUrl:url];
#endif
}

- (void)vp_requireLogin:(void (^)(VPIUserInfo *userInfo))completeBlock {
    if (completeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            VPLoginViewController *loginViewController = [[VPLoginViewController alloc] init];
            loginViewController.complete = ^{
                VPIUserInfo *userInfo = [self userLogin];
                completeBlock(userInfo);
            };
            [self presentViewController:loginViewController animated:YES completion:nil];            
        });
    }
}


- (void)buttonTappedOpenWebView:(UIButton *)sender {
    NSString *url = nil;
    
#ifdef VP_MALL
    NSString *platformID = [PrivateConfig shareConfig].platformID;
    NSString *platformName = nil;
    if ([platformID isEqualToString:@"56dd27a8b311dff60073e645"]) {
        platformName = @"zhanqi";
    }
    else if ([platformID isEqualToString:@"5a2786e14b284c3a00aa3336"]) {
        platformName = @"quanmin";
    }
    else {
        platformName = @"zhanqi";
    }
    
    if([[sender titleLabel].text isEqualToString:@"货架"]) {
        url = [VPIStoreAPIConfig getStoreAPIURL:VPIStoreAPITypeShelf platformName:platformName];
        url = [NSString stringWithFormat:@"%@?video=%@",url, _platformUserID];
    } else {
        url = [VPIStoreAPIConfig getStoreAPIURL:VPIStoreAPITypeOrder platformName:platformName];
    }
#endif
    [self vp_notifyScreenChange:url];
}


- (void)initGestureView {
    _gestureView = [[UIView alloc] initWithFrame:self.view.bounds];
    _gestureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureViewTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    
    [_gestureView addGestureRecognizer:tapGestureRecognizer];
}

- (void)initGoodsListEntrance {
    _goodListEntranceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height / 2 - 20, 40, 40)];
    _goodListEntranceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [_goodListEntranceButton setImage:[UIImage imageNamed:@"shelves_entrance"] forState:UIControlStateNormal];
    
    [_goodListEntranceButton addTarget:self action:@selector(goodListEntranceDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _shelfButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(_goodListEntranceButton.frame) - 40, CGRectGetMinY(_goodListEntranceButton.frame) - 50, 80, 40)];
    [_shelfButton setBackgroundColor:[UIColor blackColor]];
    [_shelfButton setTitle:@"货架" forState:UIControlStateNormal];
    [_shelfButton addTarget:self action:@selector(buttonTappedOpenWebView:) forControlEvents:UIControlEventTouchUpInside];
    
    _orderButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(_goodListEntranceButton.frame) - 40,CGRectGetMinY(_goodListEntranceButton.frame) + 50, 80, 40)];
    [_orderButton setBackgroundColor:[UIColor blackColor]];
    [_orderButton setTitle:@"订单" forState:UIControlStateNormal];
    [_orderButton addTarget:self action:@selector(buttonTappedOpenWebView:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initEnjoyConfigButton {
    _enjoyConfigButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height / 2 - 20, 40, 40)];
    _enjoyConfigButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [_enjoyConfigButton setBackgroundColor:[UIColor blackColor]];
    [_enjoyConfigButton setTitle:@"配置" forState:UIControlStateNormal];
    
    [_enjoyConfigButton addTarget:self action:@selector(enjoyConfigButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)goodListEntranceDidClick:(id)sender {
#ifdef VP_MALL
    if (_type == VPInterfaceControllerTypeMall) {
        [_interfaceController openGoodsList];
    }
#endif
}

- (void)enjoyConfigButtonDidClick:(id)sender {
//    [_interfaceController launchData];
//    [_interfaceController openEnjoyConfigPage:[PrivateConfig shareConfig].verticalFullScreen];
    [_interfaceController navigationWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"LuaView://defaultLuaView?template=enjoy_main.lua&id=enjoy_main"]] data:@{@"fullScreen" : @([PrivateConfig shareConfig].verticalFullScreen).stringValue}];
}

- (void)initInterfaceController {
    NSDate *datenow = [NSDate date];
    [VPIConfigSDK setIdentity:[NSString stringWithFormat:@"%f",[datenow timeIntervalSince1970]]];
    //videoIdentifier可传协商过唯一ID拼接,并非必须为url
    VPInterfaceControllerConfig *config = [[VPInterfaceControllerConfig alloc] init];
    config.platformID = [PrivateConfig shareConfig].platformID;
    config.identifier = [PrivateConfig shareConfig].identifier;
    config.types = _type;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([PrivateConfig shareConfig].cate) {
        [dict setObject:[PrivateConfig shareConfig].cate forKey:@"category"];
    }
    if ([PrivateConfig shareConfig].creativeName) {
        [dict setObject:[PrivateConfig shareConfig].creativeName forKey:@"creativeName"];
    }
    config.extendDict = dict;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    VPIVideoPlayerSize *videoPlayerSize = [[VPIVideoPlayerSize alloc] init];
    videoPlayerSize.portraitFullScreenWidth = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    videoPlayerSize.portraitFullScreenHeight = screenSize.width < screenSize.height ? screenSize.height : screenSize.width;
    videoPlayerSize.portraitSmallScreenHeight = videoPlayerSize.portraitFullScreenWidth * 9.0/16.0;
    videoPlayerSize.portraitSmallScreenOriginY = 0.0;
    if ([VPSinglePlayerViewController isIPHONEX]) {
        videoPlayerSize.portraitSmallScreenOriginY = 44.0;
    }
    _interfaceController = [[VPInterfaceController alloc] initWithFrame:self.view.bounds config:config videoPlayerSize:videoPlayerSize];
    _interfaceController.delegate = self;
    _interfaceController.userDelegate = self;
    _interfaceController.videoPlayerDelegate = self;

    [_interfaceController start];
}

- (void)refreshInterfaceContainer {
//    NSTimeInterval playbackTime = _player.currentPlaybackTime;
    //需要更新的时间为毫秒数
//    [_interfaceController updateCurrentPlaybackTime:playbackTime * 1000];
}

- (void)dismissPlayerViewController {
    [self stop];
    [self dismissViewControllerAnimated:YES completion:^{
        //TODO: 如果有navigationController需要打开多个视频页不在这里关闭
    }];
}

- (void)stop {
    if(_refreshInterfaceTimer) {
        [_refreshInterfaceTimer invalidate];
        _refreshInterfaceTimer = nil;
    }
    [_player shutdown];
    [_mediaControlView stop];
    [_interfaceController stop];
    _interfaceController.delegate = nil;
    
    if(_tableView) {
        [_sources removeAllObjects];
        _tableView.dataSource = nil;
        [_tableView removeFromSuperview];
    }
    
    [self deregisterPlayerNotification];
    
    [_gestureView removeGestureRecognizer:[_gestureView.gestureRecognizers firstObject]];
}

- (void)gestureViewTapped:(id)sender {
    if(_mediaControlView.isShowed) {
        [_mediaControlView hideControlView];
    }
    else {
        [_mediaControlView showControlView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerPlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerIsPreparedToPlay:) name:VPAVPlayerIsPreparedToPlayNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:VPAVPlayerPlaybackDidFinishNotification object:_player];
}

- (void)deregisterPlayerNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPAVPlayerIsPreparedToPlayNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPAVPlayerPlaybackDidFinishNotification object:_player];
}

- (void)registerDeviceOrientationNotification {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deregisterDeviceOrientationNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

#pragma mark -- Notification

- (void)playerIsPreparedToPlay:(NSNotification *)notification {
    //在视频加载完成后更新一次interface的界面大小
    [self updateFrame];
}

- (void)playerPlaybackDidFinish:(NSNotification *)notification {
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    NSLog(@"finish reason:%d",reason);
    
    //播放完成
    if ([PrivateConfig shareConfig].unlimitedPlay) {
        [PrivateConfig shareConfig].playedCount++;
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter]  postNotificationName:PrivateNotificationUpdatePlayedCount object:nil];
        }];
    }
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }
    CGRect rect = self.view.frame;
    CGRect cRect = self.view.frame;
    if (UIDeviceOrientationIsPortrait(orientation)) {
        cRect.size.height = MAX(rect.size.width, rect.size.height);
        cRect.size.width = MIN(rect.size.height, rect.size.width);
    }
    else if (UIDeviceOrientationIsLandscape(orientation)) {
        cRect.size.height = MIN(rect.size.width, rect.size.height);
        cRect.size.width = MAX(rect.size.height, rect.size.width);
    }
    self.view.frame = cRect;
    if(UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation)) {
        _isFullScreen = UIDeviceOrientationIsLandscape(orientation);
    }
    else {
        _isFullScreen = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    }
    
    if (_isFullScreen || [PrivateConfig shareConfig].verticalFullScreen) {
        [_player updateFrame:self.view.bounds];
    }
    else {
        float y = 0;
        float videoHeight = _player.videoNowRect.size.width > _player.videoNowRect.size.height ? _player.videoNowRect.size.height : _player.videoNowRect.size.width;
        float videoWidth = _player.videoNowRect.size.width > _player.videoNowRect.size.height ? _player.videoNowRect.size.width : _player.videoNowRect.size.height;
        float ratio = 9.0 / 16.0;
        if (videoWidth > 0) {
            ratio = videoHeight / videoWidth;
        }
        if ([VPSinglePlayerViewController isIPHONEX]) {
            y = 44.0;
        }
        [_player updateFrame:CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.width * ratio)];
    }
    
    [_mediaControlView setIsFullScreen:_isFullScreen];
    [_mediaControlView setFrame:_player.view.frame];
    //旋转更新界面大小
    [self updateFrame];
}


#pragma mark -- VPInterfaceStatusChangeNotifyDelegate
- (void)vp_webLinkOpenWithURL:(NSString *)url {
    //可以使用url去打开webview
}

- (void)vp_interfaceVideoAdBack {
    NSLog(@"点击返回按钮");
}

- (void)vp_interfaceLoadComplete:(NSDictionary *)completeDictionary {
//    NSLog(@"%@",completeDictionary);
    
    //在互动层加载完成后最好也更新一次interface界面大小
    [self updateFrame];
    //添加刷新timer,只有点播需要
    if(!_isLive) {
        if(!_refreshInterfaceTimer) {
            _refreshInterfaceTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshInterfaceContainer) userInfo:nil repeats:YES];
        }
    }
}

-(void)updateFrame {
    VPIVideoPlayerOrientation type = VPIVideoPlayerOrientationPortraitSmallScreen;
    if ([PrivateConfig shareConfig].verticalFullScreen || _isFullScreen) {
        
        if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            type = VPIVideoPlayerOrientationLandscapeFullScreen;
        }
        else {
            type = VPIVideoPlayerOrientationPortraitFullScreen;
        }
    }
    _currentPlayerOrientationType = type;
    [_interfaceController notifyVideoScreenChanged:type];
}

- (void)vp_interfaceLoadError:(NSString *)errorString {
    if(errorString) {
        NSLog(@"%@",errorString);
    }
}

- (void)vp_interfaceEnjoyEnd {
    
}

- (void)vp_interfaceScreenChangedNotify:(NSDictionary *)dict {
    int val = UIInterfaceOrientationPortrait;
    if ([[dict objectForKey:@"orientation"] integerValue] == 1) {
        val = UIInterfaceOrientationPortrait;
    }
    else {
        val = UIInterfaceOrientationMaskLandscape;
    }
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)vp_interfaceEnjoyChangeToPortrait:(BOOL)toPortrait {
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//        SEL selector = NSSelectorFromString(@"setOrientation:");
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//        [invocation setSelector:selector];
//        [invocation setTarget:[UIDevice currentDevice]];
//        int val = UIInterfaceOrientationPortrait;
//        [invocation setArgument:&val atIndex:2];
//        [invocation invoke];
//    }
}

- (void)vp_interfaceActionNotify:(NSDictionary *)actionDictionary {
    
    VPIActionType actionType = (VPIActionType)[[actionDictionary objectForKey:@"actionType"] integerValue];
    switch (actionType) {
        case VPIActionTypeOpenUrl:
            if ([actionDictionary objectForKey:@"actionString"]) {
                VPWebViewController *webViewController = [[VPWebViewController alloc] init];
                __weak typeof(self) weakSelf = self;
                [webViewController loadUrl:[actionDictionary objectForKey:@"actionString"] close:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf->_interfaceController platformCloseActionWebView];
                }];
                [self presentViewController:webViewController animated:YES completion:nil];
            }
            break;
        case VPIActionTypePauseVideo:
            [_player pause];
            _mediaControlView.hidden = YES;
            break;
        case VPIActionTypePlayVideo:
            [_player play];
            _mediaControlView.hidden = NO;
            break;
            
        default:
            break;
    }
    
    VPIEventType eventType = (VPIEventType)[[actionDictionary objectForKey:@"eventType"] integerValue];
    if (eventType == VPIEventTypeBack) {
        [self dismissPlayerViewController];
    }
    
    NSLog(@"%@", actionDictionary);
    if(!_tableView && [PrivateConfig shareConfig].notificationShow) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(50, 60, 200, 220) style:UITableViewStylePlain];
        [self.view insertSubview:_tableView atIndex:2];
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
//        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    if(!_sources) {
        _sources = [NSMutableArray array];
    }
    
    [_sources addObject:actionDictionary];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_sources count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
//        cell.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:7];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
    
    NSDictionary *source = [_sources objectAtIndex:indexPath.row];
    
//    VPIActionType actionType = [[source objectForKey:@"action"] integerValue];
//    VPIActionItemType adType = [[source objectForKey:@"adType"] integerValue];
//
//    NSString *action = @"";
//    switch (actionType) {
//        case VPIActionTypeShow:
//            action = @"显示";
//            break;
//        case VPIActionTypeClick:
//            action = @"点击";
//            break;
//        case VPIActionTypeClose:
//            action = @"关闭";
//            break;
//        default:
//            break;
//    }
    
    /*
     
     VPIActionItemTypeTag,               // 热点
     VPIActionItemTypeAdInfo,            // 海报
     VPIActionItemTypeBasicWiki,         // 百科
     VPIActionItemTypeBasicMix,          // 轮播广告
     VPIActionItemTypeCardGame,          // 卡牌
     VPIActionItemTypeVote,              // 投票
     VPIActionItemTypeImage,             // 云图
     VPIActionItemTypeGift,              // 红包
     VPIActionItemTypeEasyShop,          // 轻松购,商品
     VPIActionItemTypeLottery,           // 趣味抽奖
     VPIActionItemTypeBubble,            // 灵动气泡
     VPIActionItemTypeVideoClip,         // 中插广告
     VPIActionItemTypeNews,              // 新闻
     VPIActionItemTypeText,              // 图文链
     VPIActionItemTypeFavor,             // 点赞
     VPIActionItemTypeGoodList,          // 电商清单
     
     */
    
//    NSString *ad = @"";
//
//    switch (adType) {
//        case VPIActionItemTypeTag:
//            ad = @"热点";
//            break;
//        case VPIActionItemTypeAdInfo:
//            ad = @"海报";
//            break;
//        case VPIActionItemTypeBasicWiki:
//            ad = @"百科";
//            break;
//        case VPIActionItemTypeBasicMix:
//            ad = @"轮播";
//            break;
//        case VPIActionItemTypeCardGame:
//            ad = @"卡牌";
//            break;
//        case VPIActionItemTypeVote:
//            ad = @"投票";
//            break;
//        case VPIActionItemTypeImage:
//            ad = @"云图";
//            break;
//        case VPIActionItemTypeGift:
//            ad = @"红包";
//            break;
//        case VPIActionItemTypeEasyShop:
//            ad = @"购物";
//            break;
//        case VPIActionItemTypeLottery:
//            ad = @"抽奖";
//            break;
//        case VPIActionItemTypeBubble:
//            ad = @"气泡";
//            break;
//        case VPIActionItemTypeVideoClip:
//            ad = @"中插";
//            break;
//        case VPIActionItemTypeNews:
//            ad = @"新闻";
//            break;
//        case VPIActionItemTypeText:
//            ad = @"图文";
//            break;
//        case VPIActionItemTypeFavor:
//            ad = @"点赞";
//            break;
//        case VPIActionItemTypeGoodList:
//            ad = @"列表";
//            break;
//
//        default:
//            break;
//    }
//
//    NSString *adID = [source objectForKey:@"adID"];
//    NSString *resourceID = [source objectForKey:@"resourceID"];
//
//    cell.textLabel.text = [NSString stringWithFormat:@"type:%@, action:%@", ad, action];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"adID:%@, rID:%@", adID, resourceID];
    return cell;
}


-(void)createWebView {
#ifdef VP_MALL
    if(!_webViewContent) {
        _webViewContent = [[UIView alloc] initWithFrame:self.view.bounds];
        _webViewContent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UIView *closeView = [[UIView alloc] initWithFrame:_webViewContent.bounds];
        closeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewNeedClose)]];
        [_webViewContent addSubview:closeView];
        [_webViewContent setHidden:YES];
        [self.view addSubview:_webViewContent];
    }
    
    if(!_goodsListWebView) {
        VPIPubWebView *webView = [[VPIPubWebView alloc] initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 80)];
        webView.userDelegate = self;
        webView.delegate = self;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_webViewContent addSubview:webView];
        _goodsListWebView = webView;
    }
#endif
}

- (void)webViewNeedClose {
#ifdef VP_MALL
    [_goodsListWebView loadUrl:@""];
    [_goodsListWebView closeAndRemoveFromSuperView];
    [_webViewContent setHidden:YES];
    _goodsListWebView = nil;
#endif
}

- (BOOL)shouldAutorotate {
//    if ([PrivateConfig shareConfig].verticalFullScreen) {
//        return NO;
//    }
//    else {
        return YES;
//    }
}

/// Tells the delegate that the video player has began or resumed playing a video.
- (void)videoPlayerDidPlayVideo {
    [_interfaceController videoPlayerDidPlayVideo];
}

/// Tells the delegate that the video player has paused video.
- (void)videoPlayerDidPauseVideo {
    [_interfaceController videoPlayerDidPauseVideo];
}

/// Tells the delegate that the video player's video playback has ended.
- (void)videoPlayerDidStopVideo {
    [_interfaceController videoPlayerDidStopVideo];
}

- (NSTimeInterval)videoPlayerCurrentItemAssetDuration {
    return _player.currentItemDuration;
}

- (NSTimeInterval)videoPlayerCurrentTime {
    return _player.currentPlaybackTime;
}

- (VPIVideoPlayerSize *)videoPlayerSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    VPIVideoPlayerSize *videoPlayerSize = [[VPIVideoPlayerSize alloc] init];
    videoPlayerSize.portraitFullScreenWidth = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    videoPlayerSize.portraitFullScreenHeight = screenSize.width < screenSize.height ? screenSize.height : screenSize.width;
    videoPlayerSize.portraitSmallScreenHeight = videoPlayerSize.portraitFullScreenWidth * 9.0/16.0;
    videoPlayerSize.portraitSmallScreenOriginY = 0.0;
    if ([VPSinglePlayerViewController isIPHONEX]) {
        videoPlayerSize.portraitSmallScreenOriginY = 44.0;
    }
    return videoPlayerSize;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

+ (BOOL)isIPHONEX {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    
    return iPhoneXSeries;
}

@end
