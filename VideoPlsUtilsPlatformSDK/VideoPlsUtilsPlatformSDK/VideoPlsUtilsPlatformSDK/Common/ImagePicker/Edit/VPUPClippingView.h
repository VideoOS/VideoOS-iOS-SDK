//
//  VPUPClippingView.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPScrollView.h"

@protocol VPUPClippingViewDelegate;

@interface VPUPClippingView : VPUPScrollView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, weak) id<VPUPClippingViewDelegate> clippingDelegate;
/** 首次缩放后需要记录最小缩放值 */
@property (nonatomic, readonly) CGFloat first_minimumZoomScale;

/** 是否重置中 */
@property (nonatomic, readonly) BOOL isReseting;
/** 是否旋转中 */
@property (nonatomic, readonly) BOOL isRotating;
/** 是否缩放中 */
//@property (nonatomic, readonly) BOOL isZooming;
/** 是否可还原 */
@property (nonatomic, readonly) BOOL canReset;

/** 可编辑范围 */
@property (nonatomic, assign) CGRect editRect;
/** 剪切范围 */
@property (nonatomic, assign) CGRect cropRect;

/** 缩小到指定坐标 */
- (void)zoomOutToRect:(CGRect)toRect;
/** 放大到指定坐标(必须大于当前坐标) */
- (void)zoomInToRect:(CGRect)toRect;
/** 旋转 */
- (void)rotateClockwise:(BOOL)clockwise;
/** 还原 */
- (void)reset;
/** 取消 */
- (void)cancel;

@end

@protocol VPUPClippingViewDelegate <NSObject>

/** 同步缩放视图（调用zoomOutToRect才会触发） */
- (void (^)(CGRect))vpup_clippingViewWillBeginZooming:(VPUPClippingView *)clippingView;
- (void)vpup_clippingViewDidZoom:(VPUPClippingView *)clippingView;
- (void)vpup_clippingViewDidEndZooming:(VPUPClippingView *)clippingView;

/** 移动视图 */
- (void)vpup_clippingViewWillBeginDragging:(VPUPClippingView *)clippingView;
- (void)vpup_clippingViewDidEndDecelerating:(VPUPClippingView *)clippingView;

@end
