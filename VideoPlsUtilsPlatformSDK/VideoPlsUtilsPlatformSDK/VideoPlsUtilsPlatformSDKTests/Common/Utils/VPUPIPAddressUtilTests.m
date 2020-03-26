//
//  VPUPIPAddressUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/27.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPIPAddressUtil.h"

@interface VPUPIPAddressUtilTests : XCTestCase

@end

@implementation VPUPIPAddressUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCurrentIpAddress {
    NSString *ip = [VPUPIPAddressUtil currentIpAddress];
    XCTAssertNotNil(ip, @"Current ip couldn't be nil");
}

- (void)testGetIPAddresses {
    NSDictionary *ipDict = [VPUPIPAddressUtil getIPAddresses];
    XCTAssertNotNil(ipDict, @"Current ip couldn't be nil");
    XCTAssertNotNil([ipDict objectForKey:@"en0/ipv4"], @"IPV4 would not be nil");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
