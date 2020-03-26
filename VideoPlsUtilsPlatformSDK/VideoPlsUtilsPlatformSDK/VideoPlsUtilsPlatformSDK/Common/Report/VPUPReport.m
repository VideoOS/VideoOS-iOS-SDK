//
//  VPUPReport.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/15.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPReport.h"
#import "VPUPReportMessage.h"
#import "VPUPHTTPNetworking.h"
#import "VPUPLogUtil.h"
#import "VPUPCrashManager.h"
#import "VPUPGeneralInfo.h"
#import "VPUPNotificationCenter.h"

#import "VPUPBaseReport.h"
#import "VPUPBusinessReport.h"
#import "VPUPLogReport.h"
#import "VPUPHTTPBusinessAPI.h"

#import "VPUPLifeCycle.h"
#import "VPUPDebugSwitch.h"


static VPUPReport *sharedReport = nil;

static dispatch_queue_t reportQueue() {
    static dispatch_queue_t reportQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reportQueue = dispatch_queue_create("com.videopls.utilsplatform.report", DISPATCH_QUEUE_SERIAL);
    });
    return reportQueue;
}

@implementation VPUPReport {
    BOOL _lifeCycleDidStart;
    BOOL _videoDidStart;
    VPUPBusinessReport  *_businessReport;
    VPUPLogReport       *_logReport;
}

+ (VPUPReport *)sharedReport {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedReport = [[self alloc] init];
    });
    return sharedReport;
}

- (instancetype)init {
    if(!sharedReport) {
        sharedReport = [super init];
        [sharedReport initReport];
    }
    return sharedReport;
}

- (void)initReport {
    [self registerLifeCycleNotification];
    
    //添加crash收集
    [VPUPCrashManager initVPUPCrashManagerHandler];
    
    dispatch_async(reportQueue(), ^{
        [VPUPBaseReport createReportTableByCompleteQueue:reportQueue()
                                           completeBlock:nil];
       //放在createTable之后
//        [self checkReportDataNeedForceSend:YES];
        
        self->_businessReport = [[VPUPBusinessReport alloc] init];
        self->_logReport = [[VPUPLogReport alloc] init];
        
        [self->_businessReport startReport];
    });
    
}


+ (void)addImageWarningReportByReportClass:(Class)reportClass
                                     error:(NSError *)error
                                       url:(NSString *)url {
    
    NSString *assembledMessage = [NSString stringWithFormat:@"[image load failed], url:%@, msg:%@", url, error];
    
    [self addReportByLevel:VPUPReportLevelWarning
               reportClass:reportClass
                   message:assembledMessage];
}

+ (void)addHTTPWarningReportByReportClass:(Class)reportClass
                                    error:(NSError *)error
                                      api:(VPUPHTTPBusinessAPI *)api {
    NSString *urlString = nil;
    if([api customRequestUrl]) {
        urlString = [api customRequestUrl];
    }
    else {
        NSURL *url = [NSURL URLWithString:[api requestMethod] ? : @""
                        relativeToURL:[NSURL URLWithString:[api baseUrl]]];
        
        urlString = url.absoluteString;
    }
    
    NSString *assembledMessage = [NSString stringWithFormat:@"[HTTP response incorrect], url:%@, msg:%@", urlString, error];

    [self addReportByLevel:VPUPReportLevelWarning
               reportClass:reportClass
                   message:assembledMessage];
}

+ (void)addHTTPErrorReportByReportClass:(Class)reportClass
                                  error:(NSError *)error
                                    api:(VPUPHTTPBusinessAPI *)api {
    NSString *urlString = nil;
    if([api customRequestUrl]) {
        urlString = [api customRequestUrl];
    }
    else {
        NSURL *url = [NSURL URLWithString:[api requestMethod] ? : @""
                            relativeToURL:[NSURL URLWithString:[api baseUrl]]];
        
        urlString = url.absoluteString;
    }
    
    NSString *assembledMessage = [NSString stringWithFormat:@"[HTTP request failed], url:%@, msg:%@", urlString, error];
    
    [self addReportByLevel:VPUPReportLevelWarning
               reportClass:reportClass
                   message:assembledMessage];
}

