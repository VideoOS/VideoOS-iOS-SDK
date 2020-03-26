//
//  VPUPLocalStorageTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/2.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPLocalStorage.h"
#import "VPUPPathUtil.h"

@interface VPUPLocalStorageTests : XCTestCase

@end

@implementation VPUPLocalStorageTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStorageData {
    NSString *getValue = [VPUPLocalStorage getStorageDataWithFile:@"UnitTest" key:@"unitTest"];
    XCTAssertNil(getValue, @"didn't set hadn't value");
    
    [VPUPLocalStorage setStorageDataWithFile:@"UnitTest" key:@"unitTest" value:@"unit"];
    
    getValue = [VPUPLocalStorage getStorageDataWithFile:@"UnitTest" key:@"unitTest"];
    XCTAssertNotNil(getValue, @"Already has Value");
    XCTAssertTrue([getValue isEqualToString:@"unit"], @"Set value is unit");
    
    [VPUPLocalStorage setStorageDataWithFile:@"UnitTest" key:@"unitTest" value:nil];
    getValue = [VPUPLocalStorage getStorageDataWithFile:@"UnitTest" key:@"unitTest"];
    XCTAssertNil(getValue, @"Set nil vaule wil remove key");
    
    //Remove localStorage file path
    NSString *filePath = [VPUPPathUtil localStoragePath];
    NSString *fileNamePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", @"UnitTest", @".plist"]];
    
    [[NSFileManager defaultManager] removeItemAtPath:fileNamePath error:nil];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
