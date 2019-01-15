//
//  VPUPDBSQLString.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/19.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VPUPSQLOrderType) {
    VPUPSQLOrderSelect  = 0,
    VPUPSQLOrderCreate,
    VPUPSQLOrderInsert,
    VPUPSQLOrderUpdate,
    VPUPSQLOrderDelete
};

@interface VPUPDBSQLString : NSObject

//arguments暂时只支持NSString
//+ (instancetype)initWithMethod:(VPUPDBSQLStringType)method
//                         table:(NSString *)tableName
//                     arguments:(NSArray *)arguments
//                         where:(NSString *)where;
//
//- (instancetype)initWithMethod:(VPUPDBSQLStringType)method
//                         table:(NSString *)tableName
//                     arguments:(NSArray *)arguments
//                         where:(NSString *)where;
//
//- (instancetype)initWithSqlString:(NSString *)sqlString arguments:(NSArray *)arguments;
//
//@property (nonatomic, strong, readonly) NSString *sqlString;
//
//@property (nonatomic, strong, readonly) NSArray *arguments;

@property (nonatomic, assign, readonly) VPUPSQLOrderType orderType;
@property (nonatomic, readonly) NSString *tableName;
@property (nonatomic, readonly) NSArray *columNames;
@property (nonatomic, readonly) NSArray *columTypes;
@property (nonatomic, readonly) NSArray *primaryKeys;
@property (nonatomic, readonly) NSArray *values;
@property (nonatomic, readonly) NSArray *whereKeys;
@property (nonatomic, readonly) NSArray *whereValues;
@property (nonatomic, readonly) NSString *orderByColum;
@property (nonatomic, assign, readonly) NSComparisonResult sort;

- (instancetype)initSqlStringWithType:(VPUPSQLOrderType)orderType
                            tableName:(NSString *)tableName
                           columNames:(NSArray *)columNames
                           columTypes:(NSArray *)columTypes
                          primaryKeys:(NSArray *)primaryKeys
                               values:(NSArray *)values
                            whereKeys:(NSArray *)whereKeys
                          whereValues:(NSArray *)whereValues
                              orderBy:(NSString *)orderByColum
                                 sort:(NSComparisonResult)sort;

- (instancetype)initSelectSQLWithTableName:(NSString *)tableName
                                columNames:(NSArray *)columNames
                                    values:(NSArray *)values        //need search colum content
                                 whereKeys:(NSArray *)whereKeys
                               whereValues:(NSArray *)whereValues
                                   orderBy:(NSString *)orderByColum
                                      sort:(NSComparisonResult)sort;

- (instancetype)initCreateSQLWithTableName:(NSString *)tableName
                                columNames:(NSArray *)columNames
                                columTypes:(NSArray *)columTypes
                               primaryKeys:(NSArray *)primaryKeys;

- (instancetype)initInsertSQLWithTableName:(NSString *)tableName
                                columNames:(NSArray *)columNames
                                    values:(NSArray *)values;

- (instancetype)initUpdateSQLWithTableName:(NSString *)tableName
                                columNames:(NSArray *)columNames
                                    values:(NSArray *)values
                                 whereKeys:(NSArray *)whereKeys
                               whereValues:(NSArray *)whereValues;

- (instancetype)initDeleteSQLWithTableName:(NSString *)tableName
                                 whereKeys:(NSArray *)whereKeys
                               whereValues:(NSArray *)whereValues;

- (NSString *)sqlString;

@end
