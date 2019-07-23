//
//  VPUPHTTPBusinessAPI.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/16.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPBusinessAPI.h"
#import "VPUPGeneralInfo.h"
#import "VPUPValidator.h"
#import "VPUPBase64Util.h"
#import "VPUPNetworkReachabilityManager.h"
#import "VPUPOrderedDictionary.h"
#import "VPUPJsonUtil.h"
#import "VPUPGZIPUtil.h"
#import "VPUPCommonEncryption.h"
#import "VPUPLogUtil.h"

@implementation VPUPHTTPBusinessAPI

- (nullable NSDictionary *)apiRequestHTTPHeaderField {
    NSMutableDictionary *headerField = [NSMutableDictionary dictionary];
    
    @try {
        
        NSString *udid = [[VPUPGeneralInfo IDFA] copy];
        if(VPUP_IsStringTrimExist(udid)) {
            [headerField setObject:udid
                            forKey:@"IDFA"];
        }
        
        NSString *userIdentity = [[VPUPGeneralInfo userIdentity] copy];
        if(VPUP_IsStringTrimExist(userIdentity)) {
            [headerField setObject:userIdentity
                            forKey:@"identity"];
        }
        //todo VideoId user_token
        
        NSString *sdkVersion = [[VPUPGeneralInfo mainVPSDKVersion] copy];
        if(VPUP_IsStringTrimExist(sdkVersion)) {
            [headerField setObject:sdkVersion
                            forKey:@"sdk-version"];
        }
        
        NSString *bundleVersion = [[VPUPGeneralInfo appBundleVersion] copy];
        if(VPUP_IsStringTrimExist(bundleVersion)) {
            [headerField setObject:bundleVersion
                            forKey:@"version"];
        }
        
        NSString *platformID = [[VPUPGeneralInfo mainVPSDKPlatformID] copy];
        if(VPUP_IsStringTrimExist(platformID)) {
            [headerField setObject:platformID
                            forKey:@"3rd-platform-id"];
        }
        
        NSString *language = [[VPUPGeneralInfo appDeviceLanguage] copy];
        if(VPUP_IsStringTrimExist(language)) {
            [headerField setObject:language
                            forKey:@"lang"];
        }
        
        NSString *networkStatus = [[[VPUPNetworkReachabilityManager sharedManager] currentReachabilityStatusString] copy];
        if(VPUP_IsStringTrimExist(networkStatus)) {
            [headerField setObject:networkStatus
                            forKey:@"network"];
        }
        
        NSString *appKey = [[VPUPGeneralInfo mainVPSDKAppKey] copy];
        if(VPUP_IsStringTrimExist(appKey)) {
            [headerField setObject:appKey forKey:@"appKey"];
        }
    } @catch(NSException *exception) {
        
    }
    
    return headerField;
}

- (void)encryptedParameters {
    if(self.needEncrypted) {
        VPUPOrderedDictionary *orderedParameters = self.requestParameters;
        NSString *contentJson = VPUP_DictionaryToJson(orderedParameters);
        NSString *gzipJson = VPUP_GZIPCompressBase64String(contentJson);
        NSString *aesString = [VPUPCommonEncryption aesEncryptString:gzipJson];
        
        if(!aesString) {
            VPUPLogWR(@"api:%@ , para:%@,aes加密有误", [self requestURL].absoluteString, orderedParameters);
            //加密出错,不走加密
            return;
        }
        /*
         //        NSString *encoded;
         if(self.apiRequestMethodType == VPUPRequestMethodTypeGET ||
         self.apiRequestMethodType == VPUPRequestMethodTypeHEAD ||
         self.apiRequestMethodType == VPUPRequestMethodTypeDELETE ) {
         NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
         [allowedCharacterSet removeCharactersInString:@"/"];
         aesString = [aesString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
         }
         
         */
        //修改parameters
        self.requestParameters = @{@"isEncrypted"   : @(1),
                                   @"data"          : aesString};
        
        
        //修改completionHandle
        if(self.apiCompletionHandler) {
            __weak __typeof(self) weakSelf = self;
            __block VPUPApiCompletionHandler completeHandle = self.apiCompletionHandler;
            self.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
                if(error) {
                    completeHandle(responseObject, error, response);
                }
                else {
                    NSDictionary *responseDict = responseObject;
                    if(VPUP_IsExist([responseDict objectForKey:@"data"])) {
                        NSString *aesDataString = [responseDict objectForKey:@"data"];
                        
                        if(![aesDataString isKindOfClass:[NSString class]]) {
                            //非加密数据
                            completeHandle(responseObject, error, response);
                            return;
                        }
                        
                        NSString *gzipJson = [VPUPCommonEncryption aesDecryptString:aesDataString];
                        NSString *json = VPUP_GZIPUncompressBase64StringToString(gzipJson);
                        
                        NSDictionary *dataDict = VPUP_JsonToDictionary(json);
                        
                        if(!dataDict) {
                            VPUPLogWR(@"apiurl:%@ , para:%@,returnData:%@,aes解密有误", [weakSelf requestURL].absoluteString, orderedParameters, responseObject);
                            NSError *decryptedError = [NSError errorWithDomain:@"com.videopls.utilsplatform.http.decrypted" code:-11111 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"apiurl:%@ , para:%@,returnData:%@,aes解密有误", [weakSelf requestURL].absoluteString, orderedParameters, responseObject]}];
                            
                            completeHandle(responseObject, decryptedError, response);
                            return;
                        }
                        
                        NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionaryWithDictionary:responseDict];
                        [responseDictionary setObject:dataDict forKey:@"data"];
                        
                        completeHandle(responseDictionary, error, response);
                    }
                    else {
                        completeHandle(responseObject, error, response);
                    }
                }
            };
        }
        
    }
}

@end

