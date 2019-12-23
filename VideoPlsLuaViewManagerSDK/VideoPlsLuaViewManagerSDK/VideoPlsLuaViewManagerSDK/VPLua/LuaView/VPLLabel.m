//
//  VPLLabel.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/22.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLLabel.h"
//#import "VPUPViewScaleUtil.h"
#import "VPLMacroDefine.h"
#import <VPLuaViewSDK/LuaViewCore.h>
#import <VPLuaViewSDK/LVBaseView.h>

@implementation VPLLabel

- (id)init:(NSString*)imageName l:(lua_State*)l {
    self = [super init:imageName l:l];
    if (self) {
        
    }
    return self;
}

- (void)setVerticalAlignment:(VPLLabelVerticalAlignment)verticalAlignment {
    _verticalAlignment = verticalAlignment;
    [self setNeedsDisplay];
}

- (void)drawTextInRect:(CGRect)rect {
    switch (self.verticalAlignment) {
        case VPLLabelVerticalAlignmentTop:
        case VPLLabelVerticalAlignmentBottom: {
            CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
            [super drawTextInRect:actualRect];
            break;
        }
        case VPLLabelVerticalAlignmentCenter:
        default: {
            [super drawTextInRect:rect];
            break;
        }
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) {
        case VPLLabelVerticalAlignmentTop: {
            textRect.origin.y = bounds.origin.y;
            break;
        }
        case VPLLabelVerticalAlignmentBottom: {
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        }
        case VPLLabelVerticalAlignmentCenter:
        default: {
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
            break;
        }
    }
    return textRect;
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

- (NSAttributedString *)getLuaLabelAttributeString {
    if (self.attributedText != nil) {
        return self.attributedText;
    } else {
        if (self.text != nil && ![self.text isEqualToString:@""]) {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.alignment = self.textAlignment;
            
            [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
            
            return attributeString;
        }
    }
    return nil;
}

#pragma -mark UILabel
/*
 * lua脚本中 local label = Label() 对应的构造方法
 */
static int lvNewVPLLabel(lua_State *L) {
    // 获取构造方法对应的Class(Native类)
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLLabel class]];
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
    // 注册构造方法: "Label" 对应的C函数(lvNewVPLLabel) + 对应的类Class(self/VPLLabel)
    [LVUtil reg:L clas:self cfunc:lvNewVPLLabel globalName:globalName defaultName:@"Label"];
    
    // lua Labe构造方法创建的对象对应的方法列表
    const struct luaL_Reg memberFunctions [] = {
        {"textShadow",      textShadow},
        {"textBold",        textBold},
        {"textVAlign",      textVAlignment},
        {"strikeLines",     strikeLines},
        {"underLines",      underLines},
        {NULL, NULL}
    };
    {
        lua_settop(L, 0);
        NSDictionary* v = nil;
        v = @{
              @"TOP":@(VPLLabelVerticalAlignmentTop),
              @"BOTTOM":@(VPLLabelVerticalAlignmentBottom),
              @"CENTER":@(VPLLabelVerticalAlignmentCenter),// 上下左右都居中
              };
        [LVUtil defineGlobal:@"TextVAlign" value:v L:L];
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
        VPLLabel* label = (__bridge VPLLabel *)(user->object);// 当前userdata对应的native对象
        if ([label isKindOfClass:[VPLLabel class]]) {// 检查类型是否匹配(其实可以不用检查一般一定是对的)
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
        VPLLabel* label = (__bridge VPLLabel *)(user->object);// 当前userdata对应的native对象
        if ([label isKindOfClass:[VPLLabel class]]) {// 检查类型是否匹配(其实可以不用检查一般一定是对的)
            //也会调用setFont:导致继续乘以一次VPUPFontScale
            UIFont *font = [UIFont boldSystemFontOfSize:label.font.pointSize / VPUPFontScale];
            label.font = font;
        }
    }
    return 0;
}

/*
 * 脚本label实例对象label.textVAlign()方法对应的Native实现
 */
static int textVAlignment (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLLabel* label = (__bridge VPLLabel *)(user->object);// 当前userdata对应的native对象
        if( lua_gettop(L)>=2 ) {
            // 两个参数: 第一个对象自身, 第二个对齐方式
            NSInteger vAlign = lua_tonumber(L, 2);// 获取第二个参数对齐方式
            if( [label isKindOfClass:[VPLLabel class]] ){
                label.verticalAlignment = vAlign;
                return 0;
            }
        } else {
            // 脚本层无入参(除了self), 则 返回 对齐方式的值
            int vAlign = label.verticalAlignment;
            lua_pushnumber(L, vAlign );
            return 1;
        }
    }
    return 0;
}

static int strikeLines (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLLabel* label = (__bridge VPLLabel *)(user->object);// 当前userdata对应的native对象
        UIColor *linesColor = [label textColor];
        if( lua_gettop(L)>=2 ) {
            // 两个参数: 第一个对象自身, 第二个颜色
            UIColor* color = lv_getColorFromStack(L, 2);
            linesColor = color;
        }
        NSAttributedString *attributeString = [label getLuaLabelAttributeString];
        if (attributeString != nil) {
            NSMutableAttributedString *mutableAttrString = [attributeString mutableCopy];
            
            NSMutableDictionary *attribute = [NSMutableDictionary dictionary];
            
            [attribute setObject:@(1) forKey:NSStrikethroughStyleAttributeName];
            [attribute setObject:@(0) forKey:NSBaselineOffsetAttributeName];
            [attribute setObject:linesColor forKey:NSStrikethroughColorAttributeName];
            [attribute setObject:label.font forKey:NSFontAttributeName];
            
            [mutableAttrString addAttributes:attribute range:NSMakeRange(0, mutableAttrString.length)];
            label.attributedText = mutableAttrString;
        }
        
    }
    return 0;
}

static int underLines (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLLabel* label = (__bridge VPLLabel *)(user->object);// 当前userdata对应的native对象
        UIColor *linesColor = [label textColor];
        if( lua_gettop(L)>=2 ) {
            // 两个参数: 第一个对象自身, 第二个颜色
           UIColor* color = lv_getColorFromStack(L, 2);
            linesColor = color;
        }
        NSAttributedString *attributeString = [label getLuaLabelAttributeString];
        if (attributeString != nil) {
            NSMutableAttributedString *mutableAttrString = [attributeString mutableCopy];
            
            NSMutableDictionary *attribute = [NSMutableDictionary dictionary];
            
            [attribute setObject:@(1) forKey:NSUnderlineStyleAttributeName];
            [attribute setObject:@(0) forKey:NSBaselineOffsetAttributeName];
            [attribute setObject:linesColor forKey:NSUnderlineColorAttributeName];
            
            [mutableAttrString addAttributes:attribute range:NSMakeRange(0, mutableAttrString.length)];
            label.attributedText = mutableAttrString;
        }
        
    }
    return 0;
}


@end
