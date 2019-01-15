//
//  VPMQTTSession.m
//  VPIVASDKMQTT
//
//  Created by Zard1096 on 16/3/30.
//  Copyright (c) 2016年 videopls.com. All rights reserved.
//

#import "VPUPMQTTSession.h"
#import "vpup_mosquitto.h"
#import "vpup_mosquitto_internal.h"

#if 0 // set to 1 to enable logs

#define LogDebug(frmt, ...) NSLog(frmt, ##__VA_ARGS__);

#else

#define LogDebug(frmt, ...) {}

#endif

@interface VPUPMQTTSession()

@property (nonatomic, copy) VPMQTTConnectionCompletionHandler connectionCompletionHandler;

@property (nonatomic, copy) VPMQTTMessageHandler onMessageHandler;
@property (nonatomic, copy) VPMQTTDisconnectionHandler disconnectHandler;

@property (nonatomic, strong) NSMutableDictionary *subscriptionHandlers;
@property (nonatomic, strong) NSMutableDictionary *unsubscriptionHandlers;
// dictionary of mid -> completion handlers for messages published with a QoS of 1 or 2
@property (nonatomic, strong) NSMutableDictionary *publishHandlers;
@property (nonatomic, assign) BOOL connected;

// dispatch queue to run the vpup_mosquitto_loop_forever.
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation VPUPMQTTSession

#pragma mark - mosquitto callback methods

static void on_connect(struct vpup_mosquitto *mosq, void *obj, int rc)
{
    VPUPMQTTSession* session = (__bridge VPUPMQTTSession*)obj;
    if ([session isMemberOfClass:[VPUPMQTTSession class]]) {
        LogDebug(@"[%@] on_connect rc = %d", session.clientID, rc);
        session.connected = (rc == ConnectionAccepted);
        if (session.connectionCompletionHandler) {
            session.connectionCompletionHandler(rc);
        }
    }
}

static void on_disconnect(struct vpup_mosquitto *mosq, void *obj, int rc)
{
    VPUPMQTTSession* session = (__bridge VPUPMQTTSession*)obj;
    if ([session isMemberOfClass:[VPUPMQTTSession class]]) {
        LogDebug(@"[%@] on_disconnect rc = %d", session.clientID, rc);
        [session.publishHandlers removeAllObjects];
        [session.subscriptionHandlers removeAllObjects];
        [session.unsubscriptionHandlers removeAllObjects];
        
        session.connected = NO;
        if(session.disconnectHandler) {
            session.disconnectHandler(rc);
        }
    }
}

static void on_publish(struct vpup_mosquitto *mosq, void *obj, int message_id)
{
    VPUPMQTTSession* session = (__bridge VPUPMQTTSession*)obj;
    if ([session isMemberOfClass:[VPUPMQTTSession class]]) {
        NSNumber *mid = [NSNumber numberWithInt:message_id];
        void (^handler)(int) = [session.publishHandlers objectForKey:mid];
        if (handler) {
            handler(message_id);
            if (message_id > 0) {
                [session.publishHandlers removeObjectForKey:mid];
            }
        }
    }
}

static void on_message(struct vpup_mosquitto *mosq, void *obj, const struct vpup_mosquitto_message *mosq_msg)
{
    // Ensure these objects are cleaned up quickly by an autorelease pool.
    // The GCD autorelease pool isn't guaranteed to clean this up in any amount of time.
    // Source: https://developer.apple.com/library/ios/DOCUMENTATION/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW1
    @autoreleasepool {
        VPUPMQTTSession* session = (__bridge VPUPMQTTSession*)obj;
        if ([session isMemberOfClass:[VPUPMQTTSession class]]) {
            NSString *topic = [NSString stringWithUTF8String: mosq_msg->topic];
            NSData *payload = [NSData dataWithBytes:mosq_msg->payload length:mosq_msg->payloadlen];
            VPUPMQTTMessage *message = [[VPUPMQTTMessage alloc]
                                      initWithTopic:topic
                                      payload:payload
                                      qos:mosq_msg->qos
                                      retain:mosq_msg->retain
                                      mid:mosq_msg->mid];
            
            LogDebug(@"[%@] clientID:%@, on message %@", topic, session.clientID, message);

            if(session.onMessageHandler) {
                session.onMessageHandler(message);
            }
        }
    }
}

static void on_subscribe(struct vpup_mosquitto *mosq, void *obj, int message_id, int qos_count, const int *granted_qos)
{
    VPUPMQTTSession *session = (__bridge VPUPMQTTSession*)obj;
    if ([session isMemberOfClass:[VPUPMQTTSession class]]) {
        NSNumber *mid = [NSNumber numberWithInt:message_id];
        VPMQTTSubscriptionCompletionHandler handler = [session.subscriptionHandlers objectForKey:mid];
        if (handler) {
            NSMutableArray *grantedQos = [NSMutableArray arrayWithCapacity:qos_count];
            for (int i = 0; i < qos_count; i++) {
                [grantedQos addObject:[NSNumber numberWithInt:granted_qos[i]]];
            }
            handler(grantedQos);
            [session.subscriptionHandlers removeObjectForKey:mid];
        }
    }
}

