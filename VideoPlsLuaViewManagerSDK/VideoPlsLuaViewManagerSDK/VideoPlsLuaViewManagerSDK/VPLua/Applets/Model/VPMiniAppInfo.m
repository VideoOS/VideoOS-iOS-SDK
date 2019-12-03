//
//  VPMiniAppInfo.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/21.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPMiniAppInfo.h"

@implementation VPMiniAppInfo

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict {
    VPMiniAppInfo *info = [[VPMiniAppInfo alloc] init];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (![dict objectForKey:@"miniAppId"]) {
        return nil;
    }
    
    info.appletID = [dict objectForKey:@"miniAppId"];
    
    if ([dict objectForKey:@"luaList"]) {
        info.luaList = [dict objectForKey:@"luaList"];
    }
    if ([dict objectForKey:@"developerUserId"]) {
        info.developerUserId = [dict objectForKey:@"developerUserId"];
    } else {
        info.developerUserId = @"10001001000";
    }
    if ([dict objectForKey:@"template"]) {
        info.templateLua = [dict objectForKey:@"template"];
    }
    return info;
}

- (NSDictionary *)dictionaryValue {
    NSDictionary *dict = [NSMutableDictionary dictionary];
    if (self.appletID) {
        [dict setValue:self.appletID forKey:@"miniAppId"];
    }
    if (self.luaList) {
        [dict setValue:self.luaList forKey:@"luaList"];
    }
    if (self.developerUserId) {
        [dict setValue:self.developerUserId forKey:@"developerUserId"];
    }
    if (self.templateLua) {
        [dict setValue:self.templateLua forKey:@"template"];
    }
    return dict;
}

@end
