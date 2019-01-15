//
//  VPUPNetworkReachabilityManager.m
//  ResumeDownloader
//
//  Created by peter on 16/11/2017.
//  Copyright © 2017 JSS. All rights reserved.
//

#import "VPUPNetworkReachabilityManager.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import <UIKit/UIDevice.h>

@interface VPUPNetworkReachabilityManager()

@property (nonatomic, readwrite, assign) VPUPNetworkReachabilityStatus currentNetworkStatus;
@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) VPUPNetworkReachabilityStatus networkReachabilityStatus;

- (VPUPNetworkReachabilityStatus)networkStatusForReachabilityFlags:(SCNetworkReachabilityFlags)flags;

@end

NSString * const VPUPNetworkingReachabilityDidChangeNotification = @"com.videopls.networking.reachability.change";
NSString * const VPUPNetworkingReachabilityNotificationStatusItem = @"VPUPNetworkingReachabilityNotificationStatusItem";

typedef void (^VPUPNetworkReachabilityStatusBlock)(VPUPNetworkReachabilityStatus status);

static void VPUPPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, VPUPNetworkReachabilityStatusBlock block) {
    VPUPNetworkReachabilityStatus status = [[VPUPNetworkReachabilityManager sharedManager] networkStatusForReachabilityFlags:flags];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ VPUPNetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:VPUPNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

static void VPUPNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    VPUPPostReachabilityStatusChange(flags, (__bridge VPUPNetworkReachabilityStatusBlock)info);
}

static const void * VPUPNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void VPUPNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}


@implementation VPUPNetworkReachabilityManager

+ (VPUPNetworkReachabilityManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static VPUPNetworkReachabilityManager *_networkReachabilityManager = nil;
    dispatch_once(&onceToken, ^{
        _networkReachabilityManager = [[self alloc] init];
        //开始监控网络变化
        [_networkReachabilityManager startMonitoring];
    });
    return _networkReachabilityManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
        struct sockaddr_in6 address;
        bzero(&address, sizeof(address));
        address.sin6_len = sizeof(address);
        address.sin6_family = AF_INET6;
#else
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
#endif
        _networkReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&address);
        
        //开始解析当前网络状态
        [self reachabilityStatus];
    }
    return self;
}

- (BOOL)startMonitoring
{
    if (!_networkReachability)
    {
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
        struct sockaddr_in6 address;
        bzero(&address, sizeof(address));
        address.sin6_len = sizeof(address);
        address.sin6_family = AF_INET6;
#else
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
#endif
        _networkReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&address);
    }
    
    if (_networkReachability)
    {
        __weak __typeof(self)weakSelf = self;
        VPUPNetworkReachabilityStatusBlock callback = ^(VPUPNetworkReachabilityStatus status) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf reachabilityStatus];
//            if (strongSelf.networkReachabilityStatusBlock) {
//                strongSelf.networkReachabilityStatusBlock(status);
//            }
        };
        
        SCNetworkReachabilityContext context = {0, (__bridge void *)callback, VPUPNetworkReachabilityRetainCallback, VPUPNetworkReachabilityReleaseCallback, NULL};
        if (SCNetworkReachabilitySetCallback(self.networkReachability, VPUPNetworkReachabilityCallback, &context))
        {
            SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                SCNetworkReachabilityFlags flags;
                if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
                    VPUPPostReachabilityStatusChange(flags, callback);
                }
            });
            return YES;
        }
    }
    return NO;
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return (_currentNetworkStatus == VPUPNetworkReachabilityStatusReachableViaWWAN ||
            _currentNetworkStatus == VPUPNetworkReachabilityStatusReachableVia2G ||
            _currentNetworkStatus == VPUPNetworkReachabilityStatusReachableVia3G ||
            _currentNetworkStatus == VPUPNetworkReachabilityStatusReachableVia4G);
}

- (BOOL)isReachableViaWiFi {
    return _currentNetworkStatus == VPUPNetworkReachabilityStatusReachableViaWiFi;
}

- (VPUPNetworkReachabilityStatus)currentReachabilityStatus
{
    return _currentNetworkStatus;
}

- (NSString *)currentReachabilityStatusString
{
    switch (_currentNetworkStatus)
    {
            case VPUPNetworkReachabilityStatusUnknown:
            return @"UNKNOWN";
            
            case VPUPNetworkReachabilityStatusNotReachable:
            return @"NOTREACH";
            
            case VPUPNetworkReachabilityStatusReachableViaWiFi:
            return @"WIFI";
            
            case VPUPNetworkReachabilityStatusReachableVia2G:
            return @"2G";
            
            case VPUPNetworkReachabilityStatusReachableVia3G:
            return @"3G";
            
            case VPUPNetworkReachabilityStatusReachableVia4G:
            return @"4G";
            
            case VPUPNetworkReachabilityStatusReachableViaWWAN:
            return @"WWAN";
    }
    return @"UNKNOWN";
}

- (VPUPNetworkReachabilityStatus)reachabilityStatus
{
    if (_networkReachability)
    {
        SCNetworkReachabilityFlags flags = 0;
        if (SCNetworkReachabilityGetFlags(_networkReachability, &flags))
        {
            _currentNetworkStatus = [self networkStatusForReachabilityFlags:flags];
        }
    }
    return _currentNetworkStatus;
}

- (BOOL)checkInternetConnection
{
    
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    return (isReachable && !needsConnection) ? YES : NO;
}

- (VPUPNetworkReachabilityStatus)networkStatusForReachabilityFlags:(SCNetworkReachabilityFlags)flags
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0 || ![self checkInternetConnection])
    {
        // The target host is not reachable.
        return VPUPNetworkReachabilityStatusNotReachable;
    }
    
    VPUPNetworkReachabilityStatus returnValue = VPUPNetworkReachabilityStatusUnknown;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        returnValue = VPUPNetworkReachabilityStatusReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            returnValue = VPUPNetworkReachabilityStatusReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                                   CTRadioAccessTechnologyGPRS,
                                   CTRadioAccessTechnologyCDMA1x];
        
        NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                                   CTRadioAccessTechnologyWCDMA,
                                   CTRadioAccessTechnologyHSUPA,
                                   CTRadioAccessTechnologyCDMAEVDORev0,
                                   CTRadioAccessTechnologyCDMAEVDORevA,
                                   CTRadioAccessTechnologyCDMAEVDORevB,
                                   CTRadioAccessTechnologyeHRPD];
        
        NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
        
        CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
        
        NSString *accessString = teleInfo.currentRadioAccessTechnology;
        
        if ([typeStrings4G containsObject:accessString]) {
            returnValue = VPUPNetworkReachabilityStatusReachableVia4G;
        }
        else if ([typeStrings3G containsObject:accessString]) {
            returnValue = VPUPNetworkReachabilityStatusReachableVia3G;
        }
        else if ([typeStrings2G containsObject:accessString]) {
            returnValue = VPUPNetworkReachabilityStatusReachableVia2G;
        }
        else {
            returnValue = VPUPNetworkReachabilityStatusReachableViaWWAN;
        }
    }
    
    return returnValue;
}

- (void)dealloc
{
    [self stopMonitoring];
    if (_networkReachability)
    {
        CFRelease(_networkReachability);
    }
}

@end
