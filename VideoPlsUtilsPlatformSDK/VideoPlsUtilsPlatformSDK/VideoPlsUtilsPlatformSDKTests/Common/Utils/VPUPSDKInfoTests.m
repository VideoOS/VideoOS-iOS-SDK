//
//  VPUPSDKInfoTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/17.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPSDKInfo.h"

@interface VPUPSDKInfoTests : XCTestCase

@end

@implementation VPUPSDKInfoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitSDKInfoIntergration {
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] initSDKInfoWithSDKType:VPUPMainSDKTypeVideoOS SDKVersion:@"1.0.0" appKey:@"123"];
    XCTAssertNotNil(sdkInfo, @"init sdkInfo could not be nil");
    XCTAssertTrue(sdkInfo.mainVPSDKType == VPUPMainSDKTypeVideoOS, @"SDKInfo set type to VideoOS");
    XCTAssertTrue([sdkInfo.mainVPSDKVersion isEqualToString:@"1.0.0"], @"SDKInfo version set to 1.0.0");
    XCTAssertTrue([sdkInfo.mainVPSDKAppKey isEqualToString:@"123"], @"SDKInfo appKey set to 123");
    XCTAssertFalse(sdkInfo.enableWebP, @"SDKInfo webP default set to false");
    
    VPUPSDKInfo *sdkInfo1 = [[VPUPSDKInfo alloc] initSDKInfoWithSDKType:VPUPMainSDKTypeLiveOS SDKVersion:@"4.5.3" appKey:@"432" enableWebP:YES];
    XCTAssertNotNil(sdkInfo1, @"init sdkInfo could not be nil");
    XCTAssertTrue(sdkInfo1.mainVPSDKType == VPUPMainSDKTypeLiveOS, @"SDKInfo set type to LiveOS");
    XCTAssertTrue([sdkInfo1.mainVPSDKVersion isEqualToString:@"4.5.3"], @"SDKInfo version set to 1.0.0");
    XCTAssertTrue([sdkInfo1.mainVPSDKAppKey isEqualToString:@"432"], @"SDKInfo appKey set to 432");
    XCTAssertTrue(sdkInfo1.enableWebP, @"SDKInfo webP set to true");
    
    VPUPSDKInfo *sdkInfo2 = [[VPUPSDKInfo alloc] initSDKInfoWithSDKType:@"wrong" SDKVersion:nil appKey:nil];
    XCTAssert(sdkInfo2, @"init sdkInfo use wrong parameters could not be nil");
    XCTAssertTrue(sdkInfo2.mainVPSDKType == VPUPMainSDKTypeVideoOS, @"SDKInfo wrong value default to VideoOS");
    XCTAssertTrue(sdkInfo2.mainVPSDKVersion == nil, @"SDKInfo version set nil to nil");
    XCTAssertTrue(sdkInfo2.mainVPSDKAppKey == nil, @"SDKInfo appKey set nil to nil");
    
}

- (void)testSetMainSDKNameByType {
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    [sdkInfo setMainSDKNameByType:VPUPMainSDKTypeVideoOS];
    XCTAssertTrue(sdkInfo.mainVPSDKType == VPUPMainSDKTypeVideoOS, @"SDKInfo set type to VideoOS");
    XCTAssertTrue([sdkInfo.mainVPSDKName isEqualToString:@"VideoOS"], @"SDKInfo set type to VideoOS");
    
    [sdkInfo setMainSDKNameByType:VPUPMainSDKTypeLiveOS];
    XCTAssertTrue(sdkInfo.mainVPSDKType == VPUPMainSDKTypeLiveOS, @"SDKInfo set type to LiveOS");
    XCTAssertTrue([sdkInfo.mainVPSDKName isEqualToString:@"LiveOS"], @"SDKInfo set type to LiveOS");
    
    [sdkInfo setMainSDKNameByType:VPUPMainSDKTypeVideojj];
    XCTAssertTrue(sdkInfo.mainVPSDKType == VPUPMainSDKTypeVideojj, @"SDKInfo set type to Videojj");
    XCTAssertTrue([sdkInfo.mainVPSDKName isEqualToString:@"Videojj"], @"SDKInfo set type to Videokk");
    
    [sdkInfo setMainSDKNameByType:nil];
    XCTAssertTrue(sdkInfo.mainVPSDKType == VPUPMainSDKTypeVideoOS, @"SDKInfo set wrong vaule set to VideoOS");
    XCTAssertTrue([sdkInfo.mainVPSDKName isEqualToString:@"VideoOS"], @"SDKInfo set wrong vaule set to VideoOS");
}

