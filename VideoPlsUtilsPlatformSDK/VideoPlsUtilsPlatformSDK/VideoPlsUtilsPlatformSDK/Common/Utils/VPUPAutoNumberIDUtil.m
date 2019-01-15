//
//  VPUPAutoNumberIDUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/19.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPAutoNumberIDUtil.h"

static NSUInteger uniqueID = 0;
static NSUInteger reportID = 0;

static dispatch_queue_t auto_number_creation_queue() {
    static dispatch_queue_t vpup_auto_number_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vpup_auto_number_creation_queue = dispatch_queue_create("com.videopls.vpup.auto.number.creation", DISPATCH_QUEUE_SERIAL);
    });
    
    return vpup_auto_number_creation_queue;
}

@implementation VPUPAutoNumberIDUtil

//不考虑单次app启动的越界问题
+ (NSUInteger)getUniqueID {
    __block NSUInteger tempUniqueID = 0;
    dispatch_sync(auto_number_creation_queue(), ^{
        tempUniqueID = uniqueID++;
    });
    return tempUniqueID;
}

+ (NSUInteger)getReportID {
    __block NSUInteger tempReportID = 0;
    dispatch_sync(auto_number_creation_queue(), ^{
        tempReportID = reportID++;
    });
    return tempReportID;
}

@end
