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
//  VPIConfigSDK.h
//  VideoPlsInterfaceViewSDK
//
//  Created by Zard1096 on 2017/6/30.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPIConfigSDK : NSObject

/**
 *  初始化配置设置SDK
 */
+ (void)initSDK;

/**
 *  设置IDFA
 *  @param IDFA 苹果广告IDFA码
 */
+ (void)setIDFA:(NSString *)IDFA;


/**
 * 设置SDK在本APP中的设备ID
 * @param identity NSString 最好通过时间戳加随机字符串来生成
 */
+ (void)setIdentity:(NSString *)identity;

@end
