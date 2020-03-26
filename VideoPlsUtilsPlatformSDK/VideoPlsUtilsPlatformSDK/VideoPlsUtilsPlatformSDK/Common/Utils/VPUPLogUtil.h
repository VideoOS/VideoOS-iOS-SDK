//
//  VPUPLogUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

//日志等级
//typedef enum {
//    VPUP_LOG_LEVEL_INFO     = 0,
//    VPUP_LOG_LEVEL_WARNING  = 1,
//    VPUP_LOG_LEVEL_ERROR    = 2
//} VPUPLogLevel;

typedef NS_ENUM(NSUInteger, VPUPLogLevel) {
    VPUP_LOG_LEVEL_INFO     = 0,
    VPUP_LOG_LEVEL_WARNING  = 1,
    VPUP_LOG_LEVEL_ERROR    = 2
};

FOUNDATION_EXPORT void VPUPLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void VPUPLogI(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void VPUPLogW(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void VPUPLogE(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

//log with report
FOUNDATION_EXPORT void VPUPLogIR(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void VPUPLogWR(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void VPUPLogER(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

FOUNDATION_EXPORT void VPUPLogWithLevel(VPUPLogLevel level, BOOL needSendReport, NSString *format, ...) NS_FORMAT_FUNCTION(3, 4);

#define VPUPLogL(...)   VPUPLog(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define VPUPLogIL(...)  VPUPLogI(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define VPUPLogWL(...)  VPUPLogW(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define VPUPLogEL(...)  VPUPLogE(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])

#define VPUPLogILR(...) VPUPLogIR(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define VPUPLogWLR(...) VPUPLogWR(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define VPUPLogELR(...) VPUPLogER(@"Method:%s\nLine:%d\n%@",__PRETTY_FUNCTION__ ,__LINE__, [NSString stringWithFormat:__VA_ARGS__])

@interface VPUPLogUtil : NSObject

@end
