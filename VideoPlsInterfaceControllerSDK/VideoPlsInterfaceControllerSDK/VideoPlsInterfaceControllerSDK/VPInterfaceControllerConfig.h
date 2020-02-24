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

//注意identifier，episode，title不能为空
@property (nonatomic, copy) NSString *identifier;           //视频或房间ID

@property (nonatomic, copy) NSString *episode;              //剧集名称，例如：邪恶力量第九季

@property (nonatomic, copy) NSString *title;                //视频标题，例如：邪恶力量 第九季 第五集

@property (nonatomic, copy) NSString *platformID;           //平台ID
//默认为VPInterfaceControllerTypeDefault, 不需要传入
@property (nonatomic, assign) VPInterfaceControllerType types;

/** 分层投放的参数通过extendDict字段传递
 *  所有参数采用key:array方式传递，key为分层的层级关键字，array里面为层级对应的具体值
 *  一些常见的参数，推荐使用下面的命名方式
 *  标题title，例如 邪恶力量 第九季 第五集，[dict setObject:@[@"邪恶力量 第九季 第五集"] forKey:@"title"];
 *  剧集，例如 邪恶力量第九季，[dict setObject:@[@"邪恶力量第九季"] forKey:@"episode"];
 *  剧集Id，例如 628916289，[dict setObject:@[@"628916289"] forKey:@"episodeId"];
 *  地区/区域，例如 美剧，[dict setObject:@[@"美剧"] forKey:@"area"];
 *  年份，例如 2019，[dict setObject:@[@"2019"] forKey:@"years"];
 *  类型，例如 科幻，武侠，[dict setObject:@[@"科幻", @"武侠"] forKey:@"episodeId"];
 *  剧集Id，例如 628916289，[dict setObject:@[@"628916289"] forKey:@"episodeId"];
 *  其他扩展字段也可以通过extendDict字段传递
 */
@property (nonatomic, copy) NSDictionary *extendDict;

@end

