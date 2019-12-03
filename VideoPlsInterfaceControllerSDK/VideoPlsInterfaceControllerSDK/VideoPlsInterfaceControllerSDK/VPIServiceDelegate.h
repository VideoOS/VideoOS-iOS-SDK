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
//  VPIServiceDelegate.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by peter on 07/15/2019.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VPIServiceType) {
    VPIServiceTypeNone                  = 0,
    VPIServiceTypeVideoMode             = 1,       //视联网模式
    VPIServiceTypePreAdvertising        = 2,       //前帖广告
    VPIServiceTypePostAdvertising       = 3,       //后帖广告
    VPIServiceTypePauseAd               = 4,       //暂停广告
};

typedef NS_ENUM(NSInteger, VPIVideoAdTimeType) {
    VPIVideoAdTimeTypeNone                  = 60,           //60s
    VPIVideoAdTimeType15Seconds             = 15,           //15s
    VPIVideoAdTimeType30Seconds             = 30,           //30s
    VPIVideoAdTimeType45Seconds             = 45,           //45s
    VPIVideoAdTimeType60Seconds             = 60,           //60s
    VPIVideoAdTimeType90Seconds             = 90,           //90s
    VPIVideoAdTimeType120Seconds            = 120,          //120s
};

typedef NS_ENUM(NSInteger, VPIVideoModeType) {
    VPIVideoModeTypeLabel                   = 0,        //视联网标签模式
    VPIVideoModeTypeBubble                  = 1,        //视联网气泡模式
};

/**
 * VPIServiceDelegate 是相关服务事件, 给服务进行简单的事件通知
 */
@protocol VPIServiceDelegate<NSObject>

@optional

/**
 * 服务通知: 相关服务成功完成
 */
- (void)vp_didCompleteForService:(VPIServiceType )type;

/**
 * 服务通知: 相关服务执行失败
 */
- (void)vp_didFailToCompleteForService:(VPIServiceType )type error:(NSError *)error;

@end
