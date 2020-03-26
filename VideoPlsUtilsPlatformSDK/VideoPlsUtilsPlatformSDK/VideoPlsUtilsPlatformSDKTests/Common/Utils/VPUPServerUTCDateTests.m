//
//  VPUPServerUTCDateTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/2/24.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPServerUTCDate.h"
#import "XCTestCase+VPUPAsyncTests.h"


@interface VPUPServerUTCDateTests : XCTestCase

@end

@implementation VPUPServerUTCDateTests

- (NSString *)notifyName {
    return @"VPUPServerDateTests";
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDate {
    XCTAssertTrue([VPUPServerUTCDate date].timeIntervalSince1970 > 0, @"time couldn't be 0");
    XCTAssertTrue(fabs([VPUPServerUTCDate date].timeIntervalSince1970 - [NSDate date].timeIntervalSince1970) < 60 * 60, @"local time with internet time would similar with server time");
}

- (void)testCurrentUnixTime {
    //do not use equal because method has run time
    XCTAssertTrue(fabs([VPUPServerUTCDate date].timeIntervalSince1970 - [VPUPServerUTCDate currentUnixTime]) < 0.001, @"unix time is time since 1970");
    XCTAssertTrue(fabs([VPUPServerUTCDate date].timeIntervalSince1970 * 1000 - [VPUPServerUTCDate currentUnixTimeMillisecond]) < 0.1, @"unix time is time since 1970");
}

- (void)testDateString {
    NSString *dateString = [VPUPServerUTCDate dateString];
    NSTimeInterval time = [VPUPServerUTCDate currentUnixTimeMillisecond];
    NSString *dateString2 = [VPUPServerUTCDate dateStringWithUnixTimeMillisecond:time];
    //time string accurate to seconds, so this two dateString should be equal
    XCTAssertTrue([dateString isEqualToString:dateString2], @"time string accurate to seconds, so this two dateString should be equal");
}

- (void)testIsVerified {
    [VPUPServerUTCDate date];
    //wait for 5 second for request end
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self notify];
    });
    
    [self wait];
    
    XCTAssertTrue([VPUPServerUTCDate isVerified], @"Now correct server time");
}

- (void)testUpdateServerUTCDate {
    __block NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://videojj.com"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    request.HTTPMethod = @"HEAD";
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [self notify];
                return;
            }
            
            if([response isKindOfClass:[NSHTTPURLResponse class]]) {
                [VPUPServerUTCDate updateServerUTCDate:(NSHTTPURLResponse *)response];
                [self notify];
            }
        });
        [session finishTasksAndInvalidate];
        session = nil;
        
    }];
    
    [dataTask resume];
    
    [self wait];
    
    XCTAssertTrue([VPUPServerUTCDate isVerified], @"Updated server date is verified");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
