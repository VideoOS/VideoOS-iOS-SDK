//
//  VPUPFileHandle.m
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPFileHandle.h"
#import "VPUPMD5Util.h"
#import "VPUPPathUtil.h"

const NSInteger maxCacheVideoCount = 5;

@interface VPUPFileHandle ()

@end

@implementation VPUPFileHandle

+ (NSString *)cachePath {
    static NSString *path = nil;
    if (!path) {
        path = [VPUPPathUtil pathByPlaceholder:@"videoAds"];
    }
    return path;
}


+ (NSString *)filePathWithURL:(NSURL *)url {
    
    if (!url) {
        return nil;
    }
    
    NSString *filePath = [[VPUPFileHandle cachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",[VPUPMD5Util md5HashString:url.absoluteString],[url pathExtension]]];
    return filePath;
}

+ (NSString *)tempFilePathWithURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    
    NSString *filePath = [[VPUPFileHandle cachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_temp.%@",[VPUPMD5Util md5HashString:url.absoluteString],[url pathExtension]]];
    
    return filePath;
}

+ (void)writeToFile:(NSString *)filePath data:(NSData *)data {
    if (!filePath || !data) {
        return;
    }
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readDataWithFile:(NSString *)filePath offset:(NSUInteger)offset length:(NSUInteger)length {
    if (!filePath) {
        return nil;
    }
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (NSDictionary *)getCacheData {
    
    NSString *path = [[VPUPFileHandle cachePath] stringByAppendingPathComponent:@"cacheData.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    NSDictionary *cacheData = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cacheData;
}

+ (void)saveOrUpdateCacheFile:(NSString *)filePath {
    if ([filePath containsString:[VPUPFileHandle cachePath]]) {
        NSMutableDictionary *cacheData = [[NSMutableDictionary alloc] initWithDictionary:[VPUPFileHandle getCacheData]];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[cacheData objectForKey:@"cacheFiles"]];
        NSString *fileName = [filePath lastPathComponent];
        if (![array containsObject:fileName]) {
            [array insertObject:fileName atIndex:0];
        }
        else {
            [array removeObject:fileName];
            [array insertObject:fileName atIndex:0];
        }
        
        if (array.count > maxCacheVideoCount) {
            NSString *fileName = [array objectAtIndex:maxCacheVideoCount];
            [array removeObjectAtIndex:maxCacheVideoCount];
            [[NSFileManager defaultManager] removeItemAtPath:[[VPUPFileHandle cachePath] stringByAppendingPathComponent:fileName] error:nil];
        }
        
        [cacheData setObject:array forKey:@"cacheFiles"];
        [cacheData writeToFile:[[VPUPFileHandle cachePath] stringByAppendingPathComponent:@"cacheData.plist"] atomically:YES];
    }
}

+ (BOOL)clearCache {
    return [[NSFileManager defaultManager] removeItemAtPath:[self cachePath] error:nil];
}

@end
