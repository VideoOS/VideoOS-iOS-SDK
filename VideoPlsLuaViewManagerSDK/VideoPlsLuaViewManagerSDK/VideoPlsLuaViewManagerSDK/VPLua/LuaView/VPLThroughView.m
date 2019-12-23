//
//  VPLThroughView.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/8/31.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLThroughView.h"

@implementation VPLThroughView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

    
@end
