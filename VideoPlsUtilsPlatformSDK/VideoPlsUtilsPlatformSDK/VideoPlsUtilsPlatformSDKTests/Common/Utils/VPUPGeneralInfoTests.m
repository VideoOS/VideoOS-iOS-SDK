//
//  VPUPGeneralInfoTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/14.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPGeneralInfo.h"
#import "VPUPSDKInfo.h"

@interface VPUPGeneralInfoTests : XCTestCase

@property (nonatomic) VPUPSDKInfo *sdkInfo;

@end

@implementation VPUPGeneralInfoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    _sdkInfo = [[VPUPSDKInfo alloc] init];
    _sdkInfo.mainVPSDKAppKey = @"123";
    _sdkInfo.mainVPSDKAppSecret = @"1234";
    [_sdkInfo setMainSDKNameByType:VPUPMainSDKTypeVideojj];
    [_sdkInfo setMainVPSDKPlatformID:@"1"];
    [_sdkInfo setMainVPSDKServiceVersion:@"1.0"];
    [_sdkInfo setMainVPSDKVersion:@"1.0.0"];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"VPUPUserIdentity"];
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    //set an empty sdkInfo to reset nil
    [VPUPGeneralInfo setSDKInfo:sdkInfo];
}

- (void)testSetSDKInfo {
    XCTAssertNil([VPUPGeneralInfo getCurrentSDKInfo], @"default is nil");
    
    [VPUPGeneralInfo setSDKInfo:_sdkInfo];
    
    XCTAssertTrue([[VPUPGeneralInfo getCurrentSDKInfo].mainVPSDKAppKey isEqualToString:@"123"], @"AppKey must be equal to setting");
    
    XCTAssertTrue([[VPUPGeneralInfo getCurrentSDKInfo].mainVPSDKAppSecret isEqualToString:@"1234"], @"AppKey must be equal to setting");
    
    
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    //set an empty sdkInfo to reset nil
    [VPUPGeneralInfo setSDKInfo:sdkInfo];
    
    XCTAssertNil([VPUPGeneralInfo getCurrentSDKInfo], @"set an empty sdkInfo to reset nil");
}

- (void)testIsEqualToSDKInfo {
    XCTAssertFalse([VPUPGeneralInfo isEqualToSDKInfo:_sdkInfo], @"Default nil sdkInfo, return nil");
    
    [VPUPGeneralInfo setSDKInfo:_sdkInfo];
    XCTAssertTrue([VPUPGeneralInfo isEqualToSDKInfo:_sdkInfo], @"Set SDK Info must be equal");
    
    VPUPSDKInfo *newSDKInfo = [[VPUPSDKInfo alloc] initSDKInfoWithSDKType:VPUPMainSDKTypeVideojj SDKVersion:@"1.2.0" appKey:@"321"];
    XCTAssertFalse([VPUPGeneralInfo isEqualToSDKInfo:newSDKInfo], @"Set SDK Info must be equal");
}

- (void)testSetUserIdentity {
    [VPUPGeneralInfo setUserIdentity:@"123"];
    XCTAssertTrue([[VPUPGeneralInfo userIdentity] isEqualToString:@"123"], @"Set user identity must be same");
}

- (void)testSetIDFA {
    [VPUPGeneralInfo setIDFA:@"123"];
    XCTAssertTrue([[VPUPGeneralInfo IDFA] isEqualToString:@"123"], @"Set IDFA must be same");
    
    [VPUPGeneralInfo setIDFA:nil];
    XCTAssertFalse([VPUPGeneralInfo IDFA] == nil, @"Set IDFA can not be nil");
}

- (void)testInfo {
    
    XCTAssertNotNil([VPUPGeneralInfo appName], @"app name info cannot be nil, if not exist will return empty string");
    XCTAssertNotNil([VPUPGeneralInfo appBundleID], @"app bundleID info cannot be nil, if not exist will return empty string");
    XCTAssertNotNil([VPUPGeneralInfo appBundleName], @"app bundleName info cannot be nil, if not exist will return empty string");
    XCTAssertNotNil([VPUPGeneralInfo appBundleVersion], @"app bundleVersion info cannot be nil, if not exist will return empty string");
    XCTAssert([VPUPGeneralInfo appDeviceName] ?: @"", @"app deviceName can be nil");
    XCTAssert([VPUPGeneralInfo appDeviceModel] ?: @"", @"app deviceModel can be nil");
    XCTAssert([VPUPGeneralInfo appDeviceSystemName] ?: @"", @"app deviceSystemName can be nil");
    XCTAssert([VPUPGeneralInfo appDeviceSystemVersion] ?: @"", @"app deviceSystemVersion can be nil");
    XCTAssertNotNil([VPUPGeneralInfo appDeviceLanguage], @"app deviceLanguage info cannot be nil, if not exist will return empty string");
    XCTAssertNotNil([VPUPGeneralInfo iPhoneDeviceType], @"app deviceType info cannot be nil, if not exist will return empty string");
    
    XCTAssertNotNil([VPUPGeneralInfo platformSDKVersion], @"platformSDKVersion change with static string, not nil");
    
    //Didn't set sdkInfo
    XCTAssertNotNil([VPUPGeneralInfo mainVPSDKName], @"mainVPSDKName cannot be nil, default be VideoOS");
    XCTAssertEqualObjects([VPUPGeneralInfo mainVPSDKName], @"VideoOS", @"mainVPSDKName cannot be nil, default be VideoOS");
    
    XCTAssertNil([VPUPGeneralInfo mainVPSDKVersion], @"mainVPSDKVersion should be nil, without sdkInfo");
    XCTAssertNil([VPUPGeneralInfo mainVPSDKServiceVersion], @"mainVPSDKServiceVersion should be nil, without sdkInfo");
    XCTAssertNil([VPUPGeneralInfo mainVPSDKAppKey], @"mainVPSDKAppKey should be nil, without sdkInfo");
    XCTAssertNil([VPUPGeneralInfo mainVPSDKAppSecret], @"mainVPSDKAppSecret should be nil, without sdkInfo");
    XCTAssertNil([VPUPGeneralInfo mainVPSDKPlatformID], @"mainVPSDKPlatformID should be nil, without sdkInfo");
    
    [VPUPGeneralInfo setSDKInfo:_sdkInfo];
    //set to videojj
    XCTAssertNotNil([VPUPGeneralInfo mainVPSDKName], @"mainVPSDKName set to Videojj");
    XCTAssertEqualObjects([VPUPGeneralInfo mainVPSDKName], @"Videojj", @"mainVPSDKName set to Videojj");
    
    XCTAssertEqualObjects([VPUPGeneralInfo mainVPSDKVersion], @"1.0.0", @"mainVPSDKVersion set to 1.0.0");
    XCTAssertEqualObjects([VPUPGeneralInfo mainVPSDKServiceVersion], @"1.0", @"mainVPSDKServiceVersion set to 1.0");
    XCTAssertEqualObjects([VPUPGeneralInfo mainVPSDKAppKey], @"123", @"mainVPSDKAppKey set to 123");
    XCTAssertEqualObjects([VPUPGeneralInfo mainVPSDKAppSecret], @"1234", @"mainVPSDKAppSecret set to 1234");
    XCTAssertEqualObjects([VPUPGeneralInfo mainVPSDKPlatformID], @"1", @"mainVPSDKPlatformID set to 1");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
