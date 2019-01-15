//
//  VPUPAssetModel.h
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, VPUPAssetModelMediaType)
 {
    VPUPAssetModelMediaTypePhoto = 0,
    VPUPAssetModelMediaTypeLivePhoto,
    VPUPAssetModelMediaTypePhotoGif,
    VPUPAssetModelMediaTypeVideo,
    VPUPAssetModelMediaTypeAudio
};

@class PHAsset;

@interface VPUPAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) VPUPAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a asset
/// 用一个PHAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(VPUPAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(VPUPAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end


@class PHFetchResult;
@interface VPUPAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) PHFetchResult<PHAsset*> *result;

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@property (nonatomic, assign) BOOL isCameraRoll;

@end
