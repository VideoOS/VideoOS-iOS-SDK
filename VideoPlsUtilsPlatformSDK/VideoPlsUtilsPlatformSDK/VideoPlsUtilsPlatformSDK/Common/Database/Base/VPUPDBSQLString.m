//
//  VPUPDBSQLString.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/19.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPDBSQLString.h"
#import "VPUPValidator.h"

@implementation VPUPDBSQLString

//+ (instancetype)initWithMethod:(VPUPDBSQLStringType)method
//                         table:(NSString *)tableName
//                     arguments:(NSArray *)arguments
//                         where:(NSString *)where {
//    return [[VPUPDBSQLString alloc] initWithMethod:method table:tableName arguments:arguments where:where];
//}
//
//- (instancetype)initWithMethod:(VPUPDBSQLStringType)method
//                         table:(NSString *)tableName
//                     arguments:(NSArray *)arguments
//                         where:(NSString *)where {
//    self = [super init];
//    if(self) {
//        [self concatSqlWithMethod:method table:tableName arguments:arguments where:where];
//    }
//    return self;
//}
//
//- (instancetype)initWithSqlString:(NSString *)sqlString arguments:(NSArray *)arguments {
//    return nil;
//    self = [super init];
//    if(self) {
//        if(sqlString) {
//            _sqlString = [sqlString copy];
//        }
//        if(arguments) {
//            _arguments = [arguments copy];
//        }
//    }
//    
//    return self;
//}
//
//- (void)concatSqlWithMethod:(VPUPDBSQLStringType)method
//                      table:(NSString *)tableName
//                  arguments:(NSArray *)arguments
//                      where:(NSString *)where {
//    
//    
//}

- (instancetype)initSqlStringWithType:(VPUPSQLOrderType)orderType
                            tableName:(NSString *)tableName
                           columNames:(NSArray *)columNames
                           columTypes:(NSArray *)columTypes
                          primaryKeys:(NSArray *)primaryKeys
                               values:(NSArray *)values
                            whereKeys:(NSArray *)whereKeys
                          whereValues:(NSArray *)whereValues
                              orderBy:(NSString *)orderByColum
                                 sort:(NSComparisonResult)sort {
    self = [super init];
    if(self) {
        _orderType = orderType;
        _tableName = [tableName copy];
        if(columNames) {
            _columNames = [NSArray arrayWithArray:columNames];
        }
        if(columTypes) {
            _columTypes = [NSArray arrayWithArray:columTypes];
        }
        if(primaryKeys) {
            _primaryKeys = [NSArray arrayWithArray:primaryKeys];
        }
        if(values) {
            _values = [NSArray arrayWithArray:values];
        }
        if(whereKeys) {
            _whereKeys = [NSArray arrayWithArray:whereKeys];
        }
        if(whereValues) {
            _whereValues = [NSArray arrayWithArray:whereValues];
        }
        if(orderByColum) {
            _orderByColum = [orderByColum copy];
        }
        _sort = sort;
    }
    
    return self;
}

- (instancetype)initSelectSQLWithTableName:(NSString *)tableName
                                columNames:(NSArray *)columNames
                                    values:(NSArray *)values
                                 whereKeys:(NSArray *)whereKeys
                               whereValues:(NSArray *)whereValues
                                   orderBy:(NSString *)orderByColum
                                      sort:(NSComparisonResult)sort {
    
    self = [self initSqlStringWithType:VPUPSQLOrderSelect
                             tableName:tableName
                            columNames:columNames
                            columTypes:nil
                           primaryKeys:nil
                                values:values
                             whereKeys:whereKeys
                           whereValues:whereValues
                               orderBy:orderByColum
                                  sort:sort];
    
    return self;
}

