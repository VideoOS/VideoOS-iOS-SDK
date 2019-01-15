//
//  VPUPServerUTCDate.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/16.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPServerUTCDate.h"
//#import "VPUPHTTPNetworking.h"
#import "VPUPLogUtil.h"

//static dispatch_queue_t get_time_queue = nil;
//static id<VPUPHTTPAPIManager> httpManager = nil;

static NSTimeInterval timeDifference = 0;
static BOOL isVerified = NO;
static BOOL isVerifying = NO;


@implementation VPUPServerUTCDate

+ (NSDate *)date {
    if(!isVerified) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self verifyDate];
        });
    }
    
    return [[NSDate date] dateByAddingTimeInterval:timeDifference];
}

+ (NSTimeInterval)currentUnixTime {
    return [[self date] timeIntervalSince1970];
}

+ (NSTimeInterval)currentUnixTimeMillisecond {
    return [[self date] timeIntervalSince1970] * 1000;
}

+ (NSString *)dateString {
    return [self dateStringWithUnixTimeMillisecond:[self currentUnixTimeMillisecond]];
}

+ (NSString *)dateStringWithUnixTimeMillisecond:(NSTimeInterval)unixTime {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime / 1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (BOOL)isVerified {
    return isVerified;
}


+ (void)verifyDate {
    
//    if(!httpManager) {
//        httpManager = [VPUPHTTPManagerFactory createHTTPAPIManagerWithType:VPUPHTTPManagerTypeAFN];
//    }
//    if(!get_time_queue) {
//        get_time_queue = dispatch_queue_create("com.videopls.utilsplatform.catch.server.date", DISPATCH_QUEUE_SERIAL);
//    }
    
    //正在请求
    if(isVerifying) {
        return;
    }
    
    isVerifying = YES;
//    dispatch_async(get_time_queue, ^{
    
        
    __block NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://videojj.com"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    request.HTTPMethod = @"HEAD";
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                isVerifying = NO;
                return;
            }
            
            if([response isKindOfClass:[NSHTTPURLResponse class]]) {
                [self updateServerUTCDate:(NSHTTPURLResponse *)response];
                isVerifying = NO;
            }
        });
        [session finishTasksAndInvalidate];
        session = nil;
        
    }];
    
    [dataTask resume];
    
    
//        VPUPHTTPGeneralAPI *api = [[VPUPHTTPGeneralAPI alloc] init];
//        [api setBaseUrl:@"https://videojj.com"];
//        [api setApiRequestMethodType:VPUPRequestMethodTypeHEAD];
//        
//        [api setApiCompletionHandler:^(id _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
//            if(error) {
//                //出错
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    isVerifying = NO;
//                });
//                
//                return;
//            }
//            
//            if([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                [self updateServerUTCDate:(NSHTTPURLResponse *)response];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    isVerifying = NO;
//                });
//            }
//        }];
//        
//        [api setCallbackQueue:get_time_queue];
//        
//        [httpManager sendAPIRequest:api];
//    });
}

+ (void)updateServerUTCDate:(NSHTTPURLResponse *)response {
    
    void (^updateTime)(NSHTTPURLResponse *response) = ^(NSHTTPURLResponse *response){
        isVerified = NO;
        NSString *dateString = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Date"];
        NSDateFormatter  *dateFormat = [[NSDateFormatter alloc] init];//格式化
        [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        //本身时区不为UTC,切换为UTC
        //设置时区
        NSLocale *enGBLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        [dateFormat setLocale:enGBLocale];
        NSDate *sysDate = [dateFormat dateFromString:dateString];
        NSTimeInterval sysTime = [sysDate timeIntervalSince1970];
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        
        timeDifference = sysTime - nowTime;
        
        isVerified = YES;
        
        //释放httpManager和time队列
//        httpManager = nil;
//        get_time_queue = nil;
    };
    
    if([NSThread currentThread].isMainThread) {
        updateTime(response);
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            updateTime(response);
        });
    }
}


@end
