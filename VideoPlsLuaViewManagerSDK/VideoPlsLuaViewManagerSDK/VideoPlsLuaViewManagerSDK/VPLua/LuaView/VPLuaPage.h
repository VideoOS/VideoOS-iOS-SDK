//
//  VPLuaPage.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/4/10.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>
#import <VPLuaViewSDK/NSObject+LuaView.h>

extern NSString *const VPLuaPageWillAppearNotification;
extern NSString *const VPLuaPageDidAppearNotification;
extern NSString *const VPLuaPageWillDisappearNotification;
extern NSString *const VPLuaPageDidDisappearNotification;

@interface VPLuaPage : LVNativeObjBox

- (id)init:(lua_State*) l;

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*) globalName;

@end
