//
//  VPLuaTextField.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 16/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaTextField.h"
#import <VPLuaViewSDK/LuaViewCore.h>
#import <VPLuaViewSDK/LVBaseView.h>

@interface VPLuaTextField () <UITextFieldDelegate>

@property (nonatomic, assign) NSInteger maxLength;

@end

@implementation VPLuaTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init:(lua_State* )l {
    self = [super init:l];
    if(self) {
        [self addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (@available(iOS 11.2, *)) {
        if (@available(iOS 13.0, *)) {
            return;
        }
        NSString *keyPath = @"textContentView.provider";
        @try {
            if (self.window) {
                id provider = [self valueForKeyPath:keyPath];
                if (!provider && self) {
                    [self setValue:self forKeyPath:keyPath];
                }
            }
            else {
                [self setValue:nil forKeyPath:keyPath];
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
}

- (void)dealloc {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resignFirstResponder];
    return YES;
}

- (void)setKeyboarType:(NSString *)type {
    if ([type isEqualToString:@"number"]) {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    else if ([type isEqualToString:@"password"]) {
        self.secureTextEntry = YES;
        self.keyboardType = UIKeyboardTypeASCIICapable;
    }
    else if ([type isEqualToString:@"visible_password"]) {
        self.secureTextEntry = NO;
        self.keyboardType = UIKeyboardTypeASCIICapable;
    }
    else {
        self.keyboardType = UIKeyboardTypeDefault;
    }
}


static int lvNewTextField (lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaTextField class]];
    
    VPLuaTextField* textFiled = [[c alloc] init:L];
    {
        NEW_USERDATA(userData, View);
        userData->object = CFBridgingRetain(textFiled);
        textFiled.lv_userData = userData;
        
        luaL_getmetatable(L, META_TABLE_UITextField );
        lua_setmetatable(L, -2);
    }
    
    LuaViewCore* lview = LV_LUASTATE_VIEW(L);
    if( lview ){
        [lview containerAddSubview:textFiled];
    }
    return 1; /* new userdatum is already on the stack */
}

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName {
    
    [LVUtil reg:L clas:self cfunc:lvNewTextField globalName:globalName defaultName:@"TextField"];
    
    const struct luaL_Reg memberFunctions [] = {
        {"inputType", inputType},
        {"textColor", textColor},
        {"textSize", textSize},
        {"maxLength", maxLength},
        {"resignFirstResponder", resignFirstResponder},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L ,META_TABLE_UITextField);
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0);
    luaL_openlib(L, NULL, memberFunctions, 0);
    
    const char* keys[] = { "addView", NULL};// 移除多余API
    lv_luaTableRemoveKeys(L, keys );
    return 1;
}

static int inputType (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaTextField* textField = (__bridge VPLuaTextField *)(user->object);
        if( [textField isKindOfClass:[VPLuaTextField class]] ){
            if (lua_gettop(L)>=2) {
                NSString *type = lv_paramString(L, 2);// 2
                [textField setKeyboarType:type];
            } else {
                [textField setKeyboarType:nil];
            }
        }
    }
    return 0;
}

static int textColor (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数永远是self(lua的userdata, 对象自身)
    if( user ){
        VPLuaTextField* view = (__bridge VPLuaTextField *)(user->object);// 获取userdata对应的native对象
        if( lua_gettop(L)>=2 ) {// 如果参数大于两个
            if( [view isKindOfClass:[VPLuaTextField class]] ){
                UIColor* color = lv_getColorFromStack(L, 2); // 获取第二个参数的值(颜色)
                view.textColor = color; // 设置颜色
                return 0;
            }
        } else {
            // 脚本层无入参(除了self), 则 返回颜色值
            UIColor* color = view.textColor;
            NSUInteger c = 0;
            CGFloat a = 0;
            if( lv_uicolor2int(color, &c, &a) ){
                lua_pushnumber(L, c ); // 颜色值
                lua_pushnumber(L, a);// 透明度
                return 2;// 返回参数的个数
            }
        }
    }
    return 0;
}

static int textSize (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLuaTextField* view = (__bridge VPLuaTextField *)(user->object);// 获取self对应的native对象
        if( [view isKindOfClass:[VPLuaTextField class]] ){
            if( lua_gettop(L)>=2 ) {
                // 两个参数: 第一个对象自身, 第二个字体大小
                float fontSize = lua_tonumber(L, 2);
                view.font = [UIFont systemFontOfSize:fontSize];
                return 0;
            } else {
                // 脚本层无入参(除了self), 则 返回字体大小
                UIFont* font = view.font;
                CGFloat fontSize = font.pointSize;
                lua_pushnumber(L, fontSize);
                return 1;
            }
        }
    }
    return 0;
}

static int maxLength (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLuaTextField* view = (__bridge VPLuaTextField *)(user->object);// 获取self对应的native对象
        if( [view isKindOfClass:[VPLuaTextField class]] ){
            if( lua_gettop(L)>=2 ) {
                // 两个参数: 第一个对象自身, 第二个字符最大长度
                NSInteger maxLength = lua_tointeger(L, 2);
                view.maxLength = maxLength;
                return 0;
            } else {
                // 脚本层无入参(除了self), 则 返回字符最大长度
                NSInteger maxLength = view.maxLength;
                lua_pushinteger(L, maxLength);
                return 1;
            }
        }
    }
    return 0;
}

static int resignFirstResponder (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaTextField* textField = (__bridge VPLuaTextField *)(user->object);
        if( [textField isKindOfClass:[VPLuaTextField class]] ){
            [textField resignFirstResponder];
            return 0;
        }
    }
    return 0;
}


- (void)textFiledDidChange:(UITextField *)textField
{
    if (textField == self) {
        VPLuaTextField *luaTextField = (VPLuaTextField *)textField;
        if (luaTextField.maxLength == 0)
            return;
        
        NSString *toBeString = textField.text;
        NSString *lang = [[textField textInputMode] primaryLanguage]; // 键盘输入模式
        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
            
            //判断markedTextRange是不是为Nil，如果为Nil的话就说明你现在没有未选中的字符，
            //可以计算文字长度。否则此时计算出来的字符长度可能不正确
            
            UITextRange *selectedRange = [textField markedTextRange];
            //获取高亮部分(感觉输入中文的时候才有)
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position)
            {
                //中文和字符一起检测  中文是两个字符
                if (toBeString.length > self.maxLength)
                {
                    textField.text = [toBeString substringToIndex:self.maxLength];
                }
            }
        }
        else
        {
            if (toBeString.length > self.maxLength)
            {
                textField.text = [toBeString substringToIndex:self.maxLength];
            }
        }
    }
}

@end
