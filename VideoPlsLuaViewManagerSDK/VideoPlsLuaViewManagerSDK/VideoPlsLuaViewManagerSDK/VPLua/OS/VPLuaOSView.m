//
//  VPLuaOSView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 05/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaOSView.h"
#import "VideoPlsUtilsPlatformSDK.h"

@implementation VPLuaOSView

- (void)startLoading {
    [super startLoading];
    [self openMainPage];
}

- (void)stop {
    [super stop];
    [self deregisterLuaActionNotification];
}

- (void)initLuaView {
    [super initLuaView];
    [self registerLuaActionNotification];
}

- (void)openMainPage {
    [self loadLua:@"main.lua" data:nil];
}

- (void)registerLuaActionNotification {
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(luaEnd:) name:VPUPLuaEndNotification object:self.luaController];
}

- (void)deregisterLuaActionNotification {
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPLuaEndNotification object:self.luaController];
}

- (void)luaEnd:(NSNotification *)notification {
    NSString *name = [notification.userInfo objectForKey:@"name"];
    if ([name isEqualToString:@"main.lua"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VPOSLuaEndNotification object:nil];
    }
}

@end
