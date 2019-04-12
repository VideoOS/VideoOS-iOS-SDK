//
//  VPLuaGradientView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096 on 2018/1/9.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import "VPLuaGradientView.h"

#import <VPLuaViewSDK/LVUtil.h>
#import <VPLuaViewSDK/LVStruct.h>
#import <VPLuaViewSDK/LVBaseView.h>
#import <VPLuaViewSDK/LView.h>
#import <VPLuaViewSDK/LVHeads.h>

@interface VPLuaGradientView()

@property (nonatomic, weak) CAGradientLayer *gradientLayer;
@property (nonatomic, weak) CAShapeLayer *cornerLayer;
@property (nonatomic, strong) NSArray *radiiValue;
@property (nonatomic, weak) CAShapeLayer *pathLayer;

@end

#define META_TABLE_GradientView "UI.GradientView"

@implementation VPLuaGradientView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.gradientLayer) {
        self.gradientLayer.frame = self.bounds;
        
//        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];;
//        gradientLayer.frame = self.bounds;
//        gradientLayer.colors = self.gradientLayer.colors;
//        gradientLayer.startPoint = self.gradientLayer.startPoint;
//        gradientLayer.endPoint = self.gradientLayer.endPoint;
//        
//        self.gradientLayer = gradientLayer;
//        
//        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    
    if (self.cornerLayer) {
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        
        UIBezierPath *path = [VPLuaGradientView maskCornerRadiiValue:self.radiiValue rect:self.bounds];
        maskLayer.path = path.CGPath;
        
        self.cornerLayer = maskLayer;
        
        self.layer.mask = self.cornerLayer;
    }
    if (self.pathLayer) {
        
        UIBezierPath *path = nil;
        if (self.cornerLayer) {
            path = [VPLuaGradientView maskCornerRadiiValue:self.radiiValue rect:self.bounds];
        }
        else {
            path = [UIBezierPath bezierPathWithRect:self.bounds];
        }
        
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = self.bounds;
        pathLayer.lineWidth = self.pathLayer.lineWidth;
        pathLayer.strokeColor = self.pathLayer.strokeColor;
        pathLayer.path = path.CGPath;
        pathLayer.fillColor = nil; // 默认为blackColor
        [self.pathLayer removeFromSuperlayer];
        [self.layer addSublayer:pathLayer];
        self.pathLayer = pathLayer;
    }
}

-(id) init:(lua_State*) l{
    self = [super init:l];
    if( self ) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
    }
    return self;
}

#pragma lua clas define
+(int) lvClassDefine:(lua_State *)L globalName:(NSString*)globalName {
    [LVUtil reg:L clas:self cfunc:lvNewGradientView globalName:globalName defaultName:@"GradientView"];
    const struct luaL_Reg memberFunctions [] = {
        {"destroyView", destroyView},
        {"gradient", gradient},
        {"corner", corner},
        {"stroke", stroke},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L, META_TABLE_GradientView);
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0);
    luaL_openlib(L, NULL, memberFunctions, 0);
    
    return 1;
}

//c函数，初始化itemView
static int lvNewGradientView (lua_State *L){
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaGradientView class]];
    {
        VPLuaGradientView* gradientView = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, View);
            userData->object = CFBridgingRetain(gradientView);
            gradientView.lv_userData = userData;
            luaL_getmetatable(L, META_TABLE_GradientView );
            lua_setmetatable(L, -2);
            
        }
        LuaViewCore *view = LV_LUASTATE_VIEW(L);
        if (view) {
            [view containerAddSubview:gradientView];
        }
    }
    return 1; /* new userdatum is already on the stack */
}

