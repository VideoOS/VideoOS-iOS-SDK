//
//  VPUPMD5Util.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPMD5Util : NSObject

+ (NSString *)md5HashString:(NSString *)string;
+ (NSString *)md5_16bitHashString:(NSString *)string;

//file md5值,最好在异步执行, size不传默认为256K
+ (NSString *)md5File:(NSString *)filePath size:(size_t)fileSize;

@end
