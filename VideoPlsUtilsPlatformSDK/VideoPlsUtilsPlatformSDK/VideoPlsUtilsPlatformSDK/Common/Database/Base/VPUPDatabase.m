//
//  VPUPDatabase.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/7/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPDatabase.h"
#import "VPUPDBSQLString.h"
#import <sqlite3.h>
#import "VPUPLogUtil.h"
#import "VPUPValidator.h"

@interface VPUPDatabase() {
    void*   _db;
    BOOL    _inTransaction;
}

@end

@implementation VPUPDatabase

+ (instancetype)databaseWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    
    assert(sqlite3_threadsafe()); // whoa there big boy- gotta make sure sqlite it happy with what we're going to do.
    
    self = [super init];
    
    if (self) {
        _databasePath               = [path copy];
        _db                         = nil;
//        _maxBusyRetryTimeInterval   = 2;
    }
    
    return self;
}

- (BOOL)open {
    if (_db) {
        return YES;
    }
    
    if (![self databasePath]) {
        return NO;
    }
    
    int err = sqlite3_open([[self databasePath] UTF8String], (sqlite3**)&_db );
    if(err != SQLITE_OK) {
        VPUPLogWR(@"error opening!: %d", err);
        return NO;
    }
    
//    if (_maxBusyRetryTimeInterval > 0.0) {
//        // set the handler
//        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
//    }
    return YES;
}

- (BOOL)close {
    
    if (!_db) {
        return YES;
    }
    
    int  rc;
    BOOL retry;
    BOOL triedFinalizingOpenStatements = NO;
    
    do {
        retry = NO;
        rc = sqlite3_close(_db);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(_db, nil)) !=0) {
                    VPUPLogWR(@"Closing leaked statement");
                    sqlite3_finalize(pStmt);
                    retry = YES;
                }
            }
        }
        else if (SQLITE_OK != rc) {
            VPUPLogWR(@"error closing!: %d", rc);
        }
    }
    while (retry);
    
    _db = nil;
    return YES;
}

- (BOOL)databaseExists {
    if(!_db) {
        return NO;
    }
    return YES;
}

//- (void)setMaxBusyRetryTimeInterval:(NSTimeInterval)timeout {
//    
//    if(timeout <= 0) {
//        return;
//    }
//    
//    _maxBusyRetryTimeInterval = timeout;
//    
//    if (!_db) {
//        return;
//    }
//    
//    if (timeout > 0) {
//        sqlite3_busy_handler(_db, &FMDBDatabaseBusyHandler, (__bridge void *)(self));
//    }
//    else {
//        // turn it off otherwise
//        sqlite3_busy_handler(_db, nil, nil);
//    }
//}
//
//- (BOOL)databaseExists {
//    if (!_db) {
//        NSLog(@"The FMDatabase %@ is not open.", self);
//        return NO;
//    }
//    return YES;
//}

#pragma mark -- excute Update
- (BOOL)executeUpdate:(NSString *)sql {
    if(![self databaseExists]) {
        return NO;
    }
    if(!VPUP_IsStrictExist(sql)) {
        return NO;
    }
    char *err;
    if(sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
//        VPUPLogE(@"execError:%s",err);
        return NO;
    }
    return YES;
}

//- (BOOL)executeUpdate:(NSString *)sql, ... {
//    //TODO: wait to improve
//    return NO;
//}
//
//- (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
//    //TODO: wait to improve
//    return NO;
//}
//
//- (BOOL)executeUpdate:(NSString *)sql withArgumentsInArray:(NSArray *)arguments {
//    //TODO: wait to improve
//    return NO;
//}
//
//- (BOOL)executeUpdate:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments {
//    //TODO: wait to improve
//    return NO;
//}

- (BOOL)executeUpdateWithSQLString:(VPUPDBSQLString *)sqlString {
    return [self executeUpdate:sqlString.sqlString];
}

#pragma mark -- excute Query
- (NSArray *)executeQuery:(NSString *)sql {
    NSMutableArray *resultArray = [NSMutableArray array];

    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(_db, [sql UTF8String], -1, &statement, 0) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
//            NSMutableDictionary *singleResult = [NSMutableDictionary dictionary];
            NSDictionary *singleResult = [self resultDictionary:statement];
            [resultArray addObject:singleResult];
        }
    }
    sqlite3_finalize(statement);
    
    
    return resultArray;
}

//- (NSArray *)executeQuery:(NSString *)sql, ... {
//    //TODO: wait to improve
//    return nil;
//}
//
//- (NSArray *)executeQueryWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
//    //TODO: wait to improve
//    return nil;
//}
//
//- (NSArray *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments {
//    //TODO: wait to improve
//    return nil;
//}
//
//- (NSArray *)executeQuery:(NSString *)sql values:(NSArray *)values error:(NSError **)error {
//    //TODO: wait to improve
//    return nil;
//}
//
//- (NSArray *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments {
//    //TODO: wait to improve
//    return nil;
//}

- (NSArray<NSDictionary *> *)executeQueryWithSQLString:(VPUPDBSQLString *)sqlString {
    NSString *sql = sqlString.sqlString;
    
    return [self executeQuery:sql];
}

#pragma mark -- get result dict
- (NSDictionary *)resultDictionary:(sqlite3_stmt *)statement {
    NSUInteger num_cols = (NSUInteger)sqlite3_data_count(statement);
    
    if (num_cols > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        
        int columnCount = sqlite3_column_count(statement);
        
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, (int)columnIdx)];
//            id objectValue = [self objectForColumnIndex:columnIdx];
            id objectValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, (int)columnIdx)];
            [dict setObject:objectValue forKey:columnName];
        }
        
        return dict;
    }
    else {
        VPUPLogWR(@"Warning: There seem to be no columns in this set.");
    }
    
    return nil;
}


#pragma mark -- Transactions

- (BOOL)rollback {
    BOOL b = [self executeUpdate:@"rollback transaction"];
    
    if (b) {
        _inTransaction = NO;
    }
    
    return b;
}

- (BOOL)commit {
    BOOL b =  [self executeUpdate:@"commit transaction"];
    
    if (b) {
        _inTransaction = NO;
    }
    
    return b;
}

- (BOOL)beginDeferredTransaction {
    
    BOOL b = [self executeUpdate:@"begin deferred transaction"];
    if (b) {
        _inTransaction = YES;
    }
    
    return b;
}

- (BOOL)beginTransaction {
    
    BOOL b = [self executeUpdate:@"begin exclusive transaction"];
    if (b) {
        _inTransaction = YES;
    }
    
    return b;
}

- (BOOL)isInTransaction {
    return _inTransaction;
}

@end
