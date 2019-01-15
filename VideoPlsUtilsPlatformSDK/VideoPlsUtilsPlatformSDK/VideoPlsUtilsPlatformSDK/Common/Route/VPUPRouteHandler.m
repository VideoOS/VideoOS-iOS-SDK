//
//  VPUPRouteHandler.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPRouteHandler.h"

@implementation VPUPRouteHandler

+ (BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlockForWeakTarget:(__weak id <VPUPRouteHandlerTarget>)weakTarget
{
    NSParameterAssert([weakTarget respondsToSelector:@selector(handleRouteWithParameters:)]);
    
    return ^BOOL(NSDictionary<NSString *, id> *parameters) {
        return [weakTarget handleRouteWithParameters:parameters];
    };
}

+ (BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlockForTargetClass:(Class)targetClass completion:(BOOL (^)(id <VPUPRouteHandlerTarget> createdObject))completionHandler
{
    NSParameterAssert([targetClass conformsToProtocol:@protocol(VPUPRouteHandlerTarget)]);
    NSParameterAssert([targetClass instancesRespondToSelector:@selector(initWithRouteParameters:)]);
    NSParameterAssert(completionHandler != nil); // we want to force external ownership of the newly created object by handing it back.
    
    return ^BOOL(NSDictionary<NSString *, id> *parameters) {
        id <VPUPRouteHandlerTarget> createdObject = [[targetClass alloc] initWithRouteParameters:parameters];
        return completionHandler(createdObject);
    };
}

@end
