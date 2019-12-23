//
//  NSObject+VPLView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/8.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "NSObject+VPLView.h"
#import <VPLuaViewSDK/NSObject+LuaView.h>
#import <VPLuaViewSDK/LuaViewCore.h>

@implementation NSObject (NSObjectVPLView)

- (void)lv_buttonCallBack:(UIGestureRecognizer *)gesture {
    lua_State* L = self.lv_luaviewCore.l;
    if( L && self.lv_userData ){
        int num = lua_gettop(L);
        lv_pushUserdata(L, self.lv_userData);
        lv_pushUDataRef(L, USERDATA_KEY_DELEGATE );

        
        if ([self isKindOfClass:[UIView class]]) {
            CGPoint clickPoint = [gesture locationInView:(UIView *)self];
            CGPoint convertPoint = [((UIView *)self) convertPoint:clickPoint toView:[UIApplication sharedApplication].keyWindow];
            
            lua_pushnumber(L, clickPoint.x);
            lua_pushnumber(L, clickPoint.y);
            lua_pushnumber(L, convertPoint.x);
            lua_pushnumber(L, convertPoint.y);
            //已经push了4个，从-5取出push的userData table
            if( lua_type(L, -5)==LUA_TTABLE ) {
                lua_getfield(L, -5, STR_ON_CLICK);
            }

            lv_runFunctionWithArgs(L, 4, 0);
            lua_settop(L, num);
        } else {
            if( lua_type(L, -1)==LUA_TTABLE ) {
                lua_getfield(L, -1, STR_ON_CLICK);
            }
            
            lv_runFunction(L);
            lua_settop(L, num);
        }
    }
}

@end
