//
//  VPUPPersistentConnectionManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/27.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPPersistentConnectionDelegate.h"

@interface VPUPPersistentConnectionManager : NSObject <VPUPPersistentConnectionDelegate>

@property (nonatomic, weak) id<VPUPPersistentConnectionObserverDelegate> observerDelegate;

@end
