//
//  PrivateConfig.h
//  VPInterfaceControllerDemo
//
//  Created by 李少帅 on 2017/8/3.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#define PrivateNotificationUpdatePlayedCount @"PrivateNotificationUpdatePlayedCount"

@interface PrivateConfig : NSObject

+ (instancetype)shareConfig;

//@property (nonatomic,   copy) NSString *appkey;
@property (nonatomic,   copy) NSString *platformID;     //平台ID
@property (nonatomic,   copy) NSString *identifier;     //视频或者房间ID
@property (nonatomic,   copy) NSString *videoUrl;       //视频url,如果没有c则使用identifier
@property (nonatomic,   copy) NSString *userID;
@property (nonatomic,   copy) NSString *cate;

@property (nonatomic, assign) BOOL cytron;
@property (nonatomic, assign) BOOL live;
@property (nonatomic, assign) BOOL enjoy;
@property (nonatomic, assign) BOOL anchor;
@property (nonatomic, assign) BOOL mall;

@property (nonatomic, assign) BOOL notificationShow;

@property (nonatomic, assign) BOOL verticalFullScreen;

@property (nonatomic, assign) BOOL unlimitedPlay;
@property (nonatomic, assign) NSInteger playedCount;
@property (nonatomic, assign) NSInteger environment;

@property (nonatomic, copy) NSString *creativeName;

@end
