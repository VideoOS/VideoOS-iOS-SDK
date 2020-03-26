//
//  VPUPBaseReport.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPReportEnum.h"
#import "VPUPHTTPAPIManager.h"

@class VPUPDatabaseManager;
@class VPUPReportMessage;

@interface VPUPBaseReport : NSObject {
//    NSMutableArray *_sendReportIDs;
    dispatch_queue_t _reportQueue;
    id<VPUPHTTPAPIManager> _httpManager;
    
    VPUPReportEnable _reportEnable;
    
    BOOL _isRequesting;
    BOOL _canInsertData;
}

+ (void)createReportTableByCompleteQueue:(dispatch_queue_t)completeQueue
                           completeBlock:(void (^)(BOOL success, BOOL isNew))completeBlock;


@property (nonatomic, weak, readonly) VPUPDatabaseManager *database;

@property (nonatomic, readonly) NSString *reportTableName;
@property (nonatomic, readonly) dispatch_queue_t reportQueue;
@property (nonatomic, readonly) id<VPUPHTTPAPIManager> httpManager;
@property (nonatomic, readonly) BOOL reportEnable;
@property (nonatomic, readonly) BOOL isRequesting;
@property (nonatomic, readonly) BOOL canInsertData;
@property (nonatomic) NSUInteger minRequireSendCount;       //default is 5
@property (nonatomic) NSUInteger maxLimitCount;             //default is 100


- (void)startReport;
- (void)stopReport;

- (void)addReportByLevel:(VPUPReportLevel)reportLevel
             reportClass:(Class)reportClass
                 message:(NSString *)message;

- (void)addReportMessage:(VPUPReportMessage *)message;

- (VPUPReportMessage *)buildReportMessageWith:(VPUPReportLevel)level
                                  reportClass:(NSString *)reportClassString
                                      message:(NSString *)message;

- (void)checkReportDataNeedForceSend:(BOOL)needSend ignoreCount:(BOOL)ignoreCount;

- (void)checkNeedSendReportByReportLevel:(VPUPReportLevel)reportLevel;

- (void)deleteReportDataBySql:(id)sql;

@end
