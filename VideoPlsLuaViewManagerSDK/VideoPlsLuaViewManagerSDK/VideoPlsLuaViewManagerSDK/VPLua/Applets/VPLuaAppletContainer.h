//
//  VPLuaAppletContainer.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/1.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaAppletContainerDelegate.h"
@class VPLuaNetworkManager;
@class VPLuaVideoInfo;

typedef NS_ENUM(NSUInteger, VPLuaAppletContainerType) {
    VPLuaAppletContainerTypeLandscape     = 1,
    VPLuaAppletContainerTypePortrait      = 2
};

typedef NS_ENUM(NSUInteger, VPAppletContainerAppType) {
    VPAppletContainerAppTypeLua             = 1,
    VPAppletContainerAppTypeHybird          = 2
};

typedef NS_ENUM(NSUInteger, VPAppletContainerOrientation) {
    VPAppletContainerOrientationLandScape   = 1,
    VPAppletContainerOrientationPortriat    = 2
};

@protocol VPLuaAppletContainer <NSObject>

@property (nonatomic, readonly) NSString *appletID;

@property (nonatomic, assign, readonly) VPLuaAppletContainerType type;

@property (nonatomic, assign) VPAppletContainerOrientation currentOrientation;

@property (nonatomic, weak) id<VPLuaAppletContainerDelegate> containerDelegate;

- (instancetype)initWithAppletID:(NSString *)appletID
                  networkManager:(VPLuaNetworkManager *)networkManager
                       videoInfo:(VPLuaVideoInfo *)videoInfo
                         luaPath:(NSString *)luaPath
                            data:(id)data;

- (void)showInSuperview:(UIView *)superview;

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))getUserInfoBlock;

- (void)loadLua:(NSString *)luaUrl data:(id)data;

- (void)refreshContainerWithData:(id)data;

- (id)getInitData;

- (void)closeContainer;

- (void)destroyView;

- (void)show;

- (void)hide;

@end
