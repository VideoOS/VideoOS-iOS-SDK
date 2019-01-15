//
//  VPUPRandomUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/21.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPRandomUtil.h"

@implementation VPUPRandomUtil

#pragma mark Number
+ (NSUInteger)randomNumberByLength:(NSUInteger)length {
    return [self randomNumberByRange:NSMakeRange(0, length)];
}

+ (NSUInteger)randomNumberFrom:(NSUInteger)from to:(NSUInteger)to {
    if(from < to) {
        return NSUIntegerMax;
    }
    return [self randomNumberByRange:NSMakeRange(from, to - from)];
}

+ (NSUInteger)randomNumberByRange:(NSRange)range {
    if(range.length == 0) {
        return range.location;
    }
    
    return (NSUInteger)(range.location + arc4random() % range.length);
}

#pragma mark String
+ (NSString *)randomStringByLength:(NSInteger)length {
    NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return [self randomStringByLength:length dataString:kRandomAlphabet];
}

+ (NSString *)randomStringByLength:(NSInteger)count dataString:(NSString *)dataString {
    if(count <= 0) {
        return nil;
    }
    NSMutableString *randomString = [NSMutableString stringWithCapacity:count];
    for(int i = 0; i < count; i++) {
        [randomString appendFormat: @"%C", [dataString characterAtIndex:arc4random_uniform((u_int32_t)[dataString length])]];
    }
    return randomString;
}

+ (NSString *)randomMKTempStringByLength:(NSInteger)length {
    if(length <= 0) {
        return nil;
    }
    
    char template[length + 1];
    //init for 'X'
    memset(template, 'X', sizeof(char) * length);
    template[length] = '\0';
    char *randomChars = mktemp(template);
    
    NSString *randomString = [NSString stringWithCString:randomChars encoding:NSASCIIStringEncoding];
    
    return randomString;
}

@end