static int gradient(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if(user) {
        VPLuaGradientView* gradientView = (__bridge VPLuaGradientView *)(user->object);
        
        if (lua_gettop(L) >= 3) {
            
            if (!gradientView.gradientLayer) {
                CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
                gradientView.gradientLayer = gradientLayer;
                gradientView.gradientLayer.frame = gradientView.bounds;
                [gradientView.layer addSublayer:gradientView.gradientLayer];
            }
            
            UIColor* color1 = nil;
            UIColor* color2 = nil;
            BOOL useFourParamColor = NO;
            
            if (lua_gettop(L) < 4) {
                color1 = lv_getColorFromStack(L, 2);
                color2 = lv_getColorFromStack(L, 3);
            } else if (lua_gettop(L) >= 5) {
                useFourParamColor = YES;
                color1 = lv_getColorFromStack(L, 2);
                color2 = lv_getColorFromStack(L, 4);
            }
            
            gradientView.gradientLayer.colors = @[(id)color1.CGColor, (id)color2.CGColor];
            
            if (lua_gettop(L) >= 7 + 2 * useFourParamColor) {
                //gradient position, default [0.5, 0] -> [0.5, 1]
                NSMutableArray *positions = [NSMutableArray arrayWithObjects:@(0.5), @0, @(0.5), @1, nil];
                for (int i = 4 + 2 * useFourParamColor; i <= 7 + 2 * useFourParamColor; i++) {
                    if (lua_isnumber(L, i)) {
                        double number = lua_tonumber(L, i);
                        if(number >=0 && number <= 1) {
                            [positions replaceObjectAtIndex:i - 4 - 2 * useFourParamColor withObject:@(number)];
                        }
                    }
                }
                gradientView.gradientLayer.startPoint = CGPointMake([positions[0] doubleValue], [positions[1] doubleValue]);
                gradientView.gradientLayer.endPoint = CGPointMake([positions[2] doubleValue], [positions[3] doubleValue]);
            }
        }
    }
    return 0;
}

static int corner(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if(user) {
        VPLuaGradientView* gradientView = (__bridge VPLuaGradientView *)(user->object);
        if (lua_gettop(L) >= 9) {
            
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = gradientView.bounds;
            
            NSMutableArray *positions = [NSMutableArray arrayWithObjects:@0, @0, @0, @0, @0, @0, @0, @0, nil];
            for (int i = 2; i <= 9; i++) {
                if (lua_isnumber(L, i)) {
                    double number = lua_tonumber(L, i);
                    if(number >=0) {
                        [positions replaceObjectAtIndex:i - 2 withObject:@(number)];
                    }
                }
            }
            
            UIBezierPath *path = [VPLuaGradientView maskCornerRadiiValue:positions rect:gradientView.bounds];
            maskLayer.path = path.CGPath;
            
            gradientView.cornerLayer = maskLayer;
            
            gradientView.layer.mask = gradientView.cornerLayer;
            gradientView.radiiValue = positions;
            
            if (gradientView.pathLayer) {
//                UIBezierPath *path = [VPLuaGradientView maskCornerRadiiValue:self.radiiValue rect:self.bounds];
                
                CAShapeLayer *pathLayer = [CAShapeLayer layer];
                pathLayer.frame = gradientView.bounds;
                pathLayer.lineWidth = gradientView.pathLayer.lineWidth;
                pathLayer.strokeColor = gradientView.pathLayer.strokeColor;
                pathLayer.path = path.CGPath;
                pathLayer.fillColor = nil; // 默认为blackColor
                [gradientView.pathLayer removeFromSuperlayer];
                [gradientView.layer addSublayer:pathLayer];
                gradientView.pathLayer = pathLayer;
            }
        }
    }
    return 0;
}

static int stroke(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if(user) {
        VPLuaGradientView* gradientView = (__bridge VPLuaGradientView *)(user->object);
        if (lua_gettop(L) >= 3) {
            CGFloat width = lua_tonumber(L, 2);
            UIColor *color = lv_getColorFromStack(L, 3);
                // 线的路径
            UIBezierPath *path = nil;
            if (gradientView.cornerLayer) {
                path = [VPLuaGradientView maskCornerRadiiValue:gradientView.radiiValue rect:gradientView.bounds];
            }
            else {
                path = [UIBezierPath bezierPathWithRect:gradientView.bounds];
            }
            
            CAShapeLayer *pathLayer = [CAShapeLayer layer];
            pathLayer.lineWidth = width;
            pathLayer.strokeColor = color.CGColor;
            pathLayer.path = path.CGPath;
            pathLayer.fillColor = nil; // 默认为blackColor
            if (gradientView.pathLayer) {
                [gradientView.pathLayer removeFromSuperlayer];
            }
            [gradientView.layer addSublayer:pathLayer];
            gradientView.pathLayer = pathLayer;
        }
    }
    return 0;
}


