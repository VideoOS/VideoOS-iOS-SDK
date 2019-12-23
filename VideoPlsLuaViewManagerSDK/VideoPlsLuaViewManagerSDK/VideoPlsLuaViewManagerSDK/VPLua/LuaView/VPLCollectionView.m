//
//  VPLCollectionView.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/11/13.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLCollectionView.h"

@implementation VPLCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init:(lua_State *)l {
    self = [super init:l];
    if(self) {
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

@end
