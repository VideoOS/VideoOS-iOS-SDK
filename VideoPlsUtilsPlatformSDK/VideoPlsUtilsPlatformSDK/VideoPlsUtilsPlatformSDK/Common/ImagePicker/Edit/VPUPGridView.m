//
//  VPUPGridView.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPGridView.h"
#import "VPUPGridLayer.h"
#import "VPUPGridMaskLayer.h"
#import "VPUPResizeControl.h"
#import <AVFoundation/AVFoundation.h>

/** 可控范围 */
const CGFloat kControlWidth = 30.f;

@interface VPUPGridView () <VPUPResizeControlDelegate>

@property (nonatomic, weak) VPUPResizeControl *topLeftCornerView;
@property (nonatomic, weak) VPUPResizeControl *topRightCornerView;
@property (nonatomic, weak) VPUPResizeControl *bottomLeftCornerView;
@property (nonatomic, weak) VPUPResizeControl *bottomRightCornerView;
@property (nonatomic, weak) VPUPResizeControl *topEdgeView;
@property (nonatomic, weak) VPUPResizeControl *leftEdgeView;
@property (nonatomic, weak) VPUPResizeControl *bottomEdgeView;
@property (nonatomic, weak) VPUPResizeControl *rightEdgeView;

@property (nonatomic, weak) VPUPGridMaskLayer *gridMaskLayer;

@property (nonatomic, assign) CGRect initialRect;

@property (nonatomic, weak) VPUPGridLayer *gridLayer;

@property (nonatomic, assign) BOOL aspectRatioHorizontally;
@property (nonatomic, assign) CGSize aspectRatioSize;

@end

@implementation VPUPGridView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    _aspectRatio = VPUPGridViewAspectRatioType_1x1;
    /** 遮罩 */
    VPUPGridMaskLayer *gridMaskLayer = [[VPUPGridMaskLayer alloc] init];
    gridMaskLayer.frame = self.bounds;
    gridMaskLayer.maskColor = [UIColor colorWithWhite:.0f alpha:.5f].CGColor;
    [self.layer addSublayer:gridMaskLayer];
    self.gridMaskLayer = gridMaskLayer;
    
    /** 宫格 */
    VPUPGridLayer *gridLayer = [[VPUPGridLayer alloc] init];
    float lenght = self.bounds.size.height > self.bounds.size.width ? self.bounds.size.width : self.bounds.size.height;
    CGRect gridlayerFrame = CGRectMake((self.bounds.size.width - lenght)*0.5, (self.bounds.size.height - lenght)*0.5, lenght, lenght);
    gridLayer.frame = gridlayerFrame;
    gridLayer.lineWidth = 2.f;
    gridLayer.bgColor = [UIColor clearColor];
    gridLayer.gridColor = [UIColor whiteColor];
    
    [self.layer addSublayer:gridLayer];
    self.gridLayer = gridLayer;
    
    float space = 50;
    CGRect gridlayerRect = CGRectMake((self.bounds.size.width - lenght)*0.5+space, (self.bounds.size.height - lenght)*0.5 + space, lenght - space*2, lenght-space*2);
//    self.gridRect = CGRectInset(self.bounds, 50, 50);
    self.gridRect = gridlayerRect;
    self.controlMinSize = CGSizeMake(80, 80);
