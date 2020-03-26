//
//  VPUPRandomUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/25.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPRandomUtil.h"

@interface VPUPRandomUtilTests : XCTestCase

@end

@implementation VPUPRandomUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRandomNumberByLength {
    // random [0, length)
    NSUInteger number = [VPUPRandomUtil randomNumberByLength:3];
    XCTAssertLessThan(number, 100, @"Use length 3 for 0-2 number");
    
    NSUInteger number2 = [VPUPRandomUtil randomNumberByLength:1000];
    XCTAssertLessThan(number2, 1000, @"less 1000");
    NSUInteger number3 = [VPUPRandomUtil randomNumberByLength:1000];
    XCTAssertNotEqualWithAccuracy(number2, number3, 0.01, @"Two random less 1000 number cannot be equal accuracy");
}

- (void)testRandomNumberFromTo {
    // random [from, to)
    NSUInteger number = [VPUPRandomUtil randomNumberFrom:10 to:100];
    XCTAssertLessThan(number, 100, @"Use from to less 100");
    XCTAssertGreaterThanOrEqual(number, 10, @"Use from to greater or equal 10");
    
    NSUInteger number2 = [VPUPRandomUtil randomNumberFrom:100 to:10];
    XCTAssertGreaterThanOrEqual(number2, NSUIntegerMax, @"From could not greater then to, return max");
}

- (void)testRandomNumberByRange {
    // random [range.location, range.location + range.length)
    NSRange range = NSMakeRange(10, 40);
    NSUInteger number = [VPUPRandomUtil randomNumberByRange:range];
    XCTAssertLessThan(number, 50, @"Use from to less 40+10");
    XCTAssertGreaterThanOrEqual(number, 10, @"Use from to greater or equal 10");
    
    NSRange fatalRange = NSMakeRange(10, 0);
    XCTAssertEqual([VPUPRandomUtil randomNumberByRange:fatalRange], 10, @"0 length return only localtion");
}

- (void)testRandomStringByLength {
    //random string in a-z,A-Z
    NSString *string = [VPUPRandomUtil randomStringByLength:8];
    XCTAssertTrue(string.length == 8, @"random 8 length string");
    
    NSString *string2 = [VPUPRandomUtil randomStringByLength:8];
    XCTAssertFalse([string isEqualToString:string2], @"two random 8 length string could not be equal");
    
    XCTAssertNil([VPUPRandomUtil randomStringByLength:0], @"0 length will return nil string");
}

- (void)testRandomStringFromDataString {
    //random string in in dataString(as a code list)
    NSString *dataString = @"abcd10pteR";
    NSString *string = [VPUPRandomUtil randomStringByLength:100 dataString:dataString];
    XCTAssertTrue(string.length == 100, @"random 100 length string");
    XCTAssertFalse([string containsString:@"A"], @"string must be contained in dataString");
    XCTAssertFalse([string containsString:@"x"], @"string must be contained in dataString");
    
    XCTAssertNil([VPUPRandomUtil randomStringByLength:0 dataString:dataString], @"0 length will return nil string");
}

- (void)testRandomMKTempStringByLength {
    //use system random string
    NSString *string = [VPUPRandomUtil randomMKTempStringByLength:8];
    XCTAssertTrue(string.length == 8, @"random 8 length string");
    
    NSString *string2 = [VPUPRandomUtil randomMKTempStringByLength:8];
    XCTAssertFalse([string isEqualToString:string2], @"two random 8 length string could not be equal");
    
    XCTAssertNil([VPUPRandomUtil randomMKTempStringByLength:0], @"0 length will return nil string");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
