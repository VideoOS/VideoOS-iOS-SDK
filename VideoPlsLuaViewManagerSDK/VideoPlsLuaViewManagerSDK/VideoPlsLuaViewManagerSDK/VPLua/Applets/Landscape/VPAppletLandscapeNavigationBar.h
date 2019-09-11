//
//  VPAppletLandscapeNavigationBar.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/27.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPAppletContainerNaviSetting.h"

@protocol VPAppletNavigationBarDelegate <NSObject>

- (void)naviBackButtonTapped;
- (void)naviCloseButtonTapped;

@end


@interface VPAppletLandscapeNavigationBar : UIView

@property (nonatomic, weak) id<VPAppletNavigationBarDelegate> delegate;

- (BOOL)isBackButtonHidden;

- (void)showBackButton;
- (void)hideBackButton;

- (void)updateNavi:(VPAppletContainerNaviSetting *)setting;
- (void)updateNaviTitle:(NSString *)title;

@end

