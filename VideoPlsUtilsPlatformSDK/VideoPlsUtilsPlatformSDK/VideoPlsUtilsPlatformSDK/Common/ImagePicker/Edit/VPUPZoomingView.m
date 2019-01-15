//
//  VPUPZoomingView.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPZoomingView.h"
#import <AVFoundation/AVFoundation.h>


@interface VPUPZoomingView ()

/** 原始坐标 */
@property (nonatomic, assign) CGRect originalRect;

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation VPUPZoomingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _originalRect = frame;
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    self.imageView = imageView;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (image) {
        CGRect imageViewRect = AVMakeRectWithAspectRatioInsideRect(image.size, self.originalRect);
        CGRect tempFrame = self.frame;
        tempFrame.size = imageViewRect.size;
        self.frame = tempFrame;
        
        /** 子控件更新 */
        [[self subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.frame = self.bounds;
        }];
    }
    
    [self.imageView setImage:image];
}

@end
