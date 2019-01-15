//
//  VPUPLoadImageWebPURL.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/20.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPLoadImageWebPURL.h"
#import "VPUPValidator.h"
#import "VPUPGeneralInfo.h"
#import "VPUPSDKInfo.h"

static NSString * const WEBP_SUFFIX_QINIU = @"?imageView2/0/format/webp";
static NSString * const WEBP_SUFFIX_ALI = @"?x-oss-process=image/format,webp";

@implementation VPUPLoadImageWebPURL

+ (NSURL *)webPURLFromURL:(NSURL *)originURL {
    
    NSURL *webPURL = [originURL copy];
    
    if([[VPUPGeneralInfo getCurrentSDKInfo] enableWebP]) {
        
        NSString *urlString = webPURL.absoluteString;
        NSString *appendString = nil;
        
        //先要有后缀且后缀不为gif
        if(VPUP_IsStringTrimExist([webPURL pathExtension]) && ![[webPURL pathExtension] isEqualToString:@"gif"]) {
            if(VPUP_StringContainsString(urlString, @"staticcdn.videojj.com")) {
                if(!VPUP_StringContainsString(urlString, WEBP_SUFFIX_QINIU)) {
                    //七牛
                    appendString = WEBP_SUFFIX_QINIU;
                }
            }
            else if(VPUP_StringContainsString(urlString, @"cytroncdn.videojj.com") ||
                    VPUP_StringContainsString(urlString, @"consolecdn.videojj.com")) {
                //阿里云
                if(!VPUP_StringContainsString(urlString, WEBP_SUFFIX_ALI)) {
                    appendString = WEBP_SUFFIX_ALI;
                }
            }
        }
        
        if(appendString) {
            webPURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlString, appendString]];
        }
        
    }
    
    return webPURL;
}

@end
