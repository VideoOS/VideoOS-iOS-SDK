//
//  VPLuaHolderObject.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaHolderObject.h"
#import "VPUPHexColors.h"

@interface VPLuaHolderObject()

@end

@implementation VPLuaHolderObject

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict {
    VPLuaHolderObject *holder = [[VPLuaHolderObject alloc] init];
    if ([dict objectForKey:@"luaList"]) {
        holder.luaList = [dict objectForKey:@"luaList"];
    }
    if ([dict objectForKey:@"template"]) {
        holder.templateLua = [dict objectForKey:@"template"];
    }
    if ([dict objectForKey:@"attachInfo"]) {
        holder.attachInfo = [dict objectForKey:@"attachInfo"];
    }
    if ([dict objectForKey:@"h5Url"]) {
        holder.h5Url = [dict objectForKey:@"h5Url"];
    }
    if ([dict objectForKey:@"display"]) {
        holder.naviSetting = [VPHolderContainerNaviSetting initWithDictionary:[dict objectForKey:@"display"]];
    }
    
    return holder;
}

@end
