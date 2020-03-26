//
//  VPUPJsonUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/20.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPJsonUtil.h"

@interface VPUPJsonUtilTests : XCTestCase

@end

@implementation VPUPJsonUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDictionaryToJson {
    NSDictionary *dict = @{@"1":@"1", @"2":@"2", @"3":@3};
    XCTAssertTrue([VPUP_DictionaryToJson(dict) isEqualToString:@"{\"1\":\"1\",\"2\":\"2\",\"3\":3}"], @"Change dict to json");
    XCTAssertNil(VPUP_DictionaryToJson(nil), @"return nil to nil");
    XCTAssertNil(VPUP_DictionaryToJson(@"1"), @"return nil to not a dict object");
    
    NSArray *array = @[@1,@2];
    XCTAssertTrue([VPUP_DictionaryToJson(array) isEqualToString:@"[1,2]"], @"Array can handle");

    NSArray *arrayString = @[@"123", @"ret"];
    XCTAssertTrue([VPUP_DictionaryToJson(arrayString) isEqualToString:@"[\"123\",\"ret\"]"], @"Array can handle");
    
    NSDictionary *dict2 = @{@"1":array, @"2":dict};
    XCTAssertTrue([VPUP_DictionaryToJson(dict2) isEqualToString:@"{\"1\":[1,2],\"2\":{\"1\":\"1\",\"2\":\"2\",\"3\":3}}"], @"Dict contain array or dict");
}

- (void)testStringArrayToJson {
    NSArray *arrayString = @[@"123", @"ret"];
    XCTAssertTrue([VPUP_StringArrayToJson(arrayString) isEqualToString:@"[123,ret]"], @"string array handle by string array");
    
    NSArray *arrayJsonString = @[@"{\"1\":\"1\",\"2\":\"2\",\"3\":\"3\"}", @"{\"1\":\"1\",\"2\":\"2\",\"3\":\"3\"}"];
    //使用json序列化jsonString的数组会造成多层转义符号,所以需要使用StringArrayToJson手动来拼接
    XCTAssertFalse([VPUP_DictionaryToJson(arrayJsonString) isEqualToString:@"[{\"1\":\"1\",\"2\":\"2\",\"3\":\"3\"},{\"1\":\"1\",\"2\":\"2\",\"3\":\"3\"}]"], @"json string array could not use dictToJson");
    
    XCTAssertTrue([VPUP_StringArrayToJson(arrayJsonString) isEqualToString:@"[{\"1\":\"1\",\"2\":\"2\",\"3\":\"3\"},{\"1\":\"1\",\"2\":\"2\",\"3\":\"3\"}]"], @"json string array handle by manual joint");
}

- (void)testJsonToDictionary {
    NSString *jsonString = @"{\"1\":\"1\",\"2\":\"2\",\"3\":3}";
    NSDictionary *dict = @{@"1":@"1", @"2":@"2", @"3":@3};
    XCTAssertTrue([VPUP_JsonToDictionary(jsonString) isEqualToDictionary:dict], @"simple json to dict");
    
    
    NSArray *arrayString = @[@"123", @"ret"];
    XCTAssertTrue([(NSArray *)VPUP_JsonToDictionary(@"[\"123\",\"ret\"]") isEqualToArray:arrayString], @"Array can handle");
    
    NSString *jsonString2 = @"{\"1\":[1,2],\"2\":{\"1\":\"1\",\"2\":\"2\",\"3\":3}}";
    NSDictionary *dict2 = @{@"1":@[@1,@2], @"2":@{@"1":@"1", @"2":@"2", @"3":@3}};
    XCTAssertTrue([VPUP_JsonToDictionary(jsonString2) isEqualToDictionary:dict2], @"json to dict");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
