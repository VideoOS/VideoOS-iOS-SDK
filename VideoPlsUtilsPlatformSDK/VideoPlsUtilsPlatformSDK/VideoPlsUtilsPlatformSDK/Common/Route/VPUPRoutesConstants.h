//
//  VPUPRoutesConstants.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 07/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

//Routes schems
/**
 Routes scheme for SDK init.
 */
extern NSString *const VPUPRoutesSDKInit;

/**
 Routes scheme for SDK send request.
 */
extern NSString *const VPUPRoutesSDKSendRequest;

/**
 Routes scheme for SDK create or load lua view.
 */
extern NSString *const VPUPRoutesSDKLuaView;

/**
 Routes scheme for SDK create native view.
 */
extern NSString *const VPUPRoutesSDKNativeView;

/**
 Routes scheme for SDK navigation page.
 */
extern NSString *const VPUPRoutesSDKNavigationPage;

//Routes Key
/// The matching routes type, passed in the handler parameters.
extern NSString *const VPUPRoutesTypeKey;

/// The matching routes root view, passed in the handler parameters.
extern NSString *const VPUPRoutesRootView;
