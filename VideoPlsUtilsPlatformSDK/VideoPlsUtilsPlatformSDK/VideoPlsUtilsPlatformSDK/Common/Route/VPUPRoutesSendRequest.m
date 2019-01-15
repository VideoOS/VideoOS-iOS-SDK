//
//  VPUPRoutesSendRequest.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 06/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPRoutesSendRequest.h"
#import "VPUPRouteHandler.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPManagerFactory.h"
#import "VPUPRoutes.h"
#import "VPUPRoutesConstants.h"

const NSArray *___RequestMethodType;
#define RequestMethodTypeGet (___RequestMethodType == nil ? ___RequestMethodType = [[NSArray alloc] initWithObjects:\
@"get",\
@"post",\
@"head",\
@"put",\
@"patch",\
@"delete",\
@"download",\
@"upload", nil] : ___RequestMethodType)

// 枚举 to 字串

#define RequestMethodTypeString(type) ([RequestMethodTypeGet objectAtIndex:type])
#define RequestMethodTypeEnum(string) ([RequestMethodTypeGet indexOfObject:string])

static id<VPUPHTTPAPIManager> VPUPHTTPAPIManager() {
    static id<VPUPHTTPAPIManager> _sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [VPUPHTTPManagerFactory createHTTPAPIManagerWithType:VPUPHTTPManagerTypeAFN];
    });
    return _sharedManager;
}

@interface VPUPRoutesSendRequest () <VPUPRouteHandlerTarget>

@property (nonatomic, copy) NSDictionary <NSString *, id> *parameters;
@property (nonatomic, strong) VPUPHTTPBusinessAPI *api;

@end

@implementation VPUPRoutesSendRequest

+ (void)load {
    @autoreleasepool {
        id handlerBlock = [VPUPRouteHandler handlerBlockForTargetClass:[VPUPRoutesSendRequest class] completion:^BOOL (VPUPRoutesSendRequest *sendRequest) {
            [sendRequest createRequest];
            if (!sendRequest.api) {
                return NO;
            }
            [sendRequest sendRequest];
            return YES;
        }];
        [[VPUPRoutes routesForScheme:VPUPRoutesSDKSendRequest] addRoute:@"/request/:type" handler:handlerBlock];
    }
}

- (instancetype)initWithRouteParameters:(NSDictionary <NSString *, id> *)parameters {
    self = [super init];
    if (self) {
        _parameters = [parameters copy];
    }
    return self;
}

- (void)createRequest {
    if(_parameters && [_parameters objectForKey:@"url"]) {
        VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
        if ([_parameters objectForKey:@"type"]) {
            api.apiRequestMethodType = [VPUPRoutesSendRequest stringForType:[_parameters objectForKey:@"type"]];
        }
        api.customRequestUrl = [_parameters objectForKey:@"url"];
        [api setApiCompletionHandler:^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
            NSLog(@"request complete");
        }];
        self.api = api;
    }
}

- (void)sendRequest {
    [VPUPHTTPAPIManager() sendAPIRequest:self.api];
}

- (BOOL)handleRouteWithParameters:(NSDictionary<NSString *, id> *)parameters {
    return YES;
}

+ (VPUPRequestMethodType)stringForType:(NSString *)type {
    return RequestMethodTypeEnum(type);
}

@end
