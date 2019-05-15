//
//  VPVideoAppSettingView.h
//  VPInterfaceControllerDemo
//
//  Created by peter on 2019/4/22.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VPVideoAppSettingView : UIView

@property (nonatomic, weak) UIView *panel;
@property (nonatomic, weak) UITextField *appKeyTextField;
@property (nonatomic, weak) UITextField *appSecretTextField;
@property (nonatomic, weak) UIButton *applyButton;
@property (nonatomic, weak) UISegmentedControl *environmentControl;

- (instancetype)initWithFrame:(CGRect)frame data:(NSDictionary *)configData;

@end
