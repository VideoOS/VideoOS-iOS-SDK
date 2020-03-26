//
//  VPUPReachabilityTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/26.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPReachability.h"
#import <sys/socket.h>
#import <netinet/in.h>

@interface VPUPReachabilityTests : XCTestCase

@end

@implementation VPUPReachabilityTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReachabilityWithHostName {
    VPUPReachability *reach = [VPUPReachability reachabilityWithHostName:@"https://os-saas.videojj.com"];
    XCTAssertNotNil(reach, @"init cannot be nil");
}

- (void)testReachabilityWithAddress {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    VPUPReachability *reach = [VPUPReachability reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
    XCTAssertNotNil(reach, @"init cannot be nil");
}

- (void)testReachabilityForInternetConnection {
    VPUPReachability *reach = [VPUPReachability reachabilityForInternetConnection];
    XCTAssertNotNil(reach, @"init cannot be nil");
}

- (void)testNotify {
    //TODO: 如果修改网络环境
    VPUPReachability *reach = [VPUPReachability reachabilityForInternetConnection];
    
    BOOL startSucceed = [reach startNotifier];
    XCTAssertTrue(startSucceed, @"Normally start notify will be succeed");
    
    XCTAssertTrue([reach currentReachabilityStatus] == VPUPReachableViaWiFi, @"Show current status");
    
    [reach stopNotifier];
    
    XCTAssertTrue([reach currentReachabilityStatus] == VPUPReachableViaWiFi, @"Show current status");
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
