//
//  VPUPRouteRequest.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Options bitmask generated from JLRoutes global options methods.
typedef NS_OPTIONS(NSUInteger, VPUPRouteRequestOptions) {
    /// No options specified.
    VPUPRouteRequestOptionsNone = 0,
    
    /// If present, decoding plus symbols is enabled.
    VPUPRouteRequestOptionDecodePlusSymbols = 1 << 0,
    
    /// If present, treating URL hosts as path components is enabled.
    VPUPRouteRequestOptionTreatHostAsPathComponent = 1 << 1
};

/**
 VPUPRouteRequest is a model representing a request to route a URL.
 It gets parsed into path components and query parameters, which are then used by VPUPRouteDefinition to attempt a match.
 */

@interface VPUPRouteRequest : NSObject

/// The URL being routed.
@property (nonatomic, copy, readonly) NSURL *URL;

/// The URL's path components.
@property (nonatomic, strong, readonly) NSArray *pathComponents;

/// The URL's query parameters.
@property (nonatomic, strong, readonly) NSDictionary *queryParams;

/// Route request options, generally configured from the framework global options.
@property (nonatomic, assign, readonly) VPUPRouteRequestOptions options;

/// Additional parameters to pass through as part of the match parameters dictionary.
@property (nonatomic, copy, nullable, readonly) NSDictionary *additionalParameters;

/// Additional parameters to pass through as part of the match parameters dictionary.
@property (nonatomic, copy, nullable, readonly) void(^completion)(id result);

///-------------------------------
/// @name Creating Route Requests
///-------------------------------


/**
 Creates a new route request.
 
 @param URL The URL to route.
 @param options Options bitmask specifying parsing behavior.
 @param additionalParameters Additional parameters to include in any match dictionary created against this request.
 
 @returns The newly initialized route request.
 */
- (instancetype)initWithURL:(NSURL *)URL options:(VPUPRouteRequestOptions)options additionalParameters:(nullable NSDictionary *)additionalParameters completion:(void (^)(id result))completion NS_DESIGNATED_INITIALIZER;

/// Unavailable, use initWithURL:options:additionalParameters: instead.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable, use initWithURL:options:additionalParameters: instead.
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
