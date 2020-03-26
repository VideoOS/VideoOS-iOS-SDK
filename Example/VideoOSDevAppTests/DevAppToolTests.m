//
//  DevAppToolTests.m
//  VideoOSDevAppTests
//
//  Created by videopls on 2020/3/9.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DevAppTool.h"
@interface DevAppToolTests : XCTestCase

@end

@implementation DevAppToolTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
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

- (void)testGetInteractionLPath {
    NSString* filePath = [DevAppTool getInteractionLPath];
    XCTAssertNotNil(filePath);
}

- (void)testCopyLuaFileToFilePath {
    NSString* inputFile = [[DevAppTool devAPPBundle] pathForResource:@"devApp_json" ofType:@"json"];
    NSString* ToFilePath = [DevAppTool getInteractionLPath];
    [DevAppTool copyLuaFile:@"" ToFilePath:ToFilePath];
    [DevAppTool copyLuaFile:inputFile ToFilePath:ToFilePath];
    [DevAppTool copyLuaFile:[DevAppTool devAPPBundle].resourcePath ToFilePath:ToFilePath];
}

- (void)testDevAPPBundle {
    NSBundle* bundle = [DevAppTool devAPPBundle];
    XCTAssertNotNil(bundle);
}

- (void)testRemoveUserDataWithkey {
    NSString* key = @"";
    [DevAppTool removeUserDataWithkey:key];
}

- (void)testReadUserDataWithKey {
    NSString* key = @"";
    [DevAppTool readUserDataWithKey:key];
}

- (void)testWriteUserDataWithKey {
    NSString* key = @"";
    [DevAppTool writeUserDataWithKey:[NSData new] forKey:key];
}




@end
