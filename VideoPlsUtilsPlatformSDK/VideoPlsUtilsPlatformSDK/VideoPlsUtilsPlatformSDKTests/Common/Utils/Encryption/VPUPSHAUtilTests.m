//
//  VPUPSHAUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/4.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPSHAUtil.h"

@interface VPUPSHAUtilTests : XCTestCase

@end

@implementation VPUPSHAUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSHA1 {
    NSString *string = @"unitTest";
    NSString *sha1String = @"5ad715aabe02e21ebc8315bd0cf20f0e436e916c";
    
    XCTAssertTrue([[VPUPSHAUtil sha1HashString:string] isEqualToString:sha1String], @"SHA1 must be equal");
    XCTAssertNil([VPUPSHAUtil sha1HashString:nil], @"Nil cannot be encrypt, return nil");
    
}

- (void)testSHA256 {
    NSString *string = @"unitTest";
    NSString *sha256String = @"b359595f9d2f9bc7c7e18e1332753e3dfa98c2053651853ced92f6b1e4361117";
    
    XCTAssertTrue([[VPUPSHAUtil sha256HashString:string] isEqualToString:sha256String], @"SHA256 must be equal");
    XCTAssertNil([VPUPSHAUtil sha256HashString:nil], @"Nil cannot be encrypt, return nil");
}

- (void)testHMAC_SHA {
    NSString *string = @"unitTest";
    NSString *key = @"test";
    NSString *hmacString = @"abbd76c694b522207490e04eeedeb312d6425331";
    
    XCTAssertTrue([[VPUPSHAUtil hmac_sha1HashString:string key:key] isEqualToString:hmacString], @"HMAC_SHA1 must be equal");
    XCTAssertNil([VPUPSHAUtil hmac_sha1HashString:nil key:nil], @"Nil cannot be encrypt, return nil");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
