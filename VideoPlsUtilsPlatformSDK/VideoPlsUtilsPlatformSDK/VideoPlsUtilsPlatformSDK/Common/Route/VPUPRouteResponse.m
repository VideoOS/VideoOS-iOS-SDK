//
//  VPUPRouteResponse.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPRouteResponse.h"

@interface VPUPRouteResponse ()

@property (nonatomic, assign, getter=isMatch) BOOL match;
@property (nonatomic, copy) NSDictionary *parameters;

@end


@implementation VPUPRouteResponse

+ (instancetype)invalidMatchResponse
{
    VPUPRouteResponse *response = [[[self class] alloc] init];
    response.match = NO;
    return response;
}

+ (instancetype)validMatchResponseWithParameters:(NSDictionary *)parameters
{
    VPUPRouteResponse *response = [[[self class] alloc] init];
    response.match = YES;
    response.parameters = parameters;
    return response;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> - match: %@, params: %@", NSStringFromClass([self class]), self, (self.match ? @"YES" : @"NO"), self.parameters];
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToRouteResponse:(VPUPRouteResponse *)object];
    } else {
        return [super isEqual:object];
    }
}

- (BOOL)isEqualToRouteResponse:(VPUPRouteResponse *)response
{
    if (self.isMatch != response.isMatch) {
        return NO;
    }
    
    if (!((self.parameters == nil && response.parameters == nil) || [self.parameters isEqualToDictionary:response.parameters])) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return @(self.match).hash ^ self.parameters.hash;
}

- (id)copyWithZone:(NSZone *)zone
{
    VPUPRouteResponse *copy = [[[self class] alloc] init];
    copy.match = self.isMatch;
    copy.parameters = self.parameters;
    return copy;
}

@end
