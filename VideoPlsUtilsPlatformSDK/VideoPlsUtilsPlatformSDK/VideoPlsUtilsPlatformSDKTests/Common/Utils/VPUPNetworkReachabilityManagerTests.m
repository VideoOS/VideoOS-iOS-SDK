//
//  VPUPNetworkReachabilityManagerTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/26.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPNetworkReachabilityManager.h"

@interface VPUPNetworkReachabilityManagerTests : XCTestCase

@end

@implementation VPUPNetworkReachabilityManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testManager {
    VPUPNetworkReachabilityManager *manager = [VPUPNetworkReachabilityManager sharedManager];
    XCTAssertNotNil(manager, @"Shared manager not nil");
}

- (void)testReachable {
    VPUPNetworkReachabilityManager *manager = [VPUPNetworkReachabilityManager sharedManager];
    XCTAssertTrue([manager isReachable], @"Through wifi can reach");
}

- (void)testCurrentReachabilityStatus {
    VPUPNetworkReachabilityManager *manager = [VPUPNetworkReachabilityManager sharedManager];
    XCTAssertTrue([manager currentReachabilityStatus] == VPUPNetworkReachabilityStatusReachableViaWiFi, @"Current is wifi");
}

- (void)testCurrentReachabilityString {
    VPUPNetworkReachabilityManager *manager = [VPUPNetworkReachabilityManager sharedManager];
    XCTAssertTrue([[manager currentReachabilityStatusString] isEqualToString:@"WIFI"], @"Current is wifi");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
