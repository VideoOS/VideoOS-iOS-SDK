//
//  VPUPCommonTrackTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/28.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPCommonTrack.h"
#import "VPUPTrafficStatistics.h"

@interface VPUPCommonTrackTests : XCTestCase

@end

@implementation VPUPCommonTrackTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    VPUPCommonTrack *track = [VPUPCommonTrack shared];
    XCTAssertNotNil(track, @"track not nil");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
