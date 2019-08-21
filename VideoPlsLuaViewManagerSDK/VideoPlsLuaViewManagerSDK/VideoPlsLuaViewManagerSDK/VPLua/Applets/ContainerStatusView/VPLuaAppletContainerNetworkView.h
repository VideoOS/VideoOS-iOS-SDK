//
//  VPLuaAppletContainerNetworkView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/5.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaAppletContainerStatusView.h"

@protocol VPLuaAppletContainerNetworkDelegate <NSObject>

- (void)retryNetwork;

@end

@interface VPLuaAppletContainerNetworkView : VPLuaAppletContainerStatusView

@property (nonatomic, weak) id<VPLuaAppletContainerNetworkDelegate> networkDelegate;

- (void)useDefaultMessage;

- (void)changeNetworkMessage:(NSString *)message;

@end
