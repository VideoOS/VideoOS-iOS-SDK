//
//  XCTestCase+VPUPAsyncTests.h
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/17.
//  Copyright © 2020 videopls. All rights reserved.
//


#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (VPUPAsyncTests) 

@property (nonatomic) NSString *notifyName;

- (void)wait;
- (void)waitWithTimeout:(CGFloat)timeout;

- (void)notify;


- (void)waitWithName:(NSString *)notifyName;
- (void)waitWithTimeout:(CGFloat)timeout name:(NSString *)notifyName;

- (void)notifyWithName:(NSString *)notifyName;

@end

NS_ASSUME_NONNULL_END
