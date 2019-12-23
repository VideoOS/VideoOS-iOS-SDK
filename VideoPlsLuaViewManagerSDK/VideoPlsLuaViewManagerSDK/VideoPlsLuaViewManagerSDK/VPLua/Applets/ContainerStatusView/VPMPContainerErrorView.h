//
//  VPMPContainerErrorView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/6.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPMPContainerStatusView.h"


@interface VPMPContainerErrorView : VPMPContainerStatusView

- (void)useDefaultMessage;

- (void)changeErrorMessage:(NSString *)message;

@end
