//
//  VPUPHTTPAFNManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPAFNManager.h"
#import "VPUPNetworkErrorObserverProtocol.h"
#import "VPUPHTTPManagerConfig.h"
#import "VPUPHTTPBaseAPI.h"
#import "VPUPHTTPBatchAPIs.h"
#import "VPUPSecurityPolicy.h"
#import "VPUPRPCProtocol.h"
#import "VPUPGeneralInfo.h"
#import "VPUPNetworkReachabilityManager.h"
#import "VPUPHTTPBaseResponse.h"
#import <AFNetworking/AFNetworking.h>
#import "VPUPServiceManager.h"


static dispatch_queue_t vpup_api_task_creation_queue() {
    static dispatch_queue_t vpup_api_task_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vpup_api_task_creation_queue =
        dispatch_queue_create("com.videopls.utilsplatform.networking.api.creation", DISPATCH_QUEUE_SERIAL);
    });
    return vpup_api_task_creation_queue;
}

static VPUPHTTPAFNManager *sharedAPIManager = nil;

@interface VPUPHTTPAFNManager () <NSCacheDelegate>

@property (nonatomic, strong, nonnull) VPUPHTTPManagerConfig *configuration;

@property (nonatomic, strong) NSCache *sessionManagerCache;
@property (nonatomic, strong) NSCache *sessionTasksCache;
@property (nonatomic, strong) NSPointerArray *sessionTasks;                 //use for cancelAll
@property (nonatomic, strong) NSMutableSet<id<VPUPNetworkErrorObserverProtocol>> *errorObservers;


@end

@implementation VPUPHTTPAFNManager
//@synthesize configuration = _configuration;

+ (void)load {
    [[VPUPServiceManager sharedManager] registerService:@protocol(VPUPHTTPAPIManager) implClass:[VPUPHTTPAFNManager class]];
}

+ (nullable id<VPUPHTTPAPIManager>)sharedAPIManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPIManager = [[self alloc] init];
    });
    return sharedAPIManager;
}

//- (instancetype)init {
//    if (!sharedAPIManager) {
//        sharedAPIManager                    = [super init];
//        sharedAPIManager.configuration      = [[VPUPHTTPManagerConfig alloc]init];
//        sharedAPIManager.errorObservers     = [[NSMutableSet alloc]init];
//    }
//    return sharedAPIManager;
//}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.configuration = [[VPUPHTTPManagerConfig alloc] init];
        self.errorObservers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (NSCache *)sessionManagerCache {
    if (!_sessionManagerCache) {
        _sessionManagerCache = [[NSCache alloc] init];
        _sessionManagerCache.delegate = self;
    }
    return _sessionManagerCache;
}

- (NSCache *)sessionTasksCache {
    if (!_sessionTasksCache) {
        _sessionTasksCache = [[NSCache alloc] init];
    }
    return _sessionTasksCache;
}

- (NSPointerArray *)sessionTasks {
    if(!_sessionTasks) {
        _sessionTasks = [NSPointerArray weakObjectsPointerArray];
    }
    return _sessionTasks;
}

