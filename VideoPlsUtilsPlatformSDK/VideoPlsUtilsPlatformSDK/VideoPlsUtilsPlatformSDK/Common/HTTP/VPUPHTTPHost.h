//
//  VPUPHTTPHost.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 09/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPHTTPHost : NSObject

+ (NSURL *)urlForCurrentEnvironment:(NSURL *)url;

@end
