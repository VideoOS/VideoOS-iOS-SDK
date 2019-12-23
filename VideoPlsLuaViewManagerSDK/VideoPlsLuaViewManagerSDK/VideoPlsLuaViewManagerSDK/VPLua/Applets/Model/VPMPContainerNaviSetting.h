//
//  VPMPContainerNaviSetting.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/27.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VPMPContainerNaviSetting : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *naviTitle;
@property (nonatomic, strong) UIColor *navibackgroundColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIColor *naviButtonColor;
@property (nonatomic, assign) CGFloat naviAlpha;
@property (nonatomic, assign) BOOL naviShow;

+ (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
