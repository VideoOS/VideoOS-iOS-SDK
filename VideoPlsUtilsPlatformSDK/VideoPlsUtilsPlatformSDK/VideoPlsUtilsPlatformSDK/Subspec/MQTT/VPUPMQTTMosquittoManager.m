//
//  VPUPMQTTMosquittoManager.m
//  VideoPlsCytronSDK
//
//  Created by Zard1096 on 16/7/13.
//  Copyright © 2016年 videopls.com. All rights reserved.
//

#import "VPUPMQTTMosquittoManager.h"
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTLog.h>
#import "VPUPMQTTObserverProtocol.h"
#import "VPUPMQTTConfig.h"
#import "vpup_mqtt_default_config.h"
#import "VPUPRandomUtil.h"
#import "VPUPGeneralInfo.h"
#import "VPUPCommonEncryption.h"
#import "VPUPNotificationCenter.h"
#import "VPUPLifeCycle.h"

@interface VPUPMQTTMosquittoManager()<MQTTSessionDelegate> {
    
}

@property (nonatomic, strong) MQTTSession *session;
@property (nonatomic, strong) dispatch_queue_t mqttQueue;;
@property (nonatomic, assign) NSInteger failedCount;
@property (nonatomic, assign) BOOL isDisconnected;
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) BOOL connectOn;
@property (nonatomic, assign) BOOL canConnect;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *topicObservers;
@property (nonatomic, strong) NSMutableArray *observers;

@end

static dispatch_queue_t mqtt_manager_queue() {
    static dispatch_queue_t vpup_mqtt_manager_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vpup_mqtt_manager_queue = dispatch_queue_create("com.videopls.mqtt.manager.queue", DISPATCH_QUEUE_SERIAL);
    });
    return vpup_mqtt_manager_queue;
}

@implementation VPUPMQTTMosquittoManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.failedCount = 0;
        self.topicObservers = [NSMutableDictionary dictionary];
        self.canConnect = YES;
    }
    return self;
}

- (MQTTSession *)createSessionWithConfig:(VPUPMQTTConfig *)config {
    [MQTTLog setLogLevel:DDLogLevelOff];
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = config.serverURL;
    transport.port = (UInt32)config.serverPort;
    
    MQTTSession *session = [[MQTTSession alloc] init];
    session.transport = transport;
    session.clientId = config.clientID;
    session.userName = config.userName;
    session.password = config.password;
    session.cleanSessionFlag = YES;
    session.keepAliveInterval = 60;
    session.delegate = self;
    __weak typeof(self) weakSelf = self;
    [session setMessageHandler:^(NSData* message, NSString* topic) {
        [weakSelf onMessage:message topic:topic];
    }];
    [session setConnectionHandler:^(MQTTSessionEvent event) {
        if (event == MQTTSessionEventConnectionError) {
            [weakSelf onDisconnect:event];
        }
    }];
    
    return session;
}

- (void)addTopic:(NSString *)topic observer:(id<VPUPMQTTObserverProtocol>)observer {
    [self addTopic:topic qos:MQTTQoSLevelAtMostOnce observer:observer];
}

//- (void)addTopic:(NSString *)topic qos:(VPUPMQTTQoSLevel)qos observer:(id<VPUPMQTTObserverProtocol>)observer {
//    if(![_observers containsObject:observer]) {
//        return;
//    }
//
//
//    if([_topicObservers objectForKey:topic]) {
//        NSMutableArray *observers = [_topicObservers objectForKey:topic];
//        if(![observers containsObject:observer]) {
//            [observers addObject:(observer)];
//
//            if([observer respondsToSelector:@selector(onSubscribeTopic:)]) {
//                dispatch_async([self getQueueByObserver:observer], ^{
//                    [observer onSubscribeTopic:topic];
//                });
//            }
//
//        }
//    }
//    else {
//        NSMutableArray *observers = [NSMutableArray array];
//        @synchronized(_topicObservers) {
//            [_topicObservers setObject:observers forKey:[topic copy]];
//        }
//
//        [observers addObject:(observer)];
//
//        if(_connectOn) {
//            [self subscribeTopic:topic qos:qos];
//        }
//    }
//
//}

- (void)addTopic:(NSString *)topic qos:(VPUPMQTTQoSLevel)qos observer:(id<VPUPMQTTObserverProtocol>)observer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(mqtt_manager_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || !observer) {
            return;
        }
        if(![strongSelf.observers containsObject:observer]) {
            return;
        }
        
        if([strongSelf.topicObservers objectForKey:topic]) {
            NSMutableArray *observers = [strongSelf.topicObservers objectForKey:topic];
            if(![observers containsObject:observer]) {
                [observers addObject:(observer)];
                
                if([observer respondsToSelector:@selector(onSubscribeTopic:)]) {
                    dispatch_async([strongSelf getQueueByObserver:observer], ^{
                        [observer onSubscribeTopic:topic];
                    });
                }
                
            }
        }
        else {
            NSMutableArray *observers = [NSMutableArray array];
            @synchronized(strongSelf.topicObservers) {
                [strongSelf.topicObservers setObject:observers forKey:[topic copy]];
            }
            
            [observers addObject:(observer)];
            
            if(strongSelf.connectOn) {
                [strongSelf subscribeTopic:topic];
            }
        }
    });
}

