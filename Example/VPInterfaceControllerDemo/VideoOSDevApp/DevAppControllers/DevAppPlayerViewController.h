//
//  DevAppPlayerViewController.h
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/12.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevAppPlayerViewController : UIViewController
@property (nonatomic ,assign) DebuggingControllerType controllerType;
@property (nonatomic ,strong) NSString* videoFile;

//互动类数据
/// 启动文件名
@property (nonatomic ,strong) NSString* interaction_templateLua;

/// launchInfoData
@property (nonatomic ,strong) NSDictionary* interaction_Data;




//视频小程序数据
@property (nonatomic ,strong) NSString* service_miniAppID;
/// (type: 1横屏,2竖屏)
@property (nonatomic ,strong) NSString* service_screenType;
/// (appType: 1 lua,2 h5)
@property (nonatomic ,strong) NSString* service_appType;
@end

NS_ASSUME_NONNULL_END
