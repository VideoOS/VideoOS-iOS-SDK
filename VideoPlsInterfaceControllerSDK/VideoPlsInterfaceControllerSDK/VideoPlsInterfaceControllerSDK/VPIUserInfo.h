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
//  VPIUserInfo.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by 鄢江波 on 2017/9/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VPIUserType) {
    VPIUserTypeUser,                        //用户
    VPIUserTypeAnchor,                      //主播
};

@interface VPIUserInfo : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *phoneNum;
@property (nonatomic, assign) VPIUserType type;//默认为用户
@property (nonatomic, copy) NSString *customDeviceId;
//现有参数不能满足需求时，使用拓展字段extendJSONString
@property (nonatomic, copy) NSString *extendJSONString;

- (NSDictionary *)dictionaryForUser;

@end
