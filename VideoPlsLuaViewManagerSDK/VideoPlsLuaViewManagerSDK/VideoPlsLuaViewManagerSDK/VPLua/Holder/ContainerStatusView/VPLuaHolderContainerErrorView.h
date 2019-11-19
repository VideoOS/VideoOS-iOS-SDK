//
//  VPLuaHolderContainerErrorView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/6.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaHolderContainerStatusView.h"


@interface VPLuaHolderContainerErrorView : VPLuaHolderContainerStatusView

- (void)useDefaultMessage;

- (void)changeErrorMessage:(NSString *)message;

@end
