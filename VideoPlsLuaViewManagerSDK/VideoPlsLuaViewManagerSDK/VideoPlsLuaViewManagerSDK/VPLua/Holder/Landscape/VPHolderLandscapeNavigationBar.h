//
//  VPHolderLandscapeNavigationBar.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/27.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPHolderContainerNaviSetting.h"

@protocol VPHolderNavigationBarDelegate <NSObject>

- (void)naviBackButtonTapped;
- (void)naviCloseButtonTapped;

@end


@interface VPHolderLandscapeNavigationBar : UIView

@property (nonatomic, weak) id<VPHolderNavigationBarDelegate> delegate;

- (BOOL)isBackButtonHidden;

- (void)showBackButton;
- (void)hideBackButton;

- (void)updateNavi:(VPHolderContainerNaviSetting *)setting;
- (void)updateNaviTitle:(NSString *)title;

@end

