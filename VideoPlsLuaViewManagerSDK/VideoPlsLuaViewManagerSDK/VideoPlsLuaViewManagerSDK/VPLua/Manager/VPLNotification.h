//
//  VPLNotification.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

@class VPLBaseNode;

NS_ASSUME_NONNULL_BEGIN

@interface VPLNotification : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName;

@property (nonatomic, weak) VPLBaseNode *luaNode;

@end

NS_ASSUME_NONNULL_END
