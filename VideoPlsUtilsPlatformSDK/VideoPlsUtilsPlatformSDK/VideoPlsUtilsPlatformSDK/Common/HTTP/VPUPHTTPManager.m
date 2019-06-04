//
//  VPUPHTTPManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/24.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPHTTPManager.h"
#import "VPUPNetworkErrorObserverProtocol.h"
#import "VPUPHTTPManagerConfig.h"
#import "VPUPHTTPBaseAPI.h"
#import "VPUPHTTPBatchAPIs.h"
#import "VPUPSecurityPolicy.h"
#import "VPUPRPCProtocol.h"
#import "VPUPGeneralInfo.h"
#import "VPUPNetworkReachabilityManager.h"
#import "VPUPHTTPBaseResponse.h"
#import "VPUPServiceManager.h"


static NSString * VPUPCreateMultipartFormBoundary() {
    return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}

static inline NSString * VPUPContentTypeForPathExtension(NSString *extension) {
#ifdef __UTTYPE__
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
#else
#pragma unused (extension)
    return @"application/octet-stream";
#endif
}


@interface NSString (VPUPHTTPManager)

- (NSString*) urlEncodedString;
- (NSString*) urlDecodedString;

@end

@implementation NSString (VPUPHTTPManager)

- (NSString*) urlEncodedString { // mk_ prefix prevents a clash with a private api
    
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (__bridge CFStringRef) self,
                                                                          nil,
                                                                          CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
                                                                          kCFStringEncodingUTF8);
    
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];
    
    if(!encodedString)
        encodedString = @"";
    
    return encodedString;
}

- (NSString*) urlDecodedString {
    
    CFStringRef decodedCFString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef) self,
                                                                                          CFSTR(""),
                                                                                          kCFStringEncodingUTF8);
    
    // We need to replace "+" with " " because the CF method above doesn't do it
    NSString *decodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) decodedCFString];
    return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

@end


@interface NSDictionary (VPUPHTTPManager)

-(id) objectForCaseInsensitiveKey:(id)aKey;
-(NSString*) urlEncodedKeyValueString;
-(NSString*) jsonEncodedKeyValueString;
-(NSString*) plistEncodedKeyValueString;

@end

@implementation NSDictionary (VPUPHTTPManager)

-(id) objectForCaseInsensitiveKey:(id)aKey {
    
    for (NSString *key in self.allKeys) {
        if ([key compare:aKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return [self objectForKey:key];
        }
    }
    return  nil;
}

-(NSString*) urlEncodedKeyValueString {
    
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in self) {
        
        NSObject *value = [self valueForKey:key];
        if([value isKindOfClass:[NSString class]])
            [string appendFormat:@"%@=%@&", [key urlEncodedString], [((NSString*)value) urlEncodedString]];
        else
            [string appendFormat:@"%@=%@&", [key urlEncodedString], value];
    }
    
    if([string length] > 0)
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    
    return string;
}

-(NSString*) jsonEncodedKeyValueString {
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:0 // non-pretty printing
                                                     error:&error];
    if(error)
        NSLog(@"JSON Parsing Error: %@", error);
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


-(NSString*) plistEncodedKeyValueString {
    
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0 error:&error];
    if(error)
        NSLog(@"JSON Parsing Error: %@", error);
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end


#pragma mark - VPUPMultipartFormData

@interface VPUPMultipartFormData : NSObject <VPUPMultipartFormData>

- (instancetype)initWithURLRequest:(NSMutableURLRequest *)urlRequest
                    stringEncoding:(NSStringEncoding)encoding;

- (NSMutableURLRequest *)requestByFinalizingMultipartFormData;

@end

@interface VPUPMultipartFormData ()

@property (readwrite, nonatomic, copy) NSMutableURLRequest *request;
@property (readwrite, nonatomic, assign) NSStringEncoding stringEncoding;
@property (readwrite, nonatomic, copy) NSString *boundary;
@property (readwrite, nonatomic, strong) NSMutableData *formData;

@end

@implementation VPUPMultipartFormData

