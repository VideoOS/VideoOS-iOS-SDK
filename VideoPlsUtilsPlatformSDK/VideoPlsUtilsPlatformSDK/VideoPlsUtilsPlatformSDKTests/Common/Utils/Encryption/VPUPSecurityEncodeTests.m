//
//  VPUPSecurityEncodeTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/5.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPSecurityEncode.h"
#import "VPUPGeneralInfo.h"
#import "VPUPSDKInfo.h"

@interface VPUPSecurityEncodeTests : XCTestCase

@end

@implementation VPUPSecurityEncodeTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTokenEncode {
    NSString *string = @"UnitTest";
    
    XCTAssertTrue([[VPUPSecurityEncode tokenEncode:string] isEqualToString:@""], @"With no appkey wil return empty string");
    XCTAssertTrue([[VPUPSecurityEncode tokenEncode:nil] isEqualToString:@""], @"With no appkey and none string wil return empty string");
    
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] initSDKInfoWithSDKType:VPUPMainSDKTypeVideojj SDKVersion:@"1.0" appKey:@"133ece77-b838-48f4-9194-37877f16c41a"];
    [VPUPGeneralInfo setSDKInfo:sdkInfo];
    
    
    NSString *encodeString = @"a37d5e928097e42eccc82fbe908901e2";
    
    XCTAssertTrue([[VPUPSecurityEncode tokenEncode:string] isEqualToString:encodeString], @"Token enode string must be equal");
    XCTAssertTrue([[VPUPSecurityEncode tokenEncode:nil] isEqualToString:@""], @"Nil return empty string");
}

- (void)testMqttEncode {
    NSString *string = @"UnitTest";
    NSString *key = @"test";
    NSString *encodeString = @"GNj4bYAyGfXl+Ba5ycevKP+0iQ4=";
    
    XCTAssertTrue([[VPUPSecurityEncode mqttEncode:string key:key] isEqualToString:encodeString], @"Mqtt encode string must be equal");
    XCTAssertNil([VPUPSecurityEncode mqttEncode:nil key:nil], @"nil string or key will return nil");
    XCTAssertNil([VPUPSecurityEncode mqttEncode:string key:nil], @"nil string or key will return nil");
    XCTAssertNil([VPUPSecurityEncode mqttEncode:nil key:key], @"nil string or key will return nil");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
