//
//  VPUPAssetModel.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPAssetModel.h"
#import "VPUPImagePickerManager.h"

@implementation VPUPAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(VPUPAssetModelMediaType)type{
    VPUPAssetModel *model = [[VPUPAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(VPUPAssetModelMediaType)type timeLength:(NSString *)timeLength {
    VPUPAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end



@implementation VPUPAlbumModel

- (void)setResult:(PHFetchResult<PHAsset*> *)result {
    _result = result;
    BOOL allowPickingImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"VPUP_allowPickingImage"] isEqualToString:@"1"];
    BOOL allowPickingVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"VPUP_allowPickingVideo"] isEqualToString:@"1"];
    [[VPUPImagePickerManager manager] getAssetsFromFetchResult:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<VPUPAssetModel *> *models) {
        _models = models;
        if (_selectedModels) {
            [self checkSelectedModels];
        }
    }];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (VPUPAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (VPUPAssetModel *model in _models) {
        if ([[VPUPImagePickerManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
            self.selectedCount ++;
        }
    }
}

- (NSString *)name {
    if (_name) {
        return _name;
    }
    return @"";
}

@end
