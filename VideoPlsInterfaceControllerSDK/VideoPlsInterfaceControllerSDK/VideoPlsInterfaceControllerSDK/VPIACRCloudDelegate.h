//
//  VPIACRCloudDelegate.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by videopls on 2020/2/25.
//  Copyright © 2020 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VPUPACRResourcesCallback)(NSString*_Nullable);
@protocol VPIACRCloudDelegate<NSObject>

@required

- (void)acrRecordStart;

- (void)acrRecordEndAndcallback:(VPUPACRResourcesCallback _Nonnull)resourcesCallback;


@end
