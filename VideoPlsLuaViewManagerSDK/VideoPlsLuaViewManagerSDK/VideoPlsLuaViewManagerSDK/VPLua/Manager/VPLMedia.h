//
//  VPLMedia.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 09/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

@class VPLBaseNode;

extern NSString *const VPLMediaStartNotification;
extern NSString *const VPLMediaPlayNotification;
extern NSString *const VPLMediaPauseNotification;
extern NSString *const VPLMediaEndNotification;
extern NSString *const VPLMediaPlayerSizeNotification;
extern NSString *const VPLMediaStartTimeNotification;
extern NSString *const VPLMediaStopTimeNotification;

@interface VPLMedia : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName;

@property (nonatomic, weak) VPLBaseNode *luaNode;

@end
