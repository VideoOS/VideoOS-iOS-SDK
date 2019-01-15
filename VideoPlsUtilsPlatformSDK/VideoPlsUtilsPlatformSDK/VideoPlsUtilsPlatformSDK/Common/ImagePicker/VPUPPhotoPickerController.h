//
//  VPUPPhotoPickerController.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VPUPAlbumModel;
@interface VPUPPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) VPUPAlbumModel *model;
@end


@interface VPUPCollectionView : UICollectionView

@end
