//
//  VPLuaCapacityManager.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/4/27.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaCapacityManager.h"

static VPLuaCapacityManager *_serviceManager = nil;
static dispatch_once_t onceToken;

@interface VPLuaCapacityManager ()

@property (nonatomic, strong) VPUPMessageTransferStation *messageTransferStation;

@end

@implementation VPLuaCapacityManager

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
