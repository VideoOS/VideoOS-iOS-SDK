//
//  VPLuaService.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VPLuaServiceType) {
    VPLuaServiceTypeNone                  = 0,
    VPLuaServiceTypeVideoMode             = 1,       //视联网模式
    VPLuaServiceTypePreAdvertising        = 2,       //前帖广告
    VPLuaServiceTypePostAdvertising       = 3,       //后帖广告
    VPLuaServiceTypePauseAd               = 4,       //暂停广告
};

typedef NS_ENUM(NSInteger, VPLuaVideoModeType) {
    VPLuaVideoModeTypeLabel                   = 0,        //视联网标签模式
    VPLuaVideoModeTypeBubble                  = 1,        //视联网气泡模式
};

typedef void(^VPLuaServiceCompletionBlock)(NSError *error);

@interface VPLuaServiceConfig : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) VPLuaServiceType type;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) VPLuaVideoModeType videoModeType;

@end

@interface VPLuaService : NSObject

@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, assign) VPLuaServiceType type;
@property (nonatomic, assign) VPLuaVideoModeType videoModeType;

- (instancetype)initWithConfig:(VPLuaServiceConfig *)config;

@end

NS_ASSUME_NONNULL_END
