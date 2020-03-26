//
//  VPUPReportLogMessageTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/24.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPReportLogMessage.h"
#import "VPUPServerUTCDate.h"

@interface VPUPReportLogMessageTests : XCTestCase

@end

@implementation VPUPReportLogMessageTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    VPUPReportLogMessage *message = [VPUPReportLogMessage reportMessageWith:VPUPReportLevelLog reportClass:@"ReportTest" message:@"UnitTest"];
    XCTAssertNotNil(message, @"Init message cannot be nil");
    
}

- (void)testUniqueReportID {
    VPUPReportLogMessage *message = [VPUPReportLogMessage reportMessageWith:VPUPReportLevelLog reportClass:@"ReportTest" message:@"UnitTest"];
    XCTAssertNotNil([message uniqueReportID], @"Init message uniqueID cannot be nil");
    
}

- (void)testJsonValue {
    
    NSTimeInterval createTime = [VPUPServerUTCDate currentUnixTimeMillisecond];
    
    VPUPReportLogMessage *message = [VPUPReportLogMessage reportMessageWith:VPUPReportLevelLog reportClass:@"ReportInfoTest" message:@"Info"];
    NSString *infoMsg = [NSString stringWithFormat:@"%@ %@\n", [VPUPServerUTCDate dateStringWithUnixTimeMillisecond:createTime], message.message];
    
    XCTAssertEqualObjects([message jsonValue], infoMsg, @"json value must be equal");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