+ (void)addDownloadWarningReportByReportClass:(Class)reportClass
                                        error:(NSError *)error
                                          url:(NSString *)url {
    NSString *assembledMessage = [NSString stringWithFormat:@"[file download failed], url:%@, msg:%@", url, error];
    
    [self addReportByLevel:VPUPReportLevelWarning
               reportClass:reportClass
                   message:assembledMessage];
}

//添加一条下载成功但md5错误report
+ (void)addMD5WarningReportByReportClass:(Class)reportClass
                                   error:(NSError *)error
                                     url:(NSString *)url {
    NSString *assembledMessage = [NSString stringWithFormat:@"[file md5 failed], url:%@, msg:%@", url, error];
    
    [self addReportByLevel:VPUPReportLevelWarning
               reportClass:reportClass
                   message:assembledMessage];
}


+ (void)addReportByLevel:(VPUPReportLevel)reportLevel
             reportClass:(Class)reportClass
                 message:(NSString *)message {
    
    NSParameterAssert(reportClass);
    NSParameterAssert(message);
    
    if(reportLevel > 2 || !reportClass || !message) {
        VPUPLogW(@"could not add Log Report through Report");
        return;
    }
    
    if(!sharedReport) {
        [VPUPReport sharedReport];
        [VPUPReport addReportByLevel:reportLevel reportClass:reportClass message:message];
        return;
    }
    
//    if(!sharedReport->_lifeCycleDidStart) {
//        return;
//    }
    
    //非log点
    if(sharedReport->_businessReport) {
        [sharedReport->_businessReport addReportByLevel:reportLevel reportClass:reportClass message:message];
    }
    
//    if(reportLevel < VPUPReportLevelLog) {
//        [sharedReport->_businessReport addReportByLevel:reportLevel reportClass:reportClass message:message];
//    }
//    else {
//        if(!sharedReport->_videoDidStart) {
//            return;
//        }
//        
//        [sharedReport->_logReport addReportByLevel:reportLevel reportClass:reportClass message:message];
//    }
    
    return;
}

#pragma mark Notification
- (void)registerLifeCycleNotification {
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(lifeCycleStart) name:VPUPLifeCycleStartNotification object:nil];
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(lifeCycleStop) name:VPUPLifeCycleStopNotification object:nil];
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStart) name:VPUPVideoStartNotification object:nil];
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStop) name:VPUPVideoStopNotification object:nil];
    
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUseSDKInfo) name:VPUPGeneralInfoSDKChangedNotification object:nil];
}

- (void)removeLifeCycleNotification {
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPLifeCycleStartNotification object:nil];
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPLifeCycleStopNotification object:nil];
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPVideoStartNotification object:nil];
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPVideoStopNotification object:nil];
    
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPGeneralInfoSDKChangedNotification object:nil];
}

- (void)lifeCycleStart {
    if(!_lifeCycleDidStart) {
        _lifeCycleDidStart = YES;
        [_businessReport startReport];
    }
}

- (void)lifeCycleStop {
    if(_lifeCycleDidStart) {
        if(_videoDidStart) {
            [self videoStop];
        }
        _lifeCycleDidStart = NO;
        [_businessReport stopReport];
    }
}

- (void)videoStart {
    if(_lifeCycleDidStart) {
        if(!_videoDidStart) {
            _videoDidStart = YES;
            [_logReport startReport];
            [self registerLogReportNotification];
        }
    }
}

- (void)videoStop {
    if(_lifeCycleDidStart) {
        if(_videoDidStart) {
            _videoDidStart = NO;
            [_logReport stopReport];
            [self removeLogReportNotification];
        }
    }
}

- (void)changeUseSDKInfo {
    if(_businessReport.reportQueue) {
        dispatch_async(_businessReport.reportQueue, ^{
            [_businessReport outsideChangeCanInsert:YES];
        });
    }
}

- (void)registerLogReportNotification {
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(addLogReport:) name:VPUPLogAddReportNotification object:nil];
}

- (void)removeLogReportNotification {
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPLogAddReportNotification object:nil];
}

- (void)addLogReport:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    Class reportClass = [userInfo objectForKey:@"reportClass"];
    NSString *message = [userInfo objectForKey:@"message"];
    
    [_logReport addReportByLevel:VPUPReportLevelLog reportClass:reportClass message:message];
}

- (void)dealloc {
    [self removeLifeCycleNotification];
}

@end
