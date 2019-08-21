//
//  VPLuaAppletContainerStatusView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/5.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaAppletContainerStatusView.h"
#import "VPUPHexColors.h"

@interface VPLuaAppletContainerStatusView()

@property (nonatomic) UIView *backgroundView;

@end

@implementation VPLuaAppletContainerStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.backgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"48505a"];
    _backgroundView.alpha = 0.9;
    [self addSubview:_backgroundView];
}

@end
