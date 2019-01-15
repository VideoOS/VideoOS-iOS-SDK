//
//  VPUPParsingUtilities.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPParsingUtilities.h"

@interface NSArray (VPUPRoutes_Utilities)

- (NSArray<NSArray *> *)VPUPRoutes_allOrderedCombinations;
- (NSArray *)VPUPRoutes_filter:(BOOL (^)(id object))filterBlock;
- (NSArray *)VPUPRoutes_map:(id (^)(id object))mapBlock;

@end


@interface NSString (VPUPRoutes_Utilities)

- (NSArray <NSString *> *)VPUPRoutes_trimmedPathComponents;

@end


#pragma mark - Parsing Utility Methods


@interface VPUPParsingUtilities_RouteSubpath : NSObject

@property (nonatomic, strong) NSArray <NSString *> *subpathComponents;
@property (nonatomic, assign) BOOL isOptionalSubpath;

@end


@implementation VPUPParsingUtilities_RouteSubpath

- (NSString *)description
{
    NSString *type = self.isOptionalSubpath ? @"OPTIONAL" : @"REQUIRED";
    return [NSString stringWithFormat:@"%@ - %@: %@", [super description], type, [self.subpathComponents componentsJoinedByString:@"/"]];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    VPUPParsingUtilities_RouteSubpath *otherSubpath = (VPUPParsingUtilities_RouteSubpath *)object;
    if (![self.subpathComponents isEqual:otherSubpath.subpathComponents]) {
        return NO;
    }
    
    if (self.isOptionalSubpath != otherSubpath.isOptionalSubpath) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return self.subpathComponents.hash ^ self.isOptionalSubpath;
}

@end


@implementation VPUPParsingUtilities

+ (NSString *)variableValueFrom:(NSString *)value decodePlusSymbols:(BOOL)decodePlusSymbols
{
    if (!decodePlusSymbols) {
        return value;
    }
    return [value stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, value.length)];
}

+ (NSDictionary *)queryParams:(NSDictionary *)queryParams decodePlusSymbols:(BOOL)decodePlusSymbols
{
    if (!decodePlusSymbols) {
        return queryParams;
    }
    
    NSMutableDictionary *updatedQueryParams = [NSMutableDictionary dictionary];
    
    for (NSString *name in queryParams) {
        id value = queryParams[name];
        
        if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *variables = [NSMutableArray array];
            for (NSString *arrayValue in (NSArray *)value) {
                [variables addObject:[self variableValueFrom:arrayValue decodePlusSymbols:YES]];
            }
            updatedQueryParams[name] = [variables copy];
        } else if ([value isKindOfClass:[NSString class]]) {
            NSString *variable = [self variableValueFrom:value decodePlusSymbols:YES];
            updatedQueryParams[name] = variable;
        } else {
            NSAssert(NO, @"Unexpected query parameter type: %@", NSStringFromClass([value class]));
        }
    }
    
    return [updatedQueryParams copy];
}

+ (NSArray <NSString *> *)expandOptionalRoutePatternsForPattern:(NSString *)routePattern
{
    /* this method exists to take a route pattern that is known to contain optional params, such as:
     
     /path/:thing/(/a)(/b)(/c)
     
     and create the following paths:
     
     /path/:thing/a/b/c
     /path/:thing/a/b
     /path/:thing/a/c
     /path/:thing/b/a
     /path/:thing/a
     /path/:thing/b
     /path/:thing/c
     
     */
    
    if ([routePattern rangeOfString:@"("].location == NSNotFound) {
        return @[];
    }
    
    // First, parse the route pattern into subpath objects.
    NSArray <VPUPParsingUtilities_RouteSubpath *> *subpaths = [self _routeSubpathsForPattern:routePattern];
    if (subpaths.count == 0) {
        return @[];
    }
    
    // Next, etract out the required subpaths.
    NSSet <VPUPParsingUtilities_RouteSubpath *> *requiredSubpaths = [NSSet setWithArray:[subpaths VPUPRoutes_filter:^BOOL(VPUPParsingUtilities_RouteSubpath *subpath) {
        return !subpath.isOptionalSubpath;
    }]];
    
    // Then, expand the subpath permutations into possible route patterns.
    NSArray <NSArray <VPUPParsingUtilities_RouteSubpath *> *> *allSubpathCombinations = [subpaths VPUPRoutes_allOrderedCombinations];
    
    // Finally, we need to filter out any possible route patterns that don't actually satisfy the rules of the route.
    // What this means in practice is throwing out any that do not contain all required subpaths (since those are explicitly not optional).
    NSArray <NSArray <VPUPParsingUtilities_RouteSubpath *> *> *validSubpathCombinations = [allSubpathCombinations VPUPRoutes_filter:^BOOL(NSArray <VPUPParsingUtilities_RouteSubpath *> *possibleRouteSubpaths) {
        return [requiredSubpaths isSubsetOfSet:[NSSet setWithArray:possibleRouteSubpaths]];
    }];
    
    // Once we have a filtered list of valid subpaths, we just need to convert them back into string routes that can we registered.
    NSArray <NSString *> *validSubpathRouteStrings = [validSubpathCombinations VPUPRoutes_map:^id(NSArray <VPUPParsingUtilities_RouteSubpath *> *subpaths) {
        NSString *routePattern = @"/";
        for (VPUPParsingUtilities_RouteSubpath *subpath in subpaths) {
            NSString *subpathString = [subpath.subpathComponents componentsJoinedByString:@"/"];
            routePattern = [routePattern stringByAppendingPathComponent:subpathString];
        }
        return routePattern;
    }];
    
    // Before returning, sort them by length so that the longest and most specific routes are registered first before the less specific shorter ones.
    validSubpathRouteStrings = [validSubpathRouteStrings sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"length" ascending:NO selector:@selector(compare:)]]];
    
    return validSubpathRouteStrings;
}

