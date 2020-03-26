//
//  VPUPDatabaseManagerTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/17.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+VPUPAsyncTests.h"
#import "VPUPDatabaseManager.h"
#import "VPUPPathUtil.h"
#import <objc/runtime.h>
#import "VPUPDBSQLString.h"
#import "VPUPDatabase.h"

@interface VPUPDatabaseManagerTests : XCTestCase

@property (nonatomic) NSString *databasePath;

@end

@implementation VPUPDatabaseManagerTests

- (NSString *)notifyName {
    return @"VPUPDatabaseManagerTests";
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    NSString *path = [VPUPPathUtil pathByPlaceholder:@"unitTest"];
    self.databasePath = [path stringByAppendingPathComponent:@"UnitTest.sqlite"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtPath:self.databasePath error:nil];
    self.databasePath = nil;
    
    NSString *path = [VPUPPathUtil pathByPlaceholder:@"unitTest"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)testDatabase {
    VPUPDatabaseManager *manager = [VPUPDatabaseManager databaseManagerWithPath:self.databasePath];
    XCTAssertNotNil(manager, @"database create should not be nil");
    XCTAssertEqualObjects(manager.databasePath, self.databasePath, @"database should be the same");
    
    Ivar ivar = class_getInstanceVariable([manager class], "_db");
    VPUPDatabase *db = object_getIvar(manager, ivar);
    XCTAssertNotNil(db, @"init will open db, not nil");

    [manager close];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        VPUPDatabase *db = object_getIvar(manager, ivar);
        XCTAssertNil(db, @"close db will be nil");
        
        [self notify];
    });
    
    [self wait];
    
}

- (void)testInDatabase {
    VPUPDBSQLString *createSQLString = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] columTypes:@[@"varchar(32)", @"int"] primaryKeys:@[@"test1"]];
    VPUPDBSQLString *insertSQLString = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:@[@"test2", @2]];
    VPUPDBSQLString *insertSQLString2 = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:@[@"test1", @1]];
    VPUPDBSQLString *selectSQLString = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:nil whereKeys:nil whereValues:nil orderBy:@"test1" sort:NSOrderedAscending];
    VPUPDBSQLString *deleteSQLString = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:@"test" whereKeys:@[@"test1"] whereValues:@[@"test1"]];
    
    VPUPDatabaseManager *manager = [VPUPDatabaseManager databaseManagerWithPath:self.databasePath];
    Ivar ivarDB = class_getInstanceVariable([manager class], "_db");
    VPUPDatabase *managerDB = object_getIvar(manager, ivarDB);
    
    __weak typeof(self) weakSelf = self;
    
    [manager inDatabase:^(VPUPDatabase *db) {
        
        XCTAssertNotNil(db, @"in database db will not be nil");
        XCTAssertEqual(managerDB, db, @"the db must be the same");
        
        XCTAssertFalse([[NSThread currentThread] isMainThread], @"In database will run on own queue, not main queue");
        
        // do a create sql
        [db executeUpdateWithSQLString:createSQLString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf notify];
        });
        
    }];
    
    [self wait];
    
    
    [manager inTransaction:^(VPUPDatabase *db, BOOL *rollback) {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
            VPUPDatabase *mutiDB = [VPUPDatabase databaseWithPath:weakSelf.databasePath];
            [mutiDB open];
            
            XCTAssertFalse([mutiDB executeUpdateWithSQLString:insertSQLString2], @"db has been in transaction");
            
            [mutiDB close];
            //return to db queue
            dispatch_semaphore_signal(sem);
        });
        
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));
        
        [db executeUpdateWithSQLString:insertSQLString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notify];
        });
        
    }];
    
    [self wait];
    
    //wait some time for end db
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf notify];
    });
    [self wait];
    
    NSArray *result = [managerDB executeQueryWithSQLString:selectSQLString];
    XCTAssertTrue(result.count == 1, @"in database execute 1 insert sql");
    
    
    [manager inTransaction:^(VPUPDatabase *db, BOOL *rollback) {
        
        [db executeUpdateWithSQLString:insertSQLString2];
        
        *rollback = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notify];
        });
    }];
    
    [self wait];
    
    //wait some time for end db
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf notify];
    });
    [self wait];
    
    NSArray *result2 = [managerDB executeQueryWithSQLString:selectSQLString];
    XCTAssertTrue(result2.count == 1, @"in transaction rollback leaving it as it as");
    
    
    [manager inDeferredTransaction:^(VPUPDatabase *db, BOOL *rollback) {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
            VPUPDatabase *mutiDB = [VPUPDatabase databaseWithPath:weakSelf.databasePath];
            [mutiDB open];
            
            XCTAssertTrue([mutiDB executeUpdateWithSQLString:insertSQLString2], @"db has been in deferred transaction could be insert");
            
            [mutiDB close];
            //return to db queue
            dispatch_semaphore_signal(sem);
        });
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));
        
        
        XCTAssertFalse([db executeUpdateWithSQLString:insertSQLString2], @"already insert in async queue");
        XCTAssertTrue([db executeUpdateWithSQLString:deleteSQLString], @"delete one data");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notify];
        });
    }];
    
    [self wait];
    
    //wait some time for end db
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf notify];
    });
    [self wait];
    
    NSArray *result3 = [managerDB executeQueryWithSQLString:selectSQLString];
    XCTAssertTrue(result3.count == 1, @"out transaction add 1, then in transaction delete 1, left 1");
    XCTAssertTrue([[[result3 firstObject] valueForKey:@"test1"] isEqualToString:@"test2"], @"delete 'test1', remain 'test2'");
    
    [manager close];
    
}

