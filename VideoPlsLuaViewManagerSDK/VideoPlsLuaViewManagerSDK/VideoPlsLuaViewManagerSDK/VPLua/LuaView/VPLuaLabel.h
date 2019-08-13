//
//  VPLuaLabel.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/22.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VPLuaViewSDK/LVLabel.h>

typedef NS_ENUM(int, VPLuaLabelVerticalAlignment) {
    VPLuaLabelVerticalAlignmentCenter   = 0,
    VPLuaLabelVerticalAlignmentTop      = 1,
    VPLuaLabelVerticalAlignmentBottom   = 2,
};

@interface VPLuaLabel : LVLabel

@property (nonatomic, assign) VPLuaLabelVerticalAlignment verticalAlignment;

@end
