//
//  VPUPValidatorTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/19.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPValidator.h"

@interface VPUPValidatorTests : XCTestCase

@end

@implementation VPUPValidatorTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsExist {
    XCTAssertFalse(VPUP_IsExist(nil), @"nil is not exist");
    
    XCTAssertTrue(VPUP_IsExist(@[]), @"empty array is exist");
    XCTAssertTrue(VPUP_IsExist(@{}), @"empty dict is exist");
    XCTAssertTrue(VPUP_IsExist(@""), @"empty string is exist");
    
    XCTAssertTrue(VPUP_IsExist(@[@"1", @"2"]), @"array is exist");
    XCTAssertTrue(VPUP_IsExist(@{@"1":@"1", @"2":@"2"}), @"dict is exist");
    XCTAssertTrue(VPUP_IsExist(@"123"), @"string is exist");
    XCTAssertTrue(VPUP_IsExist(@(1)), @"number is exist");
}

- (void)testIsStrictExist {
    XCTAssertFalse(VPUP_IsStrictExist(nil), @"nil is not exist");
    
    XCTAssertFalse(VPUP_IsStrictExist(@[]), @"empty array is not exist");
    XCTAssertFalse(VPUP_IsStrictExist(@{}), @"empty dict is not exist");
    XCTAssertFalse(VPUP_IsStrictExist(@""), @"empty string is not exist");
    
    XCTAssertTrue(VPUP_IsStrictExist(@[@"1", @"2"]), @"array is exist");
    XCTAssertTrue(VPUP_IsStrictExist(@{@"1":@"1", @"2":@"2"}), @"dict is exist");
    XCTAssertTrue(VPUP_IsStrictExist(@"123"), @"string is exist");
    XCTAssertTrue(VPUP_IsStrictExist(@(1)), @"number is exist");
}

- (void)testIsStringTrimExist {
    XCTAssertFalse(VPUP_IsStringTrimExist(@""), @"empty string is not exist");
    XCTAssertFalse(VPUP_IsStringTrimExist(@" "), @"space string is not exist");
    XCTAssertFalse(VPUP_IsStringTrimExist(@"  "), @"space string is not exist");
    
    XCTAssertTrue(VPUP_IsStringTrimExist(@"1 "), @"string and spcae is exist");
}

- (void)testStringFromObject {
    XCTAssertTrue([VPUP_StringFromObject(@"123") isEqualToString:@"123"], @"String from object just return null space string");
    XCTAssertTrue([VPUP_StringFromObject(@"123 ") isEqualToString:@"123"], @"String from object just return null space string");
    XCTAssertTrue([VPUP_StringFromObject(@" 123") isEqualToString:@"123"], @"String from object just return null space string");
    XCTAssertTrue([VPUP_StringFromObject(@" 123 ") isEqualToString:@"123"], @"String from object just return null space string");
    XCTAssertTrue([VPUP_StringFromObject(@" 1 2 3 ") isEqualToString:@"1 2 3"], @"String from object just return null space string(only before or behind white space)");
    
    XCTAssertTrue([VPUP_StringFromObject(@(123)) isEqualToString:@"123"], @"String from object can change number to string");
}

- (void)testStringFromObjectNeedTrim {
    XCTAssertTrue([VPUP_StringFromObjectNeedTrim(@"123 ", false) isEqualToString:@"123 "], @"String did not trim");
    XCTAssertTrue([VPUP_StringFromObjectNeedTrim(@"123 ", true) isEqualToString:@"123"], @"String trim");
    XCTAssertTrue([VPUP_StringFromObjectNeedTrim(@(123), true) isEqualToString:@"123"], @"String trim");
    XCTAssertTrue(VPUP_StringFromObjectNeedTrim(@[@123, @123], true) == nil, @"String trim");
}

- (void)testStringContainsString {
    XCTAssertTrue(VPUP_StringContainsString(@"1234567890", @"123"), @"String 123 has contained");
    
    XCTAssertFalse(VPUP_StringContainsString(@"This is land", @"That"), @"String that hadn't contained");
}

- (void)testIsDealArrayBoundWithIndex {
    NSArray *array = @[@1, @2, @3, @4, @5, @6];
    XCTAssertTrue(VPUP_IsDealArrayBoundWithIndex(array, 3) == 3, @"3 is in bound");
    
    XCTAssertFalse(VPUP_IsDealArrayBoundWithIndex(array, -1) == -1, @"-1 is not in bound");
    XCTAssertFalse(VPUP_IsDealArrayBoundWithIndex(array, 7) == 7, @"7 is not in bound");
}

- (void)testGetValue {
    NSDictionary *dict = @{@"1":@"1", @"2":@"2", @"3":@"3"};
    XCTAssertTrue([VPUP_GetValue([dict objectForKey:@"1"], @"null") isEqualToString:@"1"], @"Dict can get value use value");
    
    XCTAssertTrue([VPUP_GetValue([dict objectForKey:@"4"], @"null") isEqualToString:@"null"], @"Dict can't get value use default value");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
