//
//  VPLService.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLService.h"

@implementation VPLServiceConfig

@end

@implementation VPLService

- (instancetype)initWithConfig:(VPLServiceConfig *)config {
    self = [super init];
    if (self) {
        _videoId = config.identifier;
        _type = config.type;
        _videoModeType = config.videoModeType;
        _eyeOriginPoint = config.eyeOriginPoint;
    }
    return self;
}

@end
