//
//  VPUPBase64UtilTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/3.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPBase64Util.h"
#import "XCTestCase+VPUPAsyncTests.h"

@interface VPUPBase64UtilTests : XCTestCase

@end

@implementation VPUPBase64UtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBase64String {
    NSString *string = @"unitTest";
    NSString *encodeString = @"dW5pdFRlc3Q=";
    XCTAssertTrue([[VPUPBase64Util base64EncryptionString:string] isEqualToString:encodeString], @"Base64 encode string must be equal");
    
    XCTAssertTrue([[VPUPBase64Util base64DecryptionString:encodeString] isEqualToString:string], @"Base64 decode string must be equal");
    
    XCTAssertNil([VPUPBase64Util base64DecryptionString:nil], @"nil encode return nil");
}

- (void)testBase64Data {
    NSString *string = @"unitTest";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeString = @"dW5pdFRlc3Q=";
    
    XCTAssertTrue([[VPUPBase64Util base64EncodingData:data] isEqualToString:encodeString], @"Base64 encode data must be equal");
    
    NSData *decodeData = [VPUPBase64Util dataBase64DecodeFromString:encodeString];
    
    XCTAssertTrue([[decodeData description] isEqualToString:[data description]] , @"Base64 decode string must be equal");
    
}

- (void)testBase64Image {
    NSString *imageUrl = @"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/img_scanner_btn_back.png";
    NSString *base64Image = @"iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAMAAABiM0N1AAAASFBMVEUAAAD///////////////////////////////////////////////////////////////////////////////8AAAD///////8aSjgtAAAAF3RSTlMA7fXhzSDaMBPwGzgX1UJHPg/4rmsCkl4fA4oAAACzSURBVFjD7dhLDsIwDARQh1JD+EMacv+b0gWpXBZsPKpGUeYAT8rfjmSBJEtPz1Y5paATwBmHMmcCOUVBTokgpySQE0aQc/CtO8rRNp0L2olO51qdc1POsTo7p7OvzqNR50bhPGmdu7jy/jovpyNhcVggOzSOyV4vP8XG/pEoDj+pZK5skBRnieI5gkpqJIoiwpZHTUqDkSjK7LXE0UIYKbG0WYukPK1obY57ev6G6t8vfwC+qSZMh3iXUgAAAABJRU5ErkJggg==";
    
    __block NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    request.HTTPMethod = @"GET";
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [weakSelf notify];
                return;
            }
            
            UIImage *image = [UIImage imageWithData:data];
            UIImage *decodeImage = [VPUPBase64Util imageFromBase64String:base64Image];
            
            //image could not be equal
            XCTAssertEqual(image.size.width, decodeImage.size.width, @"two same image must have the same width");
            XCTAssertEqual(image.size.height, decodeImage.size.height, @"two same image must have the same height");
            XCTAssertEqual(image.imageOrientation, decodeImage.imageOrientation, @"two same image must have the same height");
            
            XCTAssertEqualWithAccuracy(CGImageGetBitsPerComponent(image.CGImage) * CGImageGetBitsPerPixel(image.CGImage) * CGImageGetBytesPerRow(image.CGImage), CGImageGetBitsPerComponent(decodeImage.CGImage) * CGImageGetBitsPerPixel(decodeImage.CGImage) * CGImageGetBytesPerRow(decodeImage.CGImage), 1, @"two same image buffer size must be equal");
            
            [weakSelf notify];
            
        });
        [session finishTasksAndInvalidate];
        session = nil;
        
    }];
    
    [dataTask resume];
    
    [self wait];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
