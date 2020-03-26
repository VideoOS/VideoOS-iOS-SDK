//
//  VPUPCrashManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Bill on 10/05/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPCrashManager.h"
#include <execinfo.h>
#import "sys/utsname.h"
#import <UIKit/UIKit.h>
#import "VPUPReport.h"


static NSUncaughtExceptionHandler *_previousHandle = nil;

@interface VPUPCrashManager()

//@property (nonatomic,assign) NSUncaughtExceptionHandler *tempHandle;
@end

@implementation VPUPCrashManager

//static int signals[] = {
//    SIGABRT,
//    SIGBUS,
//    SIGFPE,
//    SIGILL,
//    SIGSEGV,
//    SIGTRAP,
//    SIGTERM,
//    SIGHUP,
//    SIGINT,
//    SIGQUIT,
//    SIGFPE,
//    SIGPIPE
//};

//+(VPUPCrashManager *)shareInstance {
//    
//    static VPUPCrashManager *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[VPUPCrashManager alloc] init];
//    });
//    return instance;
//}

/*
 1.OC层面。
 2.C++ 层面。
 */
+ (void)initVPUPCrashManagerHandler {
    
    //signal捕获暂时有问题
    
    //捕获C++层面的异常(野指针、除零、内存访问异常等) 的错误
//    NSInteger count = sizeof(signals)/sizeof(signals[0]);
//    for (int i = 0; i < count; i++) {
//        signal(signals[i], VPUPSignalHandler);
//        
//    }
    
    /*
     HandleException 函数指针。如果获取系统的异常捕获句柄不是当前自定义的函数句柄，需要先进行保存。再捕获结束之后重新还原。
     */
    NSUncaughtExceptionHandler *handle = NSGetUncaughtExceptionHandler();
    if(handle != VPUPHandleException) {
        //说明当前APP已经被注册过“未捕获异常句柄事件”。
        _previousHandle = handle;
    }
    //注册。我自己的定义的函数指针。
    NSSetUncaughtExceptionHandler(&VPUPHandleException);
}

// 处理信号类错误的回调函数
void VPUPSignalHandler(int signal)
{
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"信号类错误日志:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [mstr appendFormat:@"%s\n", strs[i]];
    }
    //1.写入本地文件中保存
    //add report
    
    [VPUPReport addReportByLevel:VPUPReportLevelError reportClass:[VPUPCrashManager class] message:mstr];
    
//    if(_previousHandle) {
//        NSSetUncaughtExceptionHandler(_previousHandle);
//    }
}

//OC层面的异常捕获信息。
void VPUPHandleException(NSException *exception)
{
    if (!exception){
        return;
    }
    
    NSArray *stackArray = [exception callStackSymbols];   // 异常的堆栈信息
    NSString *reason = [exception reason];                // 出现异常的原因
    NSString *name = [exception name];                    // 异常名称
    
    NSString *syserror = [NSString stringWithFormat:@"\nOC层面的异常错误日志:\n异常信息:\n异常名称:%@\n异常原因:%@\n异常的堆栈信息:%@\n",name,reason,stackArray];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:syserror forKey:@"syserror"];
    
    //1.写入本地文件中保存
    //add report
    [VPUPReport addReportByLevel:VPUPReportLevelError reportClass:[VPUPCrashManager class] message:syserror];
    
//    if(_previousHandle) {
        NSSetUncaughtExceptionHandler(_previousHandle);
//    }
}

@end
