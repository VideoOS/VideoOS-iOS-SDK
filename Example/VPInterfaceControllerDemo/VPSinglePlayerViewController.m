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
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPInterfaceController.h>
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIUserInfo.h>
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIUserLoginInterface.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VPUPTopViewController.h>
#import "sys/utsname.h"

#import <VideoOS/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>

#import <Masonry/Masonry.h>
#import "VPVideoSettingView.h"
#import "VPWebViewController.h"
#import "VPLoginViewController.h"
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>
#import "VPVideoAppSettingView.h"
#import "VPConfigListData.h"
#import <SVGAPlayer/SVGAPlayer.h>
#import <SVGAPlayer/SVGAParser.h>
@interface VPSinglePlayerViewController() <VPInterfaceStatusNotifyDelegate, VPIUserLoginInterface,VPVideoPlayerDelegate,VPIVideoPlayerDelegate,VPIServiceDelegate,VPMediaControlViewDelegate,SVGAPlayerDelegate> {
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
    
    VPIUserInfo *_userInfo;
    
    VPIVideoPlayerOrientation _currentPlayerOrientationType;
}


@property (nonatomic, weak) UIButton *settingButton;
@property (nonatomic, weak) UIButton *videoButton;
@property (nonatomic, weak) UIButton *simulateButton;
@property (nonatomic, weak) UIButton *closeInfoViewButton;
@property (nonatomic, weak) UIButton *appInfoViewButton;
@property (nonatomic, weak) VPVideoSettingView *settingView;
@property (nonatomic, weak) VPVideoAppSettingView *appSettingView;
@property (nonatomic, strong) SVGAPlayer *svgPlayer;

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
        
        if (urlString != nil) {
            _urlString = urlString;
        } else {
            _urlString = [@"https://ai.videojj.com/5a90cfb1a1195f9d07f891c4/搜狐视频-继承者计划第7集.mp4" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
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
        //监听控制器播放暂停
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playButtonAction:) name:@"VPIPlayButtonAction" object:nil];
        
        
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
    
    [self initInterfaceController];
    
    [self.view addSubview:_player.view];
    //手势层置于互动层下方
    [self.view addSubview:_gestureView];
    
    [self.view addSubview:_interfaceController.view];
    //控制栏没有全屏幕手势放在最上方
    [self.view addSubview:_mediaControlView];
    
    if ([PrivateConfig shareConfig].cytron == YES) {
        [self initSettingButton];
    }
    
    [self registerDeviceOrientationNotification];
    
    [_player pause];
    [self loadPreAdvertising];
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        _mediaControlView.videoSwitchButton.hidden = YES;
        _mediaControlView.btnConstraint.constant = 0;
        VPIServiceConfig *config = [[VPIServiceConfig alloc] init];
        config.type = VPIServiceTypeVideoMode;
        config.identifier = _interfaceController.config.identifier;
        [_interfaceController startService:VPIServiceTypeVideoMode config:config];
    }else {
        _mediaControlView.videoSwitchButton.hidden = NO;
        _mediaControlView.btnConstraint.constant = 60;
        [self switchVideoNetModeStateOff:NO];
    }
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
    _mediaControlView.delegate = self;
    _mediaControlView.videoSwitchButton.selected = YES;
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
    UIButton *simulateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [simulateButton setImage:whiteImage forState:UIControlStateNormal];
    [self.view addSubview:simulateButton];
    [simulateButton addTarget:self action:@selector(simulateButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [simulateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [simulateButton setTitle:@"模拟" forState:UIControlStateNormal];
    simulateButton.titleEdgeInsets = UIEdgeInsetsMake(0, -whiteImage.size.width, 0, 0);
    self.simulateButton = simulateButton;
    
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
    
    UIButton *appInfoViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [appInfoViewButton setImage:whiteImage forState:UIControlStateNormal];
    [appInfoViewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [appInfoViewButton setTitle:@"APP" forState:UIControlStateNormal];
    appInfoViewButton.titleEdgeInsets = UIEdgeInsetsMake(0, -whiteImage.size.width, 0, 0);
    [self.view addSubview:appInfoViewButton];
    [appInfoViewButton addTarget:self action:@selector(appInfoViewButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.appInfoViewButton = appInfoViewButton;
    
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
    
    [simulateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(whiteImage.size.width);
        make.height.mas_equalTo(whiteImage.size.height);
        make.centerX.equalTo(settingButton.mas_centerX);
        make.bottom.equalTo(videoButton.mas_top).with.offset(-10);
    }];
    
    [closeInfoViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(whiteImage.size.width);
        make.height.mas_equalTo(whiteImage.size.height);
        make.centerX.equalTo(settingButton.mas_centerX);
        make.bottom.equalTo(simulateButton.mas_top).with.offset(-10);
    }];
    
    [appInfoViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(whiteImage.size.width);
        make.height.mas_equalTo(whiteImage.size.height);
        make.centerX.equalTo(settingButton.mas_centerX);
        make.bottom.equalTo(closeInfoViewButton.mas_top).with.offset(-10);
    }];
    
    videoButton.hidden = YES;
    simulateButton.hidden = YES;
    closeInfoViewButton.hidden = YES;
    appInfoViewButton.hidden = YES;
}

- (void)settingButtonDidClicked:(id)sender {
    if (self.simulateButton.hidden == YES) {
        self.simulateButton.hidden = NO;
        self.videoButton.hidden = NO;
        self.closeInfoViewButton.hidden = NO;
        self.appInfoViewButton.hidden = NO;
    }
    else {
        self.simulateButton.hidden = YES;
        self.videoButton.hidden = YES;
        self.closeInfoViewButton.hidden = YES;
        self.appInfoViewButton.hidden = YES;
    }
}

- (void)simulateButtonDidClicked:(id)sender {

    
//    VPIServiceConfig *config = [[VPIServiceConfig alloc] init];
//    config.identifier = _interfaceController.config.identifier;
//    config.type = VPIServiceTypeVideoMode;
//    config.duration = VPIVideoAdTimeType60Seconds;
//    [_interfaceController startService:VPIServiceTypeVideoMode config:config];
//    return;
    
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"adInfo" ofType:@"json"];
    NSDictionary *adInfo = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
    
    [_interfaceController navigationWithURL:[NSURL URLWithString:@"LuaView://defaultLuaView?template=os_video_figureStarList_hotspot.lua&id=5aa5fa5133edbf375fe43fff4"] data:[[adInfo objectForKey:@"launchInfoList"] objectAtIndex:0]];
    
//    [_interfaceController navigationWithURL:[NSURL URLWithString:@"LuaView://defaultLuaView?template=os_bubble.lua&id=5aa5fa5133edbf375fe43fff4"] data:[[adInfo objectForKey:@"launchInfoList"] objectAtIndex:0]];
    
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

- (void)switchVideoNetModeStateOff:(BOOL)off {
    if (off == YES) {
        [self addSVGAPlayerName:@"saomiao_off"];
        [self stopVideoNetMode];
    }else {
        [self addSVGAPlayerName:@"saomiao_no"];
        [self startVideoNetMode];
    }
}

- (void)startVideoNetMode {
    VPIServiceConfig *config = [[VPIServiceConfig alloc] init];
    config.type = VPIServiceTypeVideoMode;
    config.identifier = _interfaceController.config.identifier;
    [_interfaceController startService:VPIServiceTypeVideoMode config:config];
}

- (void)stopVideoNetMode {
    [_interfaceController stopService:VPIServiceTypeVideoMode];
}

- (void)addSVGAPlayerName:(NSString *)name {
    SVGAParser *parser = [[SVGAParser alloc]init];
    self.svgPlayer = [[SVGAPlayer alloc]initWithFrame:self.view.bounds];
    self.svgPlayer.delegate = self;
    self.svgPlayer.loops = 1;
    self.svgPlayer.userInteractionEnabled = NO;
    [self.view addSubview:self.svgPlayer];
    [self.svgPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    [parser parseWithNamed:name inBundle:[NSBundle mainBundle] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
        if (videoItem != nil) {
            self.svgPlayer.videoItem = videoItem;
            [self.svgPlayer startAnimation];
        }
    } failureBlock:^(NSError * _Nonnull error) {
        NSLog(@"SVGAPlayer：：：%@",error);
    }];
}


- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player {
    
    [player clear];
    self.svgPlayer = nil;
    [player removeFromSuperview];
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
        [PrivateConfig shareConfig].videoUrl = self.settingView.urlTextField.text;
        [PrivateConfig shareConfig].identifier = self.settingView.videoIdTextField.text;
        [PrivateConfig shareConfig].environment = self.settingView.environmentControl.selectedSegmentIndex;
        [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:[PrivateConfig shareConfig].environment];
//        [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateTest];
        [self reloadVideoInfo];
    }
    [self.settingView.platformIdTextField resignFirstResponder];
    [self.settingView.urlTextField resignFirstResponder];
    [self.settingView removeFromSuperview];
    self.settingView = nil;
}

- (void)reloadVideoInfo {
    [self stopVideoNetMode];
    [_interfaceController stop];
    if ([PrivateConfig shareConfig].videoUrl != nil) {
        [_player changeContentURLString:[PrivateConfig shareConfig].videoUrl];
    } else {
        [_player changeContentURLString:[PrivateConfig shareConfig].identifier];
    }
    if ([PrivateConfig shareConfig].creativeName) {
        _interfaceController.config.extendDict = @{@"creativeName":[PrivateConfig shareConfig].creativeName};
    }
    _interfaceController.config.identifier = [PrivateConfig shareConfig].identifier;
    _mediaControlView.hidden = NO;
    [_interfaceController start];
    if (_mediaControlView.videoSwitchButton.selected) {
        [self startVideoNetMode];
    }
    [self deviceOrientationChange:nil];
}

- (void)appInfoViewButtonDidClicked:(id)sender {
    VPVideoAppSettingView *appSettingView = [[VPVideoAppSettingView alloc] initWithFrame:self.view.bounds data:self.mockConfigData];
    [self.view addSubview:appSettingView];
    [appSettingView.applyButton addTarget:self action:@selector(appSettingViewApplyButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [appSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    self.appSettingView = appSettingView;
}

- (void)appSettingViewApplyButtonDidClicked:(id)sender {
    if (self.appSettingView.appKeyTextField.text.length > 0 && self.appSettingView.appSecretTextField.text.length == 16) {
        [PrivateConfig shareConfig].environment = self.appSettingView.environmentControl.selectedSegmentIndex;
        [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:[PrivateConfig shareConfig].environment];
        [VPIConfigSDK setAppKey:self.appSettingView.appKeyTextField.text appSecret:self.appSettingView.appSecretTextField.text];
        
        [self.appSettingView.appKeyTextField resignFirstResponder];
        [self.appSettingView.appSecretTextField resignFirstResponder];
        [self.appSettingView removeFromSuperview];
        self.appSettingView = nil;
        [self dismissPlayerViewController];
        
        VPConfigData *config = [[VPConfigData alloc] init];
        config.appKey = self.appSettingView.appKeyTextField.text;
        config.appSecret = self.appSettingView.appSecretTextField.text;
        [[VPConfigListData shared] addConfigData:config];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确格式的AppKey和AppSecret" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
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

- (void)initGestureView {
    _gestureView = [[UIView alloc] initWithFrame:self.view.bounds];
    _gestureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureViewTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    
    [_gestureView addGestureRecognizer:tapGestureRecognizer];
}

- (void)initInterfaceController {
//    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateTest];
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
    _interfaceController.serviceDelegate = self;

    [_interfaceController start];
}

- (void)dismissPlayerViewController {
    [self stop];
    [self dismissViewControllerAnimated:YES completion:^{
        //TODO: 如果有navigationController需要打开多个视频页不在这里关闭
    }];
}

- (void)stop {
    [_player shutdown];
    [_mediaControlView stop];
    [_interfaceController stop];
    _interfaceController.delegate = nil;
    
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

- (void)openWebViewWithUrl:(NSString *)url {
    VPWebViewController *webViewController = [[VPWebViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    [webViewController loadUrl:url close:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_interfaceController platformCloseActionWebView];
        [strongSelf->_interfaceController playVideoAd];
    }];
    [[VPUPTopViewController topViewController] presentViewController:webViewController animated:YES completion:nil];
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
    [self loadPostAdvertising];
    
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

- (BOOL)shouldAutorotate {
    //    if ([PrivateConfig shareConfig].verticalFullScreen) {
    //        return NO;
    //    }
    //    else {
    return YES;
    //    }
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }
    
    if (orientation == UIDeviceOrientationPortrait) {
        
        _mediaControlView.videoSwitchButton.hidden = YES;
        _mediaControlView.btnConstraint.constant = 0;
    }else {
        _mediaControlView.videoSwitchButton.hidden = NO;
        _mediaControlView.btnConstraint.constant = 60;
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

- (void)vp_interfaceLoadComplete:(NSDictionary *)completeDictionary {
//    NSLog(@"%@",completeDictionary);
    
    //在互动层加载完成后最好也更新一次interface界面大小
    [self updateFrame];
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

- (void)vp_interfaceScreenChangedNotify:(NSDictionary *)dict {
    int val = UIInterfaceOrientationPortrait;
    if ([[dict objectForKey:@"orientation"] integerValue] == 1) {
        val = UIInterfaceOrientationPortrait;
    }
    else {
        val = UIInterfaceOrientationLandscapeRight;
    }
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)vp_interfaceActionNotify:(NSDictionary *)actionDictionary {
    
    VPIActionType actionType = (VPIActionType)[[actionDictionary objectForKey:@"actionType"] integerValue];
    switch (actionType) {
        case VPIActionTypeOpenUrl:
            if ([actionDictionary objectForKey:@"actionString"]) {
                
                NSString *linkUrl = [actionDictionary objectForKey:@"actionString"];
                if ([linkUrl rangeOfString:@"http"].location == 0) {
                    //纯url直接web打开处理
                    [self openWebViewWithUrl:linkUrl];
                } else {
                    //非纯url,暂定使用 | 分割
                    NSArray *stringArray = [linkUrl componentsSeparatedByString:@"|"];
                    if ([stringArray count] == 2) {
                        //第一个为功能
                        NSString *function = [stringArray firstObject];
                        //第二个为url
                        NSString *url = [stringArray lastObject];
                        
                        if ([url rangeOfString:@"http"].location != 0) {
                            //有什么错误
                            // 暂时无法处理的url
                            [self openWebViewWithUrl:linkUrl];
                            break;
                        }
                        
                        if ([function isEqualToString:@"cv"]) {
                            // cv 切换视频
                            [PrivateConfig shareConfig].videoUrl = url;
                            [PrivateConfig shareConfig].identifier = url;
                            [self reloadVideoInfo];
                            
                        } else {
                            // 暂时无法处理的url
                            [self openWebViewWithUrl:linkUrl];
                        }
                    } else {
                        // 暂时无法处理的url
                        [self openWebViewWithUrl:linkUrl];
                    }
                }
                if ([actionDictionary objectForKey:@"deepLink"] && [[actionDictionary objectForKey:@"deepLink"] length] > 0) {
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[actionDictionary objectForKey:@"deepLink"]]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[actionDictionary objectForKey:@"deepLink"]]];
                    }
                    else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"App打开失败" preferredStyle:UIAlertControllerStyleAlert];
                        __weak typeof(self) weakSelf = self;
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            __strong typeof(self) strongSelf = weakSelf;
                            [strongSelf->_interfaceController platformCloseActionWebView];
                        }];
                        [alert addAction:action];
                        [[VPUPTopViewController topViewController] presentViewController:alert animated:YES completion:nil];
                    }
                }
            }
            break;
        case VPIActionTypePauseVideo:
            [_player pause];
//            _mediaControlView.hidden = YES;
            [_mediaControlView hideControlView];
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


-(CGRect)videoFrame {
    return _player.getVideoFrame;
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

- (void)playButtonAction:(NSNotification *)sender {
    if (sender.userInfo) {
        if ([sender.userInfo[@"type"] integerValue] == 0) {
            VPIServiceConfig *config = [[VPIServiceConfig alloc] init];
            config.identifier = _interfaceController.config.identifier;
            config.type = VPIServiceTypePauseAd;
            config.duration = VPIVideoAdTimeType60Seconds;
            [_interfaceController startService:VPIServiceTypePauseAd config:config];
        }
        else {
            [_interfaceController stopService:VPIServiceTypePauseAd];
        }
    }
}

- (void)loadPreAdvertising {
    VPIServiceConfig *config = [[VPIServiceConfig alloc] init];
    config.identifier = _interfaceController.config.identifier;
    config.type = VPIServiceTypePreAdvertising;
    config.duration = VPIVideoAdTimeType60Seconds;
    [_interfaceController startService:VPIServiceTypePreAdvertising config:config];
}

- (void)loadPostAdvertising {
    VPIServiceConfig *config = [[VPIServiceConfig alloc] init];
    config.identifier = _interfaceController.config.identifier;
    config.type = VPIServiceTypePostAdvertising;
    config.duration = VPIVideoAdTimeType60Seconds;
    [_interfaceController startService:VPIServiceTypePostAdvertising config:config];
}

- (void)vp_didCompleteForService:(VPIServiceType )type {
    if (type == VPIServiceTypePostAdvertising || type == VPIServiceTypePreAdvertising) {
        if (!_player.isPlaying) {
            [_mediaControlView playButtonTapped:nil];
        }
    }
}

- (void)vp_didFailToCompleteForService:(VPIServiceType )type error:(NSError *)error {
    if (type == VPIServiceTypePostAdvertising || type == VPIServiceTypePreAdvertising) {
        if (!_player.isPlaying) {
            [_mediaControlView playButtonTapped:nil];
        }
    }
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