//    self.controlMaxRect = CGRectInset(self.bounds, 50, 50);
    self.controlMaxRect = gridlayerRect;
    self.controlSize = CGSizeZero;
    /** 遮罩范围 */
    self.showMaskLayer = YES;
    
    self.topLeftCornerView = [self createResizeControl];
    self.topRightCornerView = [self createResizeControl];
    self.bottomLeftCornerView = [self createResizeControl];
    self.bottomRightCornerView = [self createResizeControl];
    
    self.topEdgeView = [self createResizeControl];
    self.leftEdgeView = [self createResizeControl];
    self.bottomEdgeView = [self createResizeControl];
    self.rightEdgeView = [self createResizeControl];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.gridLayer.frame = self.bounds;
    float lenght = self.bounds.size.height > self.bounds.size.width ? self.bounds.size.width : self.bounds.size.height;
    CGRect gridlayerFrame = CGRectMake((self.bounds.size.width - lenght)*0.5, (self.bounds.size.height - lenght)*0.5, lenght, lenght);
    self.gridLayer.frame = self.bounds;
    self.gridMaskLayer.frame = self.bounds;
    
    CGRect rect = self.gridRect;
    
    self.topLeftCornerView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.topLeftCornerView.bounds) / 2, CGRectGetMinY(rect) - CGRectGetHeight(self.topLeftCornerView.bounds) / 2, self.topLeftCornerView.bounds.size};
    self.topRightCornerView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.topRightCornerView.bounds) / 2, CGRectGetMinY(rect) - CGRectGetHeight(self.topRightCornerView.bounds) / 2, self.topRightCornerView.bounds.size};
    self.bottomLeftCornerView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.bottomLeftCornerView.bounds) / 2, CGRectGetMaxY(rect) - CGRectGetHeight(self.bottomLeftCornerView.bounds) / 2, self.bottomLeftCornerView.bounds.size};
    self.bottomRightCornerView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.bottomRightCornerView.bounds) / 2, CGRectGetMaxY(rect) - CGRectGetHeight(self.bottomRightCornerView.bounds) / 2, self.bottomRightCornerView.bounds.size};
    
    self.topEdgeView.frame = (CGRect){CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetMinY(rect) - CGRectGetHeight(self.topEdgeView.frame) / 2, CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.bounds)};
    self.leftEdgeView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.leftEdgeView.frame) / 2, CGRectGetMaxY(self.topLeftCornerView.frame), CGRectGetWidth(self.leftEdgeView.bounds), CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame)};
    self.bottomEdgeView.frame = (CGRect){CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetMinY(self.bottomLeftCornerView.frame), CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetHeight(self.bottomEdgeView.bounds)};
    self.rightEdgeView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.rightEdgeView.bounds) / 2, CGRectGetMaxY(self.topRightCornerView.frame), CGRectGetWidth(self.rightEdgeView.bounds), CGRectGetMinY(self.bottomRightCornerView.frame) - CGRectGetMaxY(self.topRightCornerView.frame)};
}

- (void)setShowMaskLayer:(BOOL)showMaskLayer
{
    if (_showMaskLayer != showMaskLayer) {
        _showMaskLayer = showMaskLayer;
        if (showMaskLayer) {
            /** 还原遮罩 */
            [self.gridMaskLayer setMaskRect:self.gridRect animated:YES];
        } else {
            /** 扩大遮罩范围 */
            [self.gridMaskLayer setMaskRect:self.gridMaskLayer.bounds animated:YES];
        }
    }
    /** 简单粗暴的禁用拖动事件 */
    self.userInteractionEnabled = showMaskLayer;
}

#pragma mark - VPUPResizeControlDelegate

- (void)vpup_resizeConrolDidBeginResizing:(VPUPResizeControl *)resizeConrol
{
    self.initialRect = self.gridRect;
    
    //    self.showMaskLayer = NO;
    if ([self.delegate respondsToSelector:@selector(vpup_gridViewDidBeginResizing:)]) {
        [self.delegate vpup_gridViewDidBeginResizing:self];
    }
}
- (void)vpup_resizeConrolDidResizing:(VPUPResizeControl *)resizeConrol
{
    CGRect gridRect = [self cropRectMakeWithResizeControlView:resizeConrol];
    [self setGridRect:gridRect maskLayer:NO];
    
    if ([self.delegate respondsToSelector:@selector(vpup_gridViewDidResizing:)]) {
        [self.delegate vpup_gridViewDidResizing:self];
    }
}
- (void)vpup_resizeConrolDidEndResizing:(VPUPResizeControl *)resizeConrol
{
    //    self.showMaskLayer = YES;
    if ([self.delegate respondsToSelector:@selector(vpup_gridViewDidEndResizing:)]) {
        [self.delegate vpup_gridViewDidEndResizing:self];
    }
}

- (void)setGridRect:(CGRect)gridRect
{
    [self setGridRect:gridRect maskLayer:YES];
}
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer
{
    [self setGridRect:gridRect maskLayer:isMaskLayer animated:NO];
}
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated
{
    [self setGridRect:gridRect maskLayer:NO animated:animated];
}
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer animated:(BOOL)animated
{
    if (!CGRectEqualToRect(_gridRect, gridRect)) {
        _gridRect = gridRect;
        [self setNeedsLayout];
        [self.gridLayer setGridRect:gridRect animated:animated];
        if (isMaskLayer) {
            [self.gridMaskLayer setMaskRect:gridRect animated:YES];
        }
    }
}

