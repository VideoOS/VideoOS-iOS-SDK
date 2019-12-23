//
//  VPMPContainerNetworkView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/5.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPMPContainerNetworkView.h"
#import "VPUPViewScaleUtil.h"
#import "VPUPEncryption.h"
#import "VPUPHexColors.h"

NSString *const kContainerNetworkFailedImage = @"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";

@interface VPMPContainerNetworkView()

@property (nonatomic) UIImageView *networkImageView;
@property (nonatomic) UILabel *networkLabel;
@property (nonatomic) UIButton *retryButton;

@end

@implementation VPMPContainerNetworkView

- (void)initView {
    [super initView];
    
    _networkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - 62 * VPUPViewScale) / 2, 67 * VPUPViewScale, 62 * VPUPViewScale, 79 * VPUPViewScale)];
    _networkImageView.image = [VPUPBase64Util imageFromBase64String:kContainerNetworkFailedImage];
    _networkImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:_networkImageView];
    
    _networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20 * VPUPViewScale)];
    _networkLabel.text = @"网络开小差啦，请重试";
    _networkLabel.textAlignment = NSTextAlignmentCenter;
    _networkLabel.textColor = [VPUPHXColor vpup_colorWithHexARGBString:@"cccccc"];
    _networkLabel.font = [UIFont boldSystemFontOfSize:12 * VPUPFontScale];
    
    [self addSubview:_networkLabel];
    
    _networkLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 7 * VPUPViewScale);
    
    _retryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100 * VPUPViewScale, 28 * VPUPViewScale)];
    [_retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
    [_retryButton setTitleColor:[VPUPHXColor vpup_colorWithHexARGBString:@"cccccc"] forState:UIControlStateNormal];
    _retryButton.titleLabel.font = [UIFont boldSystemFontOfSize:12 * VPUPFontScale];
    _retryButton.layer.borderColor = [VPUPHXColor vpup_colorWithHexARGBString:@"cccccc"].CGColor;
    _retryButton.layer.borderWidth = 1;
    _retryButton.layer.cornerRadius = 4 * VPUPViewScale;
    
    [_retryButton addTarget:self action:@selector(retryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_retryButton];
    
    _retryButton.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 + 35 * VPUPViewScale);
    
}

- (void)retryButtonTapped {
    if (self.networkDelegate && [self.networkDelegate respondsToSelector:@selector(retryNetwork)]) {
        [self.networkDelegate retryNetwork];
    }
}

- (void)useDefaultMessage {
    _networkLabel.text = @"网络开小差啦，请重试";
}

- (void)changeNetworkMessage:(NSString *)message {
    if (message != nil && ![message isEqualToString:@""]) {
        _networkLabel.text = message;
    }
}

@end
