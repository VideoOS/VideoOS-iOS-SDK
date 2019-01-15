//
//  VPLuaScrollView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/5/14.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaScrollView.h"
#import "LuaViewCore.h"
#import "LVBaseView.h"


@interface VPLuaScrollView()

@end

#define META_TABLE_ScrollView "UI.VScrollView"

@implementation VPLuaScrollView

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
        self.alwaysBounceHorizontal = NO;
        self.lvScrollViewDelegate = self;
    }
    return self;
}

static int lvNewScrollView (lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaScrollView class]];
    
    VPLuaScrollView* scrollView = [[c alloc] init:L];
    {
        NEW_USERDATA(userData, View);
        userData->object = CFBridgingRetain(scrollView);
        scrollView.lv_userData = userData;
        
        luaL_getmetatable(L, META_TABLE_ScrollView );
        lua_setmetatable(L, -2);
    }
    
    LuaViewCore* lview = LV_LUASTATE_VIEW(L);
    if( lview ){
        [lview containerAddSubview:scrollView];
    }
    return 1; /* new userdatum is already on the stack */
}

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName {
    
    [LVUtil reg:L clas:self cfunc:lvNewScrollView globalName:globalName defaultName:@"HScrollView"];
    
    const struct luaL_Reg memberFunctions [] = {
        {"addView", addSubview},
        {"fullScroll", fullScroll},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L ,META_TABLE_ScrollView);
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0);
    luaL_openlib(L, NULL, [LVScrollView memberFunctions], 0);
    luaL_openlib(L, NULL, memberFunctions, 0);
    
//    const char* keys[] = { "addView", NULL};// 移除多余API
//    lv_luaTableRemoveKeys(L, keys );
    return 1;
}

static int addSubview (lua_State *L) {
    LVUserDataInfo * father = (LVUserDataInfo *)lua_touserdata(L, 1);
    LVUserDataInfo * son = (LVUserDataInfo *)lua_touserdata(L, 2);
    LuaViewCore* luaview = LV_LUASTATE_VIEW(L);
    if( father &&  LVIsType(son, View) ){
        VPLuaScrollView* superview = (__bridge VPLuaScrollView *)(father->object);
        UIView* subview = (__bridge UIView *)(son->object);
        if( superview && subview ){
            CGFloat y = 0.0;
            if (superview.subviews.count > 0) {
                y = [superview subviewsMaxY];
            }
//            else {
//                y = superview.bounds.size.height - subview.bounds.size.height;
//            }
            if( lua_gettop(L)>=3 && lua_type(L,3)==LUA_TNUMBER ){
                int index = lua_tonumber(L,3);
                lv_addSubviewByIndex(luaview, superview, subview, index);
            } else {
                lv_addSubview(luaview, superview, subview);
            }
            [subview lv_alignSelfWithSuperRect:superview.frame];
            subview.frame = CGRectMake(0, y, subview.bounds.size.width, subview.bounds.size.height);
            superview.contentSize = CGSizeMake(superview.bounds.size.width, [superview subviewsMaxY]);
            lua_pushvalue(L,1);
            return 1;
        }
    }
    return 0;
}

static int fullScroll (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaScrollView *scrollView = (__bridge VPLuaScrollView *)(user->object);// 获取self对应的native对象
        if( [scrollView isKindOfClass:[VPLuaScrollView class]] ){
            [scrollView setContentOffset:CGPointMake(0, MAX(0, [scrollView subviewsMaxY] - scrollView.frame.size.height)) animated:YES];
            return 0;
        }
    }
    return 0;
}

- (CGFloat)subviewsMaxY {
    CGFloat maxY = 0;
    for (UIView *view in self.subviews) {
        CGFloat tempY = CGRectGetMaxY(view.frame);
        if (tempY > maxY) {
            maxY = tempY;
        }
    }
    return maxY;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.contentOffset.y == 0) {
        [self lv_callLuaCallback:@"ScrollTop"];
    }
    if (self.contentSize.height > 0 && ceil(self.contentSize.height) == ceil(self.contentOffset.y + self.bounds.size.height)) {
        [self lv_callLuaCallback:@"ScrollBottom"];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (self.contentOffset.y == 0) {
        [self lv_callLuaCallback:@"ScrollTop"];
    }
    
    if (self.contentSize.height > 0 && ceil(self.contentSize.height) == ceil(self.contentOffset.y + self.bounds.size.height)) {
        [self lv_callLuaCallback:@"ScrollBottom"];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.contentOffset.y == 0) {
        [self lv_callLuaCallback:@"ScrollTop"];
    }
    if (self.contentSize.height > 0 && ceil(self.contentSize.height) == ceil(self.contentOffset.y + self.bounds.size.height)) {
        [self lv_callLuaCallback:@"ScrollBottom"];
    }
}

@end
