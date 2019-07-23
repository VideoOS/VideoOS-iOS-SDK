//
//  VPLuaNativeScanner.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096 on 2017/12/29.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLuaNativeScanner.h"
#import "VideoPlsUtilsPlatformSDK.h"

#import "VPLuaBaseNode.h"
#import <VPLuaViewSDK/LVStruct.h>
#import <VPLuaViewSDK/LuaViewCore.h>

@interface VPLuaNativeScanner() <VPUPImagePickerControllerDelegate>

@end

@implementation VPLuaNativeScanner

-(id) init:(lua_State *)l {
    self = [super init];
    if ( self ) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        self.luaNode = (id)self.lv_luaviewCore.viewController;
        
    }
    return self;
}

- (void)showPhotoPickerController:(NSString *)requestMethod {
    VPUPImagePickerController *imagePicker = [[VPUPImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    
    __block NSString *bRequestMethod = requestMethod;
    __weak typeof(self) weakSelf = self;
    
    imagePicker.imagePickerControllerDidCancelHandle = ^(void) {
        if (!weakSelf) {
            return;
        }
        lua_State* l = self.luaNode.lvCore.l;
        if( l ){
            lua_checkstack32(l);
            [LVUtil call:l lightUserData:bRequestMethod key1:"callback" key2:NULL nargs:0];
            [LVUtil unregistry :l key:weakSelf];
        }
    };
    
    imagePicker.didFinishPickingPhotosWithFilePathHandle = ^(NSString *filePath) {
        if (!weakSelf) {
            return;
        }
        lua_State* l = self.luaNode.lvCore.l;
        if( l ){
            lua_checkstack32(l);
            lv_pushNativeObject(l, filePath);
            [LVUtil call:l lightUserData:bRequestMethod key1:"callback" key2:NULL nargs:1];
            [LVUtil unregistry :l key:weakSelf];
        }
    };
    
    [[VPUPTopViewController topViewController] presentViewController:imagePicker animated:YES completion:nil];
    
}

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName {
    [LVUtil reg:L clas:self cfunc:lvNewNativeScanner globalName:globalName defaultName:@"NativeScanner"];
    
    const struct luaL_Reg staticFunctions [] = {
        
        {"show",  show},
        
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    
    luaL_openlib(L, NULL, staticFunctions, 0);
    
    return 1;
}

static int lvNewNativeScanner(lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaNativeScanner class]];
    {
        VPLuaNativeScanner* native = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, NativeObject);
            userData->object = CFBridgingRetain(native);
            native.lv_userData = userData;
            
            luaL_getmetatable(L, META_TABLE_NativeObject );
            lua_setmetatable(L, -2);
        }
    }
    return 1; /* new userdatum is already on the stack */
}

static int show(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaNativeScanner* native = (__bridge VPLuaNativeScanner *)(user->object);
        if (native) {
            if( lua_gettop(L) >= 2 ) {
                int type = lua_type(L, 2);
                
                NSString *bRequestMethod = [[VPUPMD5Util md5_16bitHashString:[VPUPRandomUtil randomStringByLength:6]] copy];
                if( type == LUA_TFUNCTION ) {
                    [LVUtil registryValue:L key:bRequestMethod stack:2];
                }
                
                [native showPhotoPickerController:bRequestMethod];
            }
        }
    }
    return 0;
}


#pragma mark -- VPUPImagePickerControllerDelegate
- (void)vpup_imagePickerControllerDidCancel:(VPUPImagePickerController *)picker {
    
}

- (void)vpup_imagePickerController:(VPUPImagePickerController *)picker didFinishPickingPhotosWithFilePath:(NSString*)filepath {
    
}


@end
