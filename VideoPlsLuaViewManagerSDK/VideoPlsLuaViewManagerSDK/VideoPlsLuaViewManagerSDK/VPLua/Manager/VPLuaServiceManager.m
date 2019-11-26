//
//  VPLuaServiceManager.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/29.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaServiceManager.h"
#import "VPLuaServiceAd.h"
#import "VPLuaConstant.h"
#import "VPLuaServiceVideoMode.h"
#import "VPLuaTrackManager.h"

@interface VPLuaServiceManager()

@property (nonatomic, strong) NSMutableDictionary *serviceDict;

@end

@implementation VPLuaServiceManager

- (NSMutableDictionary *)serviceDict {
    if (!_serviceDict) {
        _serviceDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _serviceDict;
}

- (void)startService:(VPLuaServiceType )type config:(VPLuaServiceConfig *)config {
    if (config.identifier && (type == VPLuaServiceTypePreAdvertising || type == VPLuaServiceTypePostAdvertising || type == VPLuaServiceTypePauseAd)) {
        VPLuaServiceAd *adService = [[VPLuaServiceAd alloc] initWithConfig:config];
        [self.serviceDict setObject:adService forKey:@(type)];
        __weak typeof(self) weakSelf = self;
        [adService startServiceWithConfig:config complete:^(NSError *error) {
            if (!weakSelf) {
                return;
            }
            
            if (error) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(vp_didFailToCompleteForService:error:)]) {
                    [weakSelf.delegate vp_didFailToCompleteForService:(VPLuaServiceType)type error:error];
                }
                weakSelf.serviceDict[@(type)] = nil;
            }
        }];
    }
    else if(config.identifier && type == VPLuaServiceTypeVideoMode) {
        VPLuaServiceVideoMode *videoModeService = [[VPLuaServiceVideoMode alloc] initWithConfig:config];
        [self.serviceDict setObject:videoModeService forKey:@(type)];
        __weak typeof(self) weakSelf = self;
        [videoModeService startServiceWithConfig:config complete:^(NSError *error) {
            if (!weakSelf) {
                return;
            }
            
            if (error) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(vp_didFailToCompleteForService:error:)]) {
                    [weakSelf.delegate vp_didFailToCompleteForService:(VPLuaServiceType)type error:error];
                }
                weakSelf.serviceDict[@(type)] = nil;
            }
        }];
        [VPLuaTrackManager trackVideoModeSwitch:YES];
    }
    else {
        NSError *error = [NSError errorWithDomain:VPLuaErrorDomain code:-4001 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unsupported parameters"]}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(vp_didFailToCompleteForService:error:)]) {
            [self.delegate vp_didFailToCompleteForService:(VPLuaServiceType)type error:error];
        }
    }
}

- (void)resumeService:(VPLuaServiceType )type {
    VPLuaService *service = [self.serviceDict objectForKey:@(type)];
    if (service && self.osView) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(VPLuaOSActionTypePause), @"osActionType",
                              @(VPLuaEventTypeOSAction), @"eventType",nil];
        [self.osView callLuaMethod:@"event" nodeId:service.serviceId data:dict];
    }
}

- (void)pauseService:(VPLuaServiceType )type {
    VPLuaService *service = [self.serviceDict objectForKey:@(type)];
    if (service && self.osView) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(VPLuaOSActionTypeResume), @"osActionType",
                              @(VPLuaEventTypeOSAction), @"eventType",nil];
        [self.osView callLuaMethod:@"event" nodeId:service.serviceId data:dict];
    }
}

- (void)stopService:(VPLuaServiceType)type {
    VPLuaService *service = [self.serviceDict objectForKey:@(type)];
    if (service && self.osView) {
        [self.osView removeViewWithNodeId:service.serviceId];
    }
    if (service && self.bubbleView) {
        [self.bubbleView removeViewWithNodeId:service.serviceId];
    }
    self.serviceDict[@(type)] = nil;
    if (type == VPLuaServiceTypeVideoMode) {
        [VPLuaTrackManager trackVideoModeSwitch:NO];
    }
}

@end
