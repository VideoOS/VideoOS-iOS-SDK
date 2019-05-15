//
//  VPUPDebugSwitch.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPDebugSwitch.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "VPUPNotificationCenter.h"
#import "VPUPGeneralInfo.h"
#import <AVFoundation/AVFoundation.h>
#import "VPUPLifeCycle.h"


//@interface _VPUPUIApplicationSwizzling : NSObject
//
//@end
//
//@implementation _VPUPUIApplicationSwizzling
//
//+ (void)startExchangeImplementations {
//
//    Class applicationClass = [UIApplication class];
//
//    if(class_getInstanceMethod(applicationClass, @selector(sendEvent:))) {
//
//        Method vpupSendEventMethod = class_getInstanceMethod(self, @selector(vpup_sendEvent:));
//
//        Method swizzledMethod = class_getInstanceMethod(applicationClass, @selector(vpup_sendEvent:));
//
//        if (!swizzledMethod) {
//            if (!class_addMethod(applicationClass, @selector(vpup_sendEvent:), method_getImplementation(vpupSendEventMethod),  method_getTypeEncoding(vpupSendEventMethod))) {
//                return;
//            }
//        }
//
//        Method originalMethod = class_getInstanceMethod(applicationClass, @selector(sendEvent:));
//        Method newSwizzledMethod = class_getInstanceMethod(applicationClass, @selector(vpup_sendEvent:));
//
//        if (originalMethod && newSwizzledMethod) {
//            method_exchangeImplementations(originalMethod, newSwizzledMethod);
//        }
//    }
//}
//
//+ (void)stopExchangeImplementations {
//    Class applicationClass = [UIApplication class];
//    Method originalMethod = class_getInstanceMethod(applicationClass, @selector(sendEvent:));
//    Method swizzledMethod = class_getInstanceMethod(applicationClass, @selector(vpup_sendEvent:));
//    if (originalMethod && swizzledMethod) {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}
//
//- (void)vpup_sendEvent:(UIEvent *)event {
//    if(event.type == UIEventTypeTouches) {
//        UITouchPhase phase = [event.allTouches anyObject].phase;
//        if(phase == UITouchPhaseBegan) {
//            [[VPUPNotificationCenter defaultCenter] postNotificationName:@"VPUPNotifyScreenTouch" object:nil userInfo:@{@"event":event}];
//        }
//    }
//
//    [self vpup_sendEvent:event];
//}
//
//@end



//NSString *const VPUPDebugVideoStartNotification = @"VPUPDebugVideoStartNotification";
//NSString *const VPUPDebugVideoStopNotification = @"VPUPDebugVideoStopNotification";
NSString *const VPUPDebugPanelPostReportLogNotification = @"VPUPDebugPanelPostReportLogNotification";
NSString *const VPUPLogAddReportNotification = @"VPUPLogAddReportNotification";

static VPUPDebugSwitch *sharedDebugSwitch = nil;

@interface VPUPDebugSwitch ()

@property (nonatomic) dispatch_queue_t touchQueue;

@property (nonatomic, assign) NSTimeInterval firstTouchTimestamp;
@property (nonatomic, assign) NSTimeInterval currentTouchTimestamp;
@property (nonatomic, assign) NSInteger eachTouchCount;
@property (nonatomic, assign) NSInteger totalTouchCount;
@property (nonatomic, assign) NSInteger switchToTestTouchCount;

@property (nonatomic, assign) BOOL enableToCalculate;
@property (nonatomic, assign) BOOL isWindowGestureAdded;

@property (nonatomic, assign) BOOL enableDebugPanel;
@property (nonatomic, assign) BOOL enableDebugPanelEntrance;
@property (nonatomic, assign) NSInteger debugPanelTouchCount;

@property (nonatomic, strong) NSMutableSet<id<VPUPDebugSwitchProtocol>> *switchObservers;

@end

@implementation VPUPDebugSwitch

+ (VPUPDebugSwitch *)sharedDebugSwitch {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDebugSwitch = [[self alloc] init];
    });
    return sharedDebugSwitch;
}

