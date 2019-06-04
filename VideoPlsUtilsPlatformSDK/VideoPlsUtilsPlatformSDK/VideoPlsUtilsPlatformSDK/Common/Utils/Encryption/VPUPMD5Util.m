//
//  VPUPMD5Util.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPMD5Util.h"
#import "vpup_hash_encode.h"
#import <CommonCrypto/CommonCrypto.h>

#define FileHashDefaultChunkSizeForReadingData 256

@implementation VPUPMD5Util

+ (NSString *)md5HashString:(NSString *)string {
    
    if (!string) {
        return nil;
    }
    
    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

+ (NSString *)md5_16bitHashString:(NSString *)string {
    NSString *md5String = [self md5HashString:string];
    NSString *md5BriefString = nil;
    if([md5String length] == 32) {
        md5BriefString = [md5String substringWithRange:NSMakeRange(8, 16)];
    }
    return md5BriefString;
}

+ (NSString *)md5File:(NSString *)filePath size:(size_t)fileSize {
    
    unsigned char *hashStr = (unsigned char *)malloc(sizeof(unsigned char) * (CC_MD5_DIGEST_LENGTH * 2 + 1));
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    if(!data) {
        return nil;
    }
    
    vpup_md5_file_encryption(data.bytes, data.length , hashStr);
    
    NSString *hashString = [NSString stringWithUTF8String:(char *)hashStr];
    
    free(hashStr);
    
    return hashString;
    
    
//    CFStringRef md5 = VPUP_FileMD5HashCreateWithPath((__bridge CFStringRef)filePath, fileSize);
//    NSString *returnMD5 = (__bridge NSString *)md5;
//    return returnMD5;
}


//CFStringRef VPUP_FileMD5HashCreateWithPath(CFStringRef filePath,
//                                           size_t chunkSizeForReadingData) {
//    
//    // Declare needed variables
//    CFStringRef result = NULL;
//    CFReadStreamRef readStream = NULL;
//    
//    // Get the file URL
//    CFURLRef fileURL =
//    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
//                                  (CFStringRef)filePath,
//                                  kCFURLPOSIXPathStyle,
//                                  (Boolean)false);
//    if (!fileURL) goto done;
//    
//    // Create and open the read stream
//    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
//                                            (CFURLRef)fileURL);
//    if (!readStream) goto done;
//    bool didSucceed = (bool)CFReadStreamOpen(readStream);
//    if (!didSucceed) goto done;
//    
//    // Initialize the hash object
//    CC_MD5_CTX hashObject;
//    CC_MD5_Init(&hashObject);
//    
//    // Make sure chunkSizeForReadingData is valid
//    if (!chunkSizeForReadingData || chunkSizeForReadingData == 0) {
//        //default is 256K
//        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
//    }
//    
//    // Feed the data to the hash object
//    bool hasMoreData = true;
//    while (hasMoreData) {
//        uint8_t buffer[chunkSizeForReadingData];
//        CFIndex readBytesCount = CFReadStreamRead(readStream,
//                                                  (UInt8 *)buffer,
//                                                  (CFIndex)sizeof(buffer));
//        if (readBytesCount == -1) break;
//        if (readBytesCount == 0) {
//            hasMoreData = false;
//            continue;
//        }
//        CC_MD5_Update(&hashObject,
//                      (const void *)buffer,
//                      (CC_LONG)readBytesCount);
//    }
//    
//    // Check if the read operation succeeded
//    didSucceed = !hasMoreData;
//    
//    // Compute the hash digest
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5_Final(digest, &hashObject);
//    
//    // Abort if the read operation failed
//    if (!didSucceed) goto done;
//    
//    // Compute the string result
//    char hash[2 * sizeof(digest) + 1];
//    for (size_t i = 0; i < sizeof(digest); ++i) {
//        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
//    }
//    result = CFStringCreateWithCString(kCFAllocatorDefault,
//                                       (const char *)hash,
//                                       kCFStringEncodingUTF8);
//    
//done:
//    
//    if (readStream) {
//        CFReadStreamClose(readStream);
//        CFRelease(readStream);
//    }
//    if (fileURL) {
//        CFRelease(fileURL);
//    }
//    return result;
//}

@end
