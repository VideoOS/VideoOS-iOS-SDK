//
//  VPUPRouteDefinition.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPRouteDefinition.h"

#import "VPUPRouteDefinition.h"
#import "VPUPRoutes.h"
#import "VPUPParsingUtilities.h"


@interface VPUPRouteDefinition ()

@property (nonatomic, copy) NSString *pattern;
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, assign) NSUInteger priority;
@property (nonatomic, copy) NSArray *patternPathComponents;
@property (nonatomic, copy) BOOL (^handlerBlock)(NSDictionary *parameters);

@end


@implementation VPUPRouteDefinition

- (instancetype)initWithPattern:(NSString *)pattern priority:(NSUInteger)priority handlerBlock:(BOOL (^)(NSDictionary *parameters))handlerBlock
{
    NSParameterAssert(pattern != nil);
    
    if ((self = [super init])) {
        self.pattern = pattern;
        self.priority = priority;
        self.handlerBlock = handlerBlock;
        
        if ([pattern characterAtIndex:0] == '/') {
            pattern = [pattern substringFromIndex:1];
        }
        
        self.patternPathComponents = [pattern componentsSeparatedByString:@"/"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> - %@ (priority: %@)", NSStringFromClass([self class]), self, self.pattern, @(self.priority)];
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if ([object isKindOfClass:[VPUPRouteDefinition class]]) {
        return [self isEqualToRouteDefinition:(VPUPRouteDefinition *)object];
    } else {
        return [super isEqual:object];
    }
}

- (BOOL)isEqualToRouteDefinition:(VPUPRouteDefinition *)routeDefinition
{
    if (!((self.pattern == nil && routeDefinition.pattern == nil) || [self.pattern isEqualToString:routeDefinition.pattern])) {
        return NO;
    }
    
    if (!((self.scheme == nil && routeDefinition.scheme == nil) || [self.scheme isEqualToString:routeDefinition.scheme])) {
        return NO;
    }
    
    if (!((self.patternPathComponents == nil && routeDefinition.patternPathComponents == nil) || [self.patternPathComponents isEqualToArray:routeDefinition.patternPathComponents])) {
        return NO;
    }
    
    if (self.priority != routeDefinition.priority) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return self.pattern.hash ^ @(self.priority).hash ^ self.scheme.hash ^ self.patternPathComponents.hash;
}

#pragma mark - Main API

- (VPUPRouteResponse *)routeResponseForRequest:(VPUPRouteRequest *)request
{
    BOOL patternContainsWildcard = [self.patternPathComponents containsObject:@"*"];
    
    if (request.pathComponents.count != self.patternPathComponents.count && !patternContainsWildcard) {
        // definitely not a match, nothing left to do
        return [VPUPRouteResponse invalidMatchResponse];
    }
    
    NSDictionary *routeVariables = [self routeVariablesForRequest:request];
    
    if (routeVariables != nil) {
        // It's a match, set up the param dictionary and create a valid match response
        NSDictionary *matchParams = [self matchParametersForRequest:request routeVariables:routeVariables];
        return [VPUPRouteResponse validMatchResponseWithParameters:matchParams];
    } else {
        // nil variables indicates no match, so return an invalid match response
        return [VPUPRouteResponse invalidMatchResponse];
    }
}

- (BOOL)callHandlerBlockWithParameters:(NSDictionary *)parameters
{
    if (self.handlerBlock == nil) {
        return YES;
    }
    
    return self.handlerBlock(parameters);
}

- (void)didBecomeRegisteredForScheme:(NSString *)scheme
{
    NSAssert(self.scheme == nil, @"Route definitions should not be added to multiple schemes.");
    self.scheme = scheme;
}

#pragma mark - Parsing Route Variables

- (NSDictionary <NSString *, NSString *> *)routeVariablesForRequest:(VPUPRouteRequest *)request
{
    NSMutableDictionary *routeVariables = [NSMutableDictionary dictionary];
    
    BOOL isMatch = YES;
    NSUInteger index = 0;
    
    for (NSString *patternComponent in self.patternPathComponents) {
        NSString *URLComponent = nil;
        BOOL isPatternComponentWildcard = [patternComponent isEqualToString:@"*"];
        
        if (index < [request.pathComponents count]) {
            URLComponent = request.pathComponents[index];
        } else if (!isPatternComponentWildcard) {
            // URLComponent is not a wildcard and index is >= request.pathComponents.count, so bail
            isMatch = NO;
            break;
        }
        
        if ([patternComponent hasPrefix:@":"]) {
            // this is a variable, set it in the params
            NSAssert(URLComponent != nil, @"URLComponent cannot be nil");
            NSString *variableName = [self routeVariableNameForValue:patternComponent];
            NSString *variableValue = [self routeVariableValueForValue:URLComponent];
            
            // Consult the parsing utilities as well to do any other standard variable transformations
            BOOL decodePlusSymbols = ((request.options & VPUPRouteRequestOptionDecodePlusSymbols) == VPUPRouteRequestOptionDecodePlusSymbols);
            variableValue = [VPUPParsingUtilities variableValueFrom:variableValue decodePlusSymbols:decodePlusSymbols];
            
            routeVariables[variableName] = variableValue;
        } else if (isPatternComponentWildcard) {
            // match wildcards
            NSUInteger minRequiredParams = index;
            if (request.pathComponents.count >= minRequiredParams) {
                // match: /a/b/c/* has to be matched by at least /a/b/c
                routeVariables[VPUPRouteWildcardComponentsKey] = [request.pathComponents subarrayWithRange:NSMakeRange(index, request.pathComponents.count - index)];
                isMatch = YES;
            } else {
                // not a match: /a/b/c/* cannot be matched by URL /a/b/
                isMatch = NO;
            }
            break;
        } else if (![patternComponent isEqualToString:URLComponent]) {
            // break if this is a static component and it isn't a match
            isMatch = NO;
            break;
        }
        index++;
    }
    
    if (!isMatch) {
        // Return nil to indicate that there was not a match
        routeVariables = nil;
    }
    
    return [routeVariables copy];
}

- (NSString *)routeVariableNameForValue:(NSString *)value
{
    NSString *name = value;
    
    if (name.length > 1 && [name characterAtIndex:0] == ':') {
        // Strip off the ':' in front of param names
        name = [name substringFromIndex:1];
    }
    
    if (name.length > 1 && [name characterAtIndex:name.length - 1] == '#') {
        // Strip of trailing fragment
        name = [name substringToIndex:name.length - 1];
    }
    
    return name;
}

- (NSString *)routeVariableValueForValue:(NSString *)value
{
    // Remove percent encoding
    NSString *var = [value stringByRemovingPercentEncoding];
    
    if (var.length > 1 && [var characterAtIndex:var.length - 1] == '#') {
        // Strip of trailing fragment
        var = [var substringToIndex:var.length - 1];
    }
    
    return var;
}

#pragma mark - Creating Match Parameters

- (NSDictionary *)matchParametersForRequest:(VPUPRouteRequest *)request routeVariables:(NSDictionary <NSString *, NSString *> *)routeVariables
{
    NSMutableDictionary *matchParams = [NSMutableDictionary dictionary];
    
    // Add the parsed query parameters ('?a=b&c=d'). Also includes fragment.
    BOOL decodePlusSymbols = ((request.options & VPUPRouteRequestOptionDecodePlusSymbols) == VPUPRouteRequestOptionDecodePlusSymbols);
//    [matchParams addEntriesFromDictionary:[VPUPParsingUtilities queryParams:request.queryParams decodePlusSymbols:decodePlusSymbols]];
    if (request.queryParams) {
        [matchParams setObject:request.queryParams forKey:VPUPRouteQueryParamsKey];
    }
    
    // Add the actual parsed route variables (the items in the route prefixed with ':').
    [matchParams addEntriesFromDictionary:routeVariables];
    
    // Add the additional parameters, if any were specified in the request.
    if (request.additionalParameters != nil) {
//        [matchParams addEntriesFromDictionary:request.additionalParameters];
        [matchParams setObject:request.additionalParameters forKey:VPUPRouteUserInfoKey];
    }
    
    if (request.completion != nil) {
        [matchParams setObject:[request.completion copy] forKey:VPUPRouteCompletionKey];
    }
    
    // Finally, add the base parameters. This is done last so that these cannot be overriden by using the same key in your route or query.
    [matchParams addEntriesFromDictionary:[self defaultMatchParametersForRequest:request]];
    
    return [matchParams copy];
}

- (NSDictionary *)defaultMatchParametersForRequest:(VPUPRouteRequest *)request
{
    return @{VPUPRoutePatternKey: self.pattern ?: [NSNull null], VPUPRouteURLKey: request.URL ?: [NSNull null], VPUPRouteSchemeKey: self.scheme ?: [NSNull null]};
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    VPUPRouteDefinition *copy = [[[self class] alloc] initWithPattern:self.pattern priority:self.priority handlerBlock:self.handlerBlock];
    copy.scheme = self.scheme;
    return copy;
}

@end
