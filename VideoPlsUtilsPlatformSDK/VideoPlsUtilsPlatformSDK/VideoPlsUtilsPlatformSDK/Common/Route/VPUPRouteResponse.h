//
//  VPUPRouteResponse.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 VPUPRouteResponse is the response from attempting to route a JLRRouteRequest.
 */

@interface VPUPRouteResponse : NSObject <NSCopying>

/// Indicates if the response is a match or not.
@property (nonatomic, assign, readonly, getter=isMatch) BOOL match;

/// The match parameters (or nil for an invalid response).
@property (nonatomic, copy, readonly, nullable) NSDictionary *parameters;

/// Check for route response equality
- (BOOL)isEqualToRouteResponse:(VPUPRouteResponse *)response;


///-------------------------------
/// @name Creating Responses
///-------------------------------


/// Creates an invalid match response.
+ (instancetype)invalidMatchResponse;

/// Creates a valid match response with the given parameters.
+ (instancetype)validMatchResponseWithParameters:(NSDictionary *)parameters;

/// Unavailable, please use +invalidMatchResponse or +validMatchResponseWithParameters: instead.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable, please use +invalidMatchResponse or +validMatchResponseWithParameters: instead.
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
