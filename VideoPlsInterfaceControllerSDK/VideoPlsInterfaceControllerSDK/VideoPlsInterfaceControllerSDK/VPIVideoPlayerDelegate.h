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
//  VPIVideoPlayerDelegate.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by peter on 11/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import "VPIVideoPlayerSize.h"

/// The VPIVideoPlayerDelegate protocol defines methods that are called by the video player
/// object in response to the video events that occured throught the lifetime of the video rendered

/**
 * VPIVideoPlayerActionDelegate 是播放器事件, 给互动层进行简单的事件通知
 */
@protocol VPIVideoPlayerActionDelegate<NSObject>

@optional


/**
 * 播放器通知: 视频开始播放(首次)
 */
- (void)videoPlayerDidStartVideo;

/**
 * 播放器通知: 视频进入播放状态
 */
- (void)videoPlayerDidPlayVideo;

/**
 * 播放器通知: 视频进入暂停状态
 */
- (void)videoPlayerDidPauseVideo;

/**
 * 播放器通知: 视频播放终止结束
 */
- (void)videoPlayerDidStopVideo;

@end


/**
 * 互动层获取播放器信息的代理
 */
@protocol VPIVideoPlayerDelegate<NSObject>

@optional

/**
 * 获取播放器当前播放内容
 * @return bool, true为正片, false为广告(前贴、中插等)
 */
- (BOOL)isPositive;


/**
 * 获取播放器音量
 * @return 数值为0-1的浮点
 */
- (float)videoPlayerCurrentVolume;


/**
 * 获取播放器当前播放的视频的总时长
 * @return 视频的总时长, 单位为秒, 包括小数
 */
- (NSTimeInterval)videoPlayerCurrentItemAssetDuration;

@required

/**
 * 获取播放器当前的时间
 * @return 当前播放时间, 单位为秒, 包括小数
 */
- (NSTimeInterval)videoPlayerCurrentTime;


/**
 * 获取当前播放器大小
 * @return VPIVideoPlayerSize 包含小屏时和大屏时的宽高, 详见 VPIVideoPlayerSize
 */
- (VPIVideoPlayerSize *)videoPlayerSize;

/**
 * 获取当前视频的位置
 * @return videoFrame 视频内容相对于播放器的位置
 */
- (CGRect)videoFrame;

@end
