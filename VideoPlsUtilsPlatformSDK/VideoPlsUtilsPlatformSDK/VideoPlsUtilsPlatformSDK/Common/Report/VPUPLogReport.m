//
//  VPUPLogReport.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPLogReport.h"
#import "VPUPReportLogMessage.h"
#import "VPUPServerUTCDate.h"
#import "VPUPJsonUtil.h"
#import "VPUPNotificationCenter.h"
#import "VPUPDebugSwitch.h"
#import "VPUPDBSQLString.h"

@implementation VPUPLogReport {
    BOOL _enableLog;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.minRequireSendCount = 0;
        self.maxLimitCount = NSUIntegerMax;
        _reportEnable = VPUPReportEnableLog;
        _canInsertData = YES;
    }
    return self;
}

- (NSString *)reportTableName {
    return @"ReportLog";
}

- (dispatch_queue_t)reportQueue {
    if(!_reportQueue) {
        _reportQueue = dispatch_queue_create("com.videopls.utilsplatform.report.log", DISPATCH_QUEUE_SERIAL);
    }
    return _reportQueue;
}

- (void)startReport {
    dispatch_async(_reportQueue, ^{
        if(!_enableLog) {
            _enableLog = YES;
            [self removeAllReportLogData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLogListenerNotification];
            });
        }
    });
}

- (void)stopReport {
    dispatch_async(_reportQueue, ^{
        if(_enableLog) {
            _enableLog = NO;
            [self removeAllReportLogData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeLogListenerNotification];
            });
        }
    });
}

- (VPUPReportMessage *)buildReportMessageWith:(VPUPReportLevel)level
                                  reportClass:(NSString *)reportClassString
                                      message:(NSString *)message {
    
    return [VPUPReportLogMessage reportMessageWith:level
                                       reportClass:reportClassString
                                           message:message];
}

- (void)addReportMessage:(VPUPReportMessage *)message {
    if(message.level != VPUPReportLevelLog) {
        return;
    }
    
    [super addReportMessage:message];
}

- (void)checkNeedSendReportByReportLevel:(VPUPReportLevel)reportLevel {
    return;
}

- (void)removeAlreadySentReportData:(NSArray *)reportIDs {
    return;
}

- (void)removeAllReportLogData {
//    VPUPDBSQLString *removeSql = [[VPUPDBSQLString alloc] initWithSqlString:[NSString stringWithFormat:@"DELETE FROM %@", [self reportTableName]] arguments:nil];
    VPUPDBSQLString *removeSql = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:[self reportTableName] whereKeys:nil whereValues:nil];
    
    [self deleteReportDataBySql:removeSql];
}

- (NSArray *)assembleMessages:(NSArray *)messages {
    NSMutableString *singleMessage = [[NSMutableString alloc] init];
    [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [singleMessage appendString:obj];
    }];
    
    //重新组成一条reportMessage
    VPUPReportMessage *message = [VPUPReportMessage reportMessageWith:VPUPReportLevelLog
                                                          reportClass:NSStringFromClass([self class])
                                                              message:singleMessage];
    
    NSString *json = [message.jsonValue copy];
    
    return @[json];
}

- (void)delayNextRequest {
    _isRequesting = NO;
}

- (void)changeReportEnable:(NSInteger)enableLevel {
    
    return;
}


- (void)postLogReport {
    //提出所有LogReport并发送
    dispatch_async(_reportQueue, ^{
        [self checkReportDataNeedForceSend:YES ignoreCount:YES];
    });
}


#pragma mark Notification
- (void)addLogListenerNotification {
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(postLogReport) name:VPUPDebugPanelPostReportLogNotification object:nil];
}

- (void)removeLogListenerNotification {
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPDebugPanelPostReportLogNotification object:nil];
}

@end
