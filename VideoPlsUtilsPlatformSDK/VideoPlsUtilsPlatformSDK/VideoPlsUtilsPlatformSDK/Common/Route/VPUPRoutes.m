//
//  VPUPRoutes.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPRoutes.h"
#import "VPUPRouteDefinition.h"
#import "VPUPParsingUtilities.h"

NSString *const VPUPRoutePatternKey = @"VPUPRoutePattern";
NSString *const VPUPRouteURLKey = @"VPUPRouteURL";
NSString *const VPUPRouteSchemeKey = @"VPUPRouteScheme";
NSString *const VPUPRouteWildcardComponentsKey = @"VPUPRouteWildcardComponents";
NSString *const VPUPRoutesGlobalRoutesScheme = @"VPUPRoutesGlobalRoutesScheme";
NSString *const VPUPRouteCompletionKey = @"VPUPRouteCompletion";
NSString *const VPUPRouteUserInfoKey = @"VPUPRouteUserInfo";
NSString *const VPUPRouteQueryParamsKey = @"VPUPRouteQueryParams";

static NSMutableDictionary *VPUPGlobal_routeControllersMap = nil;


// global options (configured in +initialize)
static BOOL VPUPGlobal_verboseLoggingEnabled;
static BOOL VPUPGlobal_shouldDecodePlusSymbols;
static BOOL VPUPGlobal_alwaysTreatsHostAsPathComponent;
static Class VPUPGlobal_routeDefinitionClass;


@interface VPUPRoutes ()

@property (nonatomic, strong) NSMutableArray *mutableRoutes;
@property (nonatomic, strong) NSString *scheme;

- (VPUPRouteRequestOptions)_routeRequestOptions;

@end


#pragma mark -

@implementation VPUPRoutes

+ (void)initialize
{
    if (self == [VPUPRoutes class]) {
        // Set default global options
        VPUPGlobal_verboseLoggingEnabled = NO;
        VPUPGlobal_shouldDecodePlusSymbols = NO;
        VPUPGlobal_alwaysTreatsHostAsPathComponent = NO;
        VPUPGlobal_routeDefinitionClass = [VPUPRouteDefinition class];
    }
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.mutableRoutes = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description
{
    return [self.mutableRoutes description];
}

+ (NSDictionary <NSString *, NSArray <VPUPRouteDefinition *> *> *)allRoutes;
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (NSString *namespace in [VPUPGlobal_routeControllersMap copy]) {
        VPUPRoutes *routesController = VPUPGlobal_routeControllersMap[namespace];
        dictionary[namespace] = [routesController.mutableRoutes copy];
    }
    
    return [dictionary copy];
}


#pragma mark - Routing Schemes

+ (instancetype)globalRoutes
{
    return [self routesForScheme:VPUPRoutesGlobalRoutesScheme];
}

+ (instancetype)routesForScheme:(NSString *)scheme
{
    VPUPRoutes *routesController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        VPUPGlobal_routeControllersMap = [[NSMutableDictionary alloc] init];
    });
    
    if (!VPUPGlobal_routeControllersMap[scheme]) {
        routesController = [[self alloc] init];
        routesController.scheme = scheme;
        VPUPGlobal_routeControllersMap[scheme] = routesController;
    }
    
    routesController = VPUPGlobal_routeControllersMap[scheme];
    
    return routesController;
}

+ (void)unregisterRouteScheme:(NSString *)scheme
{
    [VPUPGlobal_routeControllersMap removeObjectForKey:scheme];
}

+ (void)unregisterAllRouteSchemes
{
    [VPUPGlobal_routeControllersMap removeAllObjects];
}


#pragma mark - Registering Routes

- (void)addRoute:(VPUPRouteDefinition *)routeDefinition
{
    [self _registerRoute:routeDefinition];
}

- (void)addRoute:(NSString *)routePattern handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [self addRoute:routePattern priority:0 handler:handlerBlock];
}

- (void)addRoutes:(NSArray<NSString *> *)routePatterns handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    for (NSString *routePattern in routePatterns) {
        [self addRoute:routePattern handler:handlerBlock];
    }
}