- (instancetype)init {
    if(!sharedDebugSwitch) {
        sharedDebugSwitch = [super init];
        sharedDebugSwitch.switchObservers = [[NSMutableSet alloc] init];
        sharedDebugSwitch.touchQueue = dispatch_queue_create("com.videopls.utilsplatform.touchQueue", DISPATCH_QUEUE_SERIAL);
//        [sharedDebugSwitch registerWindowTouchNotification];
//        [sharedDebugSwitch registerAudioRouteNotification];
        [sharedDebugSwitch registerLifeCycleVideoNotification];
    }
    return sharedDebugSwitch;
}


- (void)disableLogging {
    _logEnable = NO;
}

- (void)enableLogging {
    _logEnable = YES;
}

//- (void)disableGesture {
//    if(_gestureEnable) {
//        _gestureEnable = NO;
//        [self removeWindowTouchNotification];
//    }
//}
//
//- (void)enableGesture {
//    if(!_gestureEnable) {
//        _gestureEnable = YES;
//        [self registerWindowTouchNotification];
//    }
//}


//- (void)disableDebugPanel {
//    if(_enableDebugPanel) {
//        _enableDebugPanel = NO;
//        [self removeAudioRouteNotification];
//    }
//}
//
//- (void)enableDebugPanel {
//    if(!_enableDebugPanel) {
//        _enableDebugPanel = YES;
//        [self registerAudioRouteNotification];
//    }
//}

- (void)videoStart {
    if(!_enableDebugPanel) {
        _enableDebugPanel = YES;
//        [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPDebugVideoStartNotification object:nil];
//        [self registerAudioRouteNotification];
//        [_VPUPUIApplicationSwizzling startExchangeImplementations];
    }
}

- (void)videoStop {
    if(_enableDebugPanel) {
        _enableDebugPanel = NO;
//        [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPDebugVideoStopNotification object:nil];
//        [self removeAudioRouteNotification];
//        [_VPUPUIApplicationSwizzling stopExchangeImplementations];
    }
}


- (void)switchEnvironment:(VPUPDebugState)environment {
    if(_debugState == environment) {
        return;
    }
    
    _debugState = environment;
    if(_debugState < 2) {
        _logEnable = NO;
    }
    else {
        _logEnable = YES;
    }
    
    [self.switchObservers enumerateObjectsUsingBlock:^(id<VPUPDebugSwitchProtocol>  _Nonnull observer, BOOL * _Nonnull stop) {
        if([observer respondsToSelector:@selector(switchEnvironmentTo:)]) {
            [observer switchEnvironmentTo:environment];
        }
    }];
    
}

- (void)registerDebugSwitchObserver:(nonnull id<VPUPDebugSwitchProtocol>)observer {
    [self.switchObservers addObject:observer];
}

- (void)removeDebugSwitchObserver:(nonnull id<VPUPDebugSwitchProtocol>)observer {
    if([self.switchObservers containsObject:observer]) {
        [self.switchObservers removeObject:observer];
    }
}

- (void)registerAudioRouteNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteDidChanged:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

- (void)removeAudioRouteNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

- (void)audioRouteDidChanged:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    AVAudioSessionRouteChangeReason routeChangeReason = [[userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    //插入耳机 激活debug面板入口10s
    if (routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        if(!_enableDebugPanelEntrance) {
            _enableDebugPanelEntrance = YES;
            _debugPanelTouchCount = 0;
            [self registerWindowTouchNotification];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), _touchQueue, ^{
                _enableDebugPanelEntrance = NO;
                _debugPanelTouchCount = NO;
                _debugPanelTouchCount = 0;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(!_gestureEnable) {
                        [self removeWindowTouchNotification];
                    }
                });
            });
        }
        else {
            _debugPanelTouchCount = 0;
        }
    }
    if(routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        if(_enableDebugPanelEntrance) {
            if(_debugPanelTouchCount == 6) {
                [self triggerDebugPanel];
                _debugPanelTouchCount = 0;
            }
        }
    }
}


