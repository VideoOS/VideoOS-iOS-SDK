//
//  UIButton+VPUPFillColor.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096-videojj on 2019/8/2.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "UIButton+VPUPFillColor.h"
#import "objc/runtime.h"
#import <UIKit/UIKit.h>

@interface UIButton()

@property (nonatomic) CAShapeLayer *vpupFillColorLayer;

@end

@implementation UIButton (VPUPFillColor)

- (CAShapeLayer *)vpupFillColorLayer {
    CAShapeLayer *shaperLayer = nil;
    NSNumber *value = objc_getAssociatedObject(self, @selector(vpupFillColorLayer));
    if ([value isKindOfClass:[CAShapeLayer class]]) {
        shaperLayer = (CAShapeLayer *)value;
    }
    return shaperLayer;
}

- (void)setVpupFillColorLayer:(CAShapeLayer *)layer {
    objc_setAssociatedObject(self, @selector(vpupFillColorLayer), layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)vpup_fillImageWithColor:(UIColor *)color {
    if (!color) {
        return;
    }
    if (!self.currentImage) {
        return;
    }
    
    if (self.vpupFillColorLayer) {
        [self.vpupFillColorLayer removeFromSuperlayer];
        self.vpupFillColorLayer = nil;
    }
    
    CAShapeLayer *imageShapeLayer = [[CAShapeLayer alloc] init];
    imageShapeLayer.fillColor = color.CGColor;
    imageShapeLayer.allowsEdgeAntialiasing = YES;
    [self.layer addSublayer:imageShapeLayer];
    
    CALayer *imageMaskLayer = [[CALayer alloc] init];
    imageMaskLayer.contents = (__bridge id __nullable)(self.currentImage.CGImage);
    imageShapeLayer.mask = imageMaskLayer;
    imageShapeLayer.allowsEdgeAntialiasing = YES;
    
    imageShapeLayer.frame = self.bounds;
    imageShapeLayer.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    imageMaskLayer.frame = self.bounds;
    
    self.vpupFillColorLayer = imageShapeLayer;
}

- (void)vpup_removeFillColor {
    if (!self.vpupFillColorLayer) {
        return;
    }
    
    [self.vpupFillColorLayer removeFromSuperlayer];
    self.vpupFillColorLayer = nil;
}

@end
