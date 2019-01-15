/*
 ---------------------------------------------------------------------------
 VideoOS - A Mini-App platform base on video player
 http://videojj.com/videoos/
 Copyright (C) 2019  Shanghai Ji Lian Network Technology Co., Ltd
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 ---------------------------------------------------------------------------
 */
//
//  VPIVideoPlayerSize.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by peter on 14/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VPIVideoPlayerOrientation) {
    VPIVideoPlayerOrientationPortraitSmallScreen,// 竖屏小屏
    VPIVideoPlayerOrientationPortraitFullScreen,// 竖屏全屏
    VPIVideoPlayerOrientationLandscapeFullScreen,// 横屏全屏
};

@interface VPIVideoPlayerSize : NSObject

/**
 *  竖屏全屏时的宽
 */
@property (nonatomic, assign) CGFloat portraitFullScreenWidth;

/**
 *  竖屏全屏时的高
 */
@property (nonatomic, assign) CGFloat portraitFullScreenHeight;

/**
 *  竖屏小屏时的高
 */
@property (nonatomic, assign) CGFloat portraitSmallScreenHeight;

/**
 *  竖屏小屏是到屏幕顶部的高
 */
@property (nonatomic, assign) CGFloat portraitSmallScreenOriginY;

@end