+ (NSArray <VPUPParsingUtilities_RouteSubpath *> *)_routeSubpathsForPattern:(NSString *)routePattern
{
    NSMutableArray <VPUPParsingUtilities_RouteSubpath *> *subpaths = [NSMutableArray array];
    
    NSScanner *scanner = [NSScanner scannerWithString:routePattern];
    while (![scanner isAtEnd]) {
        NSString *preOptionalSubpath = nil;
        BOOL didScan = [scanner scanUpToString:@"(" intoString:&preOptionalSubpath];
        if (!didScan) {
            NSAssert([routePattern characterAtIndex:scanner.scanLocation] == '(', @"Unexpected character: %c", [routePattern characterAtIndex:scanner.scanLocation]);
        }
        
        if (!scanner.isAtEnd) {
            // otherwise, advance past the ( character
            scanner.scanLocation = scanner.scanLocation + 1;
        }
        
        if (preOptionalSubpath.length > 0 && ![preOptionalSubpath isEqualToString:@")"] && ![preOptionalSubpath isEqualToString:@"/"]) {
            // content before the start of an optional subpath
            VPUPParsingUtilities_RouteSubpath *subpath = [[VPUPParsingUtilities_RouteSubpath alloc] init];
            subpath.subpathComponents = [preOptionalSubpath VPUPRoutes_trimmedPathComponents];
            [subpaths addObject:subpath];
        }
        
        if (scanner.isAtEnd) {
            break;
        }
        
        NSString *optionalSubpath = nil;
        didScan = [scanner scanUpToString:@")" intoString:&optionalSubpath];
        NSAssert(didScan, @"Could not find closing parenthesis");
        
        scanner.scanLocation = scanner.scanLocation + 1;
        
        if (optionalSubpath.length > 0) {
            VPUPParsingUtilities_RouteSubpath *subpath = [[VPUPParsingUtilities_RouteSubpath alloc] init];
            subpath.isOptionalSubpath = YES;
            subpath.subpathComponents = [optionalSubpath VPUPRoutes_trimmedPathComponents];
            [subpaths addObject:subpath];
        }
    }
    
    return [subpaths copy];
}

@end


#pragma mark - Categories


@implementation NSArray (VPUPRoutes_Utilities)

- (NSArray<NSArray *> *)VPUPRoutes_allOrderedCombinations
{
    NSInteger length = self.count;
    if (length == 0) {
        return [NSArray arrayWithObject:[NSArray array]];
    }
    
    id lastObject = [self lastObject];
    NSArray *subarray = [self subarrayWithRange:NSMakeRange(0, length - 1)];
    NSArray *subarrayCombinations = [subarray VPUPRoutes_allOrderedCombinations];
    NSMutableArray *combinations = [NSMutableArray arrayWithArray:subarrayCombinations];
    
    for (NSArray *subarrayCombos in subarrayCombinations) {
        [combinations addObject:[subarrayCombos arrayByAddingObject:lastObject]];
    }
    
    return [NSArray arrayWithArray:combinations];
}

- (NSArray *)VPUPRoutes_filter:(BOOL (^)(id object))filterBlock
{
    NSParameterAssert(filterBlock != nil);
    NSMutableArray *filteredArray = [NSMutableArray array];
    
    for (id object in self) {
        if (filterBlock(object)) {
            [filteredArray addObject:object];
        }
    }
    
    return [filteredArray copy];
}

- (NSArray *)VPUPRoutes_map:(id (^)(id object))mapBlock
{
    NSParameterAssert(mapBlock != nil);
    NSMutableArray *mappedArray = [NSMutableArray array];
    
    for (id object in self) {
        id mappedObject = mapBlock(object);
        [mappedArray addObject:mappedObject];
    }
    
    return [mappedArray copy];
}

@end


@implementation NSString (VPUPRoutes_Utilities)

- (NSArray <NSString *> *)VPUPRoutes_trimmedPathComponents
{
    // Trims leading and trailing slashes and then separates by slash
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]] componentsSeparatedByString:@"/"];
}

@end
