//
//  VPDPNativeBridge.h
//  VideoPlsLuaViewSDK
//
//  Created by 鄢江波 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPHTTPAPIManager.h"
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

#import "VPLBaseNode.h"
#import "VPLNetworkManager.h"

extern NSString *const VPLScreenChangeNotification;
extern NSString *const VPLNotifyUserLoginedNotification;
extern NSString *const VPLRequireLoginNotification;
extern NSString *const VPLActionNotification;

@interface VPLNativeBridge : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*)globalName;

+ (VPLBaseNode *)luaNodeFromLuaState:(lua_State *)l;

@end
