//
//  VPUPEditingView.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPEditingView.h"
#import "VPUPGridView.h"
#import "VPUPClippingView.h"
#import "VPUPImagePickerManager.h"
#import <AVFoundation/AVFoundation.h>


@interface UIView(VPUP_CaptureImage)

- (UIImage *)vpup_captureImageAtFrame:(CGRect)rect;

@end

@implementation UIView(VPUP_CaptureImage)

- (UIImage *)vpup_captureImageAtFrame:(CGRect)rect
{
    UIImage* image = nil;
    
    CGSize size = !CGRectEqualToRect(CGRectZero, rect) ? rect.size : self.frame.size;
    
    //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!CGRectEqualToRect(CGRectZero, rect)) {
        /** 移动上下文 */
        CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    }
    //2.绘制图层
    [self.layer renderInContext: context];
    
    //3.从上下文中获取新图片
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}
@end

typedef void(^vpup_edit_dispatch_cancelable_block_t)(BOOL cancel);

vpup_edit_dispatch_cancelable_block_t vpup_edit_dispatch_block_t(NSTimeInterval delay, void(^block)())
{
    __block vpup_edit_dispatch_cancelable_block_t cancelBlock = nil;
    vpup_edit_dispatch_cancelable_block_t delayBlcok = ^(BOOL cancel){
        if (!cancel) {
            if ([NSThread isMainThread]) {
                block();
            } else {
                dispatch_async(dispatch_get_main_queue(), block);
            }
        }
        cancelBlock = nil;
    };
    cancelBlock = delayBlcok;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (cancelBlock) {
            cancelBlock(NO);
        }
    });
    return delayBlcok;
}

void vpup_edit_dispatch_cancel(vpup_edit_dispatch_cancelable_block_t block)
{
    if (block) {
        block(YES);
    }
}



#define kMaxZoomScale 2.5f

#define kClipZoom_margin 15.f

@interface VPUPEditingView () <UIScrollViewDelegate, VPUPClippingViewDelegate, VPUPGridViewDelegate>

@property (nonatomic, weak) VPUPClippingView *clippingView;
@property (nonatomic, weak) VPUPGridView *gridView;
/** 因为LFClippingView需要调整transform属性，需要额外创建一层进行缩放处理，理由：UIScrollView的缩放会自动重置transform */
@property (nonatomic, weak) UIView *clipZoomView;

/** 剪裁尺寸, CGRectInset(self.bounds, 20, 50) */
@property (nonatomic, assign) CGRect clippingRect;

/** 显示图片剪裁像素 */
@property (nonatomic, weak) UILabel *imagePixel;

/** 图片像素参照坐标 */
@property (nonatomic, assign) CGSize referenceSize;

/* 底部栏高度 默认44 */
@property (nonatomic, assign) CGFloat editToolbarDefaultHeight;

@property (nonatomic, copy) vpup_edit_dispatch_cancelable_block_t maskViewBlock;

@end

@implementation VPUPEditingView

@synthesize image = _image;

