//
//  VPMQTTSession.h
//  VPIVASDKMQTT
//
//  Created by Zard1096 on 16/3/30.
//  Copyright (c) 2016年 videopls.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPMQTTMessage.h"

@class VPUPMQTTSession;
typedef void (^VPMQTTConnectionCompletionHandler)(NSUInteger code);
typedef void (^VPMQTTSubscriptionCompletionHandler)(NSArray *grantedQos);
typedef void (^VPMQTTMessageHandler)(VPUPMQTTMessage *message);
typedef void (^VPMQTTDisconnectionHandler)(NSUInteger code);

@class VPUPMQTTSession;
@interface VPUPMQTTSession : NSObject {
    struct vpup_mosquitto *mosq;
}


/** host an NSString containing the hostName or IP address of the host to connect to
 * defaults to @"localhost"
 */
@property (strong, nonatomic) NSString *host;

/** port an unsigned 16 bit integer containing the IP port number to connect to
 * defaults to 1883
 */
@property (nonatomic) UInt16 port;

@property (readonly, assign) BOOL connected;

@property (strong, nonatomic) NSString *clientID;

/** see userName an NSString object containing the user's name (or ID) for authentication. May be nil. */
@property (strong, nonatomic) NSString *userName;

/** see password an NSString object containing the user's password. If userName is nil, password must be nil as well.*/
@property (strong, nonatomic) NSString *password;

/** see keepAliveInterval The Keep Alive is a time interval measured in seconds.
 * The MQTTClient ensures that the interval between Control Packets being sent does not exceed
 * the Keep Alive value. In the  absence of sending any other Control Packets, the Client sends a PINGREQ Packet.
 */
@property (nonatomic) UInt16 keepAliveInterval;

@property (readwrite, assign) unsigned int reconnectDelay; // in seconds (default is 1)
@property (readwrite, assign) unsigned int reconnectDelayMax; // in seconds (default is 1)
@property (readwrite, assign) BOOL reconnectExponentialBackoff; // wheter to

/** cleanSessionFlag specifies if the server should discard previous session information. */
@property (nonatomic) BOOL cleanSessionFlag;

+ (void)initialize;

- (VPUPMQTTSession *)initWithClientID:(NSString *)clientID;
- (VPUPMQTTSession *)initWithClientID:(NSString *)clientID cleanSession:(BOOL)cleanSession;

+ (NSString*) version;

- (void)setMaxInflightMessages:(NSUInteger)maxInflightMessages;
- (void)setMessageRetry:(NSUInteger)seconds;


#pragma block for call-back
- (void)setDisconnectWithHandler:(VPMQTTDisconnectionHandler)disconnectHandler;
- (void)setMessageWithHandler:(VPMQTTMessageHandler)messageHandler;

#pragma mark - Connection

- (void)connect;
- (void)connectWithCompletionHandler:(void (^)(VPUPMQTTConnectionReturnCode code))completionHandler;

- (void)reconnect;
- (void)disconnect;

- (void)destroy;

- (void)setWillData:(NSData *)payload
            toTopic:(NSString *)willTopic
            withQos:(VPUPMQTTQoSLevel)willQos
             retain:(BOOL)retain;

- (void)setWill:(NSString *)payload
        toTopic:(NSString *)willTopic
        withQos:(VPUPMQTTQoSLevel)willQos
         retain:(BOOL)retain;
- (void)clearWill;

#pragma mark - Publish

- (void)publishData:(NSData *)payload
            toTopic:(NSString *)topic
            withQos:(VPUPMQTTQoSLevel)qos
             retain:(BOOL)retain
  completionHandler:(void (^)(int mid))completionHandler;

- (void)publishString:(NSString *)payload
              toTopic:(NSString *)topic
              withQos:(VPUPMQTTQoSLevel)qos
               retain:(BOOL)retain
    completionHandler:(void (^)(int mid))completionHandler;

#pragma mark - Subscribe

- (void)subscribe:(NSString *)topic
withCompletionHandler:(VPMQTTSubscriptionCompletionHandler)completionHandler;

- (void)subscribe:(NSString *)topic
          withQos:(VPUPMQTTQoSLevel)qos
completionHandler:(VPMQTTSubscriptionCompletionHandler)completionHandler;

- (void)unsubscribe: (NSString *)topic
withCompletionHandler:(void (^)(void))completionHandler;


@end
