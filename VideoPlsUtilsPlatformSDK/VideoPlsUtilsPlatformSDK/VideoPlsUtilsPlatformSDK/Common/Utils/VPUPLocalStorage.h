//
//  VPUPLocalStorage.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096-videojj on 2019/12/20.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VPUPLocalStorage : NSObject


/// 设置本地数据
/// @param fileName 文件名，只需要文件名比如使用developerUserId或其他id，不需要带后缀
/// @param key 需要存储的关键词，不可为空，已存在会覆盖
/// @param value 需要存储的内容，可以为空，为空则删除该关键词对应的内容
+ (void)setStorageDataWithFile:(NSString *)fileName
                           key:(NSString *)key
                         value:(NSString *)value;


/// 获取本地数据
/// @param fileName 文件名，只需要文件名比如使用developerUserId或其他id，不需要带后缀
/// @param key 需要通过关键词获取内容，可为空，空就将当前整个文件内容返回
+ (NSString *)getStorageDataWithFile:(NSString *)fileName
                                 key:(NSString *)key;

@end

