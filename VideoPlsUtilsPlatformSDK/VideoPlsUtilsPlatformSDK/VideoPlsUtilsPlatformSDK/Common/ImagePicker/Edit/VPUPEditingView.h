//
//  VPUPEditingView.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPScrollView.h"

@protocol VPUPEditingViewDelegate;

@interface VPUPEditingView : VPUPScrollView

@property (nonatomic, strong) UIImage *image;

/** 代理 */
@property (nonatomic, weak) id<VPUPEditingViewDelegate> clippingDelegate;

/** 最小尺寸 CGSizeMake(80, 80) */
@property (nonatomic, assign) CGSize clippingMinSize;
/** 最大尺寸 CGRectInset(self.frame , 20, 50) */
@property (nonatomic, assign) CGRect clippingMaxRect;

/** 开关编辑模式 */
@property (nonatomic, assign) BOOL isClipping;
- (void)setIsClipping:(BOOL)isClipping animated:(BOOL)animated;

/** 取消剪裁 */
- (void)cancelClipping:(BOOL)animated;
/** 还原 isClipping=YES 的情况有效 */
- (void)reset;
- (BOOL)canReset;
/** 旋转 isClipping=YES 的情况有效 */
- (void)rotate;
/** 长宽比例 */
- (void)setAspectRatio:(NSString *)aspectRatio;

/** 创建编辑图片 */
- (UIImage *)createEditImage;

- (NSArray <NSString *>*)aspectRatioDescs;

@end


@protocol VPUPEditingViewDelegate <NSObject>
/** 剪裁发生变化后 */
- (void)vpup_EditingViewDidEndZooming:(VPUPEditingView *)EditingView;
/** 剪裁目标移动后 */
- (void)vpup_EditingViewEndDecelerating:(VPUPEditingView *)EditingView;
@end
