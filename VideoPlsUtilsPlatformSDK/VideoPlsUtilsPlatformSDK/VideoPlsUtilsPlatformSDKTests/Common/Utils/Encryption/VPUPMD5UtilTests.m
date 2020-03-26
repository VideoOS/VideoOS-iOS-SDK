//
//  VPUPMD5UtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/4.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPMD5Util.h"
#import "VPUPPathUtil.h"

@interface VPUPMD5UtilTests : XCTestCase

@end

@implementation VPUPMD5UtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMD5HashString {
    NSString *string = @"unitTest";
    NSString *md5String = @"8c7f8209709ab837004bee976dffa2ab";
    NSString *md5_16String = @"709ab837004bee97";
    
    XCTAssertTrue([[VPUPMD5Util md5HashString:string] isEqualToString:md5String], @"MD5 string must be equal");
    XCTAssertTrue([[VPUPMD5Util md5_16bitHashString:string] isEqualToString:md5_16String], @"MD5 16 bits string must be equal");
    
    XCTAssertNil([VPUPMD5Util md5HashString:nil], @"nil will return nil");
    
}

- (void)testMD5File {
    
    NSString *path = [VPUPPathUtil localStoragePath];
    path = [path stringByAppendingPathComponent:@"UnitTest.txt"];
    
    XCTAssertNil([VPUPMD5Util md5File:path size:0], @"Without File, return nil");
    
    //写入路径下
    [@"UnitTest" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSString *md5String = @"37adc7db47085615af6389c9c50af7b9";
    
    XCTAssertTrue([[VPUPMD5Util md5File:path size:0] isEqualToString:md5String], @"MD5 file md5 must be equal");
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
