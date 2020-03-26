//
//  VPUPDBSQLStringTests.m
//  VideoPlsUtilsPlatformSDKTests
//
//  Created by Zard1096-videojj on 2020/3/11.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPUPDBSQLString.h"

@interface VPUPDBSQLStringTests : XCTestCase

@end

@implementation VPUPDBSQLStringTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitSqlString {
        
    VPUPDBSQLString *sqlString = [[VPUPDBSQLString alloc] initSqlStringWithType:VPUPSQLOrderSelect
                                                                      tableName:@"test"
                                                                     columNames:@[@"test"]
                                                                     columTypes:nil
                                                                    primaryKeys:nil
                                                                         values:@[@"test"]
                                                                      whereKeys:@[@"test"]
                                                                    whereValues:@[@"test"]
                                                                        orderBy:@"test"
                                                                           sort:NSOrderedDescending];
    
    XCTAssertNotNil(sqlString, @"total create method cannot be nil");
    
    
    VPUPDBSQLString *sqlString1 = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test"
                                                                          columNames:@[@"test"]
                                                                              values:@[@"test"]];
    XCTAssertNotNil(sqlString1, @"init cannot be nil");
    
    VPUPDBSQLString *sqlString2 = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                           columNames:nil
                                                                               values:nil
                                                                            whereKeys:nil
                                                                          whereValues:nil
                                                                              orderBy:@"test"
                                                                                 sort:NSOrderedAscending];
    XCTAssertNotNil(sqlString2, @"init cannot be nil, each can be nil, but sqlString will not pass");
    
    VPUPDBSQLString *sqlString3 = [[VPUPDBSQLString alloc] initUpdateSQLWithTableName:@"test"
                                                                          columNames:@[@"test", @"test"]
                                                                              values:@[@"test", @"test"]
                                                                           whereKeys:@[@"test"]
                                                                         whereValues:@[@"test"]];
    XCTAssertNotNil(sqlString3, @"init cannot be nil");
    
    VPUPDBSQLString *sqlString4 = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test"
                                                                           columNames:@[@"test", @"test2"]
                                                                           columTypes:@[@"string", @"string"]
                                                                          primaryKeys:@[@"test"]];
    XCTAssertNotNil(sqlString4, @"init cannot be nil");
    
    VPUPDBSQLString *sqlString5 = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:@"test"
                                                                            whereKeys:@[@"test"]
                                                                          whereValues:@[@"test"]];
    XCTAssertNotNil(sqlString5, @"init cannot be nil");
    
}

- (void)testSQLString {
    VPUPDBSQLString *sqlString = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                          columNames:nil
                                                                              values:nil
                                                                           whereKeys:nil
                                                                         whereValues:nil
                                                                             orderBy:@"test"
                                                                                sort:NSOrderedAscending];
#ifdef DEBUG
    XCTAssertThrows([sqlString sqlString], @"Not Delete method columNames could not be nil or count could not be 0");
#else
    XCTAssertNil([sqlString sqlString], @"Not Delete method columNames could not be nil or count could not be 0, return nil");
#endif
    
    VPUPDBSQLString *sqlString1 = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                           columNames:@"test"
                                                                               values:nil
                                                                            whereKeys:nil
                                                                          whereValues:nil
                                                                              orderBy:@"test"
                                                                                 sort:NSOrderedAscending];
#ifdef DEBUG
    XCTAssertThrows([sqlString1 sqlString], @"columNames must be array");
#else
    XCTAssertNil([sqlString1 sqlString], @"columNames must be array, return nil");
#endif
    
    VPUPDBSQLString *sqlString2 = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                           columNames:nil
                                                                               values:@(1)
                                                                            whereKeys:nil
                                                                          whereValues:nil
                                                                              orderBy:@"test"
                                                                                 sort:NSOrderedAscending];
#ifdef DEBUG
    XCTAssertThrows([sqlString2 sqlString], @"values must be array");
#else
    XCTAssertNil([sqlString2 sqlString], @"values must be array, return nil");
