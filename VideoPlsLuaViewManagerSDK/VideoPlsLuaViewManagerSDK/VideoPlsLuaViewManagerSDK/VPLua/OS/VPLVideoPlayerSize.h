//
//  VPLVideoPlayerSize.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 16/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VPLVideoPlayerOrientation) {
    VPLVideoPlayerOrientationPortraitSmallScreen,// 竖屏小屏
    VPLVideoPlayerOrientationPortraitFullScreen,// 竖屏全屏
    VPLVideoPlayerOrientationLandscapeFullScreen,// 横屏全屏
};

@interface VPLVideoPlayerSize : NSObject

@property (nonatomic, assign) CGFloat portraitFullScreenWidth;
@property (nonatomic, assign) CGFloat portraitFullScreenHeight;
@property (nonatomic, assign) CGFloat portraitSmallScreenHeight;
@property (nonatomic, assign) CGFloat portraitSmallScreenOriginY;

@end
