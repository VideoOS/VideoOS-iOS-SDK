//
//  VPUPPersistentConnectionDelegate.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/26.
//  Copyright © 2018 videopls. All rights reserved.
//

#ifndef VPUPPersistentConnectionDelegate_h
#define VPUPPersistentConnectionDelegate_h


@protocol VPUPPersistentConnectionObserverDelegate <NSObject>

- (void)notifyTopic:(NSString *)topic message:(NSString *)message;

@end

@protocol VPUPPersistentConnectionDelegate<NSObject>

@property (nonatomic, weak) id<VPUPPersistentConnectionObserverDelegate> observerDelegate;

@optional

- (void)addTopic:(NSString *)topic;

- (void)removeTopic:(NSString *)topic;

@end

#endif /* VPUPPersistentConnectionDelegate_h */
