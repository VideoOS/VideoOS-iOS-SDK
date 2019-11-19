//
//  DevAppPlayerViewController.m
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/12.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "DevAppPlayerViewController.h"
#import "DevAppMediaControlView.h"
#import "VPAVPlayerController.h"
#import "VPWebViewController.h"
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPInterfaceController.h>
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIUserInfo.h>
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIUserLoginInterface.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VPUPTopViewController.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>
@interface DevAppPlayerViewController ()<VPVideoPlayerDelegate,DevAppMediaControlStatusBarDelegate,VPInterfaceStatusNotifyDelegate, VPIUserLoginInterface,VPIVideoPlayerDelegate,VPIServiceDelegate>
{
    VPInterfaceController *_interfaceController;
}

@property (nonatomic) VPAVPlayerController *player;
@property (nonatomic) DevAppMediaControlView *mediaControlView;
@property (nonatomic) UIView *gestureView;
@end

@implementation DevAppPlayerViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    switch (self.controllerType) {
        case Type_Interaction:
            NSLog(@"视频小工具");
            break;
        case Type_Service:
            NSLog(@"视频小程序");
            [self setNewOrientation:true];
            break;
            
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self setUpNav];
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
    
    [_mediaControlView showControlView];
    
    [self refreshUI];
    
    
    if (self.controllerType == Type_Interaction) {
        [_interfaceController navigationWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"LuaView://defaultLuaView?template=%@&id=5aa5fa5133edbf375fe43fff4",self.interaction_templateLua]] data:self.interaction_Data];
    }else{     
        [self switchVideoNetModeStateOff:true];
    }
    
       
}

- (void)initPlayer {
    
    if (self.videoFile == nil || self.videoFile.length == 0) {
        self.videoFile = @"http://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/test/SupergirlS04E12.mp4";
    }
    
    self.player = [[VPAVPlayerController alloc] initWithContentURLString:_videoFile];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self registerPlayerNotification];
    [_player prepareToPlay];
    _player.videoPlayerDelagate = self;
}

- (void)initMediaControlView {
    _mediaControlView = [DevAppMediaControlView mediaControlViewWithNib];
    _mediaControlView.backgroundColor = [UIColor clearColor];
    if (self.controllerType == Type_Interaction) {
        [_mediaControlView.switchButton setImage:[UIImage imageNamed:@"quanping"] forState:UIControlStateNormal];
        [_mediaControlView.switchButton setImage:[UIImage imageNamed:@"quanping"] forState:UIControlStateSelected];
        _mediaControlView.eyeButton.hidden = true;
    }else{
        [_mediaControlView.switchButton setImage:[UIImage imageNamed:@"alpha0"] forState:UIControlStateNormal];
        [_mediaControlView.switchButton setImage:[UIImage imageNamed:@"alpha0"] forState:UIControlStateSelected];
    }
    
    [_mediaControlView setFrame:_player.view.frame];
    [_mediaControlView setAVPlayerController:_player];
    _mediaControlView.isFullScreen = true;
    
    __weak typeof(self) weakSelf = self;
    [_mediaControlView setBackButtonTappedToDo:^{
        [weakSelf.navigationController popViewControllerAnimated:true];
    }];

    _mediaControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _mediaControlView.statusBarDelegate = self;
    
    [_mediaControlView setTitle:@"开发者模式测试"];
    
    [_mediaControlView setClipsToBounds:true];
}

