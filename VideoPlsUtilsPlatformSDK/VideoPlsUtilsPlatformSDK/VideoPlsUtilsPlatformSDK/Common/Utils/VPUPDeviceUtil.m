//
//  VPUPDeviceUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/24.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPDeviceUtil.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation VPUPDeviceUtil

//+ (BOOL)isIPhoneX {
//
//    if ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO) {
//        return YES;
//    }
//
//    return NO;
//}

+ (BOOL)isIPhoneX {
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

+ (CGFloat)statusBarHeight {
    return [VPUPDeviceUtil isIPhoneX] ? 44 : 20;
}

+ (NSString *)phoneCarrier {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mobile;
    //先判断有没有SIM卡，如果没有则不获取本机运营商
    if (!carrier.isoCountryCode) {
        mobile = @"无运营商";
    }else{
        mobile = [carrier carrierName];
    }
    
    //极少数的情况下（1/100000），手机有SIM卡，但是系统读取不到运营商信息
    if (!mobile) {
        mobile = @"无运营商";
    }
    
    return mobile;
}

+ (int)phoneCarrierType {
    //运营商信息 0:其他，1:移动，2:联通，3:电信，4:其它
    int type = 0;
    
    NSString *carrier = [VPUPDeviceUtil phoneCarrier];
    if ([carrier containsString:@"移动"]) {
        type = 1;
    }
    else if ([carrier containsString:@"联通"]) {
        type = 2;
    }
    else if ([carrier containsString:@"电信"]) {
        type = 3;
    }
    return type;
}

@end
