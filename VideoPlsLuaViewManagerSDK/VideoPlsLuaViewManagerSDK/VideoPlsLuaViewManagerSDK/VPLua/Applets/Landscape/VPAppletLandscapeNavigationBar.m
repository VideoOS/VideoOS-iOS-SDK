//
//  VPAppletLandscapeNavigationBar.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/27.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPAppletLandscapeNavigationBar.h"
#import "UIButton+VPUPFillColor.h"
#import "VPUPViewScaleUtil.h"
#import "VPUPHexColors.h"
#import "VPUPEncryption.h"
#import "VPUPDeviceUtil.h"

@interface VPAppletLandscapeNavigationBar()

@property (nonatomic) UIView *naviBackView;
@property (nonatomic) UIButton *naviBackButton;
@property (nonatomic) UIButton *naviCloseButton;
@property (nonatomic) UILabel *naviLabel;

@end

NSString *const kContainerBackImage = @"iVBORw0KGgoAAAANSUhEUgAAAFgAAABYCAYAAABxlTA0AAAAAXNSR0IArs4c6QAAAhtJREFUeAHt2TFLw0AYh3Grgoub4OLg4qyTS0e34uSqUBxcXBX8Ak7i7EewuCr0E/gBxFUXwQ4KgoIURJT6HDRyiIPQ0+Tic/AnbyO9vvdrSNI4NuZQQAEFFFBAAQUUUEABBRRQQAEFFFBAAQUUUEABBRRQQAEFFFBAAQUUUEABBRRQQAEFFFBAgboINHJZyGAwGKfXVui30Wh0c+k7iz7BnSanpBirWTROk5NVbxTReXo8I4tV7zW7/sBtkvvisB1uD7JbSBUbBrNNXiLcULer2GtWPYE4Tg4i2FCGo7iZ1UKq2CyIXy9mAfeShPOwYxSBgDjEZPM5wp3D9Cjz+l4EQPz2Ysb+cO/rGEUAxFpfzEr9JQduuOXai76gPvUJ6UX7UpTXTNLhF+AgxWRZzAHuOvnLsVEGjOe4X1Yv7RTBoRs++5DsRmt8oj4mD9G+FOX/O0UUakBvk7foXPFIvVL83W0CAUBb5DlCfqXeTDC1UxQCgC6RXoQcyn1S2mms6K02WzDnyAWJR4cXU7VZZNkLATM8j+jGwtTnZKbs3mrz+WBOkCMSjyteLNRmkVVYCKA75D1SfqD2sWXKLwfQNdKPkG+oK/+vrpQGvz4XoMvkboh8y9Y7i9TqoM6SLeLD99S4zqeAAgoooIACCiiggAIKKKCAAgoooIACCiiggAIKKKCAAgoooIACCiiggAIKKKCAAgoooIACPxL4AH/PI5IQavh7AAAAAElFTkSuQmCC";
NSString *const kContainerCloseImage = @"iVBORw0KGgoAAAANSUhEUgAAAFgAAABYCAYAAABxlTA0AAAAAXNSR0IArs4c6QAAActJREFUeAHt2UtugzAQANCom64j9T7cf1W1h+g16ExFKhJhiHEjBfeNZBERzwSeJ+TD6SQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECDwhwLjOJ5jDDFeW8tmjanWubVWF/mBkbhfMTLeY7ztPbHMnWrE5qcm5IAYUmMWn/G4GjlzYmTuPIa9i9VNXmjkWzo7dx5VyJG4hJs1my85XUAXgD5y/9YJFnKrFmjrNbp4vgC1ijzl5Jx5wC11RCgtvdUXkae5cEuYpf0FuCvke+aU6tsfAmuAa8/BqxBYgby9LFx1d8VLmFpAjt2/Abe1TYIyP/huuzaFD4H70gog/8ACK92bHZxxiC5+yiUIvKVLQ4LeXi4g167gCm6il+A3f1bXHkeX8+8BvGdOlzitJ1UDVzO39bi6yN8DtienC6zak2iBasmtPc5Dzg+gpT/cq74ZFJD94Z4dEThDjHlU4V66KgosfbtwyyhgzjHc9Lx0yiO2E/IQ2+Z7aFkjRtZyR/kRi6UmAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAAQIECBAgQIAAgX8s8A3p5fDJQkOt8AAAAABJRU5ErkJggg==";


@implementation VPAppletLandscapeNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initNavigationBar];
    }
    return self;
}

- (void)initNavigationBar {
    CGFloat itemHeight = self.bounds.size.height;
    
    _naviBackView = [[UIView alloc] initWithFrame:self.bounds];
    _naviBackView.backgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"2E323A"];
    _naviBackView.alpha = 1;
    [self addSubview:_naviBackView];
    
    _naviBackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemHeight, itemHeight)];
    [_naviBackButton setImage:[VPUPBase64Util imageFromBase64String:kContainerBackImage] forState:UIControlStateNormal];
    [_naviBackButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _naviBackButton.hidden = YES;
    [self addSubview:_naviBackButton];
    
    CGFloat closeButtonOffset = 0.0;
    if ([VPUPDeviceUtil isIPhoneX]) {
        closeButtonOffset = 16;
    }
    
    _naviCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - itemHeight - closeButtonOffset, 0, itemHeight, itemHeight)];
    [_naviCloseButton setImage:[VPUPBase64Util imageFromBase64String:kContainerCloseImage] forState:UIControlStateNormal];
    [_naviCloseButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_naviCloseButton];
    
    _naviLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemHeight, 0, self.bounds.size.width - itemHeight * 2, itemHeight)];
    _naviLabel.textColor = [UIColor whiteColor];
    _naviLabel.textAlignment = NSTextAlignmentCenter;
    _naviLabel.font = [UIFont systemFontOfSize:12 * VPUPFontScale];
    [self addSubview:_naviLabel];
}


- (BOOL)isBackButtonHidden {
    return self.naviBackButton.isHidden;
}

- (void)showBackButton {
    self.naviBackButton.hidden = NO;
}

- (void)hideBackButton {
    self.naviBackButton.hidden = YES;
}

- (void)backButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviBackButtonTapped)]) {
        [self.delegate naviBackButtonTapped];
    }
}

- (void)closeButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviCloseButtonTapped)]) {
        [self.delegate naviCloseButtonTapped];
    }
}

- (void)updateNavi:(VPAppletContainerNaviSetting *)setting {
    if (!setting) {
        return;
    }
    
    _naviLabel.text = setting.naviTitle;
    _naviBackView.backgroundColor = setting.navibackgroundColor;
    _naviBackView.alpha = setting.naviAlpha;
    _naviLabel.textColor = setting.naviTitleColor;
    [_naviBackButton vpup_fillImageWithColor:setting.naviButtonColor];
    [_naviCloseButton vpup_fillImageWithColor:setting.naviButtonColor];
}

- (void)updateNaviTitle:(NSString *)title {
    if (!title || [title isEqualToString:@""]) {
        return;
    }
    _naviLabel.text = title;
}

@end
