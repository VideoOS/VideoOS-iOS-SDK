//
//  VPUPCrashManagerTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/23.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPCrashManager.h"

@interface VPUPCrashManagerTests : XCTestCase

@property (nonatomic) NSUncaughtExceptionHandler *previousHandle;

@end

@implementation VPUPCrashManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    _previousHandle = NSGetUncaughtExceptionHandler();
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    NSSetUncaughtExceptionHandler(_previousHandle);
    _previousHandle = nil;
}

- (void)testInit {
    XCTAssertTrue(NSGetUncaughtExceptionHandler() == _previousHandle, @"Default is equal original");
    
    [VPUPCrashManager initVPUPCrashManagerHandler];
    
    XCTAssertFalse(NSGetUncaughtExceptionHandler() == _previousHandle, @"Register self handle will replace origin handle");
}

- (void)testCrash {
    [VPUPCrashManager initVPUPCrashManagerHandler];
    NSDictionary *dict = @{};
    XCTAssertThrows([dict setValue:@"test" forKey:@"test"], @"crash will throw and be caught by Crash Mananger");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