- (void)initInterfaceController {
    
    VPInterfaceControllerConfig *config = [[VPInterfaceControllerConfig alloc] init];
//    config.platformID = @"platformID";
//    config.identifier = @"platformID";
    config.types = VPInterfaceControllerTypeVideoOS;

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    VPIVideoPlayerSize *videoPlayerSize = [[VPIVideoPlayerSize alloc] init];
    videoPlayerSize.portraitFullScreenWidth = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    videoPlayerSize.portraitFullScreenHeight = screenSize.width < screenSize.height ? screenSize.height : screenSize.width;
    videoPlayerSize.portraitSmallScreenHeight = videoPlayerSize.portraitFullScreenWidth * 9.0/16.0;
    videoPlayerSize.portraitSmallScreenOriginY = 0.0;
    if ([DevAppPlayerViewController isIPHONEX]) {
        videoPlayerSize.portraitSmallScreenOriginY = 44.0;
    }
    _interfaceController = [[VPInterfaceController alloc] initWithFrame:self.view.bounds config:config videoPlayerSize:videoPlayerSize];
    _interfaceController.delegate = self;
    _interfaceController.userDelegate = self;
    _interfaceController.videoPlayerDelegate = self;
    _interfaceController.serviceDelegate = self;

    [_interfaceController start];
}

- (void)initGestureView {
    _gestureView = [[UIView alloc] initWithFrame:self.view.bounds];
    _gestureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    _gestureView.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.2];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureViewTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    
    [_gestureView addGestureRecognizer:tapGestureRecognizer];
}

- (void)gestureViewTapped:(id)sender {
    if(_mediaControlView.isShowed) {
        [_mediaControlView hideControlView];
    }
    else {
        [_mediaControlView showControlView];
    }
}

- (void)registerPlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerIsPreparedToPlay:) name:VPAVPlayerIsPreparedToPlayNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:VPAVPlayerPlaybackDidFinishNotification object:_player];
}


#pragma mark -- Notification

- (void)playerIsPreparedToPlay:(NSNotification *)notification {
    //在视频加载完成后更新一次interface的界面大小
    
    [self refreshUI];

}

- (void)playerPlaybackDidFinish:(NSNotification *)notification {
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    NSLog(@"finish reason:%d",reason);
    
//    if (reason == MPMovieFinishReasonPlaybackError) {
//        _canChangeNext = YES;
//    }
}


-(void)setUpNav{
    self.title = @"开发者模式测试";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (UIBarButtonItem *)rt_customBackItemWithTarget:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:target
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (self.controllerType == Type_Interaction) {
        if (orientation != UIDeviceOrientationPortrait && orientation != UIDeviceOrientationLandscapeLeft  && orientation != UIDeviceOrientationLandscapeRight) {
            return;
        }

    }else{
        if (orientation != UIDeviceOrientationLandscapeLeft && orientation != UIDeviceOrientationLandscapeRight) {
            return;
        }
    }
    [self refreshUI];

}


//支持旋转
- (BOOL)shouldAutorotate {
    return true;
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    switch (self.controllerType) {
        case Type_Interaction:
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
            break;
        case Type_Service:
            return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
            break;
            
        default:
            break;
    }
}

//一开始的方向  很重要
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    switch (self.controllerType) {
        case Type_Interaction:
            return UIInterfaceOrientationPortrait;
            break;
        case Type_Service:
            return UIInterfaceOrientationLandscapeRight;
            break;
            
        default:
            break;
    }
    
}