- (void)registerWindowTouchNotification {
    if(!_isWindowGestureAdded) {
        _isWindowGestureAdded = YES;
        [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(windowTouchedNotify:) name:@"VPUPNotifyScreenTouch" object:nil];
    }
}

- (void)removeWindowTouchNotification {
    if(_isWindowGestureAdded) {
        _isWindowGestureAdded = NO;
        [[VPUPNotificationCenter defaultCenter] removeObserver:self name:@"VPUPNotifyScreenTouch" object:nil];
    }
}

- (void)windowTouchedNotify:(NSNotification *)sender {
    UIEvent *touchEvent = [[sender userInfo] objectForKey:@"event"];
    
    //原先触发方式暂时不生效
//    [self statisticsTouchesCount:[touchEvent.allTouches count] timestamp:touchEvent.timestamp];
    //debugPanel另写一个method,和现有点击不冲突
    [self checkDebugPanelWithTouchEvent:touchEvent];
}

- (void)checkDebugPanelWithTouchEvent:(UIEvent *)touchEvent {
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.touchQueue, ^{
        if(!weakSelf.enableDebugPanelEntrance) {
            weakSelf.debugPanelTouchCount = 0;
            return;
        }
        
        UITouch *touch = [[touchEvent allTouches] anyObject];
        //获得在keyWindow中的点击
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        CGPoint location = [touch locationInView:keyWindow];
        if((location.x >= keyWindow.bounds.size.width - 100)        &&
           (location.y >= keyWindow.bounds.size.height / 2 - 50)    &&
           (location.y <= keyWindow.bounds.size.height / 2 + 50)) {
            
            weakSelf.debugPanelTouchCount++;
//            if(_debugPanelTouchCount >= 5) {
//                
//            }
            
        }
        else {
            weakSelf.debugPanelTouchCount = 0;
        }
    });
}

- (void)triggerDebugPanel {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:@"%@_v%@",[VPUPGeneralInfo mainVPSDKName], [VPUPGeneralInfo mainVPSDKVersion]];
        BOOL success = NO;
        if(([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)) {
            
            __weak typeof(self) weakSelf = self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"videopls Debug Panel" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"正式环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf alertView:nil clickedButtonAtIndex:1];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"测试环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf alertView:nil clickedButtonAtIndex:2];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"上报日志" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf alertView:nil clickedButtonAtIndex:3];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"开启日志输出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self enableLogging];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            
            UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while(topViewController.presentedViewController) {
                topViewController = topViewController.presentedViewController;
            }
            if(topViewController) {
                [topViewController presentViewController:alertController animated:YES completion:nil];
                if(!alertController.presentingViewController) {
                    alertController = nil;
                    success = NO;
                }
                else {
                    success = YES;
                }
            }
        }
        
        if(!success) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"videopls Debug Panel" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"正式环境", @"测试环境", @"上报日志", nil];
            [alert dismissWithClickedButtonIndex:0 animated:NO];
            [[UIApplication sharedApplication].keyWindow addSubview:alert];
            [alert show];
        }
    });
}


