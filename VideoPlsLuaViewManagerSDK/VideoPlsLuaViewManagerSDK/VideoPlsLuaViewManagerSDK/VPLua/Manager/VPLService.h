//
//  VPLService.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VPLServiceType) {
    VPLServiceTypeNone                  = 0,
    VPLServiceTypeVideoMode             = 1,       //视联网模式
    VPLServiceTypePreAdvertising        = 2,       //前帖广告
    VPLServiceTypePostAdvertising       = 3,       //后帖广告
    VPLServiceTypePauseAd               = 4,       //暂停广告
};

typedef NS_ENUM(NSInteger, VPLVideoModeType) {
    VPLVideoModeTypeLabel                   = 0,        //视联网标签模式
    VPLVideoModeTypeBubble                  = 1,        //视联网气泡模式
};

typedef void(^VPLServiceCompletionBlock)(NSError *error);

@interface VPLServiceConfig : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) VPLServiceType type;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) VPLVideoModeType videoModeType;
@property (nonatomic, assign) CGPoint eyeOriginPoint;

@end

@interface VPLService : NSObject

@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, assign) VPLServiceType type;
@property (nonatomic, assign) VPLVideoModeType videoModeType;
@property (nonatomic, assign) CGPoint eyeOriginPoint;

- (instancetype)initWithConfig:(VPLServiceConfig *)config;

@end

NS_ASSUME_NONNULL_END
