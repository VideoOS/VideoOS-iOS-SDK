//
//  VPUPGZIPUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/18.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPGZIPUtil.h"
#import "VPUPLogUtil.h"
#import "VPUPBase64Util.h"
#import <zlib.h>

void VPUP_GZIPInitError(int errorCode, char* msg) {
    NSString *errorMsg = nil;
    switch (errorCode) {
        case Z_STREAM_ERROR:
            errorMsg = @"Invalid parameter passed in to function.";
            break;
        case Z_MEM_ERROR:
            errorMsg = @"Insufficient memory.";
            break;
        case Z_VERSION_ERROR:
            errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
            break;
        default:
            errorMsg = @"Unknown error code.";
            break;
    }
    VPUPLogW(@"%s: deflateInit2() Error: \"%@\" Message: \"%s\"", __func__, errorMsg, msg);
}

void VPUP_GZIPFlateError(int errorCode, char* msg) {
    NSString *errorMsg = nil;
    switch (errorCode) {
        case Z_ERRNO:
            errorMsg = @"Error occured while reading file.";
            break;
        case Z_STREAM_ERROR:
            errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
            break;
        case Z_DATA_ERROR:
            errorMsg = @"The deflate data was invalid or incomplete.";
            break;
        case Z_MEM_ERROR:
            errorMsg = @"Memory could not be allocated for processing.";
            break;
        case Z_BUF_ERROR:
            errorMsg = @"Ran out of output buffer for writing compressed bytes.";
            break;
        case Z_VERSION_ERROR:
            errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
            break;
        default:
            errorMsg = @"Unknown error code.";
            break;
    }
    
    VPUPLogW(@"%s: zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, msg);
}

NSData* VPUP_GZIPCompressData(NSData* data) {
    if(!data || [data length] == 0) {
        return nil;
    }
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.total_out = 0;
    stream.next_in = (Bytef *)[data bytes];
    stream.avail_in = (unsigned int)[data length];
    stream.total_out = 0;
    stream.avail_out = 0;
    
    int error = deflateInit2(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15 + 16), 8, Z_DEFAULT_STRATEGY);
    if(error != Z_OK) {
        VPUP_GZIPInitError(error, stream.msg);
        return nil;
    }
    
    //for safe, use 1.2 * length + 16 //append 16 bytes for safe
    NSUInteger compressDataLength = (NSUInteger)(ceil([data length] * 1.2f) + 16);
    compressDataLength = compressDataLength < 64 ? 64 : compressDataLength;
    NSMutableData *compressData = [NSMutableData dataWithLength:compressDataLength];
    
    int deflateStatus;
    do {
        // Store location where next byte should be put in next_out
        stream.next_out = [compressData mutableBytes] + stream.total_out;
        
        /* Calculate the amount of remaining free space in the output buffer 
         by subtracting the number of bytes that have been written so far 
         from the buffer's total capacity*/

        stream.avail_out = (unsigned int)([compressData length] - stream.total_out);
        
        /* deflate() compresses as much data as possible, and stops/returns when
         the input buffer becomes empty or the output buffer becomes full. If
         deflate() returns Z_OK, it means that there are more bytes left to
         compress in the input buffer but the output buffer is full; the output
         buffer should be expanded and deflate should be called again (i.e., the
         loop should continue to rune). If deflate() returns Z_STREAM_END, the
         end of the input stream was reached (i.e.g, all of the data has been
         compressed) and the loop should stop. */
        deflateStatus = deflate(&stream, Z_FINISH);
        
    } while(deflateStatus == Z_OK);
    
    if (deflateStatus != Z_STREAM_END) {
        
        VPUP_GZIPFlateError(deflateStatus, stream.msg);
        deflateEnd(&stream);
        return nil;
    }
    
    deflateEnd(&stream);
    [compressData setLength:stream.total_out];
    
    return compressData;
}

NSData* VPUP_GZIPUncompressData(NSData *data) {
    if(!data || [data length] == 0) {
        return nil;
    }
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.next_in = (Bytef *)[data bytes];
    stream.avail_in = (unsigned int)[data length];
    stream.avail_out = 0;
    stream.total_out = 0;
    
    int error = inflateInit2(&stream, (15 + 32));
    
    if(error != Z_OK) {
        VPUP_GZIPInitError(error, stream.msg);
        return nil;
    }
    
    int status = Z_OK;
    NSMutableData *uncompressData = [NSMutableData dataWithCapacity:(NSUInteger)([data length] * 1.5)];
    
    while (status == Z_OK)
    {
        if (stream.total_out >= uncompressData.length)
        {
            uncompressData.length += [data length] / 2;
        }
        stream.next_out = (uint8_t *)uncompressData.mutableBytes + stream.total_out;
        stream.avail_out = (uInt)(uncompressData.length - stream.total_out);
        status = inflate(&stream, Z_SYNC_FLUSH);
    }
    
    int inflateStatus = inflateEnd(&stream);
    if(inflateStatus != Z_OK) {
        VPUP_GZIPFlateError(inflateStatus, stream.msg);
        return nil;
    }
    
    if(status == Z_STREAM_END) {
        [uncompressData setLength:stream.total_out];
    }
    
    
    return uncompressData;
}

NSString* VPUP_GZIPCompressBase64String(NSString *string) {
    //是内容过少,导致GZIP压出的内容反而更多
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *compressData = VPUP_GZIPCompressData(data);
    NSString *compressBase64String = [VPUPBase64Util base64EncodingData:compressData];
    return compressBase64String;
}

NSString* VPUP_GZIPUncompressDataToString(NSData *data) {
    NSData *uncompressData = VPUP_GZIPUncompressData(data);
    NSString *uncompressString = [[NSString alloc] initWithData:uncompressData encoding:NSUTF8StringEncoding];
    return uncompressString;
}

NSString* VPUP_GZIPUncompressBase64StringToString(NSString* base64String) {
    NSData *compressData = [VPUPBase64Util dataBase64DecodeFromString:base64String];
    return VPUP_GZIPUncompressDataToString(compressData);
}

@implementation VPUPGZIPUtil

@end