- (NSArray <NSString *>*)aspectRatioDescs
{
    return [self.gridView aspectRatioDescs:(self.image.size.width > self.image.size.height)];
}

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
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    /** 缩放 */
    self.maximumZoomScale = kMaxZoomScale;
    self.minimumZoomScale = 1.0;
    _editToolbarDefaultHeight = 44.f;
    
    /** 创建缩放层，避免直接缩放LFClippingView，会改变其transform */
    UIView *clipZoomView = [[UIView alloc] initWithFrame:self.bounds];
    clipZoomView.backgroundColor = [UIColor clearColor];
    [self addSubview:clipZoomView];
    self.clipZoomView = clipZoomView;
    
    /** 创建剪裁层 */
    VPUPClippingView *clippingView = [[VPUPClippingView alloc] initWithFrame:self.bounds];
    clippingView.clippingDelegate = self;
    /** 非剪裁情况禁止剪裁层移动 */
    clippingView.scrollEnabled = NO;
    [self.clipZoomView addSubview:clippingView];
    self.clippingView = clippingView;
    
    VPUPGridView *gridView = [[VPUPGridView alloc] initWithFrame:self.bounds];
    gridView.delegate = self;
    /** 先隐藏剪裁网格 */
    gridView.alpha = 0.f;
    [self addSubview:gridView];
    self.gridView = gridView;
    
    self.clippingMinSize = CGSizeMake(80, 80);
    self.clippingMaxRect = CGRectInset(self.frame , 20, 50);
    
    /** 创建显示图片像素控件 */
    UILabel *imagePixel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-40, 30)];
    imagePixel.numberOfLines = 1;
    imagePixel.textAlignment = NSTextAlignmentCenter;
    imagePixel.font = [UIFont boldSystemFontOfSize:13.f];
    imagePixel.textColor = [UIColor whiteColor];
    imagePixel.highlighted = YES;
    imagePixel.highlightedTextColor = [UIColor whiteColor];
    imagePixel.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePixel.layer.shadowOpacity = 1.f;
    imagePixel.layer.shadowOffset = CGSizeMake(0, 0);
    imagePixel.layer.shadowRadius = 8;
    imagePixel.alpha = 0.f;
    [self addSubview:imagePixel];
    self.imagePixel = imagePixel;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (image) {
        CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(image.size, self.frame);
        
        float lenght = cropRect.size.height > cropRect.size.width ? cropRect.size.width : cropRect.size.height;
        CGRect gridlayerFrame = CGRectMake(cropRect.origin.x + (cropRect.size.width - lenght)*0.5,cropRect.origin.y + (cropRect.size.height - lenght)*0.5, lenght, lenght);
        
        self.gridView.controlSize = gridlayerFrame.size;
        self.gridView.gridRect = gridlayerFrame;
        self.imagePixel.center = CGPointMake(CGRectGetMidX(cropRect), CGRectGetMidY(cropRect));
    }
    self.clippingView.image = image;
    
    /** 计算图片像素参照坐标 */
    self.referenceSize = AVMakeRectWithAspectRatioInsideRect(self.clippingView.frame.size, self.clippingMaxRect).size;
}

- (void)setClippingRect:(CGRect)clippingRect
{
    CGFloat toolbarHeight = self.editToolbarDefaultHeight;
    if (@available(iOS 11.0, *)) {
        toolbarHeight += self.safeAreaInsets.bottom;
    }
    CGFloat clippingMinY = CGRectGetHeight(self.frame)-toolbarHeight-kClipZoom_margin-CGRectGetHeight(clippingRect);
    if (clippingRect.origin.y > clippingMinY) {
        clippingRect.origin.y = clippingMinY;
    }
    _clippingRect = clippingRect;
    
    float lenght = clippingRect.size.height > clippingRect.size.width ? clippingRect.size.width : clippingRect.size.height;
    CGRect gridlayerFrame = CGRectMake(clippingRect.origin.x + (clippingRect.size.width - lenght)*0.5,clippingRect.origin.y + (clippingRect.size.height - lenght)*0.5, lenght, lenght);
    
    self.gridView.gridRect = gridlayerFrame;
    self.clippingView.cropRect = clippingRect;
    self.imagePixel.center = CGPointMake(CGRectGetMidX(self.gridView.gridRect), CGRectGetMidY(self.gridView.gridRect));
    
    if (_isClipping) {
        /** 关闭缩放 */
        self.maximumZoomScale = self.minimumZoomScale;
        [self setZoomScale:self.zoomScale];
    } else {
        self.maximumZoomScale = MIN(MAX(self.minimumZoomScale + kMaxZoomScale - kMaxZoomScale * (self.clippingView.zoomScale/self.clippingView.maximumZoomScale), self.minimumZoomScale), kMaxZoomScale);
    }
}

- (void)setClippingMinSize:(CGSize)clippingMinSize
{
    if (CGSizeEqualToSize(CGSizeZero, _clippingMinSize) || (clippingMinSize.width < CGRectGetWidth(_clippingMaxRect) && clippingMinSize.height < CGRectGetHeight(_clippingMaxRect))) {
        _clippingMinSize = clippingMinSize;
        self.gridView.controlMinSize = clippingMinSize;
    }
}

