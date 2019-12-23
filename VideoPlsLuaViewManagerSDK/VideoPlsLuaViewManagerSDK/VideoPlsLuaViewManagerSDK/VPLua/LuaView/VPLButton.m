//
//  VPLButton.m
//  VideoPlsLuaViewSDK
//
//  Created by 鄢江波 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLButton.h"

#import "VPUPLoadImageButtonConfig.h"
#import "VPUPLoadImageManager.h"
#import "VPUPLoadImageFactory.h"

#import "VPLNativeBridge.h"


@interface VPLButton()

@property (nonatomic, assign) BOOL useBackgroundImage;

@end

@implementation VPLButton {
    __weak id<VPUPLoadImageManager> _manager;
}

-(id) init:(lua_State*) l{
    self = [super init:l];
    if( self ){
        _manager = [VPLNativeBridge luaNodeFromLuaState:l].networkManager.imageManager;
        if( lua_gettop(l) >= 1 ) {
            BOOL useBackgroundImage = lua_toboolean(l, 1);
            self.useBackgroundImage = useBackgroundImage;
        }
    }
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
}

static int lvNewButton (lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[LVButton class]];
    
    {
        LVButton* button = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, View);
            userData->object = CFBridgingRetain(button);
            button.lv_userData = userData;
            
            luaL_getmetatable(L, META_TABLE_UIButton );
            lua_setmetatable(L, -2);
        }
        LuaViewCore* father = LV_LUASTATE_VIEW(L);
        if( father ){
            [father containerAddSubview:button];
        }
    }
    return 1; /* new userdatum is already on the stack */
}

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName {
    [LVButton lvClassDefine:L globalName:globalName];
    [LVUtil reg:L clas:self cfunc:lvNewButton globalName:globalName defaultName:@"VPUPButton"];
    const struct luaL_Reg memberFunctions [] = {
        {"selectedImage",    selectedImage},
        {NULL, NULL}
    };
    
    luaL_openlib(L, NULL, memberFunctions, 0);
    
    return 1;
    
}

static int selectedImage (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        NSString* selectedImage = lv_paramString(L, 2);// 2
        VPLButton* button = (__bridge VPLButton *)(user->object);
        if( [button isKindOfClass:[VPLButton class]] ){
            [button setWebImageUrl:selectedImage forState:UIControlStateSelected finished:nil];
            lua_pushvalue(L, 1);
            return 1;
        }
    }
    return 0;
}

//static int image (lua_State *L) {
//    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
//    if( user ){
//        NSString* normalImage = lv_paramString(L, 2);// 2
//        NSString* hightLightImage = lv_paramString(L, 3);// 2
//        //NSString* disableImage = lv_paramString(L, 4);// 2
//        //NSString* selectedImage = lv_paramString(L, 5);// 2
//        LVButton* button = (__bridge LVButton *)(user->object);
//        if( [button isKindOfClass:[LVButton class]] ){
//            [button setImageUrl:normalImage placeholder:nil state:UIControlStateNormal];
//            [button setImageUrl:hightLightImage placeholder:nil state:UIControlStateSelected];
//            //[button setImageUrl:disableImage placeholder:nil state:UIControlStateDisabled];
//            //[button setImageUrl:selectedImage placeholder:nil state:UIControlStateSelected];
//            
//            lua_pushvalue(L, 1);
//            return 1;
//        }
//    }
//    return 0;
//}

-(void) setWebImageUrl:(NSString *)url forState:(UIControlState)state finished:(LVLoadFinished)finished{
    VPUPLoadImageButtonConfig *config = [[VPUPLoadImageButtonConfig alloc] init];
    config.url = [NSURL URLWithString:url];
    config.view = self;
    config.state = state;
    config.backgroundImage = self.useBackgroundImage;
    config.completedBlock = ^(UIImage *image, NSError *error, VPUPImageCacheType cacheType, NSURL *imageURL) {
        if (finished) {
            finished(error);
        }
    };
    [_manager loadImageWithConfig:config];
}

@end
