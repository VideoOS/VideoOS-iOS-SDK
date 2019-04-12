//
//  VPLuaPlayer.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/5/10.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LVHeads.h"
#import "VideoPlsUtilsPlatformSDK.h"

@interface VPLuaPlayer : VPUPVideoClip<LVProtocal, LVClassProtocal>

@property (nonatomic, weak) LuaViewCore* lv_luaviewCore;
@property (nonatomic, assign) LVUserDataInfo* lv_userData;
@property (nonatomic, assign) NSUInteger lv_align;
@property (nonatomic, strong) CAShapeLayer* lv_shapeLayer;

- (id)init:(lua_State*) l;

/*
 * luaview所有扩展类的桥接协议: 只是一个静态协议, luaview统一调用该接口加载luaview扩展的类
 */
+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *) globalName;

@end
