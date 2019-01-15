//
//  VPUPFileHandle.h
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPFileHandle : NSObject

/**
 *  创建URL对应cache文件
 */
+ (NSString *)filePathWithURL:(NSURL *)url;

/**
 *  创建URL对应temp cache文件
 */
+ (NSString *)tempFilePathWithURL:(NSURL *)url;

/**
 *  往文件写入数据
 */
+ (void)writeToFile:(NSString *)filePath data:(NSData *)data;

/**
 *  读取文件数据
 */
+ (NSData *)readDataWithFile:(NSString *)filePath offset:(NSUInteger)offset length:(NSUInteger)length;

+ (void)saveOrUpdateCacheFile:(NSString *)filePath;

/**
 *  清空缓存文件
 */
+ (BOOL)clearCache;

@end
