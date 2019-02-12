//
//  VPUPHTTPHost.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 09/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPHTTPHost.h"
#import "VPUPDebugSwitch.h"

//old base url
//static NSString *const ServerURLString = @"https://cytron.videojj.com/";
//static NSString *const PreServerURLString = @"https://precytron.videojj.com/";
//static NSString *const DevServerURLString = @"https://dev-cytron.videojj.com/";
//static NSString *const TestServerURLString = @"https://test-cytron.videojj.com/";
//
//static NSString *const ServerURLString = @"https://va.videojj.com/track/va.gif/";
//static NSString *const PreServerURLString = @"https://va.videojj.com/track/va.gif/";
//static NSString *const DevServerURLString = @"https://test.va.videojj.com/track/va.gif/";
//static NSString *const TestServerURLString = @"https://test.va.videojj.com/track/va.gif/";
//
//static NSString *const ServerURLString = @"https://ads-api.videojj.com/";
//static NSString *const PreServerURLString = @"https://ads-api.videojj.com/";
//static NSString *const DevServerURLString = @"http://dev-ads-api.videojj.com/";
//static NSString *const TestServerURLString = @"http://test-ads-api.videojj.com/";
//
//
//static NSString *const ServerURLString = @"https://liveapi.videojj.com/";
//static NSString *const PreServerURLString = @"https://liveapi.videojj.com/";
//static NSString *const DevServerURLString = @"http://test.liveapi.videojj.com/";
//static NSString *const TestServerURLString = @"http://test.liveapi.videojj.com/";
//
//
//static NSString *const ServerURLString = @"https://plat.videojj.com/";
//static NSString *const PreServerURLString = @"https://pre-plat.videojj.com/";
//static NSString *const DevServerURLString = @"https://dev-plat.videojj.com/";
//static NSString *const TestServerURLString = @"https://test-plat.videojj.com/";
//
//local httpUrlHead = "http://liveapi.videojj.com/api/"
//local preHttpUrlHead = "http://liveapi.videojj.com/api/"
//local debugHttpUrlHead = "http://test.liveapi.videojj.com/api/"
//local devHttpUrlHead = "http://dev-liveapi.videojj.com/api/"

@implementation VPUPHTTPHost

+ (NSArray *)urlHostArray {
    static NSArray *hostsArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hostsArray = @[
                       //live and enjoy host
                       @[@"liveapi.videojj.com",
                         @"liveapi.videojj.com",
                         @"test.liveapi.videojj.com",
                         @"dev-liveapi.videojj.com"],
                       
                       //video host
                       @[@"cytron.videojj.com",
                         @"precytron.videojj.com",
                         @"test-cytron.videojj.com",
                         @"dev-cytron.videojj.com"],
                       
                       //video ad host
                       @[@"ads-api.videojj.com",
                         @"ads-api.videojj.com",
                         @"test-ads-api.videojj.com",
                         @"dev-ads-api.videojj.com"],
                       
                       //mall host
                       @[@"plat.videojj.com",
                         @"pre-plat.videojj.com",
                         @"test-plat.videojj.com",
                         @"dev-plat.videojj.com"],
                       
                       //track host
                       //@[@"va.videojj.com",@"va.videojj.com",@"va.videojj.com",@"va.videojj.com"]
                       @[@"va.videojj.com",
                         @"va.videojj.com",
                         @"test-va.videojj.com",
                         @"test-va.videojj.com"],
                       
                       @[@"os-open.videojj.com",
                         @"os-open.videojj.com",
                         @"test-os-open.videojj.com",
                         @"dev-os-open.videojj.com"],
                       ];
    });
    return hostsArray;
}

+ (NSArray *)urlSchemeArray {
    static NSArray *schemeArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        schemeArray = @[@"http",@"http",@"http",@"http"];
    });
    return schemeArray;
}


+ (NSURL *)urlForCurrentEnvironment:(NSURL *)url {
    
    NSArray *hostsArray = [VPUPHTTPHost urlHostArray];
    
    NSString *urlHost = [url host];
    int hostIndex = -1;
    for (int i = 0; i < hostsArray.count; i++) {
        NSArray *tempArray = [hostsArray objectAtIndex:i];
        if ([tempArray containsObject:urlHost]) {
            hostIndex = i;
        }
    }
    
    NSString *replaceHost = nil;
    NSURL *replaceUrl = nil;
    if (hostIndex > -1) {
        NSString *absoluteUrlString = [url absoluteString];
        replaceHost = [[hostsArray objectAtIndex:hostIndex] objectAtIndex:[VPUPDebugSwitch sharedDebugSwitch].debugState];
        if ([[url scheme] isEqualToString:[[VPUPHTTPHost urlSchemeArray] objectAtIndex:[VPUPDebugSwitch sharedDebugSwitch].debugState]]) {
            replaceUrl = [NSURL URLWithString:[absoluteUrlString stringByReplacingCharactersInRange:[absoluteUrlString rangeOfString:[url host]] withString:replaceHost]];
        }
        else {
            NSString *replaceUrlString = [absoluteUrlString stringByReplacingCharactersInRange:[absoluteUrlString rangeOfString:[url scheme]] withString:[[VPUPHTTPHost urlSchemeArray] objectAtIndex:[VPUPDebugSwitch sharedDebugSwitch].debugState]];
            replaceUrl = [NSURL URLWithString:[replaceUrlString stringByReplacingCharactersInRange:[replaceUrlString rangeOfString:[url host]] withString:replaceHost]];
        }
    }
    
    return replaceUrl ? replaceUrl : url;
}

@end