#pragma mark - Serializer
- (AFHTTPRequestSerializer *)requestSerializerForAPI:(VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    
    AFHTTPRequestSerializer *requestSerializer;
    if ([api apiRequestSerializerType] == VPUPRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    requestSerializer.cachePolicy          = [api apiRequestCachePolicy];
    requestSerializer.timeoutInterval      = [api apiRequestTimeoutInterval];
    NSDictionary *requestHeaderFieldParams = [api apiRequestHTTPHeaderField];
    if (![[requestHeaderFieldParams allKeys] containsObject:@"User-Agent"] &&
        self.configuration.userAgent) {
        [requestSerializer setValue:self.configuration.userAgent forHTTPHeaderField:@"User-Agent"];
    }
    if (requestHeaderFieldParams) {
        [requestHeaderFieldParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    return requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializerForAPI:(VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    AFHTTPResponseSerializer *responseSerializer;
    if ([api apiResponseSerializerType] == VPUPResponseSerializerTypeHTTP) {
        responseSerializer = [AFHTTPResponseSerializer serializer];
    } else {
        responseSerializer = [AFJSONResponseSerializer serializer];
    }
    responseSerializer.acceptableContentTypes = [api apiResponseAcceptableContentTypes];
    return responseSerializer;
}

//move to baseAPI, configuration.baseUrlStr do not use
/*
#pragma mark - Request Invoke Organize
- (NSString *)requestBaseUrlStringWithAPI:(VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    
    // 如果定义了自定义的RequestUrl, 则直接定义RequestUrl
    if ([api customRequestUrl]) {
        NSURL *url  = [NSURL URLWithString:[api customRequestUrl]];
        NSURL *root = [NSURL URLWithString:@"/" relativeToURL:url];
        return [NSString stringWithFormat:@"%@", root.absoluteString];
    }
    
    NSAssert(api.baseUrl != nil || self.configuration.baseUrlStr != nil,
             @"api baseURL or self.configuration.baseurl can't be nil together");
    
    NSString *baseUrl = api.baseUrl ? : self.configuration.baseUrlStr;
    
    // 在某些情况下，一些用户会直接把整个url地址写进 baseUrl
    // 因此，还需要对baseUrl 进行一次切割
    NSURL *theUrl = [NSURL URLWithString:baseUrl];
    NSURL *root   = [NSURL URLWithString:@"/" relativeToURL:theUrl];
    return [NSString stringWithFormat:@"%@", root.absoluteString];
}

// Request Url
- (NSString *)requestUrlStringWithAPI:(VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    
    NSString *baseUrlStr = [self requestBaseUrlStringWithAPI:api];
    NSString *baseUrlStr = [api requestBaseUrlString];
    // 如果定义了自定义的RequestUrl, 则直接定义RequestUrl
    if ([api customRequestUrl]) {
        return [[api customRequestUrl] stringByReplacingOccurrencesOfString:baseUrlStr
                                                                 withString:@""];
    }
    NSAssert(api.baseUrl != nil || self.configuration.baseUrlStr != nil,
             @"api baseURL or self.configuration.baseurl can't be nil together");
    
    if (api.rpcDelegate) {
        NSString *rpcRequestUrlStr = [api.rpcDelegate rpcRequestUrlWithAPI:api];
        return [rpcRequestUrlStr stringByReplacingOccurrencesOfString:baseUrlStr
                                                           withString:@""];
    }
    // 如果啥都没定义，则使用BaseUrl + requestMethod 组成 UrlString
    // 即，直接返回requestMethod
    NSURL *url = [NSURL URLWithString:[api requestMethod] ? : @""
                        relativeToURL:[NSURL URLWithString:[api baseUrl]? : self.configuration.baseUrlStr]];
    return [url.absoluteString stringByReplacingOccurrencesOfString:baseUrlStr
                                                         withString:@""];
}

// Request Protocol
- (id)requestParamsWithAPI:(VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    
    if (api.rpcDelegate) {
        return [api.rpcDelegate rpcRequestParamsWithAPI:api];
    } else {
        return [api requestParameters];
    }
}
*/

#pragma mark - AFSessionManager
- (AFHTTPSessionManager *)sessionManagerWithAPI:(VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForAPI:api];
    if (!requestSerializer) {
        // Serializer Error, just return;
        return nil;
    }
    
    // Response Part
    AFHTTPResponseSerializer *responseSerializer = [self responseSerializerForAPI:api];
    
    NSString *baseUrlStr = [NSString stringWithFormat:@"%@://%@/",[api requestURL].scheme,[api requestURL].host];
    
    if(!baseUrlStr || [baseUrlStr isEqual:[NSNull null]]) {
        baseUrlStr = @"";
    }
    // AFHTTPSession
    AFHTTPSessionManager *sessionManager = nil;
    
    @try {
         sessionManager = [self.sessionManagerCache objectForKey:baseUrlStr];
    } @catch (NSException *exception) {
        
    }
   
    if (!sessionManager) {
        sessionManager = [self newSessionManagerWithBaseUrlStr:baseUrlStr];
//        __block typeof(sessionManager) blockSessionManager = sessionManager;
        __weak typeof(self) weakSelf = self;
        __block NSString *blockBaseUrl = [baseUrlStr copy];
        [sessionManager setSessionDidBecomeInvalidBlock:^(NSURLSession *session, NSError *error) {
            dispatch_async(vpup_api_task_creation_queue(), ^{
                if(blockBaseUrl) {
                    [weakSelf.sessionManagerCache removeObjectForKey:blockBaseUrl];
                }
            });
        }];
        if(sessionManager) {
            [self.sessionManagerCache setObject:sessionManager forKey:baseUrlStr];
        }
    }
    
    sessionManager.requestSerializer     = requestSerializer;
    sessionManager.responseSerializer    = responseSerializer;
    sessionManager.securityPolicy        = [self securityPolicyWithAPI:api];
    sessionManager.completionQueue       = vpup_api_task_creation_queue();
    
    return sessionManager;
}

- (AFHTTPSessionManager *)newSessionManagerWithBaseUrlStr:(NSString *)baseUrlStr {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    if (self.configuration) {
        sessionConfig.HTTPMaximumConnectionsPerHost = self.configuration.maxHttpConnectionPerHost;
    } else {
        sessionConfig.HTTPMaximumConnectionsPerHost = VPUP_MAX_HTTP_CONNECTION_PER_HOST;
    }
    
    sessionConfig.timeoutIntervalForRequest = 15;
    
    return [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]
                                    sessionConfiguration:sessionConfig];
}

- (AFSecurityPolicy *)securityPolicyWithAPI:(VPUPHTTPBaseAPI *)api {
    NSUInteger pinningMode                      = api.apiSecurityPolicy.SSLPinningMode;
    AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:pinningMode];
    securityPolicy.allowInvalidCertificates     = api.apiSecurityPolicy.allowInvalidCertificates;
    securityPolicy.validatesDomainName          = api.apiSecurityPolicy.validatesDomainName;
    return securityPolicy;
}

#pragma mark - Response Handle
- (void)handleSuccWithResponse:(id)responseObject andAPI:(VPUPHTTPBaseAPI *)api andTask:(NSURLSessionTask *)task {
//    if (api.rpcDelegate) {
//        id formattedResponseObj = [api.rpcDelegate rpcResponseObjReformer:responseObject withAPI:api];
//        NSError *rpcError = [api.rpcDelegate rpcErrorWithFormattedResponse:formattedResponseObj withAPI:api];
//        if (rpcError) {
//            [self callAPICompletion:api obj:nil error:rpcError task:task];
//            return;
//        }
//        id rpcResult = [api.rpcDelegate rpcResultWithFormattedResponse:formattedResponseObj withAPI:api];
//        [self callAPICompletion:api obj:rpcResult error:nil task:task];
//    } else
    {
        [self callAPICompletion:api obj:responseObject error:nil task:task];
    }
}

- (void)handleFailureWithError:(NSError *)error andAPI:(VPUPHTTPBaseAPI *)api andTask:(NSURLSessionTask *)task {
    if (error) {
        [self.errorObservers enumerateObjectsUsingBlock:^(id<VPUPNetworkErrorObserverProtocol> observer, BOOL * _Nonnull stop) {
            [observer networkErrorWithErrorInfo:error];
        }];
    }
    
    // Error -999, representing API Cancelled
    if ([error.domain isEqualToString: NSURLErrorDomain] &&
        error.code == NSURLErrorCancelled) {
        [self callAPICompletion:api obj:nil error:error task:task];
        return;
    }
    
//    // Handle Networking Error
//    NSString *errorTypeStr = self.configuration.generalErrorTypeStr;
//    NSMutableDictionary *tmpUserInfo = [[NSMutableDictionary alloc]initWithDictionary:error.userInfo copyItems:NO];
//    if (![[tmpUserInfo allKeys] containsObject:NSLocalizedFailureReasonErrorKey]) {
//        [tmpUserInfo setValue: NSLocalizedString(errorTypeStr, nil) forKey:NSLocalizedFailureReasonErrorKey];
//    }
//    if (![[tmpUserInfo allKeys] containsObject:NSLocalizedRecoverySuggestionErrorKey]) {
//        [tmpUserInfo setValue: NSLocalizedString(errorTypeStr, nil)  forKey:NSLocalizedRecoverySuggestionErrorKey];
//    }
//    // 加上 networking error code
//    NSString *newErrorDescription = errorTypeStr;
//    if (self.configuration.isErrorCodeDisplayEnabled) {
//        newErrorDescription = [NSString stringWithFormat:@"%@ (%ld)", errorTypeStr, (long)error.code];
//    }
//    [tmpUserInfo setValue:NSLocalizedString(newErrorDescription, nil) forKey:NSLocalizedDescriptionKey];
//    
//    NSDictionary *userInfo = [tmpUserInfo copy];
//    NSError *err = [NSError errorWithDomain:error.domain
//                                       code:error.code
//                                   userInfo:userInfo];
    
    [self callAPICompletion:api obj:nil error:error task:task];
}

- (void)callAPICompletion:(VPUPHTTPBaseAPI *)api
                      obj:(id)obj
                    error:(NSError *)error
                     task:(NSURLSessionTask *)task {
    obj = [api apiResponseObjReformer:obj andError:error];
    if ([api apiCompletionHandler]) {
        dispatch_queue_t callBackQueue = [api callbackQueue] ? : dispatch_get_main_queue();
        
        NSHTTPURLResponse *httpResponse = nil;
        NSInteger statusCode = 0;
        if (task&&task.response) {
            httpResponse = (NSHTTPURLResponse *)task.response;
            statusCode = httpResponse.statusCode;
        }
        else {
            httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[api requestURL]
                                                       statusCode:error.code
                                                      HTTPVersion:nil
                                                     headerFields:[api apiRequestHTTPHeaderField]];
            statusCode = error.code;
        }
//        VPUPLog(@"request url = %@, statusCode = %lu",httpResponse.URL.absoluteString,httpResponse.statusCode);
//        VPUPHTTPBaseResponse *response = [[VPUPHTTPBaseResponse alloc] initWithRequest:api
//                                                                            statusCode:statusCode
//                                                                              response:httpResponse
//                                                                                  data:obj];
//        VPUPLog(@"VPUPHTTPBaseResponse = %@",response);
        
        dispatch_async(callBackQueue, ^{
//            NSURLResponse *response = [task isKindOfClass:[NSURLResponse class]] ? (NSURLResponse *)task : task.response;
            api.apiCompletionHandler(obj, error, httpResponse);
        });
    }
}