- (void)testSQL {
    VPUPDBSQLString *createSQLString = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] columTypes:@[@"varchar(32)", @"int"] primaryKeys:@[@"test1"]];
    VPUPDBSQLString *insertSQLString = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:@[@"test2", @2]];
    VPUPDBSQLString *insertSQLString2 = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:@[@"test1", @1]];
    VPUPDBSQLString *selectSQLString = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:nil whereKeys:nil whereValues:nil orderBy:@"test1" sort:NSOrderedAscending];
    
    VPUPDatabaseManager *manager = [VPUPDatabaseManager databaseManagerWithPath:self.databasePath];
    
    __weak typeof(self) weakSelf = self;
    [manager executeUpdateSql:createSQLString completeQueue:nil completeBlock:^(BOOL success) {
        
        XCTAssertTrue(success, @"create sql will be true");
        
        XCTAssertTrue([[NSThread currentThread] isMainThread], @"Do not use complete queue will complete run on main thread");
        
        [weakSelf notify];
    }];
    
    [self wait];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    [manager executeUpdateSqls:@[insertSQLString, insertSQLString2] completeQueue:queue completeBlock:^(BOOL success) {
        
        XCTAssertTrue(success, @"insert sql will be true");
        
        XCTAssertFalse([[NSThread currentThread] isMainThread], @"use complete queue will complete run on set queue, not main queue");
        
        //not on main thread, return main to notify
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notify];
        });
        
    }];
    
    [self wait];
    
    [manager executeQuerySql:selectSQLString completeQueue:nil completeBlock:^(NSArray *selectObject) {
        
        XCTAssertNotNil(selectObject, @"select sql should return 2 result");
        
        XCTAssertTrue(selectObject.count == 2, @"select sql should return 2 result");
        
        [weakSelf notify];
    }];
    
    [self wait];
}

- (void)testDatabaseVersion {
    
    VPUPDatabaseManager *manager = [VPUPDatabaseManager databaseManagerWithPath:self.databasePath];
    __weak typeof(self) weakSelf = self;
    
    [manager getDatabaseVersionByCompleteQueue:nil completeBlock:^(BOOL success, NSUInteger version) {
        XCTAssertTrue([[NSThread currentThread] isMainThread], @"completeQueue nil will on main queue");
        
        XCTAssertTrue(success, @"Default has a version '0'");
        
        XCTAssertTrue(version == 0, @"Did not set database version, version will be 0");
        
        [weakSelf notify];
    }];
    
    [self wait];
    
    [manager setDatabaseVersion:1 completeQueue:dispatch_get_global_queue(0, 0) completeBlock:^(BOOL success) {
        XCTAssertFalse([[NSThread currentThread] isMainThread], @"set completeQueue should not on main queue");
        
        XCTAssertTrue(success, @"set success");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notify];
        });
    }];
    
    [self wait];
    
    [manager getDatabaseVersionByCompleteQueue:nil completeBlock:^(BOOL success, NSUInteger version) {
        XCTAssertTrue(version == 1, @"Set 1 should get 1");
        
        [weakSelf notify];
    }];
    
    [self wait];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
