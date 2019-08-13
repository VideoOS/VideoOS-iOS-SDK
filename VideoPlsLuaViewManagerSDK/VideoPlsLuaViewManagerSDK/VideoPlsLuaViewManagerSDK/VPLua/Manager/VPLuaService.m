//
//  VPLuaService.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaService.h"

@implementation VPLuaServiceConfig

@end

@implementation VPLuaService

- (instancetype)initWithConfig:(VPLuaServiceConfig *)config {
    self = [super init];
    if (self) {
        _videoId = config.identifier;
        _type = config.type;
    }
    return self;
}

@end
