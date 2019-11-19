//
//  VPLuaHolderContainer.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/1.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaHolderContainerDelegate.h"
@class VPLuaNetworkManager;
@class VPLuaVideoInfo;

typedef NS_ENUM(NSUInteger, VPLuaHolderContainerType) {
    VPLuaHolderContainerTypeLandscape     = 1,
    VPLuaHolderContainerTypePortrait      = 2
};

typedef NS_ENUM(NSUInteger, VPHolderContainerAppType) {
    VPHolderContainerAppTypeLua             = 1,
    VPHolderContainerAppTypeHybird          = 2
};

@protocol VPLuaHolderContainer <NSObject>

@property (nonatomic, readonly) NSString *holderID;

@property (nonatomic, assign, readonly) VPLuaHolderContainerType type;

@property (nonatomic, weak) id<VPLuaHolderContainerDelegate> containerDelegate;

- (instancetype)initWithHolderID:(NSString *)holderID
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