static int destroyView(lua_State *L) {
    return 0;
}


+ (UIBezierPath *)maskCornerRadiiValue:(NSArray *)radiiValue rect:(CGRect)rect {
    
    CGFloat currentX = rect.origin.x;
    CGFloat currentY = rect.origin.y;
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    
    //结束点和起始点区别itemWidthRadius和itemHeightRadius交换, 第1,3位需要相反
    //顺序  width,height,itemWidth,itemHeight
    NSArray *markArray = @[@[@0,@0,@0,   @1   ],
                           @[@1,@0,@(-1),@0   ],
                           @[@1,@1,@0,   @(-1)],
                           @[@0,@1,@1,   @0   ]];
    
    //    NSArray *endArray   = @[@[@0,@0,@1,   @0   ],
    //                            @[@1,@0,@0,   @1   ],
    //                            @[@1,@1,@(-1),@0   ],
    //                            @[@0,@1,@0,   @(-1)]];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:CGPointMake(currentX, currentY +  height / 2)];
    
    for(NSInteger i = 0;i < [radiiValue count] / 2; i++) {
        
        CGFloat itemWidthRadius = [[radiiValue objectAtIndex:i * 2] floatValue];
        CGFloat itemHeightRadius = [[radiiValue objectAtIndex:i * 2 + 1] floatValue];
        itemWidthRadius = itemWidthRadius > width / 2 ? width / 2 : itemWidthRadius;
        itemHeightRadius = itemHeightRadius > height / 2 ? height / 2 : itemHeightRadius;
        
        CGFloat kappa = 0.5522848f;     //4*((sqrt(2)-1)/3) 好像是绘制圆形、椭圆形的偏移
        //control point 偏移
        CGFloat ox = itemWidthRadius * kappa;
        CGFloat oy = itemHeightRadius * kappa;
        
        
        //startPoint
        NSArray *currentMark = [markArray objectAtIndex:i];
        
        //item mark for endPoint and controlPoint2
        NSInteger mark = pow(-1, i);
        
        //ox,oy mark2
        NSInteger oMark = -1;
        
        CGPoint startPoint = CGPointMake(
                                         currentX +
                                         width * [currentMark[0] integerValue] +
                                         itemWidthRadius * [currentMark[2] integerValue],
                                         currentY +
                                         height * [currentMark[1] integerValue] +
                                         itemHeightRadius * [currentMark[3] integerValue]);
        
        CGPoint endPoint = CGPointMake(
                                       currentX +
                                       width * [currentMark[0] integerValue] +
                                       (itemWidthRadius * [currentMark[3] integerValue]) * mark,
                                       currentY +
                                       height * [currentMark[1] integerValue] +
                                       (itemHeightRadius * [currentMark[2] integerValue]) * mark);
        
        CGPoint controlPoint1 = CGPointMake(
                                            startPoint.x +
                                            [currentMark[2] integerValue] * oMark * ox,
                                            startPoint.y +
                                            [currentMark[3] integerValue] * oMark * oy);
        
        CGPoint controlPoint2 = CGPointMake(
                                            endPoint.x +
                                            [currentMark[3] integerValue] * oMark * ox,
                                            endPoint.y +
                                            [currentMark[2] integerValue] * mark * oMark * oy);
        
        [maskPath addLineToPoint:startPoint];
        
        [maskPath addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    }
    
    [maskPath closePath];
    
    markArray = nil;
    
    return maskPath;
}

@end
