//
//  VPLCapacityManager.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/4/27.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLCapacityManager.h"

static VPLCapacityManager *_serviceManager = nil;
static dispatch_once_t onceToken;

@interface VPLCapacityManager ()

@property (nonatomic, strong) VPUPMessageTransferStation *messageTransferStation;

@end

@implementation VPLCapacityManager

+ (instancetype)sharedManager {
    return _serviceManager;
}

+ (void)startService {
    dispatch_once(&onceToken, ^{
        _serviceManager = [[self alloc] init];
    });
}

+ (void)stopService {
    onceToken = 0;
    _serviceManager = nil;
}

- (VPUPMessageTransferStation *)messageTransferStation {
    if (!_messageTransferStation) {
        _messageTransferStation = [[VPUPMessageTransferStation alloc] init];
    }
    return _messageTransferStation;
}

@end