- (void)addTopics:(NSArray<NSString *> *)topic observer:(id<VPUPMQTTObserverProtocol>)observer {
    [topic enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addTopic:obj observer:observer];
    }];
}


- (void)attachWithObserver:(id<VPUPMQTTObserverProtocol>)observer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(mqtt_manager_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf.canConnect) {
            return;
        }
        
        if(!strongSelf.connectOn && !strongSelf.isConnecting) {
            [strongSelf connectWithConfig:nil];
        }
        
        if(!strongSelf.observers) {
            strongSelf.observers = [NSMutableArray array];
        }
        
        if(![strongSelf.observers containsObject:observer]) {
            [strongSelf.observers addObject:(observer)];
        }
    });
}

- (void)detachWithObserver:(id<VPUPMQTTObserverProtocol>)observer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(mqtt_manager_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf.topicObservers.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *observers = [strongSelf.topicObservers objectForKey:obj];
            
            if([observers containsObject:observer]) {
                [observers removeObject:observer];
                
                if([observers count] == 0) {
                    //unsbscribe topic
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf unsubscribeTopic:obj];
                    });
                }
            }
        }];
        
        if([strongSelf.observers containsObject:observer]) {
            [strongSelf.observers removeObject:observer];
        }
    });
}

- (NSString *)getClientID {
    if(self.session) {
        return self.session.clientId;
    }
    return nil;
}

- (VPUPMQTTConfig *)createDefaultConfig {
    NSDictionary *mqttConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttConfig"];
    if (!mqttConfig) {
        return nil;
    }
    NSString *host = [mqttConfig objectForKey:@"host"];
    NSUInteger port = [[mqttConfig objectForKey:@"port"] integerValue];
    NSString *userName = nil;
    NSString *password = nil;
    NSString *clientID = nil;
    
    NSString *identifier = [NSString stringWithFormat:@"%@", [VPUPGeneralInfo userIdentity]];
    identifier = [identifier stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[VPUPRandomUtil randomNumberByLength:999]]];
    
    unsigned char *customer_id = (unsigned char *)malloc(sizeof(unsigned char) * 12);
    vpup_mqtt_default_customer_id(customer_id);
    NSString *customerID = [NSString stringWithUTF8String:(const char *)customer_id];
    clientID = [NSString stringWithFormat:@"%@@@@%@",customerID,identifier];
    
//    unsigned char *user_name = (unsigned char *)malloc(sizeof(unsigned char) * 17);
//    vpup_mqtt_default_user_name(user_name);
//    userName = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:(const char *)user_name]];
//
//    unsigned char *password_key = (unsigned char *)malloc(sizeof(unsigned char) * 31);
//    vpup_mqtt_default_key(password_key);
//    NSString *key = [NSString stringWithUTF8String:(const char *)password_key];
//    password = [VPUPCommonEncryption mqttEncryptionWithData:customerID key:key];
    userName = [mqttConfig objectForKey:@"username"];
    password = [mqttConfig objectForKey:@"password"];
    if (!userName) {
        userName = @"";
    }
    if(!password) {
        password = @"";
    }
    
    VPUPMQTTConfig *config = [[VPUPMQTTConfig alloc] initWithServerURL:[host mutableCopy]
                                                            serverPort: port
                                                              userName:[userName mutableCopy]
                                                              password:[password mutableCopy]
                                                              clientID:[clientID mutableCopy]];
    
    free(customer_id);
//    free(user_name);
//    free(password_key);
    return config;
}

- (void)connectWithConfig:(VPUPMQTTConfig *)config {
    
    // create mqttQueue
    self.isConnecting = YES;
    
    if(!self.mqttQueue) {
        const char *mqttQueueString = [[NSString stringWithFormat:@"com.videopls.cytron.mqttQueue"] cStringUsingEncoding:NSUTF8StringEncoding];
        self.mqttQueue = dispatch_queue_create(mqttQueueString, DISPATCH_QUEUE_CONCURRENT);
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.mqttQueue, ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        VPUPMQTTConfig *useConfig = config;
        
        if(!useConfig) {
            useConfig = [strongSelf createDefaultConfig];
        }
        
        MQTTSession *session = [strongSelf createSessionWithConfig:useConfig];
        
        strongSelf.isDisconnected = NO;
        [session connectWithConnectHandler:^(NSError *error){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.isConnecting = NO;
            if(!error) {
                strongSelf.connectOn = YES;
                [strongSelf subscribeTopics];
            }
        }];
        
        if(strongSelf.isDisconnected) {
            [session disconnect];
            session = nil;
            return;
        }
        
        strongSelf.session = session;
        
    });
}

