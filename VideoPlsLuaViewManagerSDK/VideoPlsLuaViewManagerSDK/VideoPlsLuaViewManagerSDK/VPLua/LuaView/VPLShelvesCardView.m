//
//  VPLShelvesCardView.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLShelvesCardView.h"
#import "VPLNativeBridge.h"

#import <VPLuaViewSDK/LuaViewCore.h>
#import <VPLuaViewSDK/LVBaseView.h>

//#import "VPMShelvesViewDelegate.h"//TODO IN MALL

#define META_TABLE_ShelvesCardView "UI.ShelvesCardView"

//@interface VPUPLShelvesCardView()<VPMShelvesViewDelegate>//TODO IN MALL
@interface VPLShelvesCardView()

@property (nonatomic, weak) VPLNativeBridge *nativeBridge;

@end

@implementation VPLShelvesCardView {
//    __weak id<VPUPLoadImageManager> _manager;
}

-(id) init:(lua_State*) l{
    self = [super init];
    if( self ) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        
        if( lua_gettop(l) >= 1 ) {
            if (lua_isuserdata(l, 1)) {
                LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(l, 1);
                VPLNativeBridge* native = (__bridge VPLNativeBridge *)(user->object);
                if(native) {
                    _nativeBridge = native;
//                    id<VPUPLoadImageManager> manager = _nativeBridge.luaNode.networkManager.imageManager;
//                    self.imageManager = manager;//TODO IN MALL
                }
            }
        }
        if( lua_gettop(l) >= 2 ) {
            if( lua_type(l, 2) == LUA_TTABLE ) {
                NSDictionary *goodsData = lv_luaValueToNativeObject(l, 2);
//                self.goodsData = goodsData; //TODO IN MALL
//                if(!self.goodsData) {
//                    // value有误
//
//                }
            }
        }
        
//        self.delegate = self;//TODO IN MALL
        
    }
    return self;
}

#pragma mark delegate 
- (void)itemDidSelected:(NSInteger)selectedIndex {
    lua_State *l = self.lv_luaviewCore.l;
    
    if(!l) {
        return;
    }
    
    lua_settop(l, 0);
    lua_checkstack(l, 4);
    // lua 从1开始
    lua_pushnumber(l, selectedIndex + 1);
    
    lv_pushUserdata(l, self.lv_userData);
    lv_pushUDataRef(l, USERDATA_KEY_DELEGATE);
    
    
    if([LVUtil call:l key1:STR_CALLBACK key2:"itemOnClick" key3:NULL key4:NULL nargs:1 nrets:0 retType:LUA_TNONE] == 0) {
        
    }
}

- (void)itemDidAddToCart:(NSInteger)selectedIndex {
    lua_State *l = self.lv_luaviewCore.l;
    
    if(!l) {
        return;
    }
    
    lua_settop(l, 0);
    lua_checkstack(l, 4);
    // lua 从1开始
    lua_pushnumber(l, selectedIndex + 1);
    
    lv_pushUserdata(l, self.lv_userData);
    lv_pushUDataRef(l, USERDATA_KEY_DELEGATE);
    
    
    if([LVUtil call:l key1:STR_CALLBACK key2:"itemOnAddCart" key3:NULL key4:NULL nargs:1 nrets:0 retType:LUA_TNONE] == 0) {
        
    }
}

- (void)itemDidImmediatelyBuy:(NSInteger)selectedIndex {
    lua_State *l = self.lv_luaviewCore.l;
    
    if(!l) {
        return;
    }
    
    lua_settop(l, 0);
    lua_checkstack(l, 4);
    // lua 从1开始
    lua_pushnumber(l, selectedIndex + 1);
    
    lv_pushUserdata(l, self.lv_userData);
    lv_pushUDataRef(l, USERDATA_KEY_DELEGATE);
    
    
    if([LVUtil call:l key1:STR_CALLBACK key2:"itemOnImmediatelyBuy" key3:NULL key4:NULL nargs:1 nrets:0 retType:LUA_TNONE] == 0) {
        
    }
}


#pragma lua clas define
+(int) lvClassDefine:(lua_State *)L globalName:(NSString*)globalName {
    [LVUtil reg:L clas:self cfunc:lvNewShelvesCardView globalName:globalName defaultName:@"ShelvesCardView"];
    const struct luaL_Reg memberFunctions [] = {
//        {"initParams",   initParams },
        {"initView", initView},
//        {"callJS", callJS},
        {"destroyView", destroyView},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L,META_TABLE_ShelvesCardView);
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0);
    luaL_openlib(L, NULL, memberFunctions, 0);
    
    const char* keys[] = { "addView", NULL};// 移除多余API
    lv_luaTableRemoveKeys(L, keys );
    
    return 1;
}

//c函数，初始化itemView
static int lvNewShelvesCardView (lua_State *L){
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLShelvesCardView class]];
    {
        VPLShelvesCardView* cardView = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, View);
            userData->object = CFBridgingRetain(cardView);
            cardView.lv_userData = userData;
            luaL_getmetatable(L, META_TABLE_ShelvesCardView );
            lua_setmetatable(L, -2);
            
            // top(L,1) 压Native, (L,2)压goodsData, (L,3)压Callback
            if ( lua_gettop(L) >= 3 && lua_type(L, 3) == LUA_TTABLE ) {
                lua_pushvalue(L, 3);
                lv_udataRef(L, USERDATA_KEY_DELEGATE );
            }
        }
    }
    return 1; /* new userdatum is already on the stack */
}

static int initView(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLShelvesCardView* cardView = (__bridge VPLShelvesCardView *)(user->object);
//        [cardView initView];//TODO IN MALL
    }
    return 0;
}

static int destroyView(lua_State *L) {
    return 0;
}


@end
