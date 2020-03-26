//
//  VPUPAESUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/4.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPAESUtil.h"

@interface VPUPAESUtilTests : XCTestCase

@end

@implementation VPUPAESUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAES {
    NSString *string = @"unitTest";
    NSString *key = @"8lgK5fr5yatOfHio";
    NSString *initVector = @"lx7eZhVoBEnKXELF";
    NSString *aesBase64String = @"FK+tffqGqaq5kX7ECwnFQA==";
    
    XCTAssertTrue([[VPUPAESUtil aesEncryptString:string] isEqualToString:[VPUPAESUtil aesEncryptString:string key:key initVector:initVector]], @"Default AES use default key and initVector");
    XCTAssertTrue([[VPUPAESUtil aesEncryptString:string] isEqualToString:aesBase64String], @"Default AES Encrypt must be equal");
    
    XCTAssertTrue([[VPUPAESUtil aesDecryptString:aesBase64String] isEqualToString:[VPUPAESUtil aesDecryptString:aesBase64String key:key initVector:initVector]], @"Default AES use default key and initVector");
    XCTAssertTrue([[VPUPAESUtil aesDecryptString:aesBase64String] isEqualToString:string], @"Default AES Encrypt must be equal");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
