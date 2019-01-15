//
//  VPUPMQTTObserverProtocol.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VPUPMQTTObserverProtocol <NSObject>

@optional

- (dispatch_queue_t)getCallbackQueue;

- (void)onSubscribeTopic:(NSString *)topic;

- (void)onMessage:(id)message;

@end
