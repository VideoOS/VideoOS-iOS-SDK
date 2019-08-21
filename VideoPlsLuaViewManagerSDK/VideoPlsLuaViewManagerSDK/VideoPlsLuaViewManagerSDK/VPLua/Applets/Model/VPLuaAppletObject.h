//
//  VPLuaAppletObject.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface VPLuaAppletContainerNaviSetting : NSObject

@property (nonatomic, strong) NSString *appletName;
@property (nonatomic, strong) NSString *naviTitle;
@property (nonatomic, strong) UIColor *navibackgroundColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIColor *naviButtonColor;
@property (nonatomic, assign) CGFloat naviAlpha;

+ (instancetype)initWithDictionary:(NSDictionary *)dict;

@end


@interface VPLuaAppletObject : NSObject

//luaList:  [{url:xxx, md5:xxx}, {url:xxx, md5:xxx} , ...]
@property (nonatomic, strong) NSString *appletID;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *luaList;
@property (nonatomic, strong) NSString *templateLua;
@property (nonatomic, strong) NSDictionary *attachInfo;
@property (nonatomic, strong) VPLuaAppletContainerNaviSetting *naviSetting;

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict;

@end

