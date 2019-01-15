//
//  VPUPHTTPBatchAPIs.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPBatchAPIs.h"
#import "VPUPHTTPBaseAPI.h"

static  NSString * const vpup_error_hint = @"API should be kind of VPUPBaseAPI";


@interface VPUPHTTPBatchAPIs ()

@property (nonatomic, strong, readwrite) NSMutableSet *apiRequestsSet;

@end

@implementation VPUPHTTPBatchAPIs

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.apiRequestsSet = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Add Requests
- (void)addAPIRequest:(VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    NSAssert([api isKindOfClass:[VPUPHTTPBaseAPI class]],
             vpup_error_hint);
    if ([self.apiRequestsSet containsObject:api]) {
#ifdef DEBUG
        NSLog(@"Add SAME API into BatchRequest set");
#endif
    }
    
    [self.apiRequestsSet addObject:api];
}

- (void)addBatchAPIRequests:(NSSet *)apis {
    NSParameterAssert(apis);
    NSAssert([apis count] > 0, @"Apis amounts should greater than ZERO");
    [apis enumerateObjectsUsingBlock:^(id  obj, BOOL * stop) {
        
        [self addAPIRequest:obj];
        
    }];
}

@end