- (void)setAspectRatio:(VPUPGridViewAspectRatioType)aspectRatio
{
    if (_aspectRatio != aspectRatio) {
        _aspectRatio = aspectRatio;
        CGSize size = self.aspectRatioSize;
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            CGRect gridRect = self.gridRect;
            /** 计算比例后高度 */
            CGFloat newHeight = gridRect.size.width * (size.height/size.width);
            /** 超出最大高度计算 */
            if (newHeight > _controlMaxRect.size.height) {
                CGFloat newWidth = gridRect.size.width * (_controlMaxRect.size.height/newHeight);
                CGFloat diffWidth = gridRect.size.width - newWidth;
                gridRect.size.width = newWidth;
                gridRect.origin.x = gridRect.origin.x + diffWidth/2;
                newHeight = _controlMaxRect.size.height;
            }
            CGFloat diffHeight = gridRect.size.height - newHeight;
            gridRect.size.height = newHeight;
            gridRect.origin.y = gridRect.origin.y + diffHeight/2;
            
            [self setGridRect:gridRect maskLayer:NO];
            
            if ([self.delegate respondsToSelector:@selector(vpup_gridViewDidAspectRatio:)]) {
                [self.delegate vpup_gridViewDidAspectRatio:self];
            }
        }
    }
}

- (NSArray <NSString *>*)aspectRatioDescs:(BOOL)horizontally
{
    _aspectRatioHorizontally = horizontally;
    return @[@"1x1"];
//    if (horizontally) {
//        return @[@"Original", @"1x1", @"3x2", @"4x3", @"5x3", @"15x9", @"16x9", @"16x10"];
//    } else {
//        return @[@"Original", @"1x1", @"2x3", @"3x4", @"3x5", @"9x15", @"9x16", @"10x16"];
//    }
}

#pragma mark - private

- (CGSize)aspectRatioSize
{
    if (self.aspectRatioHorizontally) {
        switch (self.aspectRatio) {
            case VPUPGridViewAspectRatioType_None:
                return CGSizeZero;
            case VPUPGridViewAspectRatioType_Original:
                if (self.controlSize.width == 0 || self.controlSize.height == 0) {
                    return CGSizeZero;
                }
                return CGSizeMake(1, self.controlSize.height/self.controlSize.width);
            case VPUPGridViewAspectRatioType_1x1:
                return CGSizeMake(1, 1);
            case VPUPGridViewAspectRatioType_3x2:
                return CGSizeMake(3, 2);
            case VPUPGridViewAspectRatioType_4x3:
                return CGSizeMake(4, 3);
            case VPUPGridViewAspectRatioType_5x3:
                return CGSizeMake(5, 3);
            case VPUPGridViewAspectRatioType_15x9:
                return CGSizeMake(15, 9);
            case VPUPGridViewAspectRatioType_16x9:
                return CGSizeMake(16, 9);
            case VPUPGridViewAspectRatioType_16x10:
                return CGSizeMake(16, 10);
        }
    } else {
        switch (self.aspectRatio) {
            case VPUPGridViewAspectRatioType_None:
                return CGSizeZero;
            case VPUPGridViewAspectRatioType_Original:
                if (self.controlSize.width == 0 || self.controlSize.height == 0) {
                    return CGSizeZero;
                }
                return CGSizeMake(self.controlSize.width/self.controlSize.height, 1);
            case VPUPGridViewAspectRatioType_1x1:
                return CGSizeMake(1, 1);
            case VPUPGridViewAspectRatioType_3x2:
                return CGSizeMake(2, 3);
            case VPUPGridViewAspectRatioType_4x3:
                return CGSizeMake(3, 4);
            case VPUPGridViewAspectRatioType_5x3:
                return CGSizeMake(3, 5);
            case VPUPGridViewAspectRatioType_15x9:
                return CGSizeMake(9, 15);
            case VPUPGridViewAspectRatioType_16x9:
                return CGSizeMake(9, 16);
            case VPUPGridViewAspectRatioType_16x10:
                return CGSizeMake(10, 16);
        }
    }
    
    return CGSizeZero;
}

- (VPUPResizeControl *)createResizeControl
{
    VPUPResizeControl *control = [[VPUPResizeControl alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(kControlWidth, kControlWidth)}];
    control.delegate = self;
    [self addSubview:control];
    return control;
}

