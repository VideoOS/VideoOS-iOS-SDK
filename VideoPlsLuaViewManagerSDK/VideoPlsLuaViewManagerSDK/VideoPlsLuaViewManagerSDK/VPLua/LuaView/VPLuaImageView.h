//
//  VPLuaImageView.h
//  VideoPlsLuaViewSDK
//
//  Created by 鄢江波 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPUPFLAnimatedImageView.h"
#import <VPLuaViewSDK/LView.h>
#import <VPLuaViewSDK/LVHeads.h>

@interface VPLuaImageView : VPUPFLAnimatedImageView<LVProtocal, LVClassProtocal>

@property(nonatomic,weak) LuaViewCore* lv_luaviewCore;
@property(nonatomic,assign) LVUserDataInfo* lv_userData;
@property(nonatomic,assign) NSUInteger lv_align;
@property(nonatomic,strong) CAShapeLayer* lv_shapeLayer;

-(id) init:(lua_State*) l;

-(void) setImageByName:(NSString*) imageName;
-(void) setImageByData:(NSData*) data;
-(void) setWebImageUrl:(NSURL*) url finished:(LVLoadFinished) finished;
-(void) effectParallax:(CGFloat)dx dy:(CGFloat)dy ;
-(void) effectClick:(NSInteger)color alpha:(CGFloat)alpha;

/*
 * Lua 脚本回调
 */
-(void) callLuaDelegate:(id) obj;

/*
 * luaview所有扩展类的桥接协议: 只是一个静态协议, luaview统一调用该接口加载luaview扩展的类
 */
+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName;

@end
