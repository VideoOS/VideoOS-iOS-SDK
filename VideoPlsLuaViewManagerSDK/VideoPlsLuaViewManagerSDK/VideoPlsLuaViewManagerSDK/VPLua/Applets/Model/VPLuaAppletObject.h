//
//  VPLuaAppletObject.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPAppletContainerNaviSetting.h"
#import "VPMiniAppInfo.h"


@interface VPLuaAppletObject : NSObject

@property (nonatomic, strong) VPMiniAppInfo *miniAppInfo;
@property (nonatomic, strong) NSString *h5Url;
@property (nonatomic, strong) NSDictionary *attachInfo;
@property (nonatomic, strong) VPAppletContainerNaviSetting *naviSetting;

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict;

@end

