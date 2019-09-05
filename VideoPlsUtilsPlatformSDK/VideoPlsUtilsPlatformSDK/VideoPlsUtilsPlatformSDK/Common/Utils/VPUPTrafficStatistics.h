//
//  VPUPTrafficStatistics.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096-videojj on 2019/8/19.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VPUPTrafficType) {
    VPUPTrafficTypeInitApp      = 0,
    VPUPTrafficTypeOpenVideo    = 1,
    VPUPTrafficTypeRealTime     = 2
};

@interface VPUPTrafficStatisticsObject : NSObject

@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *fileUrl;
@property (nonatomic) NSUInteger fileSize;

- (instancetype)initWithFileName:(NSString *)fileName fileUrl:(NSString *)fileUrl fileSize:(NSInteger)fileSize;

@end

@interface VPUPTrafficStatisticsList : NSObject

@property (nonatomic) NSMutableArray<VPUPTrafficStatisticsObject *> *statisticsArray;

- (void)addFileTrafficByName:(NSString *)fileName fileUrl:(NSString *)fileUrl filePath:(NSString *)path;
- (void)addTrafficNoSizeByName:(NSString *)fileName fileUrl:(NSString *)fileUrl;

@end


@interface VPUPTrafficStatistics : NSObject

+ (void)sendTrafficeStatistics:(VPUPTrafficStatisticsList *)list type:(VPUPTrafficType)type;

@end
