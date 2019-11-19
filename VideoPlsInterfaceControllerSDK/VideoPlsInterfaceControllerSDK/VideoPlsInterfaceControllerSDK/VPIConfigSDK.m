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
//  VPIConfigSDK.m
//  VideoPlsInterfaceViewSDK
//
//  Created by Zard1096 on 2017/6/30.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPIConfigSDK.h"

#import "VideoPlsUtilsPlatformSDK.h"
#import "VPLuaSDK.h"

@implementation VPIConfigSDK

+ (void)initSDK {
    [VPLuaSDK initSDK];
}

+ (void)setIDFA:(NSString *)IDFA {
    [VPLuaSDK setIDFA:IDFA];
}

+ (void)setIdentity:(NSString *)identity {
    [VPLuaSDK setIdentity:identity];
}

+ (void)setAppKey:(NSString *)appKey appSecret:(NSString *)appSecret {
    [VPLuaSDK setAppKey:appKey appSecret:appSecret];
}

+ (void)setAppDevEnable:(BOOL)enable {
    [VPLuaSDK setAppDevEnable:enable];
}

@end
