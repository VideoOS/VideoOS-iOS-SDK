//
//  VPUPAutoNumberIDUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/25.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPAutoNumberIDUtil.h"

@interface VPUPAutoNumberIDUtilTests : XCTestCase

@end

@implementation VPUPAutoNumberIDUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetUniqueID {
    NSUInteger uniqueID = [VPUPAutoNumberIDUtil getUniqueID];
    XCTAssertTrue([VPUPAutoNumberIDUtil getUniqueID] == uniqueID + 1, @"UniqueID call then +1");
}

- (void)testGetReportID {
    NSUInteger reportID = [VPUPAutoNumberIDUtil getReportID];
    XCTAssertTrue([VPUPAutoNumberIDUtil getReportID] == reportID + 1, @"ReportID call then +1");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
