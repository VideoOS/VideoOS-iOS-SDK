//
//  VPUPHTTPBaseResponse.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 15/01/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPHTTPBaseResponse.h"

@interface VPUPHTTPBaseResponse()

@property (nonatomic, readwrite, assign) NSInteger statusCode;

@property (nonatomic, readwrite, strong) id data;

@property (nonatomic, readwrite, strong) VPUPHTTPBaseAPI *request;

@property (nonatomic, readwrite, strong) NSHTTPURLResponse *response;

@end


@implementation VPUPHTTPBaseResponse

+ (instancetype)responseWithRequest:(VPUPHTTPBaseAPI *)request
                         statusCode:(NSInteger)statusCode
                           response:(NSHTTPURLResponse *)response
                               data:(id)responseData
{
    return [[VPUPHTTPBaseResponse alloc] initWithRequest:request
                                              statusCode:statusCode
                                                response:response
                                                    data:responseData];
}

- (instancetype)initWithRequest:(VPUPHTTPBaseAPI *)request
                     statusCode:(NSInteger)statusCode
                       response:(NSHTTPURLResponse *)response
                           data:(id)responseData
{
    self = [super init];
    if (self) {
        _request = request;
        _statusCode = statusCode;
        _response = response;
        _data = responseData;
    }
    return self;
}

@end