static void on_unsubscribe(struct vpup_mosquitto *mosq, void *obj, int message_id)
{
    VPUPMQTTSession* session = (__bridge VPUPMQTTSession*)obj;
    if ([session isMemberOfClass:[VPUPMQTTSession class]]) {
        NSNumber *mid = [NSNumber numberWithInt:message_id];
        void (^completionHandler)(void) = [session.unsubscriptionHandlers objectForKey:mid];
        if (completionHandler) {
            completionHandler();
            [session.subscriptionHandlers removeObjectForKey:mid];
        }
    }
}


#pragma init

+ (void)initialize {
    vpup_mosquitto_lib_init();
}

+ (NSString*)version {
    int major, minor, revision;
    vpup_mosquitto_lib_version(&major, &minor, &revision);
    return [NSString stringWithFormat:@"%d.%d.%d", major, minor, revision];
}

- (VPUPMQTTSession *)initWithClientID:(NSString *)clientID {
    return [self initWithClientID:clientID cleanSession:YES];
}

- (VPUPMQTTSession *)initWithClientID:(NSString *)clientID
                    cleanSession:(BOOL)cleanSession {
    if ((self = [super init])) {
//        self.clientID = clientId;
        self.port = 1883;
        self.keepAliveInterval = 60;
        self.reconnectDelay = 1;
        self.reconnectDelayMax = 1;
        self.reconnectExponentialBackoff = NO;
        
        self.subscriptionHandlers = [[NSMutableDictionary alloc] init];
        self.unsubscriptionHandlers = [[NSMutableDictionary alloc] init];
        self.publishHandlers = [[NSMutableDictionary alloc] init];
        self.cleanSessionFlag = cleanSession;
        self.clientID = clientID;
        
    }
    return self;
}

- (VPUPMQTTSession *)initWithServerUrl:(NSString *)url port:(NSInteger)port {
    if ((self = [super init])) {
        //        self.clientID = clientId;
        self.port = 1883;
        self.keepAliveInterval = 60;
        self.reconnectDelay = 1;
        self.reconnectDelayMax = 1;
        self.reconnectExponentialBackoff = NO;
        
        self.subscriptionHandlers = [[NSMutableDictionary alloc] init];
        self.unsubscriptionHandlers = [[NSMutableDictionary alloc] init];
        self.publishHandlers = [[NSMutableDictionary alloc] init];
        self.cleanSessionFlag = YES;
    }
    return self;
}

- (void)initMosqWithClientID:(NSString *)clientID {
//    NSLog(@"session init,%@",self);
    if(!self.clientID) {
        self.clientID = clientID;
    }
    const char* cstrClientId = [self.clientID cStringUsingEncoding:NSUTF8StringEncoding];
    
    mosq = vpup_mosquitto_new(cstrClientId, self.cleanSessionFlag, (__bridge void *)(self));
    vpup_mosquitto_connect_callback_set(mosq, on_connect);
    vpup_mosquitto_disconnect_callback_set(mosq, on_disconnect);
    vpup_mosquitto_publish_callback_set(mosq, on_publish);
    vpup_mosquitto_message_callback_set(mosq, on_message);
    vpup_mosquitto_subscribe_callback_set(mosq, on_subscribe);
    vpup_mosquitto_unsubscribe_callback_set(mosq, on_unsubscribe);
    
    self.queue = dispatch_queue_create(cstrClientId, NULL);
}

- (void)setMaxInflightMessages:(NSUInteger)maxInflightMessages
{
    vpup_mosquitto_max_inflight_messages_set(mosq, (unsigned int)maxInflightMessages);
}

- (void)setMessageRetry:(NSUInteger)seconds
{
    vpup_mosquitto_message_retry_set(mosq, (unsigned int)seconds);
}

- (void)setDisconnectWithHandler:(VPMQTTDisconnectionHandler)disconnectHandler {
    if(disconnectHandler) {
        self.disconnectHandler = disconnectHandler;
    }
}

- (void)setMessageWithHandler:(VPMQTTMessageHandler)messageHandler {
    if(messageHandler) {
        self.onMessageHandler = messageHandler;
    }
}

- (void) dealloc {
    if (mosq) {
        vpup_mosquitto_user_data_set(mosq, NULL);
        vpup_mosquitto_destroy(mosq);
        mosq = NULL;
        vpup_mosquitto_lib_cleanup();
    }
    _onMessageHandler = nil;
    _disconnectHandler = nil;
    _publishHandlers = nil;
    _unsubscriptionHandlers = nil;
//    NSLog(@"session dealloc,%@",self);
}

#pragma mark - Connection

