//
//  VPMPContainer.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/1.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPMPContainerDelegate.h"
@class VPLNetworkManager;
@class VPLVideoInfo;

typedef NS_ENUM(NSUInteger, VPMPContainerType) {
    VPMPContainerTypeLandscape     = 1,
    VPMPContainerTypePortrait      = 2
};

typedef NS_ENUM(NSUInteger, VPMPContainerAppType) {
    VPMPContainerAppTypeLScript         = 1,
    VPMPContainerAppTypeHybird          = 2
};

typedef NS_ENUM(NSUInteger, VPMPContainerOrientation) {
    VPMPContainerOrientationLandScape   = 1,
    VPMPContainerOrientationPortriat    = 2
};

@protocol VPMPContainer <NSObject>

@property (nonatomic, readonly) NSString *mpID;

@property (nonatomic, assign, readonly) VPMPContainerType type;

@property (nonatomic, assign) VPMPContainerOrientation currentOrientation;

@property (nonatomic, weak) id<VPMPContainerDelegate> containerDelegate;

- (instancetype)initWithMPID:(NSString *)mpID
              networkManager:(VPLNetworkManager *)networkManager
                   videoInfo:(VPLVideoInfo *)videoInfo
                       lPath:(NSString *)lPath
                        data:(id)data;

- (void)showInSuperview:(UIView *)superview;

- (void)setGetUserInfoBlock:(NSDictionary *(^)(void))getUserInfoBlock;

- (void)loadLFile:(NSString *)luaUrl data:(id)data;

- (void)refreshContainerWithData:(id)data;

- (id)getInitData;

- (void)closeContainer;

- (void)destroyView;

- (void)show;

- (void)hide;

@end
