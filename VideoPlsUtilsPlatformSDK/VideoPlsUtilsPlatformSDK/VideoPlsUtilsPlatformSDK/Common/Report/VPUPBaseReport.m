//
//  VPUPBaseReport.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPBaseReport.h"
#import "VPUPHTTPNetworking.h"
#import "VPUPReportMessage.h"
#import "VPUPGeneralInfo.h"
#import "VPUPEncryption.h"
#import "VPUPCommonEncryption.h"
#import "VPUPUtils.h"
#import "VPUPDebugSwitch.h"
#import "VPUPJsonUtil.h"
#import "VPUPDBHeader.h"


static VPUPDatabaseManager* databaseManager() {
    static VPUPDatabaseManager* databaseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不需要移除旧的
//        //移除旧的
//        NSString *oldPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
//
//        oldPath = [oldPath stringByAppendingPathComponent:@"com.videopls.UtilsPlatform"];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:oldPath]) {
//            [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
//        }
        
        NSString *path = [VPUPPathUtil reportPath];
        
        path = [path stringByAppendingPathComponent:@"VideoPlsReportDB.sqlite"];
        databaseManager = [VPUPDatabaseManager databaseManagerWithPath:path];
    });
    return databaseManager;
}

@interface VPUPBaseReport()

@property (nonatomic, assign) NSUInteger overflowCount;
@property (nonatomic, assign) BOOL forceDelete;

@end

@implementation VPUPBaseReport

+ (void)createReportTableByCompleteQueue:(dispatch_queue_t)completeQueue
                           completeBlock:(void (^)(BOOL success, BOOL isNew))completeBlock {
    
//    VPUPDBSQLString *checkTable = [[VPUPDBSQLString alloc] initWithSqlString:@"select count(*) as 'count' from sqlite_master where type ='table' and name LIKE ?" arguments:@[@"Report%"]];
    VPUPDBSQLString *checkTableSql = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"sqlite_master" columNames:@[@"count"] values:@[@"count(*)"] whereKeys:@[@"type", @"name"] whereValues:@[@"table", @"Report%"] orderBy:nil sort:0];
    
    //backdata [{count:0}]
    [databaseManager() executeQuerySql:checkTableSql completeQueue:completeQueue completeBlock:^(NSArray *selectObject) {
        // 只有2张表，videoNet和Log
        if([selectObject firstObject] && [[[selectObject firstObject] objectForKey:@"count"] integerValue] >= 2) {
            //有表了,把里面数据发送出去,没表也没有必要发送了
            
            if(completeBlock) {
                completeBlock(YES, NO);
            }
            
        }
        else {
            //创建表
            NSMutableArray *createTableSqls = [NSMutableArray array];
            NSArray *tableNames = @[@"ReportIoV", @"ReportLog"];
            for(NSString* tableName in tableNames) {
//                VPUPDBSQLString *createTable = [[VPUPDBSQLString alloc] initWithSqlString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (reportID Varchar(32) DEFAULT NULL, message TEXT, level Varchar(2) DEFAULT NULL, PRIMARY KEY(reportID))", tableName] arguments:nil];
                VPUPDBSQLString *createTable = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:tableName columNames:@[@"reportID", @"message", @"level"] columTypes:@[@"Varchar(32)", @"TEXT", @"int"] primaryKeys:@[@"reportID"]];
                
                [createTableSqls addObject:createTable];
            }
            
            [databaseManager() executeUpdateSqls:createTableSqls completeQueue:completeQueue completeBlock:^(BOOL success) {
                if(completeBlock) {
                    completeBlock(success, YES);
                }
            }];
        }
    }];
}

+ (void)checkReportDatabaseVersionByCompleteQueue:(dispatch_queue_t)completeQueue
                                    completeBlock:(void (^)(BOOL success, BOOL isNew))completeBlock {
    
    [databaseManager() getDatabaseVersionByCompleteQueue:completeQueue completeBlock:^(BOOL success, NSUInteger version) {
        if(version <= 0 || version == NSUIntegerMax) {
            //重新建库,暂时不需要对版本做处理
            
            
        }
    }];
    
}

+ (void)setReportDatabaseVersion:(NSUInteger)version
                   completeQueue:(dispatch_queue_t)completeQueue
                   completeBlock:(void (^)(BOOL success, BOOL isNew))completeBlock {
    [databaseManager() setDatabaseVersion:version completeQueue:completeQueue completeBlock:^(BOOL success) {
        
        
    }];
}







- (instancetype)init {
    self = [super init];
    if(self) {
        _database = databaseManager();
        _minRequireSendCount = 5;
        _maxLimitCount = 100;
        _reportEnable = VPUPReportEnableInfo | VPUPReportEnableWarning | VPUPReportEnableError;
        _canInsertData = YES;
        _overflowCount = 0;
        _forceDelete = NO;
        [self httpManager];
        [self reportQueue];
    }
    return self;
}

