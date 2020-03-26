//
//  VPLACRCloud.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by videopls on 2020/2/26.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>
#import <VPLuaViewSDK/NSObject+LuaView.h>

@interface VPLACRCloud : LVNativeObjBox

- (id)init:(lua_State*) l;

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*) globalName;

@end

