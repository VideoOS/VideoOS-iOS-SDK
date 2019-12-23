//
//  VPLLabel.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/22.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VPLuaViewSDK/LVLabel.h>

typedef NS_ENUM(int, VPLLabelVerticalAlignment) {
    VPLLabelVerticalAlignmentCenter   = 0,
    VPLLabelVerticalAlignmentTop      = 1,
    VPLLabelVerticalAlignmentBottom   = 2,
};

@interface VPLLabel : LVLabel

@property (nonatomic, assign) VPLLabelVerticalAlignment verticalAlignment;

@end
