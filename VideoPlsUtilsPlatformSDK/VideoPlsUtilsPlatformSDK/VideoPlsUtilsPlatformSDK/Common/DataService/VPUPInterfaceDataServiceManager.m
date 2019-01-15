//
//  VPUPInterfaceDataServiceManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 24/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPInterfaceDataServiceManager.h"

static VPUPInterfaceDataServiceManager *m_dataServiceManager = nil;
static dispatch_once_t m_dataServiceManagerOnceToken;

@interface VPUPInterfaceDataServiceManager ()

@property (nonatomic, weak) id<VPUPInterfaceDataServiceManagerDelegate> delegate;

@end


@implementation VPUPInterfaceDataServiceManager

- (instancetype)initWithVPUPInterfaceDataServiceManagerDelegate:(id<VPUPInterfaceDataServiceManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

+ (void)managerWithVPUPDataServiceManagerDelegate:(id<VPUPInterfaceDataServiceManagerDelegate>)delegate; {
    if (!delegate) {
        return;
    }
    dispatch_once(&m_dataServiceManagerOnceToken, ^{
        m_dataServiceManager = [[self alloc] initWithVPUPInterfaceDataServiceManagerDelegate:delegate];
    });
}


+ (NSDictionary*)getUserInfo {
    if (!m_dataServiceManager || !m_dataServiceManager.delegate) {
        return nil;
    }
    return [m_dataServiceManager.delegate getUserInfo];
}

+ (NSTimeInterval)videoPlayerCurrentItemAssetDuration {
    if (!m_dataServiceManager || !m_dataServiceManager.delegate) {
        return -1;
    }
    return [m_dataServiceManager.delegate videoPlayerCurrentItemAssetDuration];
}

+ (NSTimeInterval)videoPlayerCurrentTime {
    if (!m_dataServiceManager || !m_dataServiceManager.delegate) {
        return -1;
    }
    return [m_dataServiceManager.delegate videoPlayerCurrentTime];
}

+ (VPUPVideoPlayerSize *)videoPlayerSize {
    if (!m_dataServiceManager || !m_dataServiceManager.delegate) {
        return nil;
    }
    return [m_dataServiceManager.delegate videoPlayerSize];;
}

+ (void)deallocManager {
    m_dataServiceManagerOnceToken = 0;
    m_dataServiceManager = nil;
}

@end
