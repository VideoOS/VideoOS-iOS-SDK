//
//  VPUPDatabaseManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/7/18.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPDatabaseManager.h"
#import "VPUPDatabase.h"
#import "VPUPDBSQLString.h"
#import "VPUPLogUtil.h"

@implementation VPUPDatabaseManager

+ (instancetype)databaseManagerWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    NSAssert(path, @"database path could not be nil");
    self = [super init];
    if(self) {
        _db = [VPUPDatabase databaseWithPath:path];
        _path = [path copy];
        
        BOOL success = [_db open];
        
        if(!success) {
            VPUPLogWR(@"Could not create database queue for path %@", path);
            return nil;
        }
        
        NSString *key = [NSString stringWithFormat:@"com.videopls.utilsplatform.db.%@", self];
        _queueKey = (void *)[key UTF8String];
        
        _queue = dispatch_queue_create([key UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_queue, _queueKey, (__bridge void *)self, NULL);
    }
    return self;
}

- (void)dealloc {
    if([_db databaseExists]) {
        [_db close];
    }
    _db = nil;
    _queue = nil;
}

- (void)close {
    dispatch_async(_queue, ^{
        [self->_db close];
        self->_db = nil;
    });
}

- (VPUPDatabase *)database {
    if(!_db) {
        _db = [VPUPDatabase databaseWithPath:_path];
    }
    BOOL success = [_db open];
    if(!success) {
        VPUPLogWR(@"Could not create database queue for path %@", _path);
        _db = nil;
        return nil;
    }
    
    return _db;
}

- (NSString *)databasePath {
    return _path;
}

- (void)inDatabase:(void (^)(VPUPDatabase *))block {
    VPUPDatabaseManager *currentManager = (__bridge id)dispatch_get_specific(self->_queueKey);
    assert(currentManager != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");
    
    dispatch_async(_queue, ^{
        VPUPDatabase *db = [self database];
        block(db);
    });
}

- (void)beginTransaction:(BOOL)useDeferred withBlock:(void (^)(VPUPDatabase *db, BOOL *rollback))block {
    dispatch_async(_queue, ^{
        BOOL shouldRollback = NO;
        
        if (useDeferred) {
            [[self database] beginDeferredTransaction];
        }
        else {
            [[self database] beginTransaction];
        }
        
        block([self database], &shouldRollback);
        
        if (shouldRollback) {
            [[self database] rollback];
        }
        else {
            [[self database] commit];
        }
    });
}

- (void)inTransaction:(void (^)(VPUPDatabase *db, BOOL *rollback))block {
    [self beginTransaction:NO withBlock:block];
}

- (void)inDeferredTransaction:(void (^)(VPUPDatabase *db, BOOL *rollback))block {
    [self beginTransaction:YES withBlock:block];
}

- (void)executeUpdateSql:(VPUPDBSQLString *)sql
           completeQueue:(dispatch_queue_t)completeQueue
           completeBlock:(void(^)(BOOL success))completeBlock {
    [self inDatabase:^(VPUPDatabase *db) {
        BOOL success = [db executeUpdateWithSQLString:sql];
        dispatch_queue_t callbackQueue = completeQueue ?: dispatch_get_main_queue();
        dispatch_async(callbackQueue, ^{
            completeBlock(success);
        });
    }];
    [self close];
}

- (void)executeUpdateSqls:(NSArray<VPUPDBSQLString *> *)sqls
            completeQueue:(dispatch_queue_t)completeQueue
            completeBlock:(void(^)(BOOL success))completeBlock {
    [self inTransaction:^(VPUPDatabase *db, BOOL *rollback) {
        BOOL success = NO;
        for(VPUPDBSQLString *sql in sqls) {
            success = [db executeUpdateWithSQLString:sql];
            if(!success) {
                break;
            }
        }
        
        dispatch_queue_t callbackQueue = completeQueue ?: dispatch_get_main_queue();
        dispatch_async(callbackQueue, ^{
            completeBlock(success);
        });
        
        if(!success) {
            *rollback = YES;
            return;
        }
    }];
    [self close];
}

- (void)executeQuerySql:(VPUPDBSQLString *)sql
          completeQueue:(dispatch_queue_t)completeQueue
          completeBlock:(void(^)(NSArray *selectObject))completeBlock {
    [self inDatabase:^(VPUPDatabase *db) {
        NSArray *searchResult = [db executeQueryWithSQLString:sql];
        dispatch_queue_t callbackQueue = completeQueue ?: dispatch_get_main_queue();
        dispatch_async(callbackQueue, ^{
            completeBlock(searchResult);
        });
    }];
    [self close];
}

- (void)getDatabaseVersionByCompleteQueue:(dispatch_queue_t)completeQueue
                            completeBlock:(void(^)(BOOL success, NSUInteger version))completeBlock {
    [self inDatabase:^(VPUPDatabase *db) {
        dispatch_queue_t callbackQueue = completeQueue ?: dispatch_get_main_queue();
        NSArray *result = [_db executeQuery:@"PRAGMA user_version"];
        if(result && [result firstObject] && [[result firstObject] objectForKey:@"user_version"]) {
            id targetVersion = [[result firstObject] objectForKey:@"user_version"];
            NSUInteger version = 0;
            if ([targetVersion isKindOfClass:[NSString class]]) {
                version = [(NSString *)targetVersion intValue];
            } else {
                version = [(NSNumber *)targetVersion unsignedIntegerValue];
            }
            dispatch_async(callbackQueue, ^{
                completeBlock(YES, version);
            });
        }
        else {
            dispatch_async(callbackQueue, ^{
                completeBlock(NO, 0);
            });
        }
    }];
    [self close];
}

- (void)setDatabaseVersion:(NSUInteger)version
             completeQueue:(dispatch_queue_t)completeQueue
             completeBlock:(void(^)(BOOL success))completeBlock {
    [self inDatabase:^(VPUPDatabase *db) {
        
        dispatch_queue_t callbackQueue = completeQueue ?: dispatch_get_main_queue();
        
        if(version == NSUIntegerMax) {
            dispatch_async(callbackQueue, ^{
                completeBlock(NO);
            });
            return;
        }
        
        BOOL success = [_db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %ld", version]];
        dispatch_async(callbackQueue, ^{
            completeBlock(success);
        });

        
    }];
    [self close];
}


@end
