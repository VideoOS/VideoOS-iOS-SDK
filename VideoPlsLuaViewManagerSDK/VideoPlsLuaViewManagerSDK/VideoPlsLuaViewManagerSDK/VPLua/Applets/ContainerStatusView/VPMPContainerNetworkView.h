//
//  VPMPContainerNetworkView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/5.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPMPContainerStatusView.h"

@protocol VPMPContainerNetworkDelegate <NSObject>

- (void)retryNetwork;

@end

@interface VPMPContainerNetworkView : VPMPContainerStatusView

@property (nonatomic, weak) id<VPMPContainerNetworkDelegate> networkDelegate;

- (void)useDefaultMessage;

- (void)changeNetworkMessage:(NSString *)message;

@end
