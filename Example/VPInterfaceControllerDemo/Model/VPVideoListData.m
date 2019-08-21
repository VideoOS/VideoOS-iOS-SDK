//
//  VPVideoListData.m
//  VPInterfaceControllerDemo
//
//  Created by Zard1096-videojj on 2019/8/6.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPVideoListData.h"
#import "VPModel+DictionaryToModel.h"

static VPVideoListData *shared = nil;

@implementation VPVideoListData

+ (VPVideoListData *)shared {
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
        NSString *dataPath = [VPVideoListData configPath];
        NSArray *dataArray = [NSArray arrayWithContentsOfFile:dataPath];
        if (dataArray != nil) {
            _data = [NSMutableArray array];
            for (NSDictionary *dict in dataArray) {
                VPVideoData *configData = [VPVideoData modelWithDictionary:dict];
                if (configData != nil) {
                    [_data addObject:configData];
                }
            }
        }
    }
}

- (void)addVideoData:(VPVideoData *)videoData {
    if (videoData.videoId != nil && videoData.videoUrl != nil) {
        NSInteger appKeyPosition = -1;
        NSInteger appSecretPosition = -1;
        for (VPVideoData *config in _data) {
            if ([config.videoId isEqualToString:videoData.videoId]) {
                appKeyPosition = [_data indexOfObject:config];
            }
            if ([config.videoUrl isEqualToString:videoData.videoUrl]) {
                appSecretPosition = [_data indexOfObject:config];
            }
        }
        
        if (appKeyPosition != -1 && appKeyPosition == appSecretPosition) {
            return;
        }
        
        [_data addObject:videoData];
        
        NSMutableArray *writeArray = [NSMutableArray array];
        for (VPVideoData *config in _data) {
            NSDictionary *dict = [config modelToDictionary];
            [writeArray addObject:dict];
        }
        
        [writeArray writeToFile:[VPVideoListData configPath] atomically:YES];
    }
}

+ (NSString *)configPath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    path = [path stringByAppendingPathComponent:@"video.plist"];
    return path;
}

- (NSArray *)videoUrlArray {
    NSMutableArray *array = [NSMutableArray array];
    for (VPVideoData *config in _data) {
        [array addObject:config.videoUrl];
    }
    
    return array;
}

- (NSArray *)videoIdArray {
    NSMutableArray *array = [NSMutableArray array];
    for (VPVideoData *config in _data) {
        [array addObject:config.videoId];
    }
    
    return array;
}

@end
