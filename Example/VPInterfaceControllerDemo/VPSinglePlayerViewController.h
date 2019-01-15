//
//  VPSinglePlayerViewController.h
//  VPInterfaceControllerDemo
//
//  Created by Zard1096 on 2017/7/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VideoPlsInterfaceControllerSDK/VPInterfaceController.h>

@interface VPSinglePlayerViewController : UIViewController

@property (nonatomic, strong) NSDictionary *mockConfigData;

- (instancetype)initWithUrlString:(NSString *)urlString platformUserID:(NSString *)platformUserID isLive:(BOOL)isLive;

- (instancetype)initWithUrlString:(NSString *)urlString platformUserID:(NSString *)platformUserID type:(NSInteger)type;

@end
