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
//  VPInterfaceController.h
//  VideoPlsInterfaceViewSDK
//
//  Created by Zard1096 on 2017/6/25.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VPInterfaceStatusNotifyDelegate.h"
#import "VPIUserLoginInterface.h"
#import "VPInterfaceControllerConfig.h"
#import "VPIVideoPlayerDelegate.h"
#import "VPIVideoPlayerSize.h"

@interface VPInterfaceController : NSObject <VPIVideoPlayerActionDelegate>

/**
 *  切换环境
 *  @param isDebug 是否为测试环境
 */
+ (void)switchToDebug:(BOOL)isDebug;


#pragma mark instance property
/**
 *  互动层的View, 在添加view时使用 [xxx addSubview:interfaceView.view];
 *  注意:无法切换生成的interfaceView即VideoOS和LiveOS无法互相切换,建议每次重新生成VPInterfaceController
 */
@property (readonly, nonatomic, strong) UIView *view;

/**
 *  interface状态切换代理
 */
@property (nonatomic, weak) id<VPInterfaceStatusNotifyDelegate> delegate;


/**
 *  获取用户信息回调
 */
@property (nonatomic, weak) id<VPIUserLoginInterface> userDelegate;

/**
 *  获取video player状态
 */
@property (nonatomic, weak) id<VPIVideoPlayerDelegate> videoPlayerDelegate;


/**
 *  Interface创建时的配置信息
 */

@property (nonatomic, readonly, strong) VPInterfaceControllerConfig *config;

#pragma mark instance method
#pragma mark init method
/**
 *  初始化InterfaceView
 *
 *  @param frame view对应frame
 *  @param config 对应config的子类
 *  @return InterfaceView,注意为NSObject,需要使用 .view 来获取视图层
 */

- (instancetype)initWithFrame:(CGRect)frame
                       config:(VPInterfaceControllerConfig *)config;

- (instancetype)initWithFrame:(CGRect)frame
                       config:(VPInterfaceControllerConfig *)config
              videoPlayerSize:(VPIVideoPlayerSize *)size;

#pragma mark Interface loading and control
/**
 *  开始加载互动层,无法再设置属性
 */
- (void)start;


/**
 *  停止并销毁互动层所有内容
 */
- (void)stop;


/**
 * 通过URL的方式打开特定的lua页面
 *
 * @param url 跳转到lua页面的URL，例如[NSURL URLWithString:@"LuaView://defaultLuaView?template=os_red_envelope_hotspot.lua&id=5aa5fa5133edbf375fe43fff4"]，打开红包热点
 * @param data 传给lua页面的数据
 */
- (void)navigationWithURL:(NSURL *)url data:(NSDictionary<NSString *, NSString *> *)data;


/**
 * 通知互动层视频大小发生改变
 *
 * @param type 改变的状态,详见 VPIVideoPlayerOrientation
 */
- (void)notifyVideoScreenChanged:(VPIVideoPlayerOrientation)type;

/**
 *  平台打开外链以后，外链关闭
 */
- (void)platformCloseActionWebView;

/**
 *  暂停中插视频
 */
- (void)pauseVideoAd;

/**
 *  播放暂停的中插视频
 */
- (void)playVideoAd;

/**
 *  controller的生命周期
 */
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

/**
 *  平台需要关闭信息层时调用
 */
- (void)closeInfoView;

@end