#pragma mark - Send Batch Requests
- (void)sendBatchAPIRequests:(nonnull VPUPHTTPBatchAPIs *)apis {
    NSParameterAssert(apis);
    
    NSAssert([[apis.apiRequestsSet valueForKeyPath:@"hash"] count] == [apis.apiRequestsSet count],
             @"Should not have same API");
    
    dispatch_async(vpup_api_task_creation_queue(), ^{
        
        dispatch_group_t batch_api_group = dispatch_group_create();
        __weak typeof(self) weakSelf = self;
        [apis.apiRequestsSet enumerateObjectsUsingBlock:^(id api, BOOL * stop) {
            dispatch_group_enter(batch_api_group);
            
            __strong typeof (weakSelf) strongSelf = weakSelf;
            AFHTTPSessionManager *sessionManager = [strongSelf sessionManagerWithAPI:api];
            if (!sessionManager) {
                *stop = YES;
                dispatch_group_leave(batch_api_group);
            }
            sessionManager.completionGroup = batch_api_group;
            
            [strongSelf _sendSingleAPIRequest:api
                           withSessionManager:sessionManager
                           andCompletionGroup:batch_api_group];
        }];
        dispatch_queue_t callbackQueue = [apis callbackQueue] ? : dispatch_get_main_queue();
        dispatch_group_notify(batch_api_group, callbackQueue, ^{
            if (apis.delegate) {
                [apis.delegate batchAPIRequestsDidFinished:apis];
            }
        });
        
    });
}

