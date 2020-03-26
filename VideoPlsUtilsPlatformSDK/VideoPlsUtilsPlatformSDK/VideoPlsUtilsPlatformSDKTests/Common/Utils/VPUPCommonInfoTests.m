//
//  VPUPCommonInfoTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/13.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPCommonInfo.h"
#import "VPUPGeneralInfo.h"
#import "VPUPSDKInfo.h"

@interface VPUPCommonInfoTests : XCTestCase

@end

@implementation VPUPCommonInfoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    VPUPSDKInfo *sdkinfo = [[VPUPSDKInfo alloc] init];
    sdkinfo.mainVPSDKAppKey = @"123";
    sdkinfo.mainVPSDKAppSecret = @"123";
    [VPUPGeneralInfo setSDKInfo:sdkinfo];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    VPUPSDKInfo *sdkinfo = [[VPUPSDKInfo alloc] init];
    [VPUPGeneralInfo setSDKInfo:sdkinfo];
}

- (void)testPerformanceCommonInfo {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [VPUPCommonInfo commonParam];
    }];
}

- (void)testCommonInfo {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssert([VPUPCommonInfo commonParam], @"Common Parameters could not be nil");
}



@end
