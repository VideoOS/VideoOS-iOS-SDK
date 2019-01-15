//
//  VPUPLogUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPLogUtil.h"
#import "VPUPDebugSwitch.h"
#import "VPUPGeneralInfo.h"
#import "VPUPNotificationCenter.h"

//#define VPUPLogL(...) VPUPLog(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])
//#define VPUPLogIL(...) VPUPLogI(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])
//#define VPUPLogWL(...) VPUPLogW(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])
//#define VPUPLogEL(...) VPUPLogE(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])

@implementation VPUPLogUtil

+ (void)logWithLevel:(VPUPLogLevel)level needSendReport:(BOOL)needSendReport format:(NSString *)format va_list:(va_list)args {
    
    NSString *levelString = [self logLevelString:level];
    levelString = [NSString stringWithFormat:@"\n---%@---\n", levelString];
    NSString *formatString = [levelString stringByAppendingString:format];
    
    //args只能使用一次
    NSString *logString = [[NSString alloc] initWithFormat:formatString arguments:args];
    
    if(needSendReport) {
        //添加一条日志report
//        [VPUPReport addReportByLevel:VPUPReportLevelLog reportClass:[self class] message:logString];
        
        if(logString) {
            NSDictionary *userInfo = @{
                                       @"reportClass"   : [self class],
                                       @"message"       : logString
                                       };
            
            [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPLogAddReportNotification object:nil userInfo:userInfo];
        }
    }
    
    if(![VPUPDebugSwitch sharedDebugSwitch].isLogEnable && level < VPUP_LOG_LEVEL_ERROR) {
        return;
    }
    
//    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    
//    NSLogv(format, args);
    
    NSLog(@"%@", logString);
}

+ (NSString *)logLevelString:(VPUPLogLevel)level {

    NSString *levelString = @"";
    switch (level) {
        case VPUP_LOG_LEVEL_INFO:
            levelString = @"INFO";
            break;
        case VPUP_LOG_LEVEL_WARNING:
            levelString = @"WARNING";
            break;
        case VPUP_LOG_LEVEL_ERROR:
            levelString = @"ERROR";
            break;
        default:
            break;
    }
    
//    levelString = [NSString stringWithFormat:formatString, levelString];
    
    NSString *format = [NSString stringWithFormat:@"[%@]%@",[VPUPGeneralInfo mainVPSDKName], levelString];
    
    return format;
}

@end


void VPUPLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [VPUPLogUtil logWithLevel:VPUP_LOG_LEVEL_INFO needSendReport:NO format:format va_list:args];
    va_end(args);
}

void VPUPLogI(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [VPUPLogUtil logWithLevel:VPUP_LOG_LEVEL_INFO needSendReport:NO format:format va_list:args];
    va_end(args);
}

void VPUPLogW(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [VPUPLogUtil logWithLevel:VPUP_LOG_LEVEL_WARNING needSendReport:NO format:format va_list:args];
    va_end(args);
}

void VPUPLogE(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [VPUPLogUtil logWithLevel:VPUP_LOG_LEVEL_ERROR needSendReport:NO format:format va_list:args];
    va_end(args);
}

void VPUPLogIR(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [VPUPLogUtil logWithLevel:VPUP_LOG_LEVEL_INFO needSendReport:YES format:format va_list:args];
    va_end(args);
}

void VPUPLogWR(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [VPUPLogUtil logWithLevel:VPUP_LOG_LEVEL_WARNING needSendReport:YES format:format va_list:args];
    va_end(args);
}

void VPUPLogER(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [VPUPLogUtil logWithLevel:VPUP_LOG_LEVEL_ERROR needSendReport:YES format:format va_list:args];
    va_end(args);
}

void VPUPLogWithLevel(VPUPLogLevel level, BOOL needSendReport, NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [VPUPLogUtil logWithLevel:level needSendReport:needSendReport format:format va_list:args];
    va_end(args);
}
