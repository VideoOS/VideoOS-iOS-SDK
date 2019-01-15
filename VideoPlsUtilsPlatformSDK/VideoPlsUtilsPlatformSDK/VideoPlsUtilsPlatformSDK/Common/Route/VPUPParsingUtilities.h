//
//  VPUPParsingUtilities.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 25/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface VPUPParsingUtilities : NSObject

+ (NSString *)variableValueFrom:(NSString *)value decodePlusSymbols:(BOOL)decodePlusSymbols;

+ (NSDictionary *)queryParams:(NSDictionary *)queryParams decodePlusSymbols:(BOOL)decodePlusSymbols;

+ (NSArray <NSString *> *)expandOptionalRoutePatternsForPattern:(NSString *)routePattern;

@end


NS_ASSUME_NONNULL_END
