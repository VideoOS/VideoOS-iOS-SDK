//
//  VPLuaVideoPlayerSize.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 16/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VPLuaVideoPlayerOrientation) {
    VPLuaVideoPlayerOrientationPortraitSmallScreen,// 竖屏小屏
    VPLuaVideoPlayerOrientationPortraitFullScreen,// 竖屏全屏
    VPLuaVideoPlayerOrientationLandscapeFullScreen,// 横屏全屏
};

@interface VPLuaVideoPlayerSize : NSObject

@property (nonatomic, assign) CGFloat portraitFullScreenWidth;
@property (nonatomic, assign) CGFloat portraitFullScreenHeight;
@property (nonatomic, assign) CGFloat portraitSmallScreenHeight;
@property (nonatomic, assign) CGFloat portraitSmallScreenOriginY;

@end