- (void)setClippingMaxRect:(CGRect)clippingMaxRect
{
    if (CGRectEqualToRect(CGRectZero, _clippingMaxRect) || (CGRectGetWidth(clippingMaxRect) > _clippingMinSize.width && CGRectGetHeight(clippingMaxRect) > _clippingMinSize.height)) {
        _clippingMaxRect = clippingMaxRect;
        
        float lenght = clippingMaxRect.size.height > clippingMaxRect.size.width ? clippingMaxRect.size.width : clippingMaxRect.size.height;
        CGRect gridlayerMaxRect = CGRectMake(clippingMaxRect.origin.x + (clippingMaxRect.size.width - lenght)*0.5,clippingMaxRect.origin.y + (clippingMaxRect.size.height - lenght)*0.5, lenght, lenght);
        
        self.gridView.controlMaxRect = gridlayerMaxRect;
        self.clippingView.editRect = clippingMaxRect;
        /** 计算缩放剪裁尺寸 */
        self.referenceSize = AVMakeRectWithAspectRatioInsideRect(self.clippingView.frame.size, self.clippingMaxRect).size;
    }
}

- (void)setIsClipping:(BOOL)isClipping
{
    [self setIsClipping:isClipping animated:NO];
}
- (void)setIsClipping:(BOOL)isClipping animated:(BOOL)animated
{
    _isClipping = isClipping;
    self.clippingView.scrollEnabled = isClipping;
    if (isClipping) {
        /** 动画切换 */
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                CGRect rect = CGRectInset(self.frame , 20, 50);
                self.clippingRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.frame.size, rect);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25f animations:^{
                    self.gridView.alpha = 1.f;
                    self.imagePixel.alpha = 1.f;
                } completion:^(BOOL finished) {
                    /** 显示多余部分 */
                    self.clippingView.clipsToBounds = NO;
                }];
            }];
        } else {
            CGRect rect = CGRectInset(self.frame , 20, 50);
            self.clippingRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.frame.size, rect);
            self.gridView.alpha = 1.f;
            self.imagePixel.alpha = 1.f;
            /** 显示多余部分 */
            self.clippingView.clipsToBounds = NO;
        }
        [self updateImagePixelText];
    } else {
        /** 重置最大缩放 */
        if (animated) {
            /** 剪裁多余部分 */
            self.clippingView.clipsToBounds = YES;
            [UIView animateWithDuration:0.1f animations:^{
                self.gridView.alpha = 0.f;
                self.imagePixel.alpha = 0.f;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25f animations:^{
                    CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.frame.size, self.frame);
                    self.clippingRect = cropRect;
                }];
            }];
        } else {
            /** 剪裁多余部分 */
            self.clippingView.clipsToBounds = YES;
            self.gridView.alpha = 0.f;
            self.imagePixel.alpha = 0.f;
            CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.frame.size, self.frame);
            self.clippingRect = cropRect;
        }
    }
}

/** 取消剪裁 */
- (void)cancelClipping:(BOOL)animated
{
    _isClipping = NO;
    /** 剪裁多余部分 */
    self.clippingView.clipsToBounds = YES;
    if (animated) {
        [UIView animateWithDuration:0.1f animations:^{
            self.gridView.alpha = 0.f;
            self.imagePixel.alpha = 0.f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25f animations:^{
                [self cancel];
            }];
        }];
    } else {
        [self cancel];
    }
}

- (void)cancel
{
    [self.clippingView cancel];
    self.gridView.gridRect = self.clippingView.frame;
    self.imagePixel.center = CGPointMake(CGRectGetMidX(self.gridView.gridRect), CGRectGetMidY(self.gridView.gridRect));
    self.maximumZoomScale = MIN(MAX(self.minimumZoomScale + kMaxZoomScale - kMaxZoomScale * (self.clippingView.zoomScale/self.clippingView.maximumZoomScale), self.minimumZoomScale), kMaxZoomScale);
}

