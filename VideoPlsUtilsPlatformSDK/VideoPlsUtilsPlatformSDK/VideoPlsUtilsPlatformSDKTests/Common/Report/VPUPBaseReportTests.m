//
//  VPUPBaseReportTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/23.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPBaseReport.h"
#import "XCTestCase+VPUPAsyncTests.h"
#import "VPUPDBSQLString.h"
#import "VPUPDatabase.h"

@interface VPUPBaseReportTests : XCTestCase

@end

@implementation VPUPBaseReportTests

- (NSString *)notifyName {
    return @"VPUPBaseRerportTests";
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void)testInit {
    VPUPBaseReport *report = [[VPUPBaseReport alloc] init];
    XCTAssertNotNil(report, @"init cannot be nil");
    XCTAssertNotNil(report.database, @"database cannot be nil");
    
    XCTAssertNotNil(report.httpManager, @"Http mananger will not be nil");
    XCTAssertNotNil(report.reportQueue, @"Http mananger will not be nil");
    
    XCTAssertEqualObjects([report reportTableName], @"ReportIoV", @"Default is IoV");
    
    XCTAssertEqual(report.minRequireSendCount, 5, @"Default min send count is 5");
    XCTAssertEqual(report.maxLimitCount, 100, @"Default max save count is 100");
    XCTAssertEqual(report.reportEnable, YES, @"Default is open all log");
    XCTAssertEqual(report.canInsertData, true, @"Default data can insert");
}

- (void)testStartReport {
    VPUPBaseReport *report = [[VPUPBaseReport alloc] init];
    XCTAssertEqual(report.canInsertData, true, @"Default data can insert");
    [report startReport];
    XCTAssertEqual(report.canInsertData, true, @"Base Report startReport didn't do anything");
    [report stopReport];
    XCTAssertEqual(report.canInsertData, true, @"Base Report stopReport didn't do anything");

}

- (void)testAddReport {
    VPUPBaseReport *report = [[VPUPBaseReport alloc] init];
    [report addReportByLevel:VPUPReportLevelInfo reportClass:[self class] message:@"Unit Test Info"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self notify];
    });
    
    [self wait];
    
    VPUPDBSQLString *searchString = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:report.reportTableName columNames:@[@"count"] values:@[@"count(*)"] whereKeys:nil whereValues:nil orderBy:nil sort:NSOrderedAscending];
    
    [report.database executeQuerySql:searchString completeQueue:nil completeBlock:^(NSArray *selectObject) {
        XCTAssertEqual(selectObject.count, 1, @"select sql search cunt must be 1");
    }];
    
    [self wait];
    
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
