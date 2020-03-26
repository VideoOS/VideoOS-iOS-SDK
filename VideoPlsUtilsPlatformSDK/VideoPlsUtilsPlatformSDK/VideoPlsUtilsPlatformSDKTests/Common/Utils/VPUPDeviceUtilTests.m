//
//  VPUPDeviceUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/26.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPDeviceUtil.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface VPUPDeviceUtilTests : XCTestCase

@end

@implementation VPUPDeviceUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsIPhoneX {
    BOOL iPhoneXSeries = NO;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    XCTAssertTrue([VPUPDeviceUtil isIPhoneX] == iPhoneXSeries, @"Get current device and confirm X");
}

- (void)testStatusBarHeight {
    CGFloat statusBarHeight = [VPUPDeviceUtil isIPhoneX] ? 44 : 20;
    XCTAssertEqualWithAccuracy([VPUPDeviceUtil statusBarHeight], statusBarHeight, 0.01, @"Status bar height is equal");
}

- (void)testPhoneCarrier {
    NSString *phoneCarrier = [VPUPDeviceUtil phoneCarrier];
    
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
    
    XCTAssertTrue([phoneCarrier isEqualToString:mobile], @"Current carrier is equal");
}

- (void)testPhoneCarrierType {
    NSString *phoneCarrier = [VPUPDeviceUtil phoneCarrier];
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
    
    XCTAssertTrue([VPUPDeviceUtil phoneCarrierType] == type, @"type must be equal");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