- (CGRect)cropRectMakeWithResizeControlView:(VPUPResizeControl *)resizeControlView
{
    CGRect rect = self.gridRect;
    
    CGSize aspectRatioSize = self.aspectRatioSize;
    CGFloat widthRatio = aspectRatioSize.height == 0 ? 0 : aspectRatioSize.width/aspectRatioSize.height;
    CGFloat heightRatio = aspectRatioSize.width == 0 ? 0 : aspectRatioSize.height/aspectRatioSize.width;
    
    if (resizeControlView == self.topEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.y * widthRatio / 2,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.y * widthRatio,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
    } else if (resizeControlView == self.leftEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.x * heightRatio / 2,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.x * heightRatio);
    } else if (resizeControlView == self.bottomEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) - resizeControlView.translation.y * widthRatio / 2,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.y * widthRatio,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
    } else if (resizeControlView == self.rightEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) - resizeControlView.translation.x * heightRatio / 2,
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.x * heightRatio);
    } else if (resizeControlView == self.topLeftCornerView) {
        /** 固定大小比例 */
        if (heightRatio && widthRatio) {
            CGFloat trans = self.aspectRatioHorizontally ? MAX(resizeControlView.translation.x, resizeControlView.translation.y) : MIN(resizeControlView.translation.x, resizeControlView.translation.y);
            rect = CGRectMake(CGRectGetMinX(self.initialRect) + trans,
                              CGRectGetMinY(self.initialRect) + trans * heightRatio,
                              CGRectGetWidth(self.initialRect) - trans,
                              CGRectGetHeight(self.initialRect) - trans * heightRatio);
        } else {
            rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                              CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                              CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                              CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
        }
    } else if (resizeControlView == self.topRightCornerView) {
        /** 固定大小比例 */
        if (heightRatio && widthRatio) {
            CGFloat trans = self.aspectRatioHorizontally ? MAX(resizeControlView.translation.x * -1, resizeControlView.translation.y) : MIN(resizeControlView.translation.x * -1, resizeControlView.translation.y);
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                              CGRectGetMinY(self.initialRect) + trans * heightRatio,
                              CGRectGetWidth(self.initialRect) - trans,
                              CGRectGetHeight(self.initialRect) - trans * heightRatio);
        } else {
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                              CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                              CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                              CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
        }
    } else if (resizeControlView == self.bottomLeftCornerView) {
        /** 固定大小比例 */
        if (heightRatio && widthRatio) {
            CGFloat trans = self.aspectRatioHorizontally ? MAX(resizeControlView.translation.x, resizeControlView.translation.y * -1) : MIN(resizeControlView.translation.x, resizeControlView.translation.y * -1);
            rect = CGRectMake(CGRectGetMinX(self.initialRect) + trans,
                              CGRectGetMinY(self.initialRect),
                              CGRectGetWidth(self.initialRect) - trans,
                              CGRectGetHeight(self.initialRect) - trans * heightRatio);
        } else {
            rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                              CGRectGetMinY(self.initialRect),
                              CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                              CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
        }
    } else if (resizeControlView == self.bottomRightCornerView) {
        /** 固定大小比例 */
        if (heightRatio && widthRatio) {
            CGFloat trans = self.aspectRatioHorizontally ? MAX(resizeControlView.translation.x * -1, resizeControlView.translation.y * -1) : MIN(resizeControlView.translation.x * -1, resizeControlView.translation.y * -1);
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                              CGRectGetMinY(self.initialRect),
                              CGRectGetWidth(self.initialRect) - trans,
                              CGRectGetHeight(self.initialRect) - trans * heightRatio);
        } else {
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                              CGRectGetMinY(self.initialRect),
                              CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                              CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
        }
    }
    
    if (heightRatio && widthRatio) {
        /** 限制长宽同时少于最小值，不处理 */
        if (ceil(rect.size.width) < ceil(_controlMinSize.width) && ceil(rect.size.height) < ceil(_controlMinSize.height)) {
            return self.gridRect;
        }
    }
    
    /** ps：
     此处判断 不能使用CGRectGet开头的方法，计算会有问题；
     当rect = (origin = (x = 50, y = 618), size = (width = 61, height = -488)) 时，
     CGRectGetMaxY(rect) = 618；CGRectGetHeight(rect) = 488
     */
    
    /** 限制x/y 超出左上角 最大限度 */
    if (ceil(rect.origin.x) < ceil(CGRectGetMinX(_controlMaxRect))) {
        rect.origin.x = _controlMaxRect.origin.x;
//        rect.size.width = CGRectGetMaxX(self.initialRect)-rect.origin.x;
    }
    if (ceil(rect.origin.y) < ceil(CGRectGetMinY(_controlMaxRect))) {
        rect.origin.y = _controlMaxRect.origin.y;
//        rect.size.height = CGRectGetMaxY(self.initialRect)-rect.origin.y;
    }
    
    /** 限制宽度／高度 超出 最大限度 */
    if (ceil(rect.origin.x+rect.size.width) > ceil(CGRectGetMaxX(_controlMaxRect))) {
        rect.size.width = CGRectGetMaxX(_controlMaxRect) - CGRectGetMinX(rect);
    }
    if (ceil(rect.origin.y+rect.size.height) > ceil(CGRectGetMaxY(_controlMaxRect))) {
        rect.size.height = CGRectGetMaxY(_controlMaxRect) - CGRectGetMinY(rect);
    }
    
    /** 限制宽度／高度 小于 最小限度 */
    if (ceil(rect.size.width) <= ceil(_controlMinSize.width)) {
        /** 左上、左、左下 处理x最小值 */
        if (resizeControlView == self.topLeftCornerView || resizeControlView == self.leftEdgeView || resizeControlView == self.bottomLeftCornerView) {
            rect.origin.x = CGRectGetMaxX(self.initialRect) - _controlMinSize.width;
        }
        rect.size.width = _controlMinSize.width;
        if (heightRatio && widthRatio) {
            rect.size.height = rect.size.width * heightRatio;
            /** 左、右 处理x最小值中间 */
            if (resizeControlView == self.leftEdgeView || resizeControlView == self.rightEdgeView) {
                rect.origin.y = CGRectGetMaxY(self.initialRect) - CGRectGetHeight(self.initialRect)/2 - rect.size.height/2;
            }
            /** 上、下 处理y最小值中间 */
            if (resizeControlView == self.topEdgeView || resizeControlView == self.bottomEdgeView) {
                rect.origin.x = CGRectGetMaxX(self.initialRect) - CGRectGetWidth(self.initialRect)/2 - _controlMinSize.width/2;
            }
            /** 左上、上、右上 处理y最小值底部 */
            if (resizeControlView == self.topLeftCornerView || resizeControlView == self.topEdgeView || resizeControlView == self.topRightCornerView) {
                rect.origin.y = CGRectGetMaxY(self.initialRect) - rect.size.height;
            }
        }
    }
    if (ceil(rect.size.height) <= ceil(_controlMinSize.height)) {
        /** 左上、上、右上 处理y最小值底部 */
        if (resizeControlView == self.topLeftCornerView || resizeControlView == self.topEdgeView || resizeControlView == self.topRightCornerView) {
            rect.origin.y = CGRectGetMaxY(self.initialRect) - _controlMinSize.height;
        }
        rect.size.height = _controlMinSize.height;
        if (heightRatio && widthRatio) {
            rect.size.width = rect.size.height * widthRatio;
            /** 左、右 处理y最小值中间 */
            if (resizeControlView == self.leftEdgeView || resizeControlView == self.rightEdgeView) {
                rect.origin.y = CGRectGetMaxY(self.initialRect) - CGRectGetHeight(self.initialRect)/2 - _controlMinSize.height/2;
            }
            /** 上、下 处理x最小值中间 */
            if (resizeControlView == self.topEdgeView || resizeControlView == self.bottomEdgeView) {
                rect.origin.x = CGRectGetMaxX(self.initialRect) - CGRectGetWidth(self.initialRect)/2 - rect.size.width/2;
            }
            
            /** 左上、左、左下 处理x最小值 */
            if (resizeControlView == self.topLeftCornerView || resizeControlView == self.leftEdgeView || resizeControlView == self.bottomLeftCornerView) {
                rect.origin.x = CGRectGetMaxX(self.initialRect) - rect.size.width;
            }
        }
    }
    
    /** 固定大小比例 */
    if (heightRatio && widthRatio) {
        if (rect.size.width == _controlMaxRect.size.width) {
            rect.origin.y = self.initialRect.origin.y;
            rect.size.height = rect.size.width * heightRatio;
        } else if (rect.size.height == _controlMaxRect.size.height) {
            rect.origin.x = self.initialRect.origin.x;
            rect.size.width = rect.size.height * widthRatio;
        }
    }
    
    return rect;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (self == view) {
        return nil;
    }
    return view;
}

@end