- (void)setNewOrientation:(BOOL)fullscreen{
    

    if (fullscreen) {
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
        
    }else{
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
    
    [self refreshUI];
}

-(void)refreshUI{
//
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    
    CGRect playerViewFrame;
    
    
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            self.navigationController.navigationBarHidden = false;
            float topHeight;
            if (@available(iOS 11.0, *)) {
                topHeight = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
            } else {
                topHeight = 0;
                // Fallback on earlier versions
            }
            
            
            [_interfaceController notifyVideoScreenChanged:VPIVideoPlayerOrientationPortraitSmallScreen];
            playerViewFrame = CGRectMake(0, topHeight + self.navigationController.navigationBar.frame.size.height, SCREEN_WIDTH, SCREEN_WIDTH * (9.0 / 16.0));
            self.mediaControlView.topControlView.alpha = 0.0;
            
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.mediaControlView.topControlView.alpha = 1.0;
            self.navigationController.navigationBarHidden = true;
            playerViewFrame = CGRectMake(0, 0, MAX(SCREEN_WIDTH, SCREENH_HEIGHT), MIN(SCREEN_WIDTH, SCREENH_HEIGHT));
             [_interfaceController notifyVideoScreenChanged:VPIVideoPlayerOrientationLandscapeFullScreen];
            break;
        case UIDeviceOrientationLandscapeRight:
            self.mediaControlView.topControlView.alpha = 1.0;
            self.navigationController.navigationBarHidden = true;
            playerViewFrame = CGRectMake(0, 0, MAX(SCREEN_WIDTH, SCREENH_HEIGHT), MIN(SCREEN_WIDTH, SCREENH_HEIGHT));
             [_interfaceController notifyVideoScreenChanged:VPIVideoPlayerOrientationLandscapeFullScreen];
            break;
        
        default:
            playerViewFrame = CGRectMake(0, 0, MAX(SCREEN_WIDTH, SCREENH_HEIGHT), MIN(SCREEN_WIDTH, SCREENH_HEIGHT));
            break;
    }
    
    
    [self.player updateFrame:playerViewFrame];
//    [self.mediaControlView setFrame:playerViewFrame];
    self.mediaControlView.frame  = playerViewFrame;
    self.gestureView.frame = playerViewFrame;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark VPVideoPlayerDelegate
- (void)videoPlayerDidStartVideo{
    
}

/// Tells the delegate that the video player has began or resumed playing a video.
- (void)videoPlayerDidPlayVideo{
    [_interfaceController videoPlayerDidPlayVideo];
}

/// Tells the delegate that the video player has paused video.
- (void)videoPlayerDidPauseVideo{
    [_interfaceController videoPlayerDidPauseVideo];
}

/// Tells the delegate that the video player's video playback has ended.
- (void)videoPlayerDidStopVideo{
    [_interfaceController videoPlayerDidStopVideo];
}

#pragma mark DevAppMediaControlStatusBarDelegate
- (void)switchVideoNetModeStateOff:(BOOL)off{
    
    if (self.controllerType == Type_Service) {
        [_interfaceController navigationWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"LuaView://applets?appletId=%@&type=%@&appType=%@",self.service_miniAppID,self.service_screenType,self.service_appType]] data:nil];
        return;
    }
    
    [self setNewOrientation:off];
}

- (void)changeStatusBarHidden:(BOOL)hidden{
    
}

#pragma mark VPInterfaceStatusNotifyDelegate

- (void)vp_interfaceLoadComplete:(NSDictionary *)completeDictionary
{
    [self refreshUI];
}

- (void)vp_interfaceLoadError:(NSString *)errorString{
    if(errorString) {
        NSLog(@"%@",errorString);
    }
}

- (void)vp_interfaceActionNotify:(NSDictionary *)actionDictionary{
    
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
        [self.navigationController popViewControllerAnimated:true];
    }
    
    NSLog(@"%@", actionDictionary);
}
- (void)vp_interfaceScreenChangedNotify:(NSDictionary *)dict{
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

- (void)openWebViewWithUrl:(NSString *)url {
    VPWebViewController *webViewController = [[VPWebViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    [webViewController loadUrl:url close:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_interfaceController platformCloseActionWebView];
        [strongSelf->_interfaceController playVideoAd];
    }];
    webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [[VPUPTopViewController topViewController] presentViewController:webViewController animated:YES completion:nil];
}

#pragma mark VPIUserLoginInterface
- (id)vp_getUserInfo {
    
    VPIUserInfo *userInfo = [[VPIUserInfo alloc] init];
    return userInfo;
}

- (void)vp_userLogined:(VPIUserInfo *) userInfo {
//    NSLog(@"%@",userInfo.uid);
}

- (void)vp_requireLogin:(void (^)(VPIUserInfo *userInfo))completeBlock {
}

#pragma mark VPIVideoPlayerDelegate
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
    videoPlayerSize.portraitSmallScreenOriginY = self.navigationController.navigationBar.frame.size.height;
    if ([DevAppPlayerViewController isIPHONEX]) {
        videoPlayerSize.portraitSmallScreenOriginY = 44.0 + self.navigationController.navigationBar.frame.size.height;
    }
    return videoPlayerSize;
}
#pragma mark VPIServiceDelegate
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