- (NSString *)reportTableName {
    return @"ReportIoV";
}

- (dispatch_queue_t)reportQueue {
    if(!_reportQueue) {
        _reportQueue = dispatch_queue_create("com.videopls.utilsplatform.report", DISPATCH_QUEUE_SERIAL);
    }
    return _reportQueue;
}

- (id<VPUPHTTPAPIManager>)httpManager {
    if(!_httpManager) {
        _httpManager = [VPUPHTTPManagerFactory createHTTPAPIManagerWithType:VPUPHTTPManagerTypeAFN];
    }
    return _httpManager;
}

- (BOOL)reportEnable {
    return _reportEnable;
}

- (BOOL)isRequesting {
    return _isRequesting;
}

- (BOOL)canInsertData {
    return _canInsertData;
}


- (void)startReport {
    
}

- (void)stopReport {
    
}

- (void)addReportByLevel:(VPUPReportLevel)reportLevel
             reportClass:(Class)reportClass
                 message:(NSString *)message {
    
    NSParameterAssert(reportClass);
    NSParameterAssert(message);
    
    if(reportLevel > 3 || !reportClass || !message) {
        return;
    }
    dispatch_async(_reportQueue, ^{
        
        VPUPReportMessage *reportMessage = [self buildReportMessageWith:reportLevel
                                                            reportClass:NSStringFromClass(reportClass)
                                                                message:message];
        
        
        //        VPUPLog(@"report:ID:%@\nmsg:%@", reportMessage.uniqueReportID, reportMessage.jsonValue);
        
        //通过按位与之后得到该项是否开启,然后向右移对应位得到1或者0  例如: reportEnable    (1011B & 0010B(1 << 1)) >> 1 = 0010B >> 1 = 1
        if(!((self->_reportEnable & (1 << reportLevel)) >> reportLevel)) {
            //无需打点
            return;
        }
        
        [self addReportMessage:reportMessage];
        
    });
    
    return;
}

- (VPUPReportMessage *)buildReportMessageWith:(VPUPReportLevel)level
                                  reportClass:(NSString *)reportClassString
                                      message:(NSString *)message {
    
    return [VPUPReportMessage reportMessageWith:level
                                    reportClass:reportClassString
                                        message:message];
}

- (void)checkNeedSendReportByReportLevel:(VPUPReportLevel)reportLevel {
    if(reportLevel == VPUPReportLevelError) {
        [self checkReportDataNeedForceSend:YES ignoreCount:YES];
    }
    else {
        [self checkReportDataNeedForceSend:NO ignoreCount:NO];
    }
}

- (void)addReportMessage:(VPUPReportMessage *)message {
    //能否插入与log没有关系
    if(_canInsertData) {
        NSString *currentTableName = [self reportTableName];
        
        __weak typeof(self) weakSelf = self;
        VPUPReportLevel level = message.level;
//        VPUPDBSQLString *insertData = [[VPUPDBSQLString alloc] initWithSqlString:[NSString stringWithFormat:@"INSERT INTO %@ (reportID, message, level) VALUES(?, ?, ?)", currentTableName] arguments:@[message.uniqueReportID, message.jsonValue, [NSString stringWithFormat:@"%lu", (unsigned long)message.level]]];
        
        VPUPDBSQLString *insertData = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:currentTableName columNames:@[@"reportID", @"message", @"level"] values:@[message.uniqueReportID, message.jsonValue, @(message.level)]];
        
        [databaseManager() executeUpdateSql:insertData completeQueue:_reportQueue completeBlock:^(BOOL success) {
            [weakSelf checkNeedSendReportByReportLevel:level];
        }];
        
    } else {
        //大于上限了，直接检查发送
        [self checkNeedSendReportByReportLevel:message.level];
    }
}

- (void)removeReportDataByIDs:(NSArray *)reportIDs {
    NSMutableArray *removeSqls = [NSMutableArray array];
    
    for(NSString* reportID in reportIDs) {
//        VPUPDBSQLString *removeData = [[VPUPDBSQLString alloc] initWithSqlString:[NSString stringWithFormat:@"DELETE FROM %@ WHERE reportID = ?", [self reportTableName]] arguments:@[reportID]];
        VPUPDBSQLString *removeData = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:[self reportTableName] whereKeys:@[@"reportID"] whereValues:@[reportID]];
        [removeSqls addObject:removeData];
    }
    
    [self deleteReportDataBySql:removeSqls];
}