#endif
    
    VPUPDBSQLString *sqlString3 = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                           columNames:nil
                                                                               values:nil
                                                                            whereKeys:@"test"
                                                                          whereValues:nil
                                                                              orderBy:@"test"
                                                                                 sort:NSOrderedAscending];
#ifdef DEBUG
    XCTAssertThrows([sqlString3 sqlString], @"whereKeys must be array");
#else
    XCTAssertNil([sqlString3 sqlString], @"whereKeys must be array, return nil");
#endif
    
    VPUPDBSQLString *sqlString4 = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                           columNames:nil
                                                                               values:nil
                                                                            whereKeys:nil
                                                                          whereValues:@"test"
                                                                              orderBy:@"test"
                                                                                 sort:NSOrderedAscending];
#ifdef DEBUG
    XCTAssertThrows([sqlString4 sqlString], @"whereValues must be array");
#else
    XCTAssertNil([sqlString4 sqlString], @"whereValues must be array, return nil");
#endif
    VPUPDBSQLString *sqlString5 = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                           columNames:nil
                                                                               values:nil
                                                                            whereKeys:@[@"test", @"test"]
                                                                          whereValues:@[@"test"]
                                                                              orderBy:@"test"
                                                                                 sort:NSOrderedAscending];
#ifdef DEBUG
    XCTAssertThrows([sqlString5 sqlString], @"whereKeys count must be eqaul to whereVaules count");
#else
    XCTAssertNil([sqlString5 sqlString], @"whereKeys count must be eqaul to whereVaules count, return nil");
#endif
    
    VPUPDBSQLString *sqlString6 = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test"
                                                                           columNames:nil
                                                                           columTypes:@[@"string", @"string"]
                                                                  primaryKeys:@[@"test"]];
#ifdef DEBUG
    XCTAssertThrows([sqlString6 sqlString], @"create sql columNames cannot be nil");
#else
    XCTAssertNil([sqlString6 sqlString], @"create sql columNames cannot be nil, return nil");
#endif
    
    VPUPDBSQLString *sqlString7 = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test"
                                                                           columNames:@[]
                                                                           columTypes:@[@"string", @"string"]
                                                                          primaryKeys:@[@"test"]];
#ifdef DEBUG
    XCTAssertThrows([sqlString7 sqlString], @"create sql columNames count cannot be 0");
#else
    XCTAssertNil([sqlString7 sqlString], @"create sql columNames count cannot be 0, return nil");
#endif
    
    VPUPDBSQLString *sqlString8 = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test"
                                                                           columNames:@[@"test"]
                                                                           columTypes:@[@"string", @"string"]
                                                                          primaryKeys:@[@"test"]];
#ifdef DEBUG
    XCTAssertThrows([sqlString8 sqlString], @"create sql columNames count must be equal to columTypes count");
#else
    XCTAssertNil([sqlString8 sqlString], @"create sql columNames count must be equal to columTypes count, return nil");
#endif
    
    VPUPDBSQLString *sqlString9 = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test"
                                                                              columNames:nil
                                                                              columTypes:nil
                                                                             primaryKeys:@[@"test"]];
#ifdef DEBUG
    XCTAssertThrows([sqlString9 sqlString], @"create sql columNames and columTypes must not be nil");
#else
    XCTAssertNil([sqlString9 sqlString], @"create sql columNames and columTypes must not be nil, return nil");
#endif
    
    VPUPDBSQLString *sqlString10 = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test"
                                                                            columNames:@[@"test", @"test1"]
                                                                                values:nil];
#ifdef DEBUG
    XCTAssertThrows([sqlString10 sqlString], @"insert sql values must not be nil");
#else
    XCTAssertNil([sqlString10 sqlString], @"insert sql values must not be nil, return nil");
#endif
    
    VPUPDBSQLString *sqlString11 = [[VPUPDBSQLString alloc] initUpdateSQLWithTableName:@"test"
                                                                            columNames:@[@"test"]
                                                                                values:nil
                                                                             whereKeys:nil
                                                                           whereValues:nil];
