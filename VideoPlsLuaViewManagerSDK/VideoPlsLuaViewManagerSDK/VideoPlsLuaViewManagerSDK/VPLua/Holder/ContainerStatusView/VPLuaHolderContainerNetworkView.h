//
//  VPLuaHolderContainerNetworkView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/5.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaHolderContainerStatusView.h"

@protocol VPLuaHolderContainerNetworkDelegate <NSObject>

- (void)retryNetwork;

@end

@interface VPLuaHolderContainerNetworkView : VPLuaHolderContainerStatusView

@property (nonatomic, weak) id<VPLuaHolderContainerNetworkDelegate> networkDelegate;

- (void)useDefaultMessage;

- (void)changeNetworkMessage:(NSString *)message;

@end
