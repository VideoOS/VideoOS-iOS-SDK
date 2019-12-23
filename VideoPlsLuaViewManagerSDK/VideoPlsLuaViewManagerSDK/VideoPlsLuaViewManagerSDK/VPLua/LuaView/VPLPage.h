//
//  VPLPage.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/4/10.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>
#import <VPLuaViewSDK/NSObject+LuaView.h>

extern NSString *const VPLPageWillAppearNotification;
extern NSString *const VPLPageDidAppearNotification;
extern NSString *const VPLPageWillDisappearNotification;
extern NSString *const VPLPageDidDisappearNotification;

@interface VPLPage : LVNativeObjBox

- (id)init:(lua_State*) l;

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*) globalName;

@end
