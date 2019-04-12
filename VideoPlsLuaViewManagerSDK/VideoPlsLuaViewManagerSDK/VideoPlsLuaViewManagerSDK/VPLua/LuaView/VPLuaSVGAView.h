//
//  VPLuaSVGAView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 26/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VPLuaViewSDK/LVHeads.h>

@interface VPLuaSVGAView : UIView<LVProtocal, LVClassProtocal>

@property(nonatomic,weak) LuaViewCore* lv_luaviewCore;
@property(nonatomic,assign) LVUserDataInfo* lv_userData;

-(id) init:(lua_State*) l;

/*
 * luaview所有扩展类的桥接协议: 只是一个静态协议, luaview统一调用该接口加载luaview扩展的类
 */
+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName;

@end
