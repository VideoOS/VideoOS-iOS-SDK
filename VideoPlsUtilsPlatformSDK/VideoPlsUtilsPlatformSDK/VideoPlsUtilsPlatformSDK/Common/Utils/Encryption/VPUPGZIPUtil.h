//
//  VPUPGZIPUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/18.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Data压缩成gzip data
 * @param data 需要压缩的data
 * @return gzip data
 */
FOUNDATION_EXPORT NSData* VPUP_GZIPCompressData(NSData* data);

/**
 * string压缩成gzip后返回string
 * @param string 需要压缩的string
 * @return gzip string
 */
FOUNDATION_EXPORT NSString* VPUP_GZIPCompressBase64String(NSString *string);

/**
 * gzip data 解压缩成data
 * @param data 需要解压缩的data
 * @return 解压缩后的data
 */
FOUNDATION_EXPORT NSData* VPUP_GZIPUncompressData(NSData *data);

/**
 * gzip data 解压缩成string
 * @param data 需要解压缩的data
 * @return 解压缩后的string
 */
FOUNDATION_EXPORT NSString* VPUP_GZIPUncompressDataToString(NSData *data);

/**
 * gzip data 解压缩成string
 * @param base64String 需要解压缩的base64String
 * @return 解压缩后的string
 */
FOUNDATION_EXPORT NSString* VPUP_GZIPUncompressBase64StringToString(NSString* base64String);

@interface VPUPGZIPUtil : NSObject

@end
