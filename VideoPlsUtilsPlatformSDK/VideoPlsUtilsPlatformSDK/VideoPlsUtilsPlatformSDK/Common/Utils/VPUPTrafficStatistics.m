//
//  VPUPTrafficStatistics.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096-videojj on 2019/8/19.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPUPTrafficStatistics.h"
#import "VPUPCommonTrack.h"

@implementation VPUPTrafficStatisticsObject

- (instancetype)initWithFileName:(NSString *)fileName fileUrl:(NSString *)fileUrl fileSize:(NSInteger)fileSize {
    self = [super init];
    if (self) {
        self.fileName = fileName;
        self.fileUrl = fileUrl;
        self.fileSize = fileSize;
    }
    return self;
}

@end

@implementation VPUPTrafficStatisticsList

- (instancetype)init {
    self = [super init];
    if (self) {
        _statisticsArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)addFileTrafficByName:(NSString *)fileName fileUrl:(NSString *)fileUrl filePath:(NSString *)path {
    
    if (fileName == nil || path == nil || fileUrl == nil) {
        return;
    }
    
    NSDictionary *attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    if (attribute && [attribute objectForKey:NSFileSize]) {
        NSNumber *fileSize = [attribute objectForKey:NSFileSize];
        VPUPTrafficStatisticsObject *object = [[VPUPTrafficStatisticsObject alloc] initWithFileName:fileName fileUrl:fileUrl fileSize:[fileSize unsignedIntegerValue]];
        
        [_statisticsArray addObject:object];
    }
}

- (void)addTrafficNoSizeByName:(NSString *)fileName fileUrl:(NSString *)fileUrl {
    
    if (fileName == nil || fileUrl == nil) {
        return;
    }
    
    VPUPTrafficStatisticsObject *object = [[VPUPTrafficStatisticsObject alloc] initWithFileName:fileName fileUrl:fileUrl fileSize:0];
        
    [_statisticsArray addObject:object];
}

- (NSMutableArray<NSDictionary *> *)dictionaryValue {
    if (self.statisticsArray.count == 0) {
        return nil;
    }
    NSMutableArray *dictArray = [NSMutableArray arrayWithCapacity:self.statisticsArray.count];
    for (VPUPTrafficStatisticsObject *object in self.statisticsArray) {
        NSDictionary *dict = @{
                               @"fileName"  : object.fileName,
                               @"filePath"  : object.fileUrl,
                               @"fileSize"  : @(object.fileSize)
                              };
        [dictArray addObject:dict];
    }
    return dictArray;
}

@end
 

@implementation VPUPTrafficStatistics

+ (void)sendTrafficeStatistics:(VPUPTrafficStatisticsList *)list type:(VPUPTrafficType)type {
    
    if (!list || list.statisticsArray.count == 0) {
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSArray *fileInfo = [list dictionaryValue];
    if (!fileInfo) {
        return;
    }
    [param setObject:fileInfo forKey:@"fileInfo"];
    [param setObject:@(type) forKey:@"downLoadStage"];
    
    [[VPUPCommonTrack shared] sendTrackWithType:VPUPCommonTrackTypeTraffic dataDict:param];
}

@end
