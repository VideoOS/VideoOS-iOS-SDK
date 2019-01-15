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
//  VPIUserLoginInterface.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 鄢江波 on 2017/9/22.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPIUserInfo.h"

@protocol VPIUserLoginInterface <NSObject>

@required

/**
 *  获取用户信息
 */
- (VPIUserInfo *)vp_getUserInfo;

/**
 *  用户登录到平台
 */
- (void)vp_userLogined:(VPIUserInfo *)userInfo;

/**
 *  登陆成功后组成userInfo使用completeBlock(userInfo)完成回调
 */
- (void)vp_requireLogin:(void (^)(VPIUserInfo *userInfo))completeBlock;

@end