- (void)deleteReportDataBySql:(id)sql {
    __weak typeof(self) weakSelf = self;
    if([sql isKindOfClass:[VPUPDBSQLString class]]) {
        [databaseManager() executeUpdateSql:sql completeQueue:_reportQueue completeBlock:^(BOOL success) {
            [weakSelf deleteReportDataSucceed:success];
        }];
    }
    if([sql isKindOfClass:[NSArray class]]) {
        [databaseManager() executeUpdateSqls:sql completeQueue:_reportQueue completeBlock:^(BOOL success) {
            [weakSelf deleteReportDataSucceed:success];
        }];
    }
}

- (void)deleteReportDataSucceed:(BOOL)success {
    if(success) {
        _canInsertData = YES;
        _forceDelete = NO;
        _overflowCount = 0;
    }
}

- (void)deleteReportDataByReportIDs:(NSArray *)reportIDs FromTable:(NSString *)tableName {
    
    NSMutableArray *removeSqls = [NSMutableArray array];
    
    for(NSString* reportID in reportIDs) {
//        VPUPDBSQLString *removeData = [[VPUPDBSQLString alloc] initWithSqlString:[NSString stringWithFormat:@"DELETE FROM %@ WHERE reportID = ?", tableName] arguments:@[reportID]];
        VPUPDBSQLString *removeData = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:tableName whereKeys:@[@"reportID"] whereValues:@[reportID]];
        [removeSqls addObject:removeData];
    }
    
    [databaseManager() executeUpdateSqls:removeSqls completeQueue:_reportQueue completeBlock:^(BOOL success) {
        //不管是否正确
//        [_sendReportIDs removeAllObjects];
        if(success) {
            _canInsertData = YES;
        }
    }];
}

- (void)checkReportDataNeedForceSend:(BOOL)needSend ignoreCount:(BOOL)ignoreCount {
    //Log需要set NeedSend为YES
    if(needSend && _isRequesting) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), _reportQueue, ^{
            [self checkReportDataNeedForceSend:needSend ignoreCount:ignoreCount];
        });
        return;
    }
    if(_isRequesting) {
        return;
    }
    
    _isRequesting = YES;
    
    NSString *currentTableName = [self reportTableName];
    __weak typeof(self) weakSelf = self;
    
//    VPUPDBSQLString *checkTableSum = [[VPUPDBSQLString alloc] initWithSqlString:[NSString stringWithFormat:@"select count(*) as 'count' from %@",currentTableName] arguments:nil];
    VPUPDBSQLString *checkTableSum = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:currentTableName columNames:@[@"count"] values:@[@"count(*)"] whereKeys:nil whereValues:nil orderBy:nil sort:0];
    
    //backdata [{count:0}]
    [databaseManager() executeQuerySql:checkTableSum completeQueue:_reportQueue completeBlock:^(NSArray *selectObject) {
        if([selectObject firstObject] && [[[selectObject firstObject] objectForKey:@"count"] integerValue] > 0) {
            //有数据,总数大于5或者需要发送
            NSInteger count = [[[selectObject firstObject] objectForKey:@"count"] integerValue];
            
            [weakSelf checkReportCount:count ignoreCount:ignoreCount];
            
        }
        else {
            _isRequesting = NO;
        }
    }];
}

- (void)checkReportCount:(NSInteger)count ignoreCount:(BOOL)ignoreCount {
    
    if(ignoreCount || count >= _minRequireSendCount) {
        if(count > _maxLimitCount) {
            _overflowCount++;
            _canInsertData = NO;
        }
        else {
            _overflowCount = 0;
            _canInsertData = YES;
        }
        
        if (_overflowCount >= 3) {
            //3次强制删除非error日志，如果全是error则全部删除
            _forceDelete = YES;
        }
        [self extractAllReportDataAndSend];
        
    }
    else {
        _isRequesting = NO;
    }
}

- (void)extractAllReportDataAndSend {
//    VPUPDBSQLString *reportData = [[VPUPDBSQLString alloc] initWithSqlString:[NSString stringWithFormat:@"select * from %@",[self reportTableName]] arguments:nil];
    
     VPUPDBSQLString *reportData = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:[self reportTableName] columNames:@[@"reportID", @"message", @"level"] values:nil whereKeys:nil whereValues:nil orderBy:nil sort:0];
    
    [databaseManager() executeQuerySql:reportData completeQueue:_reportQueue completeBlock:^(NSArray *selectObject) {
        [self sendHTTPReport:selectObject];
    }];
}

