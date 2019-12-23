//
//  VPMPLandscapeNavigationBar.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/27.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPMPContainerNaviSetting.h"

@protocol VPMPNavigationBarDelegate <NSObject>

- (void)naviBackButtonTapped;
- (void)naviCloseButtonTapped;

@end


@interface VPMPLandscapeNavigationBar : UIView

@property (nonatomic, weak) id<VPMPNavigationBarDelegate> delegate;

- (BOOL)isBackButtonHidden;

- (void)showBackButton;
- (void)hideBackButton;

- (void)updateNavi:(VPMPContainerNaviSetting *)setting;
- (void)updateNaviTitle:(NSString *)title;

@end