#pragma mark - Send Request
- (void)sendAPIRequest:(nonnull VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    NSAssert(self.configuration, @"Configuration Can not be nil");
    dispatch_async(vpup_api_task_creation_queue(), ^{
        AFHTTPSessionManager *sessionManager = [self sessionManagerWithAPI:api];
        if (!sessionManager) {
            
            NSString *errorStr     = @"Did not create sessionManager with baseUrl or customReuqestUrl";
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : errorStr
                                       };
            NSError *cancelError = [NSError errorWithDomain:NSURLErrorDomain
                                                       code:NSURLErrorBadURL
                                                   userInfo:userInfo];
            [self callAPICompletion:api obj:nil error:cancelError task:nil];
            
            return;
        }
        [self _sendSingleAPIRequest:api withSessionManager:sessionManager];
    });
}

- (void)_sendSingleAPIRequest:(VPUPHTTPBaseAPI *)api withSessionManager:(AFHTTPSessionManager *)sessionManager {
    [self _sendSingleAPIRequest:api withSessionManager:sessionManager andCompletionGroup:nil];
}

- (void)_sendSingleAPIRequest:(VPUPHTTPBaseAPI *)api
           withSessionManager:(AFHTTPSessionManager *)sessionManager
           andCompletionGroup:(dispatch_group_t)completionGroup {
    NSParameterAssert(api);
    NSParameterAssert(sessionManager);
    
    __weak typeof(self) weakSelf = self;
    NSString *requestUrlStr = [api requestURL].absoluteString;
    id requestParams        = [api requestParameters];
    NSString *hashKey       = [NSString stringWithFormat:@"%lu", [api hash]];
    
    if ([self.sessionTasksCache objectForKey:hashKey]) {
        NSString *errorStr     = self.configuration.frequentRequestErrorStr;
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : errorStr
                                   };
        NSError *cancelError = [NSError errorWithDomain:NSURLErrorDomain
                                                   code:NSURLErrorCancelled
                                               userInfo:userInfo];
        [self callAPICompletion:api obj:nil error:cancelError task:[self.sessionTasksCache objectForKey:hashKey]];
        if (completionGroup) {
            dispatch_group_leave(completionGroup);
            
        }
        
        return;
    }
    
    if (![[VPUPNetworkReachabilityManager sharedManager] isReachable]) {
        // Not Reachable
        NSString *errorStr     = self.configuration.networkNotReachableErrorStr;
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : errorStr,
                                   NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"%@ unreachable", sessionManager.baseURL.host]
                                   };
        NSError *networkUnreachableError = [NSError errorWithDomain:NSURLErrorDomain
                                                               code:NSURLErrorNotConnectedToInternet
                                                           userInfo:userInfo];
        [self callAPICompletion:api obj:nil error:networkUnreachableError task:nil];
        if (completionGroup) {
            dispatch_group_leave(completionGroup);
        }
        return;
    }
    
    void (^successBlock)(NSURLSessionTask *task, id responseObject)
    = ^(NSURLSessionTask *task, id responseObject) {
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf.configuration.isNetworkingActivityIndicatorEnabled) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        }
        
