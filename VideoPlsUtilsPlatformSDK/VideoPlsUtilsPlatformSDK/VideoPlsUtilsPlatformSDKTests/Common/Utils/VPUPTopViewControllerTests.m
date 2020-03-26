//
//  VPUPTopViewControllerTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/28.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPTopViewController.h"

@interface VPUPTopViewControllerTests : XCTestCase

@end

@implementation VPUPTopViewControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTopController {
    //In unit test, has no visual, so topViewController will be nil?
    //how to test
    UIViewController *controller = [VPUPTopViewController topViewController];
    XCTAssertNil(controller, @"top controller couldn't be nil");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
