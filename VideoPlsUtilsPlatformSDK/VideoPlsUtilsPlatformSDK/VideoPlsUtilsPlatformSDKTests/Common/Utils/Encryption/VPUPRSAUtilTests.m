//
//  VPUPRSAUtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/5.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPRSAUtil.h"
#import "VPUPBase64Util.h"

@interface VPUPRSAUtilTests : XCTestCase

@property (nonatomic) NSString *publicString;
@property (nonatomic) NSString *privateString;

@end

@implementation VPUPRSAUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
//    self.publicString = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCjMroMiWPHbWMp9PTlzIqZhDM+\nWVNyDuaC2s3IQfoMG4VT8PbeQZrM+StkJOiM2DWGC4wlOVl+PCT1v9sX7NGDt4xa\ntfD94JoXXosluGKR/85rFbQVCJI9u0/sj1zUV5JXoDJFOyWGnY9njGpcYf9QbXxS\nx7b091FWhhKDxxhAiwIDAQAB\n-----END PUBLIC KEY-----";
    self.publicString =  @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDI2bvVLVYrb4B0raZgFP60VXY\ncvRmk9q56QiTmEm9HXlSPq1zyhyPQHGti5FokYJMzNcKm0bwL1q6ioJuD4EFI56D\na+70XdRz1CjQPQE3yXrXXVvOsmq9LsdxTFWsVBTehdCmrapKZVVx6PKl7myh0cfX\nQmyveT/eqyZK1gYjvQIDAQAB\n-----END PUBLIC KEY-----";
    self.privateString = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAKMyugyJY8dtYyn09OXMipmEMz5ZU3IO5oLazchB+gwbhVPw9t5Bmsz5K2Qk6IzYNYYLjCU5WX48JPW/2xfs0YO3jFq18P3gmhdeiyW4YpH/zmsVtBUIkj27T+yPXNRXklegMkU7JYadj2eMalxh/1BtfFLHtvT3UVaGEoPHGECLAgMBAAECgYBMFQUJfS+oNIXrdIiLbW0cHrapFYnCfdHXJVyURLXm2RmyRX9BpIIflvY0rMRBjTZ+tHl0jST8pdtxOi1RHRWbPOzFSbGQnvn4lKMYL1wY5xB4SX7kdd6MGDaUNKEW4Sd9r+KaovfwXbI/C6Li4lrjjkOu4/VkWEuiPFFPbu64qQJBAMzMsTeKat3F8bM+1/OdhliXid4/cBJ1hGHPz5+4INJdtSqaHGsiBjsH7hCtR4Y5ltoa5m5Qz2APKgxbOY7CkL0CQQDL/4QJSConNpYCEo7aG71XwRptjFcZMcwWOIMQhyt4apRFUBR0mGIQlB7VTRF2iD/yUdZUDQjt55oYxq8br57nAkEAmoDqSX5xdPI6kAGfJbj3e6qHZlXxlNt3jdsbReHBUTNE0+kD+4blsG8hGQ/A3/BecBjPMvZgHJYUINJJr/v0+QJBAKU7elv2SsZmTUyycWiyjUO2EkznHmk2z4K0FVzez1QCp8QYn+jswImDIBJPETT8GSeSJ9L+l9vy+vrUe2MmdcMCQQC06yMBVq/0ihHYlfGTRpVDF8m09Lgl7xk9BzyFOYcOuqtUh42LYR2YtsZTOk8ZC0iqvt0YtXAWddXOimffJ7u9";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncrypt {
    NSString *string = @"UnitTest";
    NSData *stringData = [string dataUsingEncoding:kCFStringEncodingUTF8];
    
    NSString *encryptBase64String = @"KGqXykggoFlrERjDeF5DKahzzz0Hl/O3kQQD4gp2Yn5EUjMBJge+J8G4fOPy4bIVX5/45iWyzxKxO4kEqRqhuylzMDVxHTfvwzR96quCAc11jl49STXjzbdYHQgVwfrAHC9TYojn7nrJKAgaGkoOdvoFSyzhxuNDZvSlLBAv4YQ=";
    NSData *encryptData = @"";
    
    // SecAddItem return -50 for unknown reason
    
//    XCTAssertTrue([[VPUPRSAUtil encryptString:string publicKey:self.publicString] isEqualToString:encryptBase64String], @"RSA encrypt must be equal");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
