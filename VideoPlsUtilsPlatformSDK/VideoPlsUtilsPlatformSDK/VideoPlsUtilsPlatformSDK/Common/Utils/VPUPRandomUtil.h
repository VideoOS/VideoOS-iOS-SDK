//
//  VPUPRandomUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/21.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPRandomUtil : NSObject

//random [0, length)
+ (NSUInteger)randomNumberByLength:(NSUInteger)length;

/**
 *  random [from, to)
 *  'from' equal to 'to' return from
 *  'to' less than 'from' return NSUIntegerMax
 */
+ (NSUInteger)randomNumberFrom:(NSUInteger)from to:(NSUInteger)to;

//random [range.location, range.location + range.length)
+ (NSUInteger)randomNumberByRange:(NSRange)range;


//random string in a-z,A-Z
+ (NSString *)randomStringByLength:(NSInteger)length;

//random string use in dataString(as a code list)
+ (NSString *)randomStringByLength:(NSInteger)count dataString:(NSString *)dataString;

//use system c method mktemp make random string(code list is ASCII)
+ (NSString *)randomMKTempStringByLength:(NSInteger)length;
@end