- (void)addRoute:(NSString *)routePattern priority:(NSUInteger)priority handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    NSArray <NSString *> *optionalRoutePatterns = [VPUPParsingUtilities expandOptionalRoutePatternsForPattern:routePattern];
    VPUPRouteDefinition *route = [[VPUPGlobal_routeDefinitionClass alloc] initWithPattern:routePattern priority:priority handlerBlock:handlerBlock];
    
    if (optionalRoutePatterns.count > 0) {
        // there are optional params, parse and add them
        for (NSString *pattern in optionalRoutePatterns) {
            VPUPRouteDefinition *optionalRoute = [[VPUPGlobal_routeDefinitionClass alloc] initWithPattern:pattern priority:priority handlerBlock:handlerBlock];
            [self _registerRoute:optionalRoute];
            [self _verboseLog:@"Automatically created optional route: %@", optionalRoute];
        }
        return;
    }
    
    [self _registerRoute:route];
}

- (void)removeRoute:(VPUPRouteDefinition *)routeDefinition
{
    [self.mutableRoutes removeObject:routeDefinition];
}

- (void)removeRouteWithPattern:(NSString *)routePattern
{
    NSInteger routeIndex = NSNotFound;
    NSInteger index = 0;
    
    for (VPUPRouteDefinition *route in [self.mutableRoutes copy]) {
        if ([route.pattern isEqualToString:routePattern]) {
            routeIndex = index;
            break;
        }
        index++;
    }
    
    if (routeIndex != NSNotFound) {
        [self.mutableRoutes removeObjectAtIndex:(NSUInteger)routeIndex];
    }
}

- (void)removeAllRoutes
{
    [self.mutableRoutes removeAllObjects];
}

- (void)setObject:(id)handlerBlock forKeyedSubscript:(NSString *)routePatten
{
    [self addRoute:routePatten handler:handlerBlock];
}

- (NSArray <VPUPRouteDefinition *> *)routes;
{
    return [self.mutableRoutes copy];
}

#pragma mark - Routing URLs

+ (BOOL)canRouteURL:(NSURL *)URL
{
    return [[self _routesControllerForURL:URL] canRouteURL:URL];
}

- (BOOL)canRouteURL:(NSURL *)URL
{
    return [self _routeURL:URL withParameters:nil executeRouteBlock:NO completion:nil];
}

+ (BOOL)routeURL:(NSURL *)URL
{
    return [[self _routesControllerForURL:URL] routeURL:URL];
}

- (BOOL)routeURL:(NSURL *)URL
{
    return [self _routeURL:URL withParameters:nil executeRouteBlock:YES completion:nil];
}

+ (BOOL)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [[self _routesControllerForURL:URL] routeURL:URL withParameters:parameters];
}

- (BOOL)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [self _routeURL:URL withParameters:parameters executeRouteBlock:YES completion:nil];
}

+ (BOOL)routeURL:(nullable NSURL *)URL withParameters:(nullable NSDictionary<NSString *, id> *)parameters completion:(void (^)(id result))completion {
    return [[self _routesControllerForURL:URL] routeURL:URL withParameters:parameters completion:completion];
}


- (BOOL)routeURL:(nullable NSURL *)URL withParameters:(nullable NSDictionary<NSString *, id> *)parameters completion:(void (^)(id result))completion {
    return [self _routeURL:URL withParameters:parameters executeRouteBlock:YES completion:completion];
}


#pragma mark - Private

+ (instancetype)_routesControllerForURL:(NSURL *)URL
{
    if (URL == nil) {
        return nil;
    }
    NSLog(@"%@",URL.scheme);
    return VPUPGlobal_routeControllersMap[URL.scheme] ?: [VPUPRoutes globalRoutes];
}

- (void)_registerRoute:(VPUPRouteDefinition *)route
{
    if (route.priority == 0 || self.mutableRoutes.count == 0) {
        [self.mutableRoutes addObject:route];
    } else {
        NSUInteger index = 0;
        BOOL addedRoute = NO;
        
        // search through existing routes looking for a lower priority route than this one
        for (VPUPRouteDefinition *existingRoute in [self.mutableRoutes copy]) {
            if (existingRoute.priority < route.priority) {
                // if found, add the route after it
                [self.mutableRoutes insertObject:route atIndex:index];
                addedRoute = YES;
                break;
            }
            index++;
        }
        
        // if we weren't able to find a lower priority route, this is the new lowest priority route (or same priority as self.routes.lastObject) and should just be added
        if (!addedRoute) {
            [self.mutableRoutes addObject:route];
        }
    }
    
    [route didBecomeRegisteredForScheme:self.scheme];
}

