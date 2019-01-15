//
//  VPUPPhotoEditingController.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPUPAssetModel.h"

@protocol VPUPPhotoEditingControllerDelegate;

@interface VPUPPhotoEditingController : UIViewController
/** 设置编辑图片->重新初始化（图片方向必须为正方向） */
@property (nonatomic, strong) UIImage *editImage;

@property (nonatomic, strong) VPUPAssetModel *model;

/** 自定义贴图资源 */
@property (nonatomic, strong) NSString *stickerPath;

/** 代理 */
@property (nonatomic, weak) id<VPUPPhotoEditingControllerDelegate> delegate;

@end

@protocol VPUPPhotoEditingControllerDelegate <NSObject>

- (void)vpup_photoEditingController:(VPUPPhotoEditingController *)photoEditingVC didFinishPhotoEditImagePath:(NSString *)imagePath;

@end
