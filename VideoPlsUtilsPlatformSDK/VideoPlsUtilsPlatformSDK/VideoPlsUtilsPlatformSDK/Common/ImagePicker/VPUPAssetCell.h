//
//  VPUPAssetCell.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    VPUPAssetCellTypePhoto = 0,
    VPUPAssetCellTypeLivePhoto,
    VPUPAssetCellTypePhotoGif,
    VPUPAssetCellTypeVideo,
    VPUPAssetCellTypeAudio,
} VPUPAssetCellType;

@class VPUPAssetModel;
@interface VPUPAssetCell : UICollectionViewCell

@property (weak, nonatomic) UIButton *selectPhotoButton;
@property (nonatomic, strong) VPUPAssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) VPUPAssetCellType type;
@property (nonatomic, assign) BOOL allowPickingGif;
@property (nonatomic, assign) BOOL allowPickingMultipleVideo;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) int32_t imageRequestID;

@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;

@property (nonatomic, assign) BOOL showSelectBtn;
@property (assign, nonatomic) BOOL allowPreview;

@end


@class VPUPAlbumModel;

@interface VPUPAlbumCell : UITableViewCell

@property (nonatomic, strong) VPUPAlbumModel *model;
@property (weak, nonatomic) UIButton *selectedCountButton;

@end


@interface VPUPAssetCameraCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end
