//
//  VPUPGridMaskLayer.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPGridMaskLayer.h"

@implementation VPUPGridMaskLayer

@synthesize maskColor = _maskColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentsScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

- (void)setMaskColor:(CGColorRef)maskColor
{
    self.fillColor = maskColor;
    self.fillRule = kCAFillRuleEvenOdd;
}

- (CGColorRef)maskColor
{
    return self.fillColor;
}

- (void)setMaskRect:(CGRect)maskRect
{
    [self setMaskRect:maskRect animated:NO];
}

- (void)setMaskRect:(CGRect)maskRect animated:(BOOL)animated
{
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathAddRect(mPath, NULL, self.bounds);
    CGPathAddRect(mPath, NULL, maskRect);
    [self removeAnimationForKey:@"vpup_maskLayer_opacityAnimate"];
    if (animated) {
        CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animate.duration = 0.25f;
        animate.fromValue = @(0.0);
        animate.toValue = @(1.0);
        self.path = mPath;
        [self addAnimation:animate forKey:@"vpup_maskLayer_opacityAnimate"];
    } else {
        self.path = mPath;
    }
}

@end
