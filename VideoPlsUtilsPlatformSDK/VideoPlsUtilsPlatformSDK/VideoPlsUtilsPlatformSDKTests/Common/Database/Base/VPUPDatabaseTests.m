//
//  VPUPDatabaseTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/13.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPDatabase.h"
#import "VPUPPathUtil.h"
#import "VPUPDBSQLString.h"
#import "XCTestCase+VPUPAsyncTests.h"

@interface VPUPDatabaseTests : XCTestCase

@property (nonatomic) NSString *databasePath;

@end

@implementation VPUPDatabaseTests

- (NSString *)notifyName {
    return @"VPUPDataBaseTests";
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

- (void)testDatabaseWithPath {
    VPUPDatabase * db = [VPUPDatabase databaseWithPath:self.databasePath];
    XCTAssertNotNil(db, @"init cannot be nil");
    
}

- (void)testOpenClose {
    VPUPDatabase *db2 = [VPUPDatabase databaseWithPath:nil];
    XCTAssertFalse([db2 open], @"Without path couldn't open success");
    XCTAssertTrue([db2 close] ,@"Did not create db, close also will be true");
    
    VPUPDatabase * db = [VPUPDatabase databaseWithPath:self.databasePath];
    XCTAssertFalse([db databaseExists], @"Did not open db, return false");
    
    XCTAssertTrue([db open], @"True path will open success");
    XCTAssertTrue([db databaseExists], @"Open db, return true");
    
    XCTAssertTrue([db close] ,@"Close will be true");
    XCTAssertFalse([db databaseExists], @"DB close, database did not exists");
}

- (void)testExecute {
    NSString *insertSQL = @"INSERT INTO 'test' ('test1','test2') VALUES ('test2',2)";
    NSString *selectSQL = @"SELECT * FROM 'test'";
    VPUPDBSQLString *createSQLString = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] columTypes:@[@"varchar(32)", @"int"] primaryKeys:@[@"test1"]];
    VPUPDBSQLString *insertSQLString = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:@[@"test2", @2]];
    VPUPDBSQLString *selectSQLString = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:nil whereKeys:nil whereValues:nil orderBy:@"test1" sort:NSOrderedAscending];
    VPUPDBSQLString *deleteSQLString = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:@"test" whereKeys:nil whereValues:nil];
    
    VPUPDatabase * db = [VPUPDatabase databaseWithPath:self.databasePath];
    
    XCTAssertFalse([db executeUpdate:insertSQL], @"DB did not open, return false");
    XCTAssertFalse([db executeUpdateWithSQLString:insertSQLString], @"DB did not open, return false");
    [db open];
    
    XCTAssertFalse([db executeUpdate:nil], @"excute nil sql return faslse");
    XCTAssertFalse([db executeUpdate:@""], @"excute empty sql return faslse");
    XCTAssertFalse([db executeUpdate:insertSQL], @"Table did not exist, return false");
    XCTAssertTrue([db executeQuery:selectSQL].count == 0, @"query will return 0 count array without contain");
    XCTAssertTrue([db executeQueryWithSQLString:selectSQLString].count == 0, @"query will return 0 count array without contain");
    
    XCTAssertTrue([db executeUpdateWithSQLString:createSQLString], @"Create table should be true");
    XCTAssertTrue([db executeUpdate:insertSQL], @"insert sql should be true");
    XCTAssertFalse([db executeUpdateWithSQLString:insertSQLString], @"insert same primary key sql should be false");
    
    NSArray *selectArray = [db executeQuery:selectSQL];
    XCTAssertNotNil(selectArray, @"select query exsist");
    XCTAssertTrue(selectArray.count == 1, @"insert one data for table 'test'");
    XCTAssertTrue([[[selectArray firstObject] valueForKey:@"test1"] isEqualToString:@"test2"], @"insert one data for table 'test'");
    
    XCTAssertTrue([db executeUpdateWithSQLString:deleteSQLString], @"delete sql should be true");
    XCTAssertTrue([db executeQueryWithSQLString:selectSQLString].count == 0, @"table be delete, count 0");
}

- (void)testTransaction {
    VPUPDBSQLString *createSQLString = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] columTypes:@[@"varchar(32)", @"int"] primaryKeys:@[@"test1"]];
    VPUPDBSQLString *insertSQLString = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:@[@"test2", @2]];
    VPUPDBSQLString *insertSQLString2 = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:@[@"test1", @1]];
    VPUPDBSQLString *selectSQLString = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test" columNames:@[@"test1", @"test2"] values:nil whereKeys:nil whereValues:nil orderBy:@"test1" sort:NSOrderedAscending];
    VPUPDBSQLString *deleteSQLString = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:@"test" whereKeys:@[@"test1"] whereValues:@[@"test1"]];
    
    VPUPDatabase * db = [VPUPDatabase databaseWithPath:self.databasePath];
    [db open];
    
    XCTAssertTrue([db executeUpdateWithSQLString:createSQLString], @"has no block");
    
    
    XCTAssertTrue([db beginTransaction], @"begin transaction will be true");
    XCTAssertTrue([db isInTransaction], @"begin will set to true");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        VPUPDatabase * db2 = [VPUPDatabase databaseWithPath:self.databasePath];
        [db2 open];
        XCTAssertFalse([db2 executeUpdateWithSQLString:insertSQLString], @"db has been transcation");
        [db2 close];
        
        [self notify];
    });
    
    [self wait];
    
    [db executeUpdateWithSQLString:insertSQLString];
    
    XCTAssertTrue([db commit], @"commit will submit all change to db");
    XCTAssertFalse([db isInTransaction], @"commit will set to false");
    
    XCTAssertTrue([db executeQueryWithSQLString:selectSQLString].count == 1, @"query will return 1 count array with transction commit");
    
    
    XCTAssertTrue([db beginDeferredTransaction], @"begin deferred transaction will be true");
    XCTAssertTrue([db isInTransaction], @"begin will set to true");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        VPUPDatabase * db2 = [VPUPDatabase databaseWithPath:self.databasePath];
        [db2 open];
        XCTAssertTrue([db2 executeUpdateWithSQLString:insertSQLString2], @"db has been deferred transcation, until operated can also update");
        [db2 close];
        
        [self notify];
    });
    
    [self wait];
    
    [db executeUpdateWithSQLString:deleteSQLString];
    XCTAssertTrue([db executeQueryWithSQLString:selectSQLString].count == 1, @"delete should be executed");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        VPUPDatabase * db2 = [VPUPDatabase databaseWithPath:self.databasePath];
        [db2 open];
        XCTAssertFalse([db2 executeUpdateWithSQLString:insertSQLString2], @"db already in transaction, cannot update");
        [db2 close];
        
        [self notify];
    });
    
    [self wait];
    
    XCTAssertTrue([db rollback], @"commit will rollback all change to db");
    XCTAssertFalse([db isInTransaction], @"rollback will set to false");
    
    XCTAssertTrue([db executeQueryWithSQLString:selectSQLString].count == 2, @"delete should be rollback");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
