//
//  VPUPGridMaskLayer.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface VPUPGridMaskLayer : CAShapeLayer

@property (nonatomic, assign) CGColorRef maskColor;
@property (nonatomic, setter=setMaskRect:) CGRect maskRect;
- (void)setMaskRect:(CGRect)maskRect animated:(BOOL)animated;

@end
