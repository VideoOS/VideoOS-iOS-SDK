//
//  VPUPMessageTransferStation.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/26.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPMessageTransferStation.h"
#import "VPUPMQTTObserverProtocol.h"
#import "VPUPServiceManager.h"
#import "VPUPPersistentConnectionDelegate.h"
#import "VPUPJsonUtil.h"
#import "VPUPPersistentConnectionFactory.h"

@interface VPUPMessageTransferStation () <VPUPPersistentConnectionObserverDelegate>

@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *topicObservers;
@property (nonatomic, strong) NSMutableArray *observers;
@property (nonatomic, strong) dispatch_queue_t operationQueue;
@property (nonatomic, strong) id<VPUPPersistentConnectionDelegate> persistentConnection;

@end

@implementation VPUPMessageTransferStation

- (instancetype)init {
    self = [super init];
    if (self) {
        _persistentConnection = [VPUPPersistentConnectionFactory createPersistentConnectionWithType:VPUPPersistentConnectionTypeCustom];
        if (!_persistentConnection) {
            return nil;
        }
        _persistentConnection.observerDelegate = self;
    }
    return self;
}

- (void)dealloc {
//    NSLog(@"VPUPMessageTransferStation dealloc");
    for (NSString *topic in self.topics) {
        [self.persistentConnection removeTopic:topic];
    }
}

- (NSMutableArray *)topics {
    if (!_topics) {
        _topics = [NSMutableArray array];
    }
    return _topics;
}

- (NSMutableDictionary<NSString *, NSMutableArray *> *)topicObservers {
    if (!_topicObservers) {
        _topicObservers = [NSMutableDictionary dictionary];
    }
    return _topicObservers;
}

- (NSMutableArray *)observers {
    if (!_observers) {
        _observers = [NSMutableArray array];
    }
    return _observers;
}

- (dispatch_queue_t)operationQueue {
    if (!_operationQueue) {
        _operationQueue =  dispatch_queue_create("com.videopls.platform.MessageTransferStaion.operationQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _operationQueue;
}

- (void)attachWithObserver:(id<VPUPMQTTObserverProtocol>)observer {
    if(![self.observers containsObject:observer]) {
        __weak typeof(self) weakSelf = self;
        dispatch_sync(self.operationQueue,^{
           [weakSelf.observers addObject:(observer)];
        });
    }
}

- (void)detachWithObserver:(id<VPUPMQTTObserverProtocol>)observer {
//    __weak typeof(self) weakSelf = self;
    __block NSMutableArray *removeTopics = [NSMutableArray array];
    [self.topicObservers enumerateKeysAndObjectsUsingBlock:^(NSString *topic, NSMutableArray *observers, BOOL *stop) {
        if ([observers containsObject:observer]) {
            [observers removeObject:observer];
        }
        if (observers.count == 0) {
            [removeTopics addObject:topic];
        }
    }];
    
    if (removeTopics.count > 0) {
        for (NSString *topic in removeTopics) {
            [self.topicObservers removeObjectForKey:topic];
            [self.topics removeObject:topic];
            [self.persistentConnection removeTopic:topic];
        }
    }
}

- (void)addTopic:(NSString *)topic observer:(id<VPUPMQTTObserverProtocol>)observer {
    if(![self.observers containsObject:observer]) {
        return;
    }
    
    if ([self.topicObservers objectForKey:topic]) {
        NSMutableArray *observers = [self.topicObservers objectForKey:topic];
        if ([observers containsObject:observer]) {
            [observers addObject:(observer)];
        }
    }
    else {
        [self.topics addObject:topic];
        NSMutableArray *observers = [NSMutableArray array];
        [observers addObject:(observer)];
        [self.topicObservers setObject:observers forKey:topic];
        [self.persistentConnection addTopic:topic];
    }
}

- (dispatch_queue_t)getQueueByObserver:(id<VPUPMQTTObserverProtocol>)observer {
    dispatch_queue_t callbackQueue = nil;
    if([observer respondsToSelector:@selector(getCallbackQueue)]) {
        callbackQueue = [observer getCallbackQueue];
    }
    callbackQueue = callbackQueue ?: dispatch_get_main_queue();
    return callbackQueue;
}

- (void)notifyTopic:(NSString *)topic message:(NSString *)message {
    
    NSDictionary *dictionary = VPUP_JsonToDictionary(message);
    
    if (!dictionary) {
        return;
    }
    
    NSArray *observers = [self.topicObservers objectForKey:topic];
    
    if (observers.count > 0) {
        [observers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id<VPUPMQTTObserverProtocol> observer = obj;
            if([observer respondsToSelector:@selector(onMessage:)]) {
                
                dispatch_async([self getQueueByObserver:observer], ^{
                    [observer onMessage:dictionary];
                });
            }
        }];
    }
}

@end
