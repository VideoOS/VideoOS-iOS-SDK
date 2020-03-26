//
//  VPUPGZIPUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/5.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPGZIPUtil.h"
#import "VPUPBase64Util.h"

@interface VPUPGZIPUtilTests : XCTestCase

@end

@implementation VPUPGZIPUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGZIP {
    
    NSString *string = @"UnitTestUnitTestUnitTest";
    NSData *stringData = [string dataUsingEncoding:kCFStringEncodingUTF8];
    NSString *compressedBase64String = @"H4sIAAAAAAAAEwvNyywJSS0uCUWjAZlPq4MYAAAA";
    
    XCTAssertTrue([VPUP_GZIPCompressBase64String(string) isEqualToString:compressedBase64String], @"GZIP Compress string base64 must be equal");
    XCTAssertTrue([[VPUPBase64Util base64EncodingData:VPUP_GZIPCompressData(stringData)] isEqualToString:compressedBase64String], @"GZIP Compress string base64 must be equal");
    
    XCTAssertTrue([VPUP_GZIPUncompressData(VPUP_GZIPCompressData(stringData)) isEqualToData:stringData], @"Uncompress data is equal to data");
    XCTAssertTrue([VPUP_GZIPUncompressDataToString(VPUP_GZIPCompressData(stringData)) isEqualToString:string], @"GZIP Uncompress string must be equal");
    XCTAssertTrue([VPUP_GZIPUncompressBase64StringToString(compressedBase64String) isEqualToString:string], @"GZIP Uncompress string must be equal");
    
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
