//
//  VPUPDebugSwitchTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/14.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPDebugSwitch.h"

@interface VPUPDebugSwitchTests : XCTestCase <VPUPDebugSwitchProtocol>

@property (nonatomic, assign) VPUPDebugState currentDebugState;

@end

@implementation VPUPDebugSwitchTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    [VPUPDebugSwitch sharedDebugSwitch];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateOnline];
}

- (void)testSwitchEnvironment {
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateOnline];
    XCTAssertTrue([VPUPDebugSwitch sharedDebugSwitch].debugState == VPUPDebugStateOnline, @"Debug State must be online");
    
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateProduction];
    XCTAssertTrue([VPUPDebugSwitch sharedDebugSwitch].debugState == VPUPDebugStateProduction, @"Debug State must be Pre");
    
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateTest];
    XCTAssertTrue([VPUPDebugSwitch sharedDebugSwitch].debugState == VPUPDebugStateTest, @"Debug State must be Test");
    
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateDevelop];
    XCTAssertTrue([VPUPDebugSwitch sharedDebugSwitch].debugState == VPUPDebugStateDevelop, @"Debug State must be Dev");
}

- (void)testRegisterDebugSwitchObserver {
    [[VPUPDebugSwitch sharedDebugSwitch] registerDebugSwitchObserver:self];
    XCTAssertTrue([VPUPDebugSwitch sharedDebugSwitch].debugState == _currentDebugState, @"Observer Debug State must be equal");
    
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateDevelop];
    XCTAssertTrue([VPUPDebugSwitch sharedDebugSwitch].debugState == _currentDebugState, @"Observer Debug State must be equal");
}

- (void)testRemoveDebugSwitchObserver {
    [[VPUPDebugSwitch sharedDebugSwitch] removeDebugSwitchObserver:self];
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:VPUPDebugStateTest];
    
    XCTAssertFalse([VPUPDebugSwitch sharedDebugSwitch].debugState == _currentDebugState, @"Observer Debug State must be unequal");
}

- (void)testLogging {
    [[VPUPDebugSwitch sharedDebugSwitch] disableLogging];
    XCTAssertFalse([VPUPDebugSwitch sharedDebugSwitch].logEnable, @"Disable logging");
    [[VPUPDebugSwitch sharedDebugSwitch] enableLogging];
    XCTAssertTrue([VPUPDebugSwitch sharedDebugSwitch].logEnable, @"Enable logging");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)switchEnvironmentTo:(VPUPDebugState)debugState {
    _currentDebugState = debugState;
}

@end