- (instancetype)initCreateSQLWithTableName:(NSString *)tableName
                                columNames:(NSArray *)columNames
                                columTypes:(NSArray *)columTypes
                               primaryKeys:(NSArray *)primaryKeys {
    
    self = [self initSqlStringWithType:VPUPSQLOrderCreate
                             tableName:tableName
                            columNames:columNames
                            columTypes:columTypes
                           primaryKeys:primaryKeys
                                values:nil
                             whereKeys:nil
                           whereValues:nil
                               orderBy:nil
                                  sort:0];
    
    return self;
}

- (instancetype)initInsertSQLWithTableName:(NSString *)tableName
                                columNames:(NSArray *)columNames
                                    values:(NSArray *)values {
    
    self = [self initSqlStringWithType:VPUPSQLOrderInsert
                             tableName:tableName
                            columNames:columNames
                            columTypes:nil
                           primaryKeys:nil
                                values:values
                             whereKeys:nil
                           whereValues:nil
                               orderBy:nil
                                  sort:0];
    
    return self;
}

- (instancetype)initUpdateSQLWithTableName:(NSString *)tableName
                                columNames:(NSArray *)columNames
                                    values:(NSArray *)values
                                 whereKeys:(NSArray *)whereKeys
                               whereValues:(NSArray *)whereValues {
    
    self = [self initSqlStringWithType:VPUPSQLOrderUpdate
                             tableName:tableName
                            columNames:columNames
                            columTypes:nil
                           primaryKeys:nil
                                values:values
                             whereKeys:whereKeys
                           whereValues:whereValues
                               orderBy:nil
                                  sort:0];
    
    return self;
    
}

- (instancetype)initDeleteSQLWithTableName:(NSString *)tableName
                                 whereKeys:(NSArray *)whereKeys
                               whereValues:(NSArray *)whereValues {
    self = [self initSqlStringWithType:VPUPSQLOrderDelete
                             tableName:tableName
                            columNames:nil
                            columTypes:nil
                           primaryKeys:nil
                                values:nil
                             whereKeys:whereKeys
                           whereValues:whereValues
                               orderBy:nil
                                  sort:0];
    return self;
}