#ifdef DEBUG
    XCTAssertThrows([sqlString11 sqlString], @"update sql values must not be nil");
#else
    XCTAssertNil([sqlString11 sqlString], @"update sql values must not be nil, return nil");
#endif
    
    VPUPDBSQLString *sqlString12 = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                            columNames:@[@"test"]
                                                                                values:nil
                                                                             whereKeys:@[@"test"]
                                                                           whereValues:@[@"test"]
                                                                               orderBy:@"test1"
                                                                                  sort:NSOrderedAscending];
    //columNames if did not cotain value then use * get all colum
    XCTAssertTrue([[sqlString12 sqlString] isEqualToString:@"SELECT * FROM 'test' WHERE test = 'test' order by test1 ASC"], @"select sql is correct");
    
    VPUPDBSQLString *sqlString13 = [[VPUPDBSQLString alloc] initSelectSQLWithTableName:@"test"
                                                                            columNames:@[@"count", @"avg"]
                                                                                values:@[@"count(*)", @"avg('test2')"]
                                                                             whereKeys:@[@"test"]
                                                                           whereValues:@[@"test"]
                                                                               orderBy:@"test1"
                                                                                  sort:NSOrderedDescending];
    XCTAssertTrue([[sqlString13 sqlString] isEqualToString:@"SELECT count(*) as 'count' , avg('test2') as 'avg' FROM 'test' WHERE test = 'test' order by test1 DESC"], @"select sql with special search is correct");
    
    VPUPDBSQLString *sqlString14 = [[VPUPDBSQLString alloc] initCreateSQLWithTableName:@"test"
                                                                            columNames:@[@"test1", @"test2"]
                                                                            columTypes:@[@"varchar(32)", @"int"]
                                                                           primaryKeys:@[@"test1",  @"test2"]];
                                                                                  
    XCTAssertTrue([[sqlString14 sqlString] isEqualToString:@"CREATE TABLE IF NOT EXISTS 'test' (test1 varchar(32), test2 int, PRIMARY KEY(test1,test2))"], @"create sql is correct");
    
    VPUPDBSQLString *sqlString15 = [[VPUPDBSQLString alloc] initUpdateSQLWithTableName:@"test"
                                                                            columNames:@[@"test1", @"test2"]
                                                                                values:@[@"test1", @(1)]
                                                                             whereKeys:@[@"test"]
                                                                           whereValues:@[@"test"]];
    XCTAssertTrue([[sqlString15 sqlString] isEqualToString:@"UPDATE 'test' SET test1 = 'test1' , test2 = 1 WHERE test = 'test' "], @"update sql is correct");
    
    VPUPDBSQLString *sqlString16 = [[VPUPDBSQLString alloc] initInsertSQLWithTableName:@"test"
                                                                            columNames:@[@"test1", @"test2"]
                                                                                values:@[@"test2", @(2)]];
    XCTAssertTrue([[sqlString16 sqlString] isEqualToString:@"INSERT INTO 'test' ('test1','test2') VALUES ('test2',2)"], @"insert sql is correct");
    
    VPUPDBSQLString *sqlString17 = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:@"test"
                                                                             whereKeys:@[@"test1", @"test2", @"test3", @"test4", @"test5"]
                                                                           whereValues:@[@"_est", @(2.2), @"%t", @"[ABC]%", @"test5"]];
    XCTAssertTrue([[sqlString17 sqlString] isEqualToString:@"DELETE FROM 'test' WHERE test1 LIKE '_est' AND test2 = 2.2 AND test3 LIKE '%t' AND test4 LIKE '[ABC]%' AND test5 = 'test5' "], @"delete sql is correct");
    
    VPUPDBSQLString *sqlString18 = [[VPUPDBSQLString alloc] initDeleteSQLWithTableName:@"test"
                                                                             whereKeys:nil
                                                                           whereValues:nil];
    XCTAssertTrue([[sqlString18 sqlString] isEqualToString:@"DELETE FROM 'test' "], @"delete all sql is correct");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
