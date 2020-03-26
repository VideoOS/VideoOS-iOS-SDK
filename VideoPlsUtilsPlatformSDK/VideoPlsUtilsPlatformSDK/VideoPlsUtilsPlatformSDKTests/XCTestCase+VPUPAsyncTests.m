//
//  XCTestCase+VPUPAsyncTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/17.
//  Copyright © 2020 videopls. All rights reserved.
//

#import "XCTestCase+VPUPAsyncTests.h"
#import "VPUPValidator.h"

@implementation XCTestCase (VPUPAsyncTests)

@dynamic notifyName;

- (NSString *)getNotifyName {
    NSString *notifyName = nil;
    if ([self respondsToSelector:@selector(notifyName)]) {
        notifyName = [self notifyName];
    }
    return [self verifyNotifyName:notifyName];
}

- (NSString *)verifyNotifyName:(NSString *)notifyName {
    return VPUP_IsStrictExist(notifyName) ? notifyName : @"VPUPBaseTests";
}


- (void)wait {
    [self waitWithTimeout:5];
}

- (void)waitWithTimeout:(CGFloat)timeout {
    NSString *notifyName = [self getNotifyName];
    [self waitWithTimeout:timeout name:notifyName];
}

- (void)notify {
    NSString *notifyName = [self getNotifyName];
    [self notifyWithName:notifyName];
}

- (void)waitWithName:(NSString *)notifyName {
    [self waitWithTimeout:5 name:notifyName];
}

- (void)waitWithTimeout:(CGFloat)timeout name:(NSString *)notifyName {
    do {
        [self expectationForNotification:[self verifyNotifyName:notifyName] object:nil handler:nil];
        [self waitForExpectationsWithTimeout:timeout handler:nil];
    } while (0);
}

- (void)notifyWithName:(NSString *)notifyName  {
    [[NSNotificationCenter defaultCenter] postNotificationName:[self verifyNotifyName:notifyName] object:nil];
}

@end
