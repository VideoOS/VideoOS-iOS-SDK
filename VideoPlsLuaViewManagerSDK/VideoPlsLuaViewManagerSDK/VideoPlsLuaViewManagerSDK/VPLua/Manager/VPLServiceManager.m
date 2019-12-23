//
//  VPLServiceManager.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/29.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLServiceManager.h"
#import "VPLServiceAd.h"
#import "VPLConstant.h"
#import "VPLServiceVideoMode.h"
#import "VPUPCommonTrack.h"

@interface VPLServiceManager()

@property (nonatomic, strong) NSMutableDictionary *serviceDict;

@end

@implementation VPLServiceManager

- (NSMutableDictionary *)serviceDict {
    if (!_serviceDict) {
        _serviceDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _serviceDict;
}

- (void)startService:(VPLServiceType )type config:(VPLServiceConfig *)config {
    if (config.identifier && (type == VPLServiceTypePreAdvertising || type == VPLServiceTypePostAdvertising || type == VPLServiceTypePauseAd)) {
        VPLServiceAd *adService = [[VPLServiceAd alloc] initWithConfig:config];
        [self.serviceDict setObject:adService forKey:@(type)];
        __weak typeof(self) weakSelf = self;
        [adService startServiceWithConfig:config complete:^(NSError *error) {
            if (!weakSelf) {
                return;
            }
            
            if (error) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(vp_didFailToCompleteForService:error:)]) {
                    [weakSelf.delegate vp_didFailToCompleteForService:(VPLServiceType)type error:error];
                }
                weakSelf.serviceDict[@(type)] = nil;
            }
        }];
    }
    else if(config.identifier && type == VPLServiceTypeVideoMode) {
        VPLServiceVideoMode *videoModeService = [[VPLServiceVideoMode alloc] initWithConfig:config];
        [self.serviceDict setObject:videoModeService forKey:@(type)];
        __weak typeof(self) weakSelf = self;
        [videoModeService startServiceWithConfig:config complete:^(NSError *error) {
            if (!weakSelf) {
                return;
            }
            
            if (error) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(vp_didFailToCompleteForService:error:)]) {
                    [weakSelf.delegate vp_didFailToCompleteForService:(VPLServiceType)type error:error];
                }
                weakSelf.serviceDict[@(type)] = nil;
            }
        }];
        [[VPUPCommonTrack shared] sendTrackWithType:VPUPCommonTrackTypeVideoNet dataDict:@{@"onOrOff":@"1"}];
    }
    else {
        NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-4001 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unsupported parameters"]}];
        if (self.delegate && [self.delegate respondsToSelector:@selector(vp_didFailToCompleteForService:error:)]) {
            [self.delegate vp_didFailToCompleteForService:(VPLServiceType)type error:error];
        }
    }
}

- (void)resumeService:(VPLServiceType )type {
    VPLService *service = [self.serviceDict objectForKey:@(type)];
    if (service && self.osView) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(VPLOSActionTypePause), @"osActionType",
                              @(VPLEventTypeOSAction), @"eventType",nil];
        [self.osView callLMethod:@"event" nodeId:service.serviceId data:dict];
    }
}

- (void)pauseService:(VPLServiceType )type {
    VPLService *service = [self.serviceDict objectForKey:@(type)];
    if (service && self.osView) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(VPLOSActionTypeResume), @"osActionType",
                              @(VPLEventTypeOSAction), @"eventType",nil];
        [self.osView callLMethod:@"event" nodeId:service.serviceId data:dict];
    }
}

- (void)stopService:(VPLServiceType)type {
    VPLService *service = [self.serviceDict objectForKey:@(type)];
    if (service && self.osView) {
        [self.osView removeViewWithNodeId:service.serviceId];
    }
    if (service && self.bubbleView) {
        [self.bubbleView removeViewWithNodeId:service.serviceId];
    }
    if (service && self.topView) {
        [self.topView removeViewWithNodeId:service.serviceId];
    }
    self.serviceDict[@(type)] = nil;
    if (type == VPLServiceTypeVideoMode) {
        [[VPUPCommonTrack shared] sendTrackWithType:VPUPCommonTrackTypeVideoNet dataDict:@{@"onOrOff":@"0"}];
    }
}

@end