/** 还原 */
- (void)reset
{
    if (_isClipping) {
        [self.clippingView reset];
    }
}

- (BOOL)canReset
{
    if (_isClipping) {
        return self.clippingView.canReset;
    }
    return NO;
}

/** 旋转 isClipping=YES 的情况有效 */
- (void)rotate
{
    if (_isClipping) {
        [self.clippingView rotateClockwise:YES];
    }
}

/** 长宽比例 */
- (void)setAspectRatio:(NSString *)aspectRatio
{
    NSInteger index = 0;
    NSArray *aspectRatioDescs = [self aspectRatioDescs];
    if (aspectRatio.length && [aspectRatioDescs containsObject:aspectRatio]) {
        index = [aspectRatioDescs indexOfObject:aspectRatio] + 1;
    }
    [self.gridView setAspectRatio:VPUPGridViewAspectRatioType_1x1];
}

/** 创建编辑图片 */
- (UIImage *)createEditImage
{
    CGFloat zoomScale = self.zoomScale;
    [self setZoomScale:1.f];
    UIImage *image = [self.clipZoomView vpup_captureImageAtFrame:self.gridView.gridRect];
    [self setZoomScale:zoomScale];
    
    return image;
}

#pragma mark - VPUPClippingViewDelegate
- (void (^)(CGRect))vpup_clippingViewWillBeginZooming:(VPUPClippingView *)clippingView
{
    __weak typeof(self) weakSelf = self;
    void (^block)(CGRect) = ^(CGRect rect){
        if (clippingView.isReseting || clippingView.isRotating) { /** 重置/旋转 需要将遮罩显示也重置 */
            [weakSelf.gridView setGridRect:rect maskLayer:YES animated:YES];
        } else if (clippingView.isZooming) { /** 缩放 */
            weakSelf.gridView.showMaskLayer = NO;
            vpup_edit_dispatch_cancel(weakSelf.maskViewBlock);
        } else {
            [weakSelf.gridView setGridRect:rect animated:YES];
        }
        
        /** 图片像素 */
        [self updateImagePixelText];
    };
    return block;
}
- (void)vpup_clippingViewDidZoom:(VPUPClippingView *)clippingView
{
    if (clippingView.zooming) {
        [self updateImagePixelText];
    }
}
- (void)vpup_clippingViewDidEndZooming:(VPUPClippingView *)clippingView
{
    __weak typeof(self) weakSelf = self;
    self.maskViewBlock = vpup_edit_dispatch_block_t(0.25f, ^{
        weakSelf.gridView.showMaskLayer = YES;
    });
    
    [self updateImagePixelText];
    
    if ([self.clippingDelegate respondsToSelector:@selector(vpup_EditingViewDidEndZooming:)]) {
        [self.clippingDelegate vpup_EditingViewDidEndZooming:self];
    }
}

- (void)vpup_clippingViewWillBeginDragging:(VPUPClippingView *)clippingView
{
    /** 移动开始，隐藏 */
    self.gridView.showMaskLayer = NO;
    vpup_edit_dispatch_cancel(self.maskViewBlock);
}
- (void)vpup_clippingViewDidEndDecelerating:(VPUPClippingView *)clippingView
{
    /** 移动结束，显示 */
    __weak typeof(self) weakSelf = self;
    self.maskViewBlock = vpup_edit_dispatch_block_t(0.25f, ^{
        weakSelf.gridView.showMaskLayer = YES;
    });
    if ([self.clippingDelegate respondsToSelector:@selector(vpup_EditingViewEndDecelerating:)]) {
        [self.clippingDelegate vpup_EditingViewEndDecelerating:self];
    }
}

