//
//  VPUPCipherOperationTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/2.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPCipherOperation.h"
#import <CommonCrypto/CommonCrypto.h>
#import "VPUPBase64Util.h"

@interface VPUPCipherOperationTests : XCTestCase

@end

@implementation VPUPCipherOperationTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCipherOperation {
    NSData *contentData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [@"8lgK5fr5yatOfHio" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *initVectorData = [@"lx7eZhVoBEnKXELF" dataUsingEncoding:NSUTF8StringEncoding];

    NSData *encryptData = [VPUPCipherOperation vpup_cipherOperationWithContent:contentData key:keyData initVector:initVectorData operation:kCCEncrypt algorithm:kCCAlgorithmAES options:kCCOptionPKCS7Padding keySize:kCCKeySizeAES128 blockSize:kCCBlockSizeAES128];
    
    XCTAssert([[VPUPBase64Util base64EncodingData:encryptData] isEqualToString:@"QpAY7ni/STpAvZAQ33oEHw=="], @"AES encryption must be equal");
    
    NSData *decryptData = [VPUPCipherOperation vpup_cipherOperationWithContent:encryptData key:keyData initVector:initVectorData operation:kCCDecrypt algorithm:kCCAlgorithmAES options:kCCOptionPKCS7Padding keySize:kCCKeySizeAES128 blockSize:kCCBlockSizeAES128];
    
    XCTAssert([[NSString stringWithUTF8String:decryptData.bytes] isEqualToString:@"test"], @"AES decrypt must be equal");
    
    NSData *contentData2 = [@"unittest" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData2 = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData2 = [VPUPCipherOperation vpup_cipherOperationWithContent:contentData2 key:keyData2 initVector:nil operation:kCCEncrypt algorithm:kCCAlgorithmDES options:kCCOptionECBMode keySize:kCCKeySizeDES blockSize:kCCBlockSizeDES];
    
    NSLog(@"%@",[VPUPBase64Util base64EncodingData:encryptData2]);
    //DES每次加密结果不一致?
//    XCTAssert([[VPUPBase64Util base64EncodingData:encryptData2]  isEqualToString:@"WVBmEm0JZ/ZPLRPq0nWa0w=="], @"DES encryption must be equal");
    
    NSData *decryptData2 = [VPUPCipherOperation vpup_cipherOperationWithContent:encryptData2 key:keyData2 initVector:nil operation:kCCDecrypt algorithm:kCCAlgorithmDES options:kCCOptionECBMode keySize:kCCKeySizeDES blockSize:kCCBlockSizeDES];
    
    XCTAssert([[NSString stringWithUTF8String:decryptData2.bytes] isEqualToString:@"unittest"], @"AES decrypt must be equal");
    
}

- (void)testAESOperation {
    NSData *contentData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [@"8lgK5fr5yatOfHio" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *initVectorData = [@"lx7eZhVoBEnKXELF" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encryptData = [VPUPCipherOperation vpup_aesEncryptWithContent:contentData key:keyData initVector:initVectorData];
    NSData *encryptData2 = [VPUPCipherOperation vpup_aesCipherOperationWithContent:contentData key:keyData initVector:initVectorData operation:kCCEncrypt];
    
    XCTAssertTrue([[encryptData description] isEqualToString:[encryptData2 description]], @"AES encrypt must be same");
    
    NSData *decryptData = [VPUPCipherOperation vpup_aesDecryptWithContent:encryptData key:keyData initVector:initVectorData];
    NSData *decryptData2 = [VPUPCipherOperation vpup_aesCipherOperationWithContent:encryptData key:keyData initVector:initVectorData operation:kCCDecrypt];
    
    XCTAssertTrue([[decryptData description] isEqualToString:[decryptData2 description]], @"AES decrypt must be same");
    
    NSData *contentData2 = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData2 = [@"8lgK5fr5y" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData3 = [VPUPCipherOperation vpup_aesEncryptWithContent:contentData2 key:keyData2 initVector:nil];
    
    XCTAssertNil(encryptData3, @"AES key length must be equal to 16(kCCKeySizeAES128)");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
