//
//  VPUPUrlUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/27.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPUrlUtil.h"

@interface VPUPUrlUtilTests : XCTestCase

@end

@implementation VPUPUrlUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUrlencode {
    
    NSString *urlString = @"https://baike.baidu.com/item/杨幂";
    NSString *encodelString = @"https://baike.baidu.com/item/%E6%9D%A8%E5%B9%82";
    NSString *urlString2 = @"http://baike.baidu.com/item/杨幂";
    NSString *encodelString2 = @"http://baike.baidu.com/item/%E6%9D%A8%E5%B9%82";
    NSString *urlString3 = @"baike.baidu.com/item/杨幂";
    NSString *encodelString3 = @"baike.baidu.com/item/%E6%9D%A8%E5%B9%82";
    
    XCTAssertTrue([[VPUPUrlUtil urlencode:urlString] isEqualToString:encodelString], @"url encode must be equal");
    XCTAssertTrue([[VPUPUrlUtil urlencode:urlString2] isEqualToString:encodelString2], @"url encode must be equal");
    XCTAssertTrue([[VPUPUrlUtil urlencode:urlString3] isEqualToString:encodelString3], @"url encode must be equal");
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
