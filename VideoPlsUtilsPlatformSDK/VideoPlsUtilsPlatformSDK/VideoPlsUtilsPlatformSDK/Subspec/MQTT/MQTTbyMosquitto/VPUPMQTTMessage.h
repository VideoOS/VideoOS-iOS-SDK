//
//  VPMQTTMessage.h
//  VPIVASDKMQTT
//
//  Created by Zard1096 on 16/3/30.
//  Copyright (c) 2016年 videopls.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPMQTTEnum.h"

/**
 Enumeration of MQTT Connect return codes
 */
typedef NS_ENUM(NSUInteger, VPUPMQTTConnectionReturnCode) {
    ConnectionAccepted = 0,
    ConnectionRefusedUnacceptableProtocolVersion,
    ConnectionRefusedIdentiferRejected,
    ConnectionRefusedServerUnavailable,
    ConnectionRefusedBadUserNameOrPassword,
    ConnectionRefusedNotAuthorized
};

@interface VPUPMQTTMessage : NSObject

@property (readonly, assign) unsigned short mid;
@property (readonly, copy) NSString *topic;
@property (readonly, copy) NSData *payload;
@property (readonly, assign) BOOL retained;

-(id)initWithTopic:(NSString *)topic
           payload:(NSData *)payload
               qos:(VPUPMQTTQoSLevel)qos
            retain:(BOOL)retained
               mid:(short)mid;

- (NSString *)payloadString;

@end