#pragma mark -- assemble sql
- (NSString *)sqlString {
    NSAssert(_orderType <= 4, @"wrong SQL orderType");
    NSAssert(_tableName, @"tableName could not be nil");
    NSAssert(_orderType == VPUPSQLOrderDelete || (_columNames && [_columNames count] != 0), @"columNames could not be nil or zero size");
    NSAssert([_whereKeys count] == [_whereValues count], @"whereKeys count must equal to whereValues count");
    if(_values && [_values count] != 0) {
        NSAssert([_values count] == [_columNames count], @"values count must equal to columNames count");
    }
    if(_columTypes && [_columTypes count] != 0) {
        NSAssert([_columTypes count] == [_columNames count], @"columTypes count must equal to columNames count");
    }
    
    NSMutableString *sql = [NSMutableString string];
    
    switch (_orderType) {
        case VPUPSQLOrderSelect: {
            [sql appendString:@"SELECT "];
            break;
        }
        case VPUPSQLOrderCreate: {
            [sql appendFormat:@"CREATE TABLE IF NOT EXISTS '%@' ", _tableName];
            break;
        }
        case VPUPSQLOrderInsert: {
            [sql appendFormat:@"INSERT INTO '%@' ", _tableName];
            break;
        }
        case VPUPSQLOrderUpdate: {
            [sql appendFormat:@"UPDATE '%@' ", _tableName];
            break;
        }
        case VPUPSQLOrderDelete: {
            [sql appendFormat:@"DELETE FROM '%@' ", _tableName];
            break;
        }
        default:
            break;
    }
    
    if(_orderType == VPUPSQLOrderCreate) {
        NSAssert(_columTypes, @"create table types could not be nil");
        NSMutableString *createSql = [NSMutableString stringWithString:@"("];
        [_columNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *colum = (NSString *)obj;
            NSString *type = [_columTypes objectAtIndex:idx];
            [createSql appendFormat:@"%@ %@", colum, type];
            if(idx != [_columNames count] - 1) {
                [createSql appendString:@", "];
            }
        }];
        
        if(_primaryKeys && [_primaryKeys count] > 0) {
            [createSql appendString:@", PRIMARY KEY("];
            [_primaryKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [createSql appendFormat:@"%@", obj];
                if(idx != [_primaryKeys count] - 1) {
                    [createSql appendString:@","];
                }
            }];
            [createSql appendString:@")"];
        }
        
        [createSql appendString:@")"];
        
        [sql appendString:createSql];
        return sql;
    }
    
    if(_orderType == VPUPSQLOrderInsert) {
        NSAssert(_values, @"insert values could not be nil");
        NSMutableString *insertSql = [NSMutableString stringWithString:@"("];
        [_columNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[NSNumber class]]) {
                [insertSql appendFormat:@"%@",obj];
            } else {
                [insertSql appendFormat:@"'%@'", obj];
            }
            if(idx != [_columNames count] - 1) {
                [insertSql appendString:@","];
            }
        }];
        [insertSql appendString:@") VALUES ("];
        [_values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *value = (NSString *)obj;
            [insertSql appendFormat:@"'%@'", value];
            if(idx != [_values count] - 1) {
                [insertSql appendString:@","];
            }
        }];
        [insertSql appendString:@")"];
        
        [sql appendString:insertSql];
        return sql;
    }
    
    if(_orderType == VPUPSQLOrderUpdate) {
        NSAssert(_values, @"update values could not be nil");
        NSMutableString *updateSql = [NSMutableString stringWithString:@"SET "];
        [_columNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            NSString *value = [_values objectAtIndex:idx];
            if ([value isKindOfClass:[NSNumber class]]) {
                [updateSql appendFormat:@"%@ = %@", obj, value];
            } else {
                [updateSql appendFormat:@"%@ = '%@' ", obj, value];
            }
            if(idx != [_columNames count] - 1) {
                [updateSql appendString:@", "];
            }
        }];
        
        [sql appendString:updateSql];
    }
    
    if(_orderType == VPUPSQLOrderSelect) {
        if(_values) {
            NSMutableString *selectSql = [NSMutableString string];
            [_values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *value = (NSString *)obj;
                NSString *colum = [_columNames objectAtIndex:idx];
                [selectSql appendFormat:@"%@ as '%@' ", value, colum];
                if(idx != [_columNames count] - 1) {
                    [selectSql appendString:@", "];
                }
            }];
            
            [sql appendString:selectSql];
        }
        else {
            [sql appendString:@"* "];
        }
        [sql appendFormat:@"FROM '%@' ", _tableName];
    }
    
    //where
    if(_whereKeys && [_whereKeys count] != 0) {
        NSMutableString *whereSql = [NSMutableString stringWithString:@"WHERE "];
        [_whereKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = (NSString *)obj;
            NSString *value = [_whereValues objectAtIndex:idx];
            if(VPUP_StringContainsString(value, @"%") ||
               VPUP_StringContainsString(value, @"_") ||
               (VPUP_StringContainsString(value, @"[") && VPUP_StringContainsString(value, @"]"))) {
                [whereSql appendFormat:@"%@ LIKE '%@' ", key, value];
            }
            else {
                [whereSql appendFormat:@"%@ = '%@' ", key, value];
            }
            if(idx != [_whereKeys count] - 1) {
                [whereSql appendString:@"AND "];
            }
        }];
        
        [sql appendString:whereSql];
    }
    
    //order
    if(_orderByColum) {
        NSString *orderString = @"";
        if(_sort == 0) {
            _sort = NSOrderedAscending;
        }
        
        switch (_sort) {
            case NSOrderedAscending: case NSOrderedSame: {
                orderString = @"ASC";
                break;
            }
            case NSOrderedDescending: {
                orderString = @"DESC";
            }
            default: {
                orderString = @"ASC";
                break;
            }
        }
        NSString *orderSql = [NSString stringWithFormat:@"orderby %@ %@", _orderByColum, orderString];
        
        [sql appendString:orderSql];
    }
    
    return sql;
}



@end