- (BOOL)_routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters executeRouteBlock:(BOOL)executeRouteBlock completion:(void (^)(id result))completion
{
    if (!URL) {
        return NO;
    }
    
    [self _verboseLog:@"Trying to route URL %@", URL];
    
    BOOL didRoute = NO;
    
    VPUPRouteRequestOptions options = [self _routeRequestOptions];
    VPUPRouteRequest *request = [[VPUPRouteRequest alloc] initWithURL:URL options:options additionalParameters:parameters completion:completion];
    
    for (VPUPRouteDefinition *route in [self.mutableRoutes copy]) {
        // check each route for a matching response
        VPUPRouteResponse *response = [route routeResponseForRequest:request];
        if (!response.isMatch) {
            continue;
        }
        
        [self _verboseLog:@"Successfully matched %@", route];
        
        if (!executeRouteBlock) {
            // if we shouldn't execute but it was a match, we're done now
            return YES;
        }
        
        [self _verboseLog:@"Match parameters are %@", response.parameters];
        
        // Call the handler block
        didRoute = [route callHandlerBlockWithParameters:response.parameters];
        
        if (didRoute) {
            // if it was routed successfully, we're done - otherwise, continue trying to route
            break;
        }
    }
    
    if (!didRoute) {
        [self _verboseLog:@"Could not find a matching route"];
    }
    
    // if we couldn't find a match and this routes controller specifies to fallback and its also not the global routes controller, then...
    if (!didRoute && self.shouldFallbackToGlobalRoutes && ![self _isGlobalRoutesController]) {
        [self _verboseLog:@"Falling back to global routes..."];
        didRoute = [[VPUPRoutes globalRoutes] _routeURL:URL withParameters:parameters executeRouteBlock:executeRouteBlock completion:completion];
    }
    
    // if, after everything, we did not route anything and we have an unmatched URL handler, then call it
    if (!didRoute && executeRouteBlock && self.unmatchedURLHandler) {
        [self _verboseLog:@"Falling back to the unmatched URL handler"];
        self.unmatchedURLHandler(self, URL, parameters);
    }
    
    return didRoute;
}

- (BOOL)_isGlobalRoutesController
{
    return [self.scheme isEqualToString:VPUPRoutesGlobalRoutesScheme];
}

- (void)_verboseLog:(NSString *)format, ...
{
    if (!VPUPGlobal_verboseLoggingEnabled || format.length == 0) {
        return;
    }
    
    va_list argsList;
    va_start(argsList, format);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
    
    va_end(argsList);
    NSLog(@"[VPUPRoutes]: %@", formattedLogMessage);
}

- (VPUPRouteRequestOptions)_routeRequestOptions
{
    VPUPRouteRequestOptions options = VPUPRouteRequestOptionsNone;
    
    if (VPUPGlobal_shouldDecodePlusSymbols) {
        options |= VPUPRouteRequestOptionDecodePlusSymbols;
    }
    if (VPUPGlobal_alwaysTreatsHostAsPathComponent) {
        options |= VPUPRouteRequestOptionTreatHostAsPathComponent;
    }
    
    return options;
}

@end


#pragma mark - Global Options

@implementation VPUPRoutes (GlobalOptions)

+ (void)setVerboseLoggingEnabled:(BOOL)loggingEnabled
{
    VPUPGlobal_verboseLoggingEnabled = loggingEnabled;
}

+ (BOOL)isVerboseLoggingEnabled
{
    return VPUPGlobal_verboseLoggingEnabled;
}

+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDecode
{
    VPUPGlobal_shouldDecodePlusSymbols = shouldDecode;
}

+ (BOOL)shouldDecodePlusSymbols
{
    return VPUPGlobal_shouldDecodePlusSymbols;
}

+ (void)setAlwaysTreatsHostAsPathComponent:(BOOL)treatsHostAsPathComponent
{
    VPUPGlobal_alwaysTreatsHostAsPathComponent = treatsHostAsPathComponent;
}

+ (BOOL)alwaysTreatsHostAsPathComponent
{
    return VPUPGlobal_alwaysTreatsHostAsPathComponent;
}

+ (void)setDefaultRouteDefinitionClass:(Class)routeDefinitionClass
{
    NSParameterAssert([routeDefinitionClass isSubclassOfClass:[VPUPRouteDefinition class]]);
    VPUPGlobal_routeDefinitionClass = routeDefinitionClass;
}

+ (Class)defaultRouteDefinitionClass
{
    return VPUPGlobal_routeDefinitionClass;
}

@end
