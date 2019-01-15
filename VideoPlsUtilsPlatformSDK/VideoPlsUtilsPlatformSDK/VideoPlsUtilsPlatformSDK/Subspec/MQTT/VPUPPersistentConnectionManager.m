//
//  VPUPPersistentConnectionManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/27.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPPersistentConnectionManager.h"
#import "VPUPMQTTManagerFactory.h"
#import "VPUPJsonUtil.h"
#import "VPUPMQTTManager.h"
#import "VPUPMQTTHeader.h"
#import "VPUPLogUtil.h"
#import "VPUPServiceManager.h"

@interface VPUPPersistentConnectionManager() <VPUPMQTTObserverProtocol>

@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) id<VPUPMQTTManager> mqttManager;

@end


@implementation VPUPPersistentConnectionManager

+ (void)load {
    [[VPUPServiceManager sharedManager] registerService:@protocol(VPUPPersistentConnectionDelegate) implClass:[VPUPPersistentConnectionManager class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mqttManager = [VPUPMQTTManagerFactory createMQTTManagerWithType:VPUPMQTTManagerTypeMosquitto];
        [self.mqttManager attachWithObserver:self];
        _topics = [NSMutableArray array];
    }
    return self;
}

- (void)addTopic:(NSString *)topic {
    [self.mqttManager addTopic:topic observer:self];
    [self.topics addObject:topic];
}

- (void)removeTopic:(NSString *)topic {
    if (self.topics.count > 0) {
        [self.topics removeObject:topic];
    }
    if (self.topics.count == 0) {
        [self.mqttManager detachWithObserver:self];
    }
}

- (void)onMessage:(id)dictionary {
    @try {
        if([dictionary isKindOfClass:[NSError class]]) {
            VPUPLogER(@"%@",(NSError *)dictionary);
        }
        else {
            if (self.observerDelegate && [self.observerDelegate respondsToSelector:@selector(notifyTopic:message:)]) {
                [self.observerDelegate notifyTopic:[dictionary objectForKey:@"topic"] message:VPUP_DictionaryToJson(dictionary)];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

@end
