//
//  VPLuaLabel.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/22.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLuaLabel.h"
//#import "VPUPViewScaleUtil.h"
#import "VPLuaMacroDefine.h"
#import <VPLuaViewSDK/LuaViewCore.h>
#import <VPLuaViewSDK/LVBaseView.h>

@implementation VPLuaLabel

- (id)init:(NSString*)imageName l:(lua_State*)l {
    self = [super init:imageName l:l];
    if (self) {
        
    }
    return self;
}

- (void)setFont:(UIFont *)font {
    CGFloat textSize = [font pointSize];
    
//    CGFloat scale = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) / 667.0f;
//    scale = scale < 0.75 ? 0.75 : scale > 1.5 ? 1.5 : scale;
    textSize = textSize * VPUPFontScale;
    
    UIFont *newFont = [font fontWithSize:textSize];
    
    [super setFont:newFont];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    
    NSMutableArray *attributeDicts = [NSMutableArray array];
    NSMutableArray *ranges = [NSMutableArray array];
    
    [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        UIFont *font = [attrs objectForKey:NSFontAttributeName];
        if (!font) {
            font = self.font;
        }
        UIFont *newFont = [UIFont fontWithDescriptor:[font fontDescriptor] size:font.pointSize * VPUPFontScale];
        NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
        [newAttributes setObject:newFont forKey:NSFontAttributeName];
        
        [attributeDicts addObject:newAttributes];
        [ranges addObject:NSStringFromRange(range)];
    }];
    
    NSMutableAttributedString *newAttributedString = [attributedText mutableCopy];
    for (NSInteger i = 0; i < [attributeDicts count]; i++) {
        NSDictionary *attrs = [attributeDicts objectAtIndex:i];
        NSRange range = NSRangeFromString([ranges objectAtIndex:i]);
        [newAttributedString setAttributes:attrs range:range];
    }
    
    [super setAttributedText:newAttributedString];
}

#pragma -mark UILabel
/*
 * lua脚本中 local label = Label() 对应的构造方法
 */
static int lvNewVPLuaLabel(lua_State *L) {
    // 获取构造方法对应的Class(Native类)
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaLabel class]];
    {
        NSString* text = lv_paramString(L, 1);// 获取脚本传过来的第一个参数(约定是字符串类型)
        LVLabel* label = [[c alloc] init:text l:L];//通过Class和参数构造脚本对应的真实实例
        
        {
            NEW_USERDATA(userData, View);// 创建lua对象(userdata)
            userData->object = CFBridgingRetain(label);// 脚本对象引用native对象
            label.lv_userData = userData;//native对象引用脚本对象
            
            luaL_getmetatable(L, META_TABLE_UILabel ); // 获取Label对应的类方法列表
            lua_setmetatable(L, -2); // 设置刚才创建的lua对象的方法列表是类Label的方法列表
        }
        LuaViewCore* view = LV_LUASTATE_VIEW(L);// 获取当前LuaView对应的LuaViewCore
        if( view ){
            [view containerAddSubview:label]; // 把label对象加到LuaViewCore里面
        }
    }
    return 1; // 返回参数的个数
}

/*
 * luaview所有扩展类的桥接协议: 只是一个静态协议, luaview统一调用该接口加载luaview扩展的类
 */
+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName{
    // 注册构造方法: "Label" 对应的C函数(lvNewVPLuaLabel) + 对应的类Class(self/VPLuaLabel)
    [LVUtil reg:L clas:self cfunc:lvNewVPLuaLabel globalName:globalName defaultName:@"Label"];
    
    // lua Labe构造方法创建的对象对应的方法列表
    const struct luaL_Reg memberFunctions [] = {
        {"textShadow",    textShadow},
        {"textBold",    textBold},
        {NULL, NULL}
    };
    
    // 创建Label类的方法列表
    lv_createClassMetaTable(L, META_TABLE_UILabel);
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0); // 继承基类View的所有方法列表
    luaL_openlib(L, NULL, memberFunctions, 0); // 当前类Label特有的方法列表
    
    const char* keys[] = { "addView", NULL};//列出需要移除的多余API
    lv_luaTableRemoveKeys(L, keys );// 移除冗余API 兼容安卓
    return 1;
}

static int textShadow (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数永远是self(lua的userdata, 对象自身)
    if( user ) {
        VPLuaLabel* label = (__bridge VPLuaLabel *)(user->object);// 当前userdata对应的native对象
        if ([label isKindOfClass:[VPLuaLabel class]]) {// 检查类型是否匹配(其实可以不用检查一般一定是对的)
            if(lua_gettop(L) >= 3 && label.text) {
                UIColor* color = lv_getColorFromStack(L, 2);
                CGFloat shadowBlurRadius = lua_tonumber(L, 3);
                NSShadow *shadow = [[NSShadow alloc] init];
                shadow.shadowBlurRadius = shadowBlurRadius;
                shadow.shadowColor = color;
                label.attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:@{NSShadowAttributeName: shadow}];
            }
        }
    }
    return 0;
}

static int textBold (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数永远是self(lua的userdata, 对象自身)
    if( user ) {
        VPLuaLabel* label = (__bridge VPLuaLabel *)(user->object);// 当前userdata对应的native对象
        if ([label isKindOfClass:[VPLuaLabel class]]) {// 检查类型是否匹配(其实可以不用检查一般一定是对的)
            UIFont *font = [UIFont boldSystemFontOfSize:label.font.pointSize];
            label.font = font;
        }
    }
    return 0;
}

@end
