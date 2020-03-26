//
//  VPUPCommonEncryptionTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/19.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPCommonEncryption.h"
#import "VPUPSDKInfo.h"
#import "VPUPGeneralInfo.h"

@interface VPUPCommonEncryptionTests : XCTestCase

@end

@implementation VPUPCommonEncryptionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBase64 {
    NSString *string = @"unitTest";
    NSString *encryptString = @"dW5pdFRlc3Q=";
    
    XCTAssertEqualObjects([VPUPCommonEncryption base64EncryptionString:string], encryptString, @"base64 encrypt must be the same");
    
    XCTAssertEqualObjects([VPUPCommonEncryption base64DecryptionString:encryptString], string, @"base64 decrypt must be the same");
}

- (void)testMD5 {
    NSString *string = @"unitTest";
    NSString *md5String = @"8c7f8209709ab837004bee976dffa2ab";
    NSString *md5_16String = @"709ab837004bee97";
    
    XCTAssertEqualObjects([VPUPCommonEncryption md5HashString:string], md5String, @"md5 encrypt must be equal");
    XCTAssertEqualObjects([VPUPCommonEncryption md5BriefHashString:string], md5_16String, @"md5 16bit encrypt must be equal");
}

- (void)testSHA {
    NSString *string = @"unitTest";
    NSString *sha1String = @"5ad715aabe02e21ebc8315bd0cf20f0e436e916c";
    NSString *sha256String = @"b359595f9d2f9bc7c7e18e1332753e3dfa98c2053651853ced92f6b1e4361117";
    NSString *key = @"test";
    NSString *hmacString = @"abbd76c694b522207490e04eeedeb312d6425331";
    
    XCTAssertEqualObjects([VPUPCommonEncryption sha1HashString:string], sha1String, @"sha1 encrypt msut be equal");
    XCTAssertEqualObjects([VPUPCommonEncryption sha256HashString:string], sha256String, @"sha256 encrypt msut be equal");
    XCTAssertEqualObjects([VPUPCommonEncryption hmac_sha1HashString:string key:key], hmacString, @"hmac encrypt msut be equal");   
}

- (void)testAES {
    NSString *string = @"unitTest";
    NSString *key = @"8lgK5fr5yatOfHio";
    NSString *initVector = @"lx7eZhVoBEnKXELF";
    NSString *aesBase64String = @"FK+tffqGqaq5kX7ECwnFQA==";
    
    XCTAssertEqualObjects([VPUPCommonEncryption aesEncryptString:string], aesBase64String, @"default aes string encrypt must be equal");
    XCTAssertEqualObjects([VPUPCommonEncryption aesDecryptString:aesBase64String], string, @"default aes string decrypt must be equal");
    XCTAssertEqualObjects([VPUPCommonEncryption aesEncryptString:string key:key initVector:initVector], aesBase64String, @"aes string encrypt must be equal");
    XCTAssertEqualObjects([VPUPCommonEncryption aesDecryptString:aesBase64String key:key initVector:initVector], string, @"aes string decrypt must be equal");
}

- (void)testTokenAndMQTTEncryption {
    
    VPUPSDKInfo *sdkInfo = [[VPUPSDKInfo alloc] initSDKInfoWithSDKType:VPUPMainSDKTypeVideojj SDKVersion:@"1.0" appKey:@"133ece77-b838-48f4-9194-37877f16c41a"];
    [VPUPGeneralInfo setSDKInfo:sdkInfo];
    
    NSDictionary *jsonDict = @{@"UnitTest" : @"UnitTest"};
    NSString *tokenEncrypt = @"10f809fde36b58966fc2b33d36aacbcb";
    
    XCTAssertEqualObjects([VPUPCommonEncryption tokenEncryptionWithJson:jsonDict], tokenEncrypt, @"Token encrypt string must be equal");
    
    NSString *errorJsonString = @"test";
    XCTAssertNil([VPUPCommonEncryption tokenEncryptionWithJson:errorJsonString], @"error json string will return nil");
    
    
    NSString *string = @"UnitTest";
    NSString *key = @"test";
    NSString *mqttEncryptString = @"GNj4bYAyGfXl+Ba5ycevKP+0iQ4=";
    
    XCTAssertEqualObjects([VPUPCommonEncryption mqttEncryptionWithData:string key:key], mqttEncryptString, @"MQTT encrypt string must be equal");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
