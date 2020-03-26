//
//  VPUPNotificationCenterTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/25.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPNotificationCenter.h"
#import "XCTestCase+VPUPAsyncTests.h"

@interface VPUPNotificationCenterTests : XCTestCase

@property (nonatomic, assign) BOOL recieve;

@end

@implementation VPUPNotificationCenterTests

- (NSString *)notifyName {
    return @"VPUPNotificationCenterTests";
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultCenter {
    NSNotificationCenter *center = [VPUPNotificationCenter defaultCenter];
    XCTAssertNotNil(center, @"init could not be nil");
    XCTAssertTrue([center isKindOfClass:[NSNotificationCenter class]], @"center in kind of NotificationCenter");
}

- (void)testCenterPostAndRecieve {
    NSNotificationCenter *center = [VPUPNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(recieveTest) name:@"VPUPNotificationCenterTests" object:nil];
    [center postNotificationName:@"VPUPNotificationCenterTests" object:nil];
    
    [self wait];
    
    XCTAssertTrue(self.recieve, @"Recieve notification");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)recieveTest {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recieve = YES;
        
        [self notify];
    });
    
}

@end