- (void)sendHTTPReport:(NSArray *)reportArray {
    if(!reportArray || [reportArray count] == 0) {
        return;
    }
    //format: [{reportID:xx,message:xx,level:xx}]
    
    __block NSMutableArray *reportIDs = [NSMutableArray array];
    __block NSMutableArray *forceDeleteReportIDs = [NSMutableArray array];
    NSMutableArray *messages = [NSMutableArray array];
    
    for(NSDictionary *reportDict in reportArray) {
        NSString *reportID = [reportDict objectForKey:@"reportID"];
        NSString *message = [reportDict objectForKey:@"message"];
        //取出level并统计非error的id，用作强制删除
        VPUPReportLevel level = [[reportDict objectForKey:@"level"] unsignedIntValue];

        if(VPUP_IsExist(reportID)) {
            if(![reportIDs containsObject:reportID]) {
                [reportIDs addObject:reportID];
                if (level < VPUPReportLevelError) {
                    [forceDeleteReportIDs addObject:reportID];
                }
            }
        }
        if(VPUP_IsExist(message)) {
            if(![messages containsObject:message]) {
                [messages addObject:message];
            }
        }
    }
    
    if ([reportIDs count] >= _maxLimitCount && [forceDeleteReportIDs count] == 0) {
        //全是error数据，如果需要强制删除也强制删除
        forceDeleteReportIDs = reportIDs;
    }
    
    NSArray *assembleMessages = [self assembleMessages:messages];
    
    NSString *json = VPUP_StringArrayToJson(assembleMessages);
    NSString *gzipJson = VPUP_GZIPCompressBase64String(json);
    NSString *aesString = [VPUPCommonEncryption aesEncryptString:gzipJson];
    
    if(!aesString) {
        //加密有误
        VPUPLog(@"加密有误,aesString为空");
        //可能需要删除所有记录保证之后正常运行
        _isRequesting = NO;
        [self removeReportDataByIDs:reportIDs];
        return;
    }
    
    //TODO: 日志api路径待定
    VPUPHTTPBusinessAPI *businessAPI = [[VPUPHTTPBusinessAPI alloc] init];
    __weak typeof(businessAPI) weakApi = businessAPI;
    businessAPI.baseUrl = [NSString stringWithFormat:@"%@/%@", @"https://os-saas.videojj.com/os-report-log", @"api/log"];
    
    [businessAPI setApiRequestMethodType:VPUPRequestMethodTypePOST];
    [businessAPI setRequestParameters:@{@"info":aesString}];
    [businessAPI setCallbackQueue:_reportQueue];
    
    
    __weak typeof(self) weakSelf = self;
    
    [businessAPI setApiCompletionHandler:^(id _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        [weakSelf delayNextRequest];
        
        if (error) {
            [VPUPReport addHTTPErrorReportByReportClass:[weakSelf class] error:error api:weakApi];
            if (weakSelf.forceDelete) {
                [weakSelf removeReportDataByIDs:forceDeleteReportIDs];
                [VPUPReport addReportByLevel:VPUPReportLevelWarning reportClass:[weakSelf class] message:@"Report database overflow, delete not error report log"];
            }
            return;
        }
        
        NSString *status = nil;
        NSInteger enableLevel = 0;
        
        if([responseObject objectForKey:@"status"]) {
            status = [responseObject objectForKey:@"status"];
        }
        
        if([responseObject objectForKey:@"data"]) {
            if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSNumber class]]) {
                enableLevel = [[responseObject objectForKey:@"data"] integerValue];
                [weakSelf changeReportEnable:enableLevel];
            }
            
        }
        
        
        if(!status || ![status isEqualToString:@"0000"]) {
            //发送失败或有误,只移除id队列
            NSString *errorMessage = @"Status is not 0000";
            if([responseObject objectForKey:@"msg"]) {
                errorMessage = [responseObject objectForKey:@"msg"];
            }
            NSError *error = [[NSError alloc] initWithDomain:@"com.videopls.VPUPBaseReport" code:1001 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            [VPUPReport addHTTPWarningReportByReportClass:[weakSelf class] error:error api:weakApi];
            //如果3次大于100条数据无法插入数据，则强制删除非error数据；全是error数据时也删除
            if (weakSelf.forceDelete) {
                [weakSelf removeReportDataByIDs:forceDeleteReportIDs];
                [VPUPReport addReportByLevel:VPUPReportLevelWarning reportClass:[weakSelf class] message:@"Report database overflow, delete not error report log"];
            }
        }
        else {
            //日志无需移除
            [weakSelf removeReportDataByIDs:reportIDs];
        }
    }];
    
    [_httpManager sendAPIRequest:businessAPI];
}

- (NSArray *)assembleMessages:(NSArray *)messages {
    return messages;
}

- (void)delayNextRequest {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), _reportQueue, ^{
        //下一次请求至少在5s之后才能发送
        _isRequesting = NO;
    });
}

- (void)changeReportEnable:(NSInteger)enableLevel {
    if(enableLevel > 7) {
        //数字有异常,过滤出需要的3位
        enableLevel &= 7;
    }
    _reportEnable = enableLevel;
}


@end
