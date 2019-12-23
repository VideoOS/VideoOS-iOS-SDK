//
//  DevAppTool.h
//  VideoOSDevApp
//
//  Created by videopls on 2019/10/11.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DebuggingControllerType) {
    Type_Interaction,
    Type_Service
};

@interface DevAppTool : NSObject

#pragma mark NSUserDefults 相关封装
// 存储用户偏好设置到NSUserDefults
+ (void)writeUserDataWithKey:(id)data forKey:(NSString*)key;

//读取用户偏好设置
+ (id)readUserDataWithKey:(NSString*)key;

//删除用户偏好设置
+ (void)removeUserDataWithkey:(NSString*)key;

+ (NSBundle *)devAPPBundle;



/// 文件拷贝
/// @param bundlePath bundlepath 为文件夹 destinationPath也为文件夹
/// @param destinationPath bundlepath 为文件 destinationPath也为文件
+ (void)copyLuaFile:(NSString*)bundlePath ToFilePath:(NSString*)destinationPath;


/// 获取用户视频小工具lua根路径
+ (NSString*)getInteractionLPath;

@end

NS_ASSUME_NONNULL_END