#pragma disconnect
- (void)disconnect {
    if(self.isDisconnected) {
        return;
    }
    if(self.session) {
        self.isDisconnected = YES;
        [self.session disconnect];
        self.session = nil;
    }
}

#pragma subscribe
- (void)subscribeTopics {
    __weak typeof(self) weakSelf = self;
    dispatch_async(mqtt_manager_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf.topicObservers || [strongSelf.topicObservers.allKeys count] == 0) {
            return;
        }
        
        for(NSString *topic in strongSelf.topicObservers.allKeys) {
            [strongSelf subscribeTopic:topic];
        }
    });
}

- (void)subscribeTopic:(NSString *)topic {
    [self subscribeTopic:topic qos:MQTTQoSLevelAtMostOnce];
}

- (void)subscribeTopic:(NSString *)topic qos:(VPUPMQTTQoSLevel)qos {
    __weak typeof(self) weakSelf = self;
    [self.session subscribeToTopic:topic atLevel:MQTTQosLevelAtMostOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        dispatch_async(mqtt_manager_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSArray *observers = [strongSelf.topicObservers objectForKey:topic];
            if([observers count] == 0) {
                [strongSelf unsubscribeTopic:topic];
                return;
            }
            [observers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id<VPUPMQTTObserverProtocol> observer = obj;
                if([observer respondsToSelector:@selector(onSubscribeTopic:)]) {
                    dispatch_async([strongSelf getQueueByObserver:observer], ^{
                        [observer onSubscribeTopic:topic];
                    });
                }
            }];
        });
    }];
}

- (void)unsubscribeTopic:(NSString *)topic {
    __weak typeof(self) weakSelf = self;
    [self.session unsubscribeTopic:topic unsubscribeHandler:^(NSError *error) {
        dispatch_async(mqtt_manager_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSArray *tempTopics = [NSArray arrayWithArray:strongSelf.topicObservers.allKeys];
            if([tempTopics containsObject:topic]) {
                @synchronized(strongSelf.topicObservers) {
                    [strongSelf.topicObservers removeObjectForKey:topic];
                }
            }
        });
    }];
}

#pragma MQTT_session call-back
- (void)onDisconnect:(NSUInteger)code {
    self.connectOn = NO;
    if(code == MQTTSessionEventConnectionError) {
        self.failedCount++;
        if(self.failedCount > 5) {
            self.failedCount = 0;
            [self.session disconnect];
            self.session = nil;
        }
        else if(self.topicObservers.count > 0) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.failedCount * 1.0 * NSEC_PER_SEC)), self.mqttQueue, ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.session connectWithConnectHandler:^(NSError *error){
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf.isConnecting = NO;
                    if(!error) {
                        strongSelf.connectOn = YES;
                        [strongSelf subscribeTopics];
                    }
                }];
            });
        }
    }
    //    NSLog(@"on disconnect mqtt");
    //    [self removeReference];
    
}

- (void)onMessage:(NSData *)message topic:(NSString *)topic {
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:message options:NSJSONReadingAllowFragments error:&error];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict addEntriesFromDictionary:dictionary];
    [dict setObject:topic forKey:@"topic"];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(mqtt_manager_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray *observers = [strongSelf.topicObservers objectForKey:topic];
        
        NSArray *array = [topic pathComponents];
        if([observers count] == 0 && [array count] >= 3 && [[array objectAtIndex:[array count] - 2] isEqualToString:@"p2p"]) {
            NSString *trueTopic = [topic stringByDeletingLastPathComponent];
            observers = [strongSelf.topicObservers objectForKey:trueTopic];
        }
        
        if([observers count] == 0) {
            //是否考虑移除topic
            [strongSelf unsubscribeTopic:topic];
            return;
        }
        
        [observers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id<VPUPMQTTObserverProtocol> observer = obj;
            if([observer respondsToSelector:@selector(onMessage:)]) {
                
                dispatch_async([strongSelf getQueueByObserver:observer], ^{
                    if(error) {
                        [observer onMessage:error];
                    }
                    else {
                        [observer onMessage:dict];
                    }
                });
            }
        }];
    });
}

- (dispatch_queue_t)getQueueByObserver:(id<VPUPMQTTObserverProtocol>)observer {
    dispatch_queue_t callbackQueue = nil;
    if([observer respondsToSelector:@selector(getCallbackQueue)]) {
        callbackQueue = [observer getCallbackQueue];
    }
    callbackQueue = callbackQueue ?: dispatch_get_main_queue();
    return callbackQueue;
}

#pragma destroy
- (void)dealloc {
    //    self.connectCompletionHandler = nil;
    //    self.disconnectCompletionHandler = nil;
    //    self.onMessageHandler = nil;
    //    self.subscribeTopicHandler = nil;
//    NSLog(@"mqtt dealloc，%@", self);
//    [self removeLifeCycleNotification];
}


@end
