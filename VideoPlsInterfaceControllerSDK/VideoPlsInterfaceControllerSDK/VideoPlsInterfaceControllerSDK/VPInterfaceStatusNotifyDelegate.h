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
//  VPInterfaceStatusNotifyDelegate.h
//  VideoPlsInterfaceViewSDK
//
//  Created by Zard1096 on 2017/7/3.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VPInterfaceStatusNotifyDelegate <NSObject>

@optional

/**
 *  互动层加载完成后通知
 *  @param completeDictionary 点播端会有返回值,直播端为空(直播由于数据有实时性, 初始加载基本不含数据)
 *  点播端返回结果为 {@"VideoDataIsEmpty" : NSNumber(boolValue), @"VideoDataNeedShowInFullScreen" : NSNumber(boolValue)}
 *  VideoDataIsEmpty                    表示该视频是否有点位
 *  VideoDataNeedShowInFullScreen       表示是否有全屏点
 */
- (void)vp_interfaceLoadComplete:(NSDictionary *)completeDictionary;


/**
 *  互动层加载失败
 *  @param errorString 错误信息
 */
- (void)vp_interfaceLoadError:(NSString *)errorString;

/**
 *  事件发送通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPIEventType) {
    VPIEventTypePrepareShow = 1,       //
    VPIEventTypeShow,                  // 显示
    VPIEventTypeClick,                 // 点击
    VPIEventTypeClose,                 // 关闭
    VPIEventTypeBack,                  // 中插返回
};

/**
 *  事件处理通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPIActionType) {
    VPIActionTypeNone = 0,          //
    VPIActionTypeOpenUrl,           // 打开外链
    VPIActionTypePauseVideo,        // 暂停视频
    VPIActionTypePlayVideo,         // 播放视频
    VPIActionTypeGetItem,           // 获得物品
};

@required
/**
 *  事件监控通知
 *  @param actionDictionary 参数字典
 *  对应
 *  Key:    adID
 *  Value:  string
 *
 *  Key:    adName
 *  Value:  string
 *
 *  Key:    eventType
 *  Value:  VPIEventType
 *
 *  Key:    actionType
 *  Value:  VPIActionType
 *
 *  Key:    actionString
 *  Value:  string
 *  注：VPIActionTypeOpenUrl对应Url，VPIActionTypeGetItem对应ItemId
 */
- (void)vp_interfaceActionNotify:(NSDictionary *)actionDictionary;

/**
 *  客户端需要切换屏幕方向通知
 *  @param dict 参数字典
 *  对应
 *  Key:    orientation
 *  Value:  NSNumber(1代表横屏切竖屏，2代表竖屏切横屏)
 */
- (void)vp_interfaceScreenChangedNotify:(NSDictionary *)dict;

@end
