//
//  VPUPMQTTConfig.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPMQTTConfig.h"

@implementation VPUPMQTTConfig

- (instancetype)initWithServerURL:(NSString *)serverURL
                       serverPort:(NSUInteger)serverPort
                         userName:(NSString *)userName
                         password:(NSString *)password
                         clientID:(NSString *)clientID {
    
    NSParameterAssert(serverURL);
    NSParameterAssert(serverPort != 0);
    NSParameterAssert(userName);
    NSParameterAssert(password);
    NSParameterAssert(clientID);
    self = [super init];
    if(self) {
        _serverURL          = serverURL;
        _serverPort         = serverPort;
        _userName           = userName;
        _password           = password;
        _clientID           = clientID;
    }
    return self;
}

@end