//- (void)statisticsTouchesCount:(NSInteger)touchesCount timestamp:(NSTimeInterval)timestamp {
//    dispatch_sync(_touchQueue,^{
//
//        //大于4.5s清零计数
//        if(timestamp - _firstTouchTimestamp >= 4.5f) {
//            _firstTouchTimestamp = 0;
//            _currentTouchTimestamp = 0;
//            _eachTouchCount = 0;
//            _totalTouchCount = 0;
//            _switchToTestTouchCount = 0;
//        }
//        //重新初始化
//        if(_firstTouchTimestamp == 0) {
//            _firstTouchTimestamp = timestamp;
//        }
//
////        //大于0.2s清零本次点击
//        if(timestamp - _currentTouchTimestamp > 0.2f) {
//            _currentTouchTimestamp = 0;
//            _eachTouchCount = 0;
//        }
////
//        //初始化本次点击
//        if(_currentTouchTimestamp == 0) {
//            _currentTouchTimestamp = timestamp;
//        }
//
//        //在刚发生0.1s内触发多次取最大,不做叠加,在0.1-0.2之间触发作为无效点击,重置本次
//        if(fabs(timestamp - _currentTouchTimestamp) <= 0.1f) {
//            _enableToCalculate = YES;
//            if(_eachTouchCount == 0) {
//                _eachTouchCount = touchesCount;
//            }
//            else {
//                _enableToCalculate = NO;
//                _eachTouchCount = MAX(_eachTouchCount, touchesCount);
//            }
//
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), _touchQueue, ^{
//                if(_enableToCalculate) {
//                    [self statisticsEachClick];
//                }
//                else {
//                    _enableToCalculate = YES;
//                }
//            });
//        }
//        else {
//            _firstTouchTimestamp = 0;
//            _currentTouchTimestamp = 0;
//            _eachTouchCount = 0;
//            _totalTouchCount = 0;
//            _switchToTestTouchCount = 0;
//        }
//    });
//}

- (void)statisticsEachClick {
    //切换环境,双击1次后单击9次
    if(_switchToTestTouchCount > 0) {
        if(_eachTouchCount == 1) {
            _switchToTestTouchCount++;
            if(_switchToTestTouchCount == 10) {
                [self showSwitchEnvironmentAlert];
                _firstTouchTimestamp = 0;
                _totalTouchCount = 0;
                _switchToTestTouchCount = 0;
            }
        }
    }
    //彩蛋双击10次
    if(_eachTouchCount == 2) {
        _eachTouchCount = 0;
        _totalTouchCount++;
        _switchToTestTouchCount = 1;
        if(_totalTouchCount == 10) {
            //                    [self showEasterEggView];
            _firstTouchTimestamp = 0;
            _switchToTestTouchCount = 0;
            _totalTouchCount = 0;
        }
    }
    
    if(_eachTouchCount > 2) {
        _totalTouchCount = 0;
        _switchToTestTouchCount = 0;
    }
    
    _currentTouchTimestamp = 0;
    _eachTouchCount = 0;
}

- (void)showSwitchEnvironmentAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:@"%@_v%@",[VPUPGeneralInfo mainVPSDKName], [VPUPGeneralInfo mainVPSDKVersion]];
        if(([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"切换环境" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"online", @"pre", @"test", @"dev", nil];
            [alert dismissWithClickedButtonIndex:0 animated:NO];
            [[UIApplication sharedApplication].keyWindow addSubview:alert];
            [alert show];
        }
        else {
            __weak typeof(self) weakSelf = self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"切换环境" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"online" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf alertView:nil clickedButtonAtIndex:1];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"pre" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf alertView:nil clickedButtonAtIndex:2];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"test" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf alertView:nil clickedButtonAtIndex:3];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"dev" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf alertView:nil clickedButtonAtIndex:4];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //切换环境
    if(buttonIndex == 0) {
        return;
    }
    
    if([alertView.title isEqualToString:@"切换环境"]) {

        NSUInteger enviroment = buttonIndex - 1;
        if(enviroment > 3) {
            enviroment = 0;
        }
        
        [self switchEnvironment:enviroment];
    }
    else {
        //DebugPanel
        //1: 正式  2: 测试  3: 上报日志
        if(buttonIndex == 1 || buttonIndex == 2) {
            NSUInteger enviroment = 0;
            if(buttonIndex == 1) {
                enviroment = 0;
            }
            if(buttonIndex == 2) {
                enviroment = 2;
            }
            
            [self switchEnvironment:enviroment];
        }
        else {
            //3 上报日志
            [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPDebugPanelPostReportLogNotification object:nil];
        }
        
    }
}


- (void)registerLifeCycleVideoNotification {
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStart) name:VPUPVideoStartNotification object:nil];
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStop) name:VPUPVideoStopNotification object:nil];
}

- (void)removeLifeCycleVideoNotification {
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPVideoStartNotification object:nil];
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPVideoStopNotification object:nil];
}

- (void)dealloc {
    [self removeAudioRouteNotification];
    [self removeWindowTouchNotification];
    [self removeLifeCycleVideoNotification];
    
}

@end
