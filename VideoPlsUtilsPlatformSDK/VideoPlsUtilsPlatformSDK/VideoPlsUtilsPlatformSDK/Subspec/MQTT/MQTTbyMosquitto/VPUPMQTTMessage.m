//
//  VPMQTTMessage.m
//  VPIVASDKMQTT
//
//  Created by Zard1096 on 16/3/30.
//  Copyright (c) 2016年 videopls.com. All rights reserved.
//

#import "VPUPMQTTMessage.h"

@interface VPUPMQTTMessage()

@property (readwrite, assign) unsigned short mid;
@property (readwrite, copy) NSString *topic;
@property (readwrite, copy) NSData *payload;
@property (readwrite, assign) VPUPMQTTQoSLevel qos;
@property (readwrite, assign) BOOL retained;

@end

@implementation VPUPMQTTMessage

-(id)initWithTopic:(NSString *)topic
           payload:(NSData *)payload
               qos:(VPUPMQTTQoSLevel)qos
            retain:(BOOL)retained
               mid:(short)mid
{
    if ((self = [super init])) {
        self.topic = topic;
        self.payload = payload;
        self.qos = qos;
        self.retained = retained;
        self.mid = mid;
    }
    return self;
}

- (NSString *)payloadString {
    return [[NSString alloc] initWithBytes:self.payload.bytes length:self.payload.length encoding:NSUTF8StringEncoding];
}

@end
