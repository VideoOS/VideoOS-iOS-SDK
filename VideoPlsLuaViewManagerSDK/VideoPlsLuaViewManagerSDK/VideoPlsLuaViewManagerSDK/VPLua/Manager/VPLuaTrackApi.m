//
//  VPLuaTrackApi.m
//  VideoPlsLuaViewSDK
//
//  Created by peter on 17/11/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPLuaTrackApi.h"
#import "VPUPDebugSwitch.h"
#import "VPUPHTTPAPIEnum.h"

static NSString *const ServerURLString = @"https://va.videojj.com/track/v5/va.gif/";
static NSString *const TestServerURLString = @"http://test-va.videojj.com/track/v5/va.gif/";

@implementation VPLuaTrackApi

- (NSString *)baseUrl {
    if([VPUPDebugSwitch sharedDebugSwitch].debugState > 1) {
        return TestServerURLString;
    }
    else {
        return ServerURLString;
    }
}

-(instancetype)initWithTrackEventCat:(NSUInteger)cat
                              params:(NSMutableDictionary *)params {
    self = [super init];
    if(self) {
        
        if(![params isKindOfClass:[NSMutableDictionary class]]) {
            params = [params mutableCopy];
        }
        
        [params setObject:@(cat) forKey:@"cat"];
        
        self.requestParameters = params;
        self.apiRequestMethodType = VPUPRequestMethodTypeGET;
        
        self.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
            
            NSString *gifString = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Content-Type"];
            if ([gifString isEqualToString:@"image/gif"]) {
                return ;
            }
            
        };
        
    }
    return self;
}

@end
