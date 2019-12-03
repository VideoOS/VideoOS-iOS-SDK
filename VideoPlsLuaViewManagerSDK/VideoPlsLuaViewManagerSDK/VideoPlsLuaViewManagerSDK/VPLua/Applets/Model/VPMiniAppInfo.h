//
//  VPMiniAppInfo.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/21.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPMiniAppInfo : NSObject

//luaList:  [{url:xxx, md5:xxx}, {url:xxx, md5:xxx} , ...]
@property (nonatomic, strong) NSString *appletID;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *luaList;
@property (nonatomic, strong) NSString *templateLua;
@property (nonatomic, strong) NSString *developerUserId;

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryValue;

@end

