//
//  VPUPACRCloudAPIManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2020/3/23.
//  Copyright © 2020 videopls. All rights reserved.
//

#ifndef VPUPACRCloudAPIManager_h
#define VPUPACRCloudAPIManager_h

typedef void (^VPUPACRMusicInfoCallback)(NSDictionary*_Nullable);

@protocol VPUPACRCloudAPIManager <NSObject>

+ (void)acrRecognitionMusic:(NSString*_Nullable)path key:(NSString*_Nullable)key secret:(NSString*_Nullable)secret  callback:(VPUPACRMusicInfoCallback _Nonnull)musicInfoCallback;

@end

#endif /* VPUPACRCloudAPIManager_h */
