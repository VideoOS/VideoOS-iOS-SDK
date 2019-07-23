//
//  VPConfigListData.m
//  VideoOSDemo
//
//  Created by Zard1096-videojj on 2019/2/26.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPConfigListData.h"
#import "VPModel+DictionaryToModel.h"

static VPConfigListData *shared = nil;

@implementation VPConfigListData

+ (VPConfigListData *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _selectedIndex = -1;
        [self initData];
    }
    
    return self;
}

- (void)initData {
    if (_data == nil) {
        _data = [NSMutableArray array];
        NSString *dataPath = [VPConfigListData configPath];
        NSArray *dataArray = [NSArray arrayWithContentsOfFile:dataPath];
        if (dataArray != nil) {
            _data = [NSMutableArray array];
            for (NSDictionary *dict in dataArray) {
                VPConfigData *configData = [VPConfigData modelWithDictionary:dict];
                if (configData != nil) {
                    [_data addObject:configData];
                }
            }
        }
    }
}

- (void)addConfigData:(VPConfigData *)configData {
    if (configData.appKey != nil && configData.appSecret != nil) {
        NSInteger appKeyPosition = -1;
        NSInteger appSecretPosition = -1;
        for (VPConfigData *config in _data) {
            if ([config.appKey isEqualToString:configData.appKey]) {
                appKeyPosition = [_data indexOfObject:config];
            }
            if ([config.appSecret isEqualToString:configData.appSecret]) {
                appSecretPosition = [_data indexOfObject:config];
            }
        }
        
        if (appKeyPosition != -1 && appKeyPosition == appSecretPosition) {
            return;
        }
        
        [_data addObject:configData];
        
        NSMutableArray *writeArray = [NSMutableArray array];
        for (VPConfigData *config in _data) {
            NSDictionary *dict = [config modelToDictionary];
            [writeArray addObject:dict];
        }
        
        [writeArray writeToFile:[VPConfigListData configPath] atomically:YES];
    }
}

+ (NSString *)configPath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    path = [path stringByAppendingPathComponent:@"config.plist"];
    return path;
}

- (NSArray *)appKeyArray {
    NSMutableArray *array = [NSMutableArray array];
    for (VPConfigData *config in _data) {
        [array addObject:config.appKey];
    }
    
    return array;
}

- (NSArray *)appSecretArray {
    NSMutableArray *array = [NSMutableArray array];
    for (VPConfigData *config in _data) {
        [array addObject:config.appSecret];
    }
    
    return array;
}

@end
