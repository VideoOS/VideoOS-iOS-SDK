//
//  VPUPLoadImageButtonConfig.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/6.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPLoadImageBaseConfig.h"

@interface VPUPLoadImageButtonConfig : VPUPLoadImageBaseConfig

/**
 *  UIButton 特殊选项
 */
@property (nonatomic, assign) UIControlState state;

/**
 *  UIButton 特殊选项，是背景图片还是左侧 icon，可选。默认为左侧 icon
 */
@property (nonatomic, assign, getter=isBackgroundImage) BOOL backgroundImage;

@end
