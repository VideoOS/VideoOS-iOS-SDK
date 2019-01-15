/*
 ---------------------------------------------------------------------------
 VideoOS - A Mini-App platform base on video player
 http://videojj.com/videoos/
 Copyright (C) 2019  Shanghai Ji Lian Network Technology Co., Ltd
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 ---------------------------------------------------------------------------
 */
//
//  VPIServiceManager.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by peter on 2018/4/24.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @Description VPIServiceManager支持使用第三方的或平台的网络请求、图片、webview，实现相关的协议，替代代码里面的实现，
 
 例如实现VPUPLoadImageManager Protocol，
 ----------------------------------------------------------------------------------------
 @protocol VPUPLoadImageManager <NSObject>

- (void)loadImageWithConfig:(VPUPLoadImageBaseConfig *)config;

- (void)loadImageWithButtonConfig:(VPUPLoadImageButtonConfig *)config;

- (void)clearMemory;

- (void)prefetchURLs:(NSArray<NSString *> *)urls;

- (void)prefetchURLs:(NSArray<NSString *> *)urls
completionBlock:(void(^)(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls))completionBlock;

- (void)cancelPrefetching;
 
 @end
 
 @interface NewLoadImageManager : NSObject<VPUPLoadImageManager>
 
 @end
-----------------------------------------------------------------------------------------
 
 并将实现Protocol的类NewLoadImageManager注册，可以实现替代VPUPLoadImageSDManager处理图片请求
 */

@interface VPIServiceManager : NSObject

- (void)registerService:(Protocol *)service implClass:(Class)implClass;

@end
