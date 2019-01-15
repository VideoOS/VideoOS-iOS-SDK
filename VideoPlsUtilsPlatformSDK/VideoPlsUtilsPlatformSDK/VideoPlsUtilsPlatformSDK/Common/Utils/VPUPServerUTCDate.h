//
//  VPUPServerUTCDate.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/16.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPServerUTCDate : NSObject

+ (NSDate *)date;

+ (NSTimeInterval)currentUnixTime;
+ (NSTimeInterval)currentUnixTimeMillisecond;

+ (NSString *)dateString;
+ (NSString *)dateStringWithUnixTimeMillisecond:(NSTimeInterval)unixTime;

+ (BOOL)isVerified;


/**
 *  有可能在开启后由用户或者可能发生修改时间,导致网络请求不成功(仅限自己的服务器的接口).此时把response传入重新匹配线上时间
 */
+ (void)updateServerUTCDate:(NSHTTPURLResponse *)response;

@end
