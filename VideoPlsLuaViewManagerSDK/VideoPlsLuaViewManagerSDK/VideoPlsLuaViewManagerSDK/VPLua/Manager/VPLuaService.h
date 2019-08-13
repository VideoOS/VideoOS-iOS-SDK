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

typedef void(^VPLuaServiceCompletionBlock)(NSError *error);

@interface VPLuaServiceConfig : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) VPLuaServiceType type;
@property (nonatomic, assign) NSInteger duration;

@end

@interface VPLuaService : NSObject

@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, assign) VPLuaServiceType type;

- (instancetype)initWithConfig:(VPLuaServiceConfig *)config;

@end

NS_ASSUME_NONNULL_END
