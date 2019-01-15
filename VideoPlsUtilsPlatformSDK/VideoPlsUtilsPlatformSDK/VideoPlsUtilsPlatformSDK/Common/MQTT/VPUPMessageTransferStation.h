//
//  VPUPMessageTransferStation.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/26.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VPUPMQTTObserverProtocol;

@interface VPUPMessageTransferStation : NSObject

- (void)attachWithObserver:(id<VPUPMQTTObserverProtocol>)observer;

- (void)detachWithObserver:(id<VPUPMQTTObserverProtocol>)observer;

- (void)addTopic:(NSString *)topic observer:(id<VPUPMQTTObserverProtocol>)observer;

@end
