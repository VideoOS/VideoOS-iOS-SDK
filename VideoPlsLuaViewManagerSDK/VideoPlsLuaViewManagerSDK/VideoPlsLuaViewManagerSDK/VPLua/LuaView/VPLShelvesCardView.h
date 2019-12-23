//
//  VPLShelvesCardView.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLShelvesCardView.h"

#import <VPLuaViewSDK/LVHeads.h>

@interface VPLShelvesCardView : UIView

@property(nonatomic,weak) LuaViewCore* lv_luaviewCore;// 对应的lua运行内核
@property(nonatomic,assign) LVUserDataInfo* lv_userData;// native对象对应的脚本对象

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*)globalName;

@end