- (void)testSetMainVPSDKVersion {
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    [sdkInfo setMainVPSDKVersion:@"1.0.0"];
    XCTAssertTrue([sdkInfo.mainVPSDKVersion isEqualToString:@"1.0.0"], @"SDKInfo mainSDKVersion set to 1.0.0");
    [sdkInfo setMainVPSDKVersion:nil];
    XCTAssertTrue([sdkInfo.mainVPSDKVersion isEqualToString:@"1.0.0"], @"SDKInfo mainSDKVersion has value set to nil inoperative");
    
    VPUPSDKInfo *sdkInfo1 = [[VPUPSDKInfo alloc] init];
    [sdkInfo1 setMainVPSDKVersion:nil];
    XCTAssertNil(sdkInfo1.mainVPSDKVersion, @"SDKInfo mainSDKVersion default is nil");
}

- (void)testSetMainVPSDKServiceVersion {
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    [sdkInfo setMainVPSDKServiceVersion:@"1.0.0"];
    XCTAssertTrue([sdkInfo.mainVPSDKServiceVersion isEqualToString:@"1.0.0"], @"SDKInfo mainSDKServiceVersion set to 1.0.0");
    [sdkInfo setMainVPSDKServiceVersion:nil];
    XCTAssertTrue([sdkInfo.mainVPSDKServiceVersion isEqualToString:@"1.0.0"], @"SDKInfo mainSDKServiceVersion has value set to nil inoperative");
    
    VPUPSDKInfo *sdkInfo1 = [[VPUPSDKInfo alloc] init];
    XCTAssertNil(sdkInfo1.mainVPSDKServiceVersion, @"SDKInfo mainSDKServiceVersion default is nil");
    [sdkInfo1 setMainVPSDKServiceVersion:nil];
    XCTAssertNil(sdkInfo1.mainVPSDKServiceVersion, @"SDKInfo mainSDKServiceVersion default is nil");
}

- (void)testSetMainVPSDKAppKey {
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    [sdkInfo setMainVPSDKAppKey:@"123"];
    XCTAssertTrue([sdkInfo.mainVPSDKAppKey isEqualToString:@"123"], @"SDKInfo mainVPSDKAppKey set to 123");
    [sdkInfo setMainVPSDKAppKey:nil];
    XCTAssertTrue([sdkInfo.mainVPSDKAppKey isEqualToString:@"123"], @"SDKInfo mainVPSDKAppKey has value set to nil inoperative");
    
    VPUPSDKInfo *sdkInfo1 = [[VPUPSDKInfo alloc] init];
    XCTAssertNil(sdkInfo1.mainVPSDKAppKey, @"SDKInfo mainVPSDKAppKey default is nil");
    [sdkInfo1 setMainVPSDKAppKey:nil];
    XCTAssertNil(sdkInfo1.mainVPSDKAppKey, @"SDKInfo mainVPSDKAppKey default is nil");
}

- (void)testSetMainVPSDKAppSecret {
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    [sdkInfo setMainVPSDKAppSecret:@"123"];
    XCTAssertTrue([sdkInfo.mainVPSDKAppSecret isEqualToString:@"123"], @"SDKInfo mainVPSDKAppSecret set to 123");
    [sdkInfo setMainVPSDKAppSecret:nil];
    XCTAssertTrue([sdkInfo.mainVPSDKAppSecret isEqualToString:@"123"], @"SDKInfo mainVPSDKAppSecret has value set to nil inoperative");
    
    VPUPSDKInfo *sdkInfo1 = [[VPUPSDKInfo alloc] init];
    XCTAssertNil(sdkInfo1.mainVPSDKAppSecret, @"SDKInfo mainVPSDKAppSecret default is nil");
    [sdkInfo1 setMainVPSDKAppSecret:nil];
    XCTAssertNil(sdkInfo1.mainVPSDKAppSecret, @"SDKInfo mainVPSDKAppSecret default is nil");
}

- (void)testSetMainVPSDKPlatformID {
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    [sdkInfo setMainVPSDKPlatformID:@"123"];
    XCTAssertTrue([sdkInfo.mainVPSDKPlatformID isEqualToString:@"123"], @"SDKInfo mainVPSDKPlatformID set to 123");
    [sdkInfo setMainVPSDKPlatformID:nil];
    XCTAssertTrue([sdkInfo.mainVPSDKPlatformID isEqualToString:@"123"], @"SDKInfo mainVPSDKPlatformID has value set to nil inoperative");
    
    VPUPSDKInfo *sdkInfo1 = [[VPUPSDKInfo alloc] init];
    XCTAssertNil(sdkInfo1.mainVPSDKPlatformID, @"SDKInfo mainVPSDKPlatformID default is nil");
    [sdkInfo1 setMainVPSDKPlatformID:nil];
    XCTAssertNil(sdkInfo1.mainVPSDKPlatformID, @"SDKInfo mainVPSDKPlatformID default is nil");
}

- (void)testSetEnableWebP {
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] init];
    [sdkInfo setEnableWebP:YES];
    XCTAssertTrue(sdkInfo.enableWebP, @"SDKInfo webP set to true");
    [sdkInfo setEnableWebP:NO];
    XCTAssertFalse(sdkInfo.enableWebP, @"SDKInfo webP set to false");    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
