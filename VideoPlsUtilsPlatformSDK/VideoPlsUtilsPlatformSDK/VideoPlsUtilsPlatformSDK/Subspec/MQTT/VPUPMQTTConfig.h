//
//  VPUPMQTTConfig.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPMQTTConfig : NSObject

@property (nonatomic, readonly, copy) NSString *serverURL;

@property (nonatomic, readonly, assign) NSUInteger serverPort;

@property (nonatomic, readonly, copy) NSString *userName;

@property (nonatomic, readonly, copy) NSString *password;

@property (nonatomic, readonly, copy) NSString *clientID;

- (instancetype)initWithServerURL:(NSString *)serverURL
                       serverPort:(NSUInteger)serverPort
                         userName:(NSString *)userName
                         password:(NSString *)password
                         clientID:(NSString *)clientID;

@end
