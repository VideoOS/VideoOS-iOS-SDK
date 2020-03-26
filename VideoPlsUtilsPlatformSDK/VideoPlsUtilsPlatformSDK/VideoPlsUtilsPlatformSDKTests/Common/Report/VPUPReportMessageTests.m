//
//  VPUPReportMessageTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/23.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPReportMessage.h"
#import "VPUPServerUTCDate.h"

@interface VPUPReportMessageTests : XCTestCase

@end

@implementation VPUPReportMessageTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    VPUPReportMessage *message = [VPUPReportMessage reportMessageWith:VPUPReportLevelLog reportClass:@"ReportTest" message:@"UnitTest"];
    XCTAssertNotNil(message, @"Init message cannot be nil");
    
    VPUPReportMessage *message2 = [VPUPReportMessage reportMessageWith:4 reportClass:nil message:nil];
    XCTAssertNotNil(message2, @"Init message cannot be nil");
    
}

- (void)testUniqueReportID {
    VPUPReportMessage *message = [VPUPReportMessage reportMessageWith:VPUPReportLevelLog reportClass:@"ReportTest" message:@"UnitTest"];
    XCTAssertNotNil([message uniqueReportID], @"Init message uniqueID cannot be nil");
    
    VPUPReportMessage *message2 = [VPUPReportMessage reportMessageWith:VPUPReportLevelLog reportClass:@"ReportTest" message:@"UnitTest"];
    XCTAssertNotNil([message2 uniqueReportID], @"Init message uniqueID cannot be nil");
    XCTAssertNotEqualObjects([message uniqueReportID], [message2 uniqueReportID], @"Unique Report ID could not be equal");
}

- (void)testJsonValue {
    
    NSString *createTime = [NSString stringWithFormat:@"%0.0lf", [VPUPServerUTCDate currentUnixTimeMillisecond]];
    
    VPUPReportMessage *message = [VPUPReportMessage reportMessageWith:VPUPReportLevelInfo reportClass:@"ReportInfoTest" message:@"Info"];
    NSString *infoMsg = [NSString stringWithFormat:@"{\"message\":\"Info\",\"level\":\"info\",\"create_time\":\"%@\",\"tag\":\"ReportInfoTest\"}", createTime];
    
    XCTAssertEqualObjects([message jsonValue], infoMsg, @"json value must be equal");
    
    VPUPReportMessage *message2 = [VPUPReportMessage reportMessageWith:VPUPReportLevelWarning reportClass:@"ReportWarningTest" message:@"Warning"];
    NSString *warningMsg = [NSString stringWithFormat:@"{\"message\":\"Warning\",\"level\":\"warning\",\"create_time\":\"%@\",\"tag\":\"ReportWarningTest\"}", createTime];
    
    XCTAssertEqualObjects([message2 jsonValue], warningMsg, @"json value must be equal");
    
    VPUPReportMessage *message3 = [VPUPReportMessage reportMessageWith:VPUPReportLevelError reportClass:@"ReportErrorTest" message:@"Error"];
    
    NSString *errorMsg = [NSString stringWithFormat:@"{\"message\":\"Error\",\"level\":\"error\",\"create_time\":\"%@\",\"tag\":\"ReportErrorTest\"}", createTime];
    
    XCTAssertEqualObjects([message3 jsonValue], errorMsg, @"json value must be equal");
    
    VPUPReportMessage *message4 = [VPUPReportMessage reportMessageWith:VPUPReportLevelLog reportClass:@"ReportLogTest" message:@"Log"];
    
    NSString *logMsg = [NSString stringWithFormat:@"{\"message\":\"Log\",\"level\":\"u\",\"create_time\":\"%@\",\"tag\":\"ReportLogTest\"}", createTime];
    
    XCTAssertEqualObjects([message4 jsonValue], logMsg, @"json value must be equal");
    
    VPUPReportMessage *message5 = [VPUPReportMessage reportMessageWith:4 reportClass:nil message:nil];
    
    NSString *fatalMsg = [NSString stringWithFormat:@"{\"message\":\"\",\"level\":\"\",\"create_time\":\"%@\",\"tag\":\"\"}", createTime];
    
    XCTAssertEqualObjects([message5 jsonValue], fatalMsg, @"json value must be equal");
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
