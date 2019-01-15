//
//  VPMediaMoreButtonView.m
//  VPInterfaceControllerDemo
//
//  Created by 李少帅 on 2017/10/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPMediaMoreButtonView.h"
#import <VideoPls-iOS-SDK/VideoPlsUtilsPlatformSDK/VPUPDebugSwitch.h>


@implementation VPMediaMoreButtonView

+ (instancetype)mediaMoreButtonWithNib {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"VPMediaMoreButtonView" owner:nil options:nil];
    VPMediaMoreButtonView *moreButtonView = [nibViews objectAtIndex:0];
    return moreButtonView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (IBAction)tapGesture:(id)sender {
    [self setHidden:YES];
}

- (IBAction)controlPannelDidShow:(id)sender {
    
    [[VPUPDebugSwitch sharedDebugSwitch] performSelector:@selector(triggerDebugPanel)];
    
    
}


@end
