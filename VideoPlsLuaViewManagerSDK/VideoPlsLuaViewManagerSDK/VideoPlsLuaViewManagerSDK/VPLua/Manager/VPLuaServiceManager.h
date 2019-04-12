//
//  VPLuaServiceManager.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/4/27.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPMessageTransferStation.h"

@interface VPLuaServiceManager : NSObject

@property (nonatomic, strong, readonly) VPUPMessageTransferStation *messageTransferStation;

//获取sharedManager之前，必须要startService，stopService释放对象
+ (instancetype)sharedManager;

+ (void)startService;

+ (void)stopService;

@end
