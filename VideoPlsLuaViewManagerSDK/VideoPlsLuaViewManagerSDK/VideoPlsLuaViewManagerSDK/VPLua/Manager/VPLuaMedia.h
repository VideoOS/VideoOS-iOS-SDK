//
//  VPLuaMedia.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 09/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

@class VPLuaBaseNode;

extern NSString *const VPLuaMediaStartNotification;
extern NSString *const VPLuaMediaPlayNotification;
extern NSString *const VPLuaMediaPauseNotification;
extern NSString *const VPLuaMediaEndNotification;
extern NSString *const VPLuaMediaPlayerSizeNotification;
extern NSString *const VPLuaMediaStartTimeNotification;
extern NSString *const VPLuaMediaStopTimeNotification;

@interface VPLuaMedia : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName;

@property (nonatomic, weak) VPLuaBaseNode *luaNode;

@end
