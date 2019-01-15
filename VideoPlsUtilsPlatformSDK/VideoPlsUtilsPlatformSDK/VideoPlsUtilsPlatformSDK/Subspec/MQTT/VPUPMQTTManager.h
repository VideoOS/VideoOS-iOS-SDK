//
//  VPUPMQTTManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPMQTTEnum.h"

@class VPUPMQTTConfig;
@protocol VPUPMQTTObserverProtocol;

@protocol VPUPMQTTManager <NSObject>

- (instancetype)init;

//需要先attach之后再加topic,否则无效
- (void)attachWithObserver:(id<VPUPMQTTObserverProtocol>)observer;

//结束必须detach,否则不会释放
- (void)detachWithObserver:(id<VPUPMQTTObserverProtocol>)observer;

//attach之后可以获取clientID
- (NSString *)getClientID;


- (void)addTopic:(NSString *)topic observer:(id<VPUPMQTTObserverProtocol>)observer;

- (void)addTopics:(NSArray<NSString *> *)topic observer:(id<VPUPMQTTObserverProtocol>)observer;

- (void)addTopic:(NSString *)topic qos:(VPUPMQTTQoSLevel)qos observer:(id<VPUPMQTTObserverProtocol>)observer;

@end