#pragma mark - VPUPGridViewDelegate
- (void)vpup_gridViewDidBeginResizing:(VPUPGridView *)gridView
{
    gridView.showMaskLayer = NO;
    vpup_edit_dispatch_cancel(self.maskViewBlock);
}
- (void)vpup_gridViewDidResizing:(VPUPGridView *)gridView
{
    /** 放大 */
    [self.clippingView zoomInToRect:gridView.gridRect];
    
    /** 图片像素 */
    [self updateImagePixelText];
}
- (void)vpup_gridViewDidEndResizing:(VPUPGridView *)gridView
{
    /** 缩小 */
    [self.clippingView zoomOutToRect:gridView.gridRect];
    /** 让clippingView的动画回调后才显示showMaskLayer */
    //    self.gridView.showMaskLayer = YES;
}
/** 调整长宽比例 */
- (void)vpup_gridViewDidAspectRatio:(VPUPGridView *)gridView
{
    [self vpup_gridViewDidBeginResizing:gridView];
    [self vpup_gridViewDidResizing:gridView];
    [self vpup_gridViewDidEndResizing:gridView];
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.clipZoomView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.contentInset = UIEdgeInsetsZero;
    self.scrollIndicatorInsets = UIEdgeInsetsZero;
    [self refreshImageZoomViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    /** 重置contentSize */
    CGRect realClipZoomRect = AVMakeRectWithAspectRatioInsideRect(self.clippingView.frame.size, self.clipZoomView.frame);
    CGFloat width = MAX(self.frame.size.width, realClipZoomRect.size.width);
    CGFloat height = MAX(self.frame.size.height, realClipZoomRect.size.height);
    CGFloat diffWidth = (width-self.clipZoomView.frame.size.width)/2;
    CGFloat diffHeight = (height-self.clipZoomView.frame.size.height)/2;
    self.contentInset = UIEdgeInsetsMake(diffHeight, diffWidth, 0, 0);
    self.scrollIndicatorInsets = UIEdgeInsetsMake(diffHeight, diffWidth, 0, 0);
    self.contentSize = CGSizeMake(width, height);
}


#pragma mark - 重写父类方法

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    
    if (!([[self subviews] containsObject:view] || [[self.clipZoomView subviews] containsObject:view])) { /** 非自身子视图 */
        if (event.allTouches.count == 2) { /** 2个手指 */
            return NO;
        }
    }
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if (!([[self subviews] containsObject:view] || [[self.clipZoomView subviews] containsObject:view])) { /** 非自身子视图 */
        return NO;
    }
    return [super touchesShouldCancelInContentView:view];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (!self.isClipping && (self.clippingView == view || self.clipZoomView == view)) { /** 非编辑状态，改变触发响应最顶层的scrollView */
        return self;
    } else if (self.isClipping && (view == self || self.clipZoomView == view)) {
        return self.clippingView;
    }
    return view;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /** 解决部分机型在编辑期间会触发滑动导致无法编辑的情况 */
    if (gestureRecognizer.view == self && touch.view != self && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        /** 自身手势被触发、响应视图非自身、被触发收拾为滑动手势 */
        return NO;
    }
    return YES;
}

#pragma mark - Private
- (void)refreshImageZoomViewCenter {
    CGFloat offsetX = (self.frame.size.width > self.contentSize.width) ? ((self.frame.size.width - self.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (self.frame.size.height > self.contentSize.height) ? ((self.frame.size.height - self.contentSize.height) * 0.5) : 0.0;
    self.clipZoomView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, self.contentSize.height * 0.5 + offsetY);
}

#pragma mark - 更新图片像素
- (void)updateImagePixelText;
{
    //    CGFloat scale = self.clippingView.zoomScale/self.clippingView.first_minimumZoomScale;
    //    CGSize realSize = CGSizeMake(CGRectGetWidth(self.gridView.gridRect)/scale, CGRectGetHeight(self.gridView.gridRect)/scale);
    //    CGFloat screenScale = [UIScreen mainScreen].scale;
    //    int pixelW = (int)((self.image.size.width*screenScale)/self.referenceSize.width*realSize.width+0.5);
    //    int pixelH = (int)((self.image.size.height*screenScale)/self.referenceSize.height*realSize.height+0.5);
    //    self.imagePixel.text = [NSString stringWithFormat:@"%dx%d", pixelW, pixelH];
    //    self.imagePixel.center = CGPointMake(CGRectGetMidX(self.gridView.gridRect), CGRectGetMidY(self.gridView.gridRect));
}

@end
