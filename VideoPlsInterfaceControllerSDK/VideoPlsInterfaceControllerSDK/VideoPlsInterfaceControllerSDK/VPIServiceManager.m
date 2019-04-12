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
//  VPIServiceManager.m
//  VideoPlsInterfaceControllerSDK
//
//  Created by peter on 2018/4/24.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPIServiceManager.h"
#import "VideoPlsUtilsPlatformSDK.h"

@implementation VPIServiceManager

- (void)registerService:(Protocol *)service implClass:(Class)implClass {
    [[VPUPServiceManager sharedManager] registerService:service implClass:implClass];
}

@end
