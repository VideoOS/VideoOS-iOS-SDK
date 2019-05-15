//
//  VPLuaHttpRequest.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/5/7.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

@class VPLuaBaseNode;

@interface VPLuaHttpRequest : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName;

@property (nonatomic, weak) VPLuaBaseNode *luaNode;

@end