- (void)connect {
    [self connectWithCompletionHandler:nil];
}

- (void)connectWithCompletionHandler:(void (^)(VPUPMQTTConnectionReturnCode code))completionHandler {
    if(!self.host) {
        completionHandler(ConnectionRefusedServerUnavailable);
        return;
    }
    self.connectionCompletionHandler = completionHandler;
    
    [self initMosqWithClientID:self.clientID];
    
    const char *cstrHost = [self.host cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cstrUsername = NULL, *cstrPassword = NULL;
    
    if (self.userName)
        cstrUsername = [self.userName cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (self.password)
        cstrPassword = [self.password cStringUsingEncoding:NSUTF8StringEncoding];
    
    // FIXME: check for errors
    vpup_mosquitto_username_pw_set(mosq, cstrUsername, cstrPassword);
    vpup_mosquitto_reconnect_delay_set(mosq, self.reconnectDelay, self.reconnectDelayMax, self.reconnectExponentialBackoff);
    
    vpup_mosquitto_connect(mosq, cstrHost, self.port, self.keepAliveInterval);
    
    dispatch_async(self.queue, ^{
        LogDebug(@"start mosquitto loop on %@", self.queue);
        vpup_mosquitto_loop_forever(mosq, -1, 1);
        LogDebug(@"end mosquitto loop on %@", self.queue);
    });
    
}

- (void) reconnect {
    vpup_mosquitto_reconnect(mosq);
}

- (void) disconnect {
    vpup_mosquitto_disconnect(mosq);
}

- (void)destroy {
    if(mosq) {
        vpup_mosquitto_user_data_set(mosq, NULL);
        vpup_mosquitto_destroy(mosq);
        mosq = NULL;
        vpup_mosquitto_lib_cleanup();
    }
}


- (void)setWillData:(NSData *)payload
            toTopic:(NSString *)willTopic
            withQos:(VPUPMQTTQoSLevel)willQos
             retain:(BOOL)retain
{
    const char* cstrTopic = [willTopic cStringUsingEncoding:NSUTF8StringEncoding];
    vpup_mosquitto_will_set(mosq, cstrTopic, (int)payload.length, payload.bytes, willQos, retain);
}

- (void)setWill:(NSString *)payload
        toTopic:(NSString *)willTopic
        withQos:(VPUPMQTTQoSLevel)willQos
         retain:(BOOL)retain;
{
    [self setWillData:[payload dataUsingEncoding:NSUTF8StringEncoding]
              toTopic:willTopic
              withQos:willQos
               retain:retain];
}

- (void)clearWill
{
    vpup_mosquitto_will_clear(mosq);
}

#pragma mark - Publish

- (void)publishData:(NSData *)payload
            toTopic:(NSString *)topic
            withQos:(VPUPMQTTQoSLevel)qos
             retain:(BOOL)retain
  completionHandler:(void (^)(int mid))completionHandler {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    if (qos == 0 && completionHandler) {
        [self.publishHandlers setObject:completionHandler forKey:[NSNumber numberWithInt:0]];
    }
    int mid;
    vpup_mosquitto_publish(mosq, &mid, cstrTopic, (int)payload.length, payload.bytes, qos, retain);
    if (completionHandler) {
        if (qos == 0) {
            completionHandler(mid);
        } else {
            [self.publishHandlers setObject:completionHandler forKey:[NSNumber numberWithInt:mid]];
        }
    }
}

- (void)publishString:(NSString *)payload
              toTopic:(NSString *)topic
              withQos:(VPUPMQTTQoSLevel)qos
               retain:(BOOL)retain
    completionHandler:(void (^)(int mid))completionHandler; {
    [self publishData:[payload dataUsingEncoding:NSUTF8StringEncoding]
              toTopic:topic
              withQos:qos
               retain:retain
    completionHandler:completionHandler];
}

#pragma mark - Subscribe

- (void)subscribe:(NSString *)topic withCompletionHandler:(VPMQTTSubscriptionCompletionHandler)completionHandler {
    [self subscribe:topic withQos:0 completionHandler:completionHandler];
}

- (void)subscribe:(NSString *)topic withQos:(VPUPMQTTQoSLevel)qos completionHandler:(VPMQTTSubscriptionCompletionHandler)completionHandler
{
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    int mid;
    vpup_mosquitto_subscribe(mosq, &mid, cstrTopic, qos);
    if (completionHandler) {
        [self.subscriptionHandlers setObject:[completionHandler copy] forKey:[NSNumber numberWithInteger:mid]];
    }
}

- (void)unsubscribe:(NSString *)topic withCompletionHandler:(void (^)(void))completionHandler
{
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    int mid;
    vpup_mosquitto_unsubscribe(mosq, &mid, cstrTopic);
    if (completionHandler) {
        [self.unsubscriptionHandlers setObject:[completionHandler copy] forKey:[NSNumber numberWithInteger:mid]];
    }
}

@end
