//
//  VPUPHTTPBaseResponse.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 15/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VPUPHTTPBaseAPI;
@interface VPUPHTTPBaseResponse : NSObject

+ (instancetype)responseWithRequest:(VPUPHTTPBaseAPI *)request
                         statusCode:(NSInteger)statusCode
                           response:(NSHTTPURLResponse *)response
                               data:(id)responseData;

- (instancetype)initWithRequest:(VPUPHTTPBaseAPI *)request
                     statusCode:(NSInteger)statusCode
                       response:(NSHTTPURLResponse *)response
                           data:(id)responseData;

@property (nonatomic, readonly, assign) NSInteger statusCode;

@property (nonatomic, readonly, strong) id data;//默认为NSDictionary，download请求为downloadFileURL(NSURL类型),根据Request.apiResponseSerializerType确定

@property (nonatomic, readonly, strong) VPUPHTTPBaseAPI *request;

@property (nonatomic, readonly, strong) NSHTTPURLResponse *response;

@end

NS_ASSUME_NONNULL_END
