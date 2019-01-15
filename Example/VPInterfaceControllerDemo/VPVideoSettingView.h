//
//  VPVideoSettingView.h
//  VPInterfaceControllerDemo
//
//  Created by peter on 2018/6/5.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VPVideoSettingView : UIView

@property (nonatomic, weak) UIView *panel;
@property (nonatomic, weak) UITextField *urlTextField;
@property (nonatomic, weak) UITextField *platformIdTextField;
@property (nonatomic, weak) UIButton *applyButton;
@property (nonatomic, weak) UISegmentedControl *environmentControl;

- (instancetype)initWithFrame:(CGRect)frame data:(NSDictionary *)configData;

@end