//        //如果请求HEAD,且responseObject为空,则responseObject置为response
//        if([api apiRequestMethodType] == VPUPRequestMethodTypeHEAD) {
//            if(!responseObject) {
//                responseObject = task.response;
//            }
//        }
        
        [strongSelf handleSuccWithResponse:responseObject andAPI:api andTask:task];
//        [strongSelf.sessionTasksCache removeObjectForKey:hashKey];
        
        NSArray *tasks = strongSelf.sessionTasks.allObjects;
        __block NSInteger index = -1;
        [tasks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSURLSessionTask *downloadTask = obj;
            if([task isKindOfClass:[NSURLSessionTask class]]) {
                if(task == downloadTask) {
                    index = idx;
                    *stop = YES;
                }
            }
            if([task isKindOfClass:[NSURLResponse class]]) {
                if(task == downloadTask.response) {
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        
        if(index != -1) {
            [strongSelf.sessionTasks removePointerAtIndex:index];
        }
        else {
            [strongSelf.sessionTasks compact];
        }

        
        [strongSelf.sessionTasksCache removeObjectForKey:hashKey];
        
        if (completionGroup) {
            dispatch_group_leave(completionGroup);
        }
    };
    
    void (^failureBlock)(id task, NSError * error)
    = ^(id task, NSError * error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf.configuration.isNetworkingActivityIndicatorEnabled) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        }
        [strongSelf handleFailureWithError:error andAPI:api andTask:task];
        
        NSArray *tasks = strongSelf.sessionTasks.allObjects;
        __block NSInteger index = -1;
        [tasks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSURLSessionTask *downloadTask = obj;
            if([task isKindOfClass:[NSURLSessionTask class]]) {
                if(task == downloadTask) {
                    index = idx;
                    *stop = YES;
                }
            }
            if([task isKindOfClass:[NSURLResponse class]]) {
                if(task == downloadTask.response) {
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        
        if(index != -1) {
            [strongSelf.sessionTasks removePointerAtIndex:index];
        }
        else {
            [strongSelf.sessionTasks compact];
        }
        
        [strongSelf.sessionTasksCache removeObjectForKey:hashKey];
        
        if (completionGroup) {
            dispatch_group_leave(completionGroup);
        }
    };

//    void (^apiProgressBlock)(NSProgress *progress)
//    = api.apiProgressBlock ?
//    ^(NSProgress *progress) {
//        if (progress.totalUnitCount <= 0) {
//            return;
//        }
//        api.apiProgressBlock(progress);
//    } : nil;
    
//    dispatch_queue_t callBackQueue = [api callbackQueue] ? : dispatch_get_main_queue();
//    dispatch_async(callBackQueue, ^{
//        [api apiRequestWillBeSent];
//    });
    
//    if ([[NSThread currentThread] isMainThread]) {
//        [api apiRequestWillBeSent];
//    } else {
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [api apiRequestWillBeSent];
//        });
//    }
    
    if (self.configuration.isNetworkingActivityIndicatorEnabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
    }
    NSURLSessionTask *dataTask;
    switch ([api apiRequestMethodType]) {
        case VPUPRequestMethodTypeGET: {
//#ifdef AFN_2
            dataTask =
            [sessionManager GET:requestUrlStr
                     parameters:requestParams
                        success:successBlock
                        failure:failureBlock];
//#else
//            dataTask =
//            [sessionManager GET:requestUrlStr
//                     parameters:requestParams
//                       progress:apiProgressBlock
//                        success:successBlock
//                        failure:failureBlock];
//#endif
            break;
        }
        case VPUPRequestMethodTypeDELETE: {
            dataTask =
            [sessionManager DELETE:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
            break;
        }
        case VPUPRequestMethodTypePATCH: {
            dataTask =
            [sessionManager PATCH:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
            break;
        }
        case VPUPRequestMethodTypePUT: {
            dataTask =
            [sessionManager PUT:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
            break;
        }
        case VPUPRequestMethodTypeHEAD: {
            dataTask =
            [sessionManager HEAD:requestUrlStr
                      parameters:requestParams
                         success:^(NSURLSessionDataTask * _Nonnull task) {
                             if (successBlock) {
                                 successBlock(task, nil);
                             }
                         }
                         failure:failureBlock];
            break;
        }
        case VPUPRequestMethodTypePOST:
        {
            if (![api apiRequestConstructingBodyBlock]) {
                dataTask =
                [sessionManager POST:requestUrlStr
                          parameters:requestParams
                             success:successBlock
                             failure:failureBlock];
//                dataTask =
//                [sessionManager POST:requestUrlStr
//                          parameters:requestParams
//                            progress:apiProgressBlock
//                             success:successBlock
//                             failure:failureBlock];
            }
            else {
                void (^block)(id <AFMultipartFormData> formData)
                = ^(id <AFMultipartFormData> formData) {
                    api.apiRequestConstructingBodyBlock((id<VPUPMultipartFormData>)formData);
                };
                dataTask =
                [sessionManager POST:requestUrlStr
                          parameters:requestParams
           constructingBodyWithBlock:block
                             success:successBlock
                             failure:failureBlock];
//                dataTask =
//                [sessionManager POST:requestUrlStr
//                          parameters:requestParams
//           constructingBodyWithBlock:block
//                            progress:apiProgressBlock
//                             success:successBlock
//                             failure:failureBlock];
            }
            break;
        }
        
        default: {
            dataTask =
            [sessionManager POST:requestUrlStr
                      parameters:requestParams
                         success:successBlock
                         failure:failureBlock];
//            dataTask =
//            [sessionManager POST:requestUrlStr
//                      parameters:requestParams
//                        progress:apiProgressBlock
//                         success:successBlock
//                         failure:failureBlock];
            break;
        }
    }
    if (dataTask) {
        [self.sessionTasksCache setObject:dataTask forKey:hashKey];
        
        [self.sessionTasks addPointer:(__bridge void * _Nullable)(dataTask)];
    }
    
//    dispatch_async(callBackQueue, ^{
//        [api apiRequestDidSent];
//    });
    

//    if ([[NSThread currentThread] isMainThread]) {
//        [api apiRequestDidSent];
//    } else {
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [api apiRequestDidSent];
//        });
//    }
}

- (void)cancelAPIRequest:(nonnull VPUPHTTPBaseAPI *)api {
    dispatch_async(vpup_api_task_creation_queue(), ^{
        NSString *hashKey = [NSString stringWithFormat:@"%lu", (unsigned long)[api hash]];
        NSURLSessionDataTask *dataTask = [self.sessionTasksCache objectForKey:hashKey];
        
        NSArray *tasks = self.sessionTasks.allObjects;
        __block NSInteger index = -1;
        [tasks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSURLSessionTask *downloadTask = obj;
            if([dataTask isKindOfClass:[NSURLSessionTask class]]) {
                if(dataTask == downloadTask) {
                    index = idx;
                    *stop = YES;
                }
            }
            if([dataTask isKindOfClass:[NSURLResponse class]]) {
                if((id)dataTask == downloadTask.response) {
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        
        if(index != -1) {
            [self.sessionTasks removePointerAtIndex:index];
        }
        else {
            [self.sessionTasks compact];
        }
        
        [self.sessionTasksCache removeObjectForKey:hashKey];
        
//        NSUInteger index = [self.sessionTasks.allObjects indexOfObject:api];
//        [self.sessionTasks removePointerAtIndex:index];
        
        if (dataTask) {
            [dataTask cancel];
        }
    });
}

- (void)cancelAll {
//    [_sessionManagers compact];
//    [_sessionManagers.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        VPUPAFHTTPSessionManager *sessionManager = obj;
//        [[sessionManager session] invalidateAndCancel];
//    }];
//
    dispatch_async(vpup_api_task_creation_queue(), ^{
        [_sessionTasks compact];
        [_sessionTasks.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURLSessionTask *task = obj;
            [task cancel];
        }];
        
        [_sessionTasksCache removeAllObjects];
        [_sessionTasks compact];
    });
//    [_sessionManagerCache removeAllObjects];
}

- (void)setMaxHTTPConnection:(NSUInteger)maxHTTPConnect {
    if(maxHTTPConnect < 1) {
        maxHTTPConnect = 1;
    }
    if(maxHTTPConnect > 10) {
        maxHTTPConnect = 10;
    }
    
    [self.configuration setMaxHttpConnectionPerHost:maxHTTPConnect];
}


//- (BOOL)isConnecting {
//}

- (void)dealloc {
//    [self.sessionManagerCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        AFHTTPSessionManager *sessionManager = obj;
//        [sessionManager invalidateSessionCancelingTasks:YES];
//    }];
    [self.sessionManagerCache removeAllObjects];
    [self.sessionTasksCache removeAllObjects];
    [self.sessionTasks compact];
    
    self.sessionManagerCache = nil;
    self.sessionTasksCache = nil;
    self.sessionTasks = nil;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    if(cache == self.sessionManagerCache) {
        if([obj isKindOfClass:[AFHTTPSessionManager class]]) {
            dispatch_async(vpup_api_task_creation_queue(), ^{
                [(AFHTTPSessionManager *)obj invalidateSessionCancelingTasks:NO];
            });
        }
    }
}

#pragma Network Error Observer -
- (void)registerNetworkErrorObserver:(nonnull id<VPUPNetworkErrorObserverProtocol>)observer {
    [self.errorObservers addObject:observer];
}


- (void)removeNetworkErrorObserver:(nonnull id<VPUPNetworkErrorObserverProtocol>)observer {
    if ([self.errorObservers containsObject:observer]) {
        [self.errorObservers removeObject:observer];
    }
}

@end
