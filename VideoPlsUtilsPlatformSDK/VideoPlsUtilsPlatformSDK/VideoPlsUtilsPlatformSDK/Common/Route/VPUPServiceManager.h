//
//  VPUPServiceManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 02/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPServiceManager : NSObject

@property (nonatomic, assign) BOOL  enableException;

+ (instancetype)sharedManager;

- (void)registerService:(Protocol *)service implClass:(Class)implClass;

- (id)createService:(Protocol *)service;

- (Class)serviceImplClass:(Protocol *)service;

@end
