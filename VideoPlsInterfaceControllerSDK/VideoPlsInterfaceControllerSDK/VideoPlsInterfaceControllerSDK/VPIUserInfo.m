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
//  VPIUserInfo.m
//  VideoPlsInterfaceControllerSDK
//
//  Created by 鄢江波 on 2017/9/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPIUserInfo.h"

@implementation VPIUserInfo

- (NSDictionary *)dictionaryForUser {
    
    if(!self.uid) {
        return nil;
    }
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:self.uid forKey:@"uid"];
    
    if(self.token) {
        [dictionary setObject:self.token forKey:@"token"];
    }
    if(self.nickName) {
        [dictionary setObject:self.nickName forKey:@"nickName"];
    }
    if(self.userName) {
        [dictionary setObject:self.userName forKey:@"userName"];
    }
    if(self.phoneNum) {
        [dictionary setObject:self.phoneNum forKey:@"phoneNum"];
    }
    
    [dictionary setObject:@(self.type) forKey:@"userType"];
    
    if (self.customDeviceId) {
        [dictionary setObject:self.customDeviceId forKey:@"customDeviceId"];
    }
    
    if (self.extendJSONString) {
        [dictionary setObject:self.extendJSONString forKey:@"extendJSONString"];
    }
    
    return dictionary;
}

@end
