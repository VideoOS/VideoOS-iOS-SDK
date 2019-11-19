//
//  VPLuaHolderObject.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPHolderContainerNaviSetting.h"





@interface VPLuaHolderObject : NSObject

//luaList:  [{url:xxx, md5:xxx}, {url:xxx, md5:xxx} , ...]
@property (nonatomic, strong) NSString *holderID;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *luaList;
@property (nonatomic, strong) NSString *templateLua;
@property (nonatomic, strong) NSString *h5Url;
@property (nonatomic, strong) NSDictionary *attachInfo;
@property (nonatomic, strong) VPHolderContainerNaviSetting *naviSetting;

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict;

@end

