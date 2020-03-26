//
//  VPUPTrafficStatisticsTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/27.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPTrafficStatistics.h"
#import "VPUPPathUtil.h"

@interface VPUPTrafficStatisticsTests : XCTestCase

@end

@implementation VPUPTrafficStatisticsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStatisticsInit {
    VPUPTrafficStatisticsObject *object = [[VPUPTrafficStatisticsObject alloc] initWithFileName:@"testUTFile" fileUrl:@"http://testUnitTestFile" fileSize:1024];
    
    XCTAssertNotNil(object, @"init statistics object could not be nil");
}

- (void)testAddFileTraffic {
    VPUPTrafficStatisticsList *list = [[VPUPTrafficStatisticsList alloc] init];
    XCTAssertTrue(list.statisticsArray.count == 0, @"Init statistics list count be 0");
    
    NSData *data = [[NSMutableData alloc] initWithLength:256 * 1024];

    //指定path
    NSString *path = [VPUPPathUtil lPath];
    path = [path stringByAppendingPathComponent:@"testUnit.test"];
    //写入路径下
    [data writeToFile:path atomically:NO];
    
    [list addFileTrafficByName:@"testUTFile" fileUrl:@"http://testUnitTestFile" filePath:path];
    
    XCTAssertTrue(list.statisticsArray.count == 1, @"List add count 1");
    XCTAssertTrue([list.statisticsArray firstObject].fileSize == 256 * 1024, @"The same size");
    
    [list addFileTrafficByName:@"testUTFile2" fileUrl:@"http://testUnitTestFile2" filePath:nil];
    XCTAssertFalse(list.statisticsArray.count == 2, @"Without filePath or nil file will be false");
    
    [list addTrafficNoSizeByName:@"testUTFile3" fileUrl:@"http://testUnitTestFile3"];
    XCTAssertTrue(list.statisticsArray.count == 2, @"List add count 2");
    XCTAssertTrue([list.statisticsArray lastObject].fileSize == 0, @"The same size");
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
