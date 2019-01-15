//
//  VPUPTopViewController.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPTopViewController.h"

@implementation VPUPTopViewController

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
