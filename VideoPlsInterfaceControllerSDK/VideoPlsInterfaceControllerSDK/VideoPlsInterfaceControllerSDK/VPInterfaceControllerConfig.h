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
//  VPInterfaceControllerConfig.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by peter on 07/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VPInterfaceControllerType) {
    VPInterfaceControllerTypeDefault        = 0,
    VPInterfaceControllerTypeVideoOS        = 1 << 0,       //点播
    VPInterfaceControllerTypeLiveOS         = 1 << 1,       //直播
    VPInterfaceControllerTypeMall           = 1 << 2,       //子商城
    VPInterfaceControllerTypeEnjoy          = 1 << 3        //互娱
};


@interface VPInterfaceControllerConfig : NSObject

@property (nonatomic, copy) NSString *identifier;           //视频或房间ID
@property (nonatomic, copy) NSString *platformID;           //平台ID
//默认为VPInterfaceControllerTypeDefault, 不需要传入
@property (nonatomic, assign) VPInterfaceControllerType types;

/** 现有参数不能满足需求时，使用拓展字段
 *  点播有title字段(初次播放时生成的标题文字), value为NSString
 *  直播有category字段(分区投放), value为NSString
 *  直播或互娱有userType(是否为主播), value为NSNumber(VPIUserType)
 */
@property (nonatomic, copy) NSDictionary *extendDict;

@end

