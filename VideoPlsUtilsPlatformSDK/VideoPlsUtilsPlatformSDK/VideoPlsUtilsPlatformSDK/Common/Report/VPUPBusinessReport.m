//
//  VPUPBusinessReport.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPBusinessReport.h"
#import "VPUPGeneralInfo.h"
#import "VPUPReportMessage.h"

@implementation VPUPBusinessReport {
    NSTimer *_reportTimer;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        //发送残留数据
        [self checkReportDataNeedForceSend:NO ignoreCount:YES];
    }
    return self;
}

// table name use super "ReportVideoNet"
//- (NSString *)reportTableName {
//    return [NSString stringWithFormat:@"Report%@",[VPUPGeneralInfo mainVPSDKName]];
//}

- (dispatch_queue_t)reportQueue {
    if(!_reportQueue) {
        _reportQueue = dispatch_queue_create("com.videopls.utilsplatform.report.business", DISPATCH_QUEUE_SERIAL);
    }
    return _reportQueue;
}

- (void)addReportMessage:(VPUPReportMessage *)message {
    if(message.level == VPUPReportLevelLog) {
        return;
    }
    
    [super addReportMessage:message];
}

- (void)startReport {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self->_reportTimer) {
            self->_reportTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 10 target:self selector:@selector(checkReportDataFromTimer) userInfo:nil repeats:YES];
        }
//        [self checkReportDataFromTimer];
    });
}

- (void)stopReport {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_reportTimer invalidate];
        self->_reportTimer = nil;
    });
}

- (void)checkReportDataFromTimer {
    dispatch_async(_reportQueue, ^{
        [self checkReportDataNeedForceSend:NO ignoreCount:YES];
    });
}

- (void)outsideChangeCanInsert:(BOOL)canInsert {
    _canInsertData = canInsert;
}

@end
