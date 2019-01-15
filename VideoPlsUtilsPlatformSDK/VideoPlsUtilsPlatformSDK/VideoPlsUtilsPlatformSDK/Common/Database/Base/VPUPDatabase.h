//
//  VPUPDatabase.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/7/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VPUPDBSQLString;

@interface VPUPDatabase : NSObject

+ (instancetype)databaseWithPath:(NSString *)path;

@property (nonatomic, readonly) NSString *databasePath;

//@property (nonatomic) NSTimeInterval maxBusyRetryTimeInterval;

- (BOOL)open;
- (BOOL)close;

- (BOOL)databaseExists;

//执行(create insert update)
- (BOOL)executeUpdate:(NSString *)sql;
//- (BOOL)executeUpdate:(NSString *)sql, ...;
//- (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
//- (BOOL)executeUpdate:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
//- (BOOL)executeUpdate:(NSString *)sql values:(NSArray *)values error:(NSError **)error;
//- (BOOL)executeUpdate:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;

- (BOOL)executeUpdateWithSQLString:(VPUPDBSQLString *)sqlString;

//查询(select)
- (NSArray<NSDictionary *> *)executeQuery:(NSString *)sql;
//- (NSArray *)executeQuery:(NSString *)sql, ...;
//- (NSArray *)executeQueryWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
//- (NSArray *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
//- (NSArray *)executeQuery:(NSString *)sql values:(NSArray *)values error:(NSError **)error;
//- (NSArray *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;

- (NSArray<NSDictionary *> *)executeQueryWithSQLString:(VPUPDBSQLString *)sqlString;

//事物(transaction)
- (BOOL)beginTransaction;
- (BOOL)beginDeferredTransaction;
- (BOOL)commit;
- (BOOL)rollback;
@property (nonatomic, readonly) BOOL isInTransaction;

@end