- (id)initWithURLRequest:(NSMutableURLRequest *)urlRequest
          stringEncoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.request = urlRequest;
    self.stringEncoding = encoding;
    self.boundary = VPUPCreateMultipartFormBoundary();
    self.formData = [[NSMutableData alloc] init];
    
    return self;
}

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(fileURL);
    NSParameterAssert(name);
    
    NSString *fileName = [fileURL lastPathComponent];
    NSString *mimeType = VPUPContentTypeForPathExtension([fileURL pathExtension]);
    
    return [self appendPartWithFileURL:fileURL name:name fileName:fileName mimeType:mimeType error:error];
}

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(fileURL);
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    
    if (![fileURL isFileURL]) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"Expected URL to be a file URL", @"VPUPNetworking", nil)};
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"com.videopls.error.serialization.request" code:NSURLErrorBadURL userInfo:userInfo];
        }
        
        return NO;
    } else if ([fileURL checkResourceIsReachableAndReturnError:error] == NO) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"File URL not reachable.", @"VPUPNetworking", nil)};
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"com.videopls.error.serialization.request" code:NSURLErrorBadURL userInfo:userInfo];
        }
        
        return NO;
    }
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:error];
    if (!fileAttributes) {
        return NO;
    }
    
    NSString *thisFieldString = [NSString stringWithFormat:
                                 @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n",
                                 self.boundary,
                                 name,
                                 [fileURL lastPathComponent],
                                 mimeType];
    
    [self.formData appendData:[thisFieldString dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData appendData: [NSData dataWithContentsOfURL:fileURL]];
    [self.formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    return YES;
}

- (void)appendPartWithInputStream:(NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(int64_t)length
                         mimeType:(NSString *)mimeType
{
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
}

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType
{
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name
{
    NSParameterAssert(name);
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"", name] forKey:@"Content-Disposition"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         body:(NSData *)body
{
    NSParameterAssert(body);
    
    NSMutableString *thisFieldString = [NSMutableString stringWithFormat:@"--%@\r\n",self.boundary];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        [thisFieldString appendString:[NSString stringWithFormat:@"%@: %@\r\n",key,obj]];
    }];
    
    [self.formData appendData:[thisFieldString dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData appendData:body];
    [self.formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay
{
    
}

- (NSMutableURLRequest *)requestByFinalizingMultipartFormData {
    if (![self.formData length]) {
        return self.request;
    }
    [self.formData appendData:[[NSString stringWithFormat:@"--%@--",self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [self.request setHTTPBodyStream:[[NSInputStream alloc] initWithData:self.formData]];
    
    [self.request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary] forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:[NSString stringWithFormat:@"%lu", [self.formData length]] forHTTPHeaderField:@"Content-Length"];
    
    return self.request;
}

@end



static dispatch_queue_t vpup_api_task_creation_queue() {
    static dispatch_queue_t vpup_api_task_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vpup_api_task_creation_queue =
        dispatch_queue_create("com.videopls.utilsplatform.networking.api.creation", DISPATCH_QUEUE_SERIAL);
    });
    return vpup_api_task_creation_queue;
}

static VPUPHTTPManager *sharedAPIManager = nil;

@interface VPUPHTTPManager () <NSCacheDelegate>

@property (nonatomic, strong, nonnull) VPUPHTTPManagerConfig *configuration;

@property (nonatomic, strong) NSCache *sessionManagerCache;
@property (nonatomic, strong) NSCache *sessionTasksCache;
@property (nonatomic, strong) NSPointerArray *sessionTasks;                 //use for cancelAll
@property (nonatomic, strong) NSMutableSet<id<VPUPNetworkErrorObserverProtocol>> *errorObservers;


@end

@implementation VPUPHTTPManager

+ (nullable id<VPUPHTTPAPIManager>)sharedAPIManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPIManager = [[self alloc] init];
    });
    return sharedAPIManager;
}

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

#pragma mark - SessionManager
- (NSURLSession *)sessionManagerWithAPI:(VPUPHTTPBaseAPI *)api {
    NSParameterAssert(api);
    
    NSString *baseUrlStr = [NSString stringWithFormat:@"%@://%@/",[api requestURL].scheme,[api requestURL].host];
    
    if(!baseUrlStr || [baseUrlStr isEqual:[NSNull null]]) {
        baseUrlStr = @"";
    }
    // AFHTTPSession
    NSURLSession *sessionManager = nil;
    
    @try {
        sessionManager = [self.sessionManagerCache objectForKey:baseUrlStr];
    } @catch (NSException *exception) {
        
    }
    
    if (!sessionManager) {
        sessionManager = [self newSessionManagerWithBaseUrlStr:baseUrlStr];
        if(sessionManager) {
            [self.sessionManagerCache setObject:sessionManager forKey:baseUrlStr];
        }
    }
    
    return sessionManager;
}

- (NSURLSession *)newSessionManagerWithBaseUrlStr:(NSString *)baseUrlStr {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    if (self.configuration) {
        sessionConfig.HTTPMaximumConnectionsPerHost = self.configuration.maxHttpConnectionPerHost;
    } else {
        sessionConfig.HTTPMaximumConnectionsPerHost = VPUP_MAX_HTTP_CONNECTION_PER_HOST;
    }
    
    sessionConfig.timeoutIntervalForRequest = 15;
    
    return [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
}

//TODO SecurityPolicy
//- (AFSecurityPolicy *)securityPolicyWithAPI:(VPUPHTTPBaseAPI *)api {
//    NSUInteger pinningMode                      = api.apiSecurityPolicy.SSLPinningMode;
//    AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:pinningMode];
//    securityPolicy.allowInvalidCertificates     = api.apiSecurityPolicy.allowInvalidCertificates;
//    securityPolicy.validatesDomainName          = api.apiSecurityPolicy.validatesDomainName;
//    return securityPolicy;
//}

#pragma mark - Response Handle
- (void)handleSuccWithResponse:(id)responseObject andAPI:(VPUPHTTPBaseAPI *)api andTask:(NSURLSessionTask *)task {
    [self callAPICompletion:api obj:responseObject error:nil task:task];
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
    
    [self callAPICompletion:api obj:nil error:error task:task];
}

- (void)callAPICompletion:(VPUPHTTPBaseAPI *)api
                      obj:(id)obj
                    error:(NSError *)error
                     task:(NSURLSessionTask *)task {
    
    if (error && api.retryCount > 0) {
        [api setRetryCount:api.retryCount - 1];
        [self sendAPIRequest:api];
        return;
    }
    
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
        
        dispatch_async(callBackQueue, ^{
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
            NSURLSession *sessionManager = [strongSelf sessionManagerWithAPI:api];
            if (!sessionManager) {
                *stop = YES;
                dispatch_group_leave(batch_api_group);
            }
//            sessionManager.completionGroup = batch_api_group;
            
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
        NSURLSession *sessionManager = [self sessionManagerWithAPI:api];
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

- (void)_sendSingleAPIRequest:(VPUPHTTPBaseAPI *)api withSessionManager:(NSURLSession *)sessionManager {
    [self _sendSingleAPIRequest:api withSessionManager:sessionManager andCompletionGroup:nil];
}

- (NSMutableDictionary *)defaultHeaders {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *userAgent = nil;
#if TARGET_OS_IOS
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#endif
    if (userAgent) {
        [dict setObject:userAgent forKey:@"User-Agent"];
    }
    return dict;
}

- (NSMutableURLRequest *)requestWithApi:(VPUPHTTPBaseAPI *)api {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:0];
    [headers addEntriesFromDictionary:[api apiRequestHTTPHeaderField]];
    [headers addEntriesFromDictionary:[self defaultHeaders]];
    request.allHTTPHeaderFields = headers;
    NSString *requestMethod = @"POST";
    switch (api.apiRequestMethodType) {
        case VPUPRequestMethodTypeGET:
            requestMethod = @"GET";
            break;
        case VPUPRequestMethodTypePOST:
            requestMethod = @"POST";
            break;
        case VPUPRequestMethodTypeHEAD:
            requestMethod = @"HEAD";
            break;
        case VPUPRequestMethodTypePUT:
            requestMethod = @"PUT";
            break;
        case VPUPRequestMethodTypePATCH:
            requestMethod = @"PATCH";
            break;
        case VPUPRequestMethodTypeDELETE:
            requestMethod = @"DELETE";
            break;
            
        default:
            requestMethod = @"POST";
            break;
    }
    request.HTTPMethod = requestMethod;
    
    NSURL *url = nil;
    if ((api.apiRequestMethodType == VPUPRequestMethodTypeGET ||
         api.apiRequestMethodType == VPUPRequestMethodTypeHEAD ||
         api.apiRequestMethodType == VPUPRequestMethodTypeDELETE) && ((NSDictionary*)api.requestParameters).count > 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", api.requestURL.absoluteString,
                                    [api.requestParameters urlEncodedKeyValueString]]];
    }
    else {
        url = api.requestURL;
    }
    request.URL = url;
    
    if (!(api.apiRequestMethodType == VPUPRequestMethodTypeGET ||
         api.apiRequestMethodType == VPUPRequestMethodTypeHEAD ||
         api.apiRequestMethodType == VPUPRequestMethodTypeDELETE)) {
        
        if (!api.apiRequestConstructingBodyBlock) {
            
            NSString *bodyStringFromParameters = nil;
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            
            switch (api.apiRequestSerializerType) {
                    
                case VPUPRequestSerializerTypeHTTP: {
                    [request setValue:
                     [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset]
                   forHTTPHeaderField:@"Content-Type"];
                    bodyStringFromParameters = [api.requestParameters urlEncodedKeyValueString];
                }
                    break;
                case VPUPRequestSerializerTypeJSON: {
                    [request setValue:
                     [NSString stringWithFormat:@"application/json; charset=%@", charset]
                   forHTTPHeaderField:@"Content-Type"];
                    bodyStringFromParameters = [api.requestParameters jsonEncodedKeyValueString];
                }
                    break;
            }
            
            [request setHTTPBody:[bodyStringFromParameters dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else {
            request = [self requestFormMultipartWithRequest:request parameters:api.requestParameters constructingBodyWithBlock:api.apiRequestConstructingBodyBlock error:nil];
        }
    }
    
    return request;
}

- (NSMutableURLRequest *)requestFormMultipartWithRequest:(NSMutableURLRequest *)mutableRequest
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <VPUPMultipartFormData> formData))block
                                                  error:(NSError *__autoreleasing *)error
{
    __block VPUPMultipartFormData *formData = [[VPUPMultipartFormData alloc] initWithURLRequest:mutableRequest stringEncoding:NSUTF8StringEncoding];
    
    if (parameters) {
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL * _Nonnull stop) {
            NSData *data = nil;
            if ([obj isKindOfClass:[NSData class]]) {
                data = obj;
            } else if ([obj isEqual:[NSNull null]]) {
                data = [NSData data];
            } else {
                data = [(NSString*)obj dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            if (data) {
                [formData appendPartWithFormData:data name:key];
            }
        }];
    }
    
    if (block) {
        block(formData);
    }
    
    return [formData requestByFinalizingMultipartFormData];
}

- (void)_sendSingleAPIRequest:(VPUPHTTPBaseAPI *)api
           withSessionManager:(NSURLSession *)sessionManager
           andCompletionGroup:(dispatch_group_t)completionGroup {
    
    NSParameterAssert(api);
    NSParameterAssert(sessionManager);

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
                                   NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"%@ unreachable", sessionManager.configuration]
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
    
    NSMutableURLRequest *request = [self requestWithApi:api];
    if (self.configuration.isNetworkingActivityIndicatorEnabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
    }
    __block NSURLSessionTask *dataTask;
    __weak typeof(self) weakSelf = self;
    dataTask = [sessionManager dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf.configuration.isNetworkingActivityIndicatorEnabled) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        }
        
        if (error) {
//            NSLog(@"%@",error);
            [strongSelf handleFailureWithError:error andAPI:api andTask:dataTask];
        }
        else {
            if (api.apiResponseSerializerType == VPUPResponseSerializerTypeJSON) {
                NSError *serializationError = nil;
                
                id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializationError];
//                NSLog(@"%@,%@,%@",api,responseObject,serializationError);
                if (!responseObject) {
//                    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    [strongSelf handleFailureWithError:serializationError andAPI:api andTask:dataTask];
                }
                else {
                    [self handleSuccWithResponse:responseObject andAPI:api andTask:dataTask];
                }
            }
            else {
//                NSLog(@"%@,%@,%@",api,response,error);
                [self handleSuccWithResponse:data andAPI:api andTask:dataTask];
            }
        }
        
        NSArray *tasks = strongSelf.sessionTasks.allObjects;
        __block NSInteger index = -1;
        [tasks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSURLSessionTask *sessionTask = obj;
            if([dataTask isKindOfClass:[NSURLSessionTask class]]) {
                if(dataTask == sessionTask) {
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
    }];
    [dataTask resume];
    
    if (dataTask) {
        [self.sessionTasksCache setObject:dataTask forKey:hashKey];
        [self.sessionTasks addPointer:(__bridge void * _Nullable)(dataTask)];
    }
    
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
        
        if (dataTask) {
            [dataTask cancel];
        }
    });
}

- (void)cancelAll {
    __weak typeof(self) weakSelf = self;
    dispatch_async(vpup_api_task_creation_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.sessionTasks compact];
        [strongSelf.sessionTasks.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURLSessionTask *task = obj;
            [task cancel];
        }];
        
        [strongSelf.sessionTasksCache removeAllObjects];
        [strongSelf.sessionTasks compact];
    });

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

- (void)dealloc {
    [self.sessionManagerCache removeAllObjects];
    [self.sessionTasksCache removeAllObjects];
    [self.sessionTasks compact];
    
    self.sessionManagerCache = nil;
    self.sessionTasksCache = nil;
    self.sessionTasks = nil;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    if(cache == self.sessionManagerCache) {
        if([obj isKindOfClass:[NSURLSession class]]) {
            dispatch_async(vpup_api_task_creation_queue(), ^{
                [(NSURLSession *)obj invalidateAndCancel];
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
