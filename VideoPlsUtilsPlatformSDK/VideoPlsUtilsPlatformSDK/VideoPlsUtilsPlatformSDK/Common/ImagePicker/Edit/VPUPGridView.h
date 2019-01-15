//
//  VPUPGridView.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VPUPGridViewAspectRatioType) {
    VPUPGridViewAspectRatioType_None,
    VPUPGridViewAspectRatioType_Original,
    VPUPGridViewAspectRatioType_1x1,
    VPUPGridViewAspectRatioType_3x2,
    VPUPGridViewAspectRatioType_4x3,
    VPUPGridViewAspectRatioType_5x3,
    VPUPGridViewAspectRatioType_15x9,
    VPUPGridViewAspectRatioType_16x9,
    VPUPGridViewAspectRatioType_16x10,
};

@protocol VPUPGridViewDelegate;
@interface VPUPGridView : UIView

@property (nonatomic, assign) CGRect gridRect;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated;
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer animated:(BOOL)animated;
/** 最小尺寸 CGSizeMake(80, 80); */
@property (nonatomic, assign) CGSize controlMinSize;
/** 最大尺寸 CGRectInset(self.bounds, 50, 50) */
@property (nonatomic, assign) CGRect controlMaxRect;
/** 原图尺寸 */
@property (nonatomic, assign) CGSize controlSize;

/** 显示遮罩层（触发拖动条件必须设置为YES）default is YES */
@property (nonatomic, assign) BOOL showMaskLayer;

/** 设置固定比例 */
@property (nonatomic, assign) VPUPGridViewAspectRatioType aspectRatio;

@property (nonatomic, weak) id<VPUPGridViewDelegate> delegate;

/** 长宽比例描述 */
- (NSArray <NSString *>*)aspectRatioDescs:(BOOL)horizontally;

@end

@protocol VPUPGridViewDelegate <NSObject>

- (void)vpup_gridViewDidBeginResizing:(VPUPGridView *)gridView;
- (void)vpup_gridViewDidResizing:(VPUPGridView *)gridView;
- (void)vpup_gridViewDidEndResizing:(VPUPGridView *)gridView;

/** 调整长宽比例 */
- (void)vpup_gridViewDidAspectRatio:(VPUPGridView *)gridView;

@end
