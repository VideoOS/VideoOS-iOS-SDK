//
//  VPUPDatabaseManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/7/18.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VPUPDatabase;
@class VPUPDBSQLString;

@interface VPUPDatabaseManager : NSObject {
    NSString *          _path;
    VPUPDatabase *      _db;
    dispatch_queue_t    _queue;
    void *              _queueKey;
}

@property (nonatomic, readonly) NSString *databasePath;

+ (instancetype)databaseManagerWithPath:(NSString *)path;
- (void)close;

#pragma mark special use
- (void)inDatabase:(void (^)(VPUPDatabase *db))block;
- (void)inTransaction:(void (^)(VPUPDatabase *db, BOOL *rollback))block;
- (void)inDeferredTransaction:(void (^)(VPUPDatabase *db, BOOL *rollback))block;

#pragma mark normal use
- (void)executeUpdateSql:(VPUPDBSQLString *)sql
           completeQueue:(dispatch_queue_t)completeQueue
           completeBlock:(void(^)(BOOL success))completeBlock;
- (void)executeUpdateSqls:(NSArray<VPUPDBSQLString *> *)sqls
            completeQueue:(dispatch_queue_t)completeQueue
            completeBlock:(void(^)(BOOL success))completeBlock;
- (void)executeQuerySql:(VPUPDBSQLString *)sql
           completeQueue:(dispatch_queue_t)completeQueue
           completeBlock:(void(^)(NSArray *selectObject))completeBlock;


- (void)getDatabaseVersionByCompleteQueue:(dispatch_queue_t)completeQueue
                            completeBlock:(void(^)(BOOL success, NSUInteger version))completeBlock;

- (void)setDatabaseVersion:(NSUInteger)version
             completeQueue:(dispatch_queue_t)completeQueue
             completeBlock:(void(^)(BOOL success))completeBlock;

@end
