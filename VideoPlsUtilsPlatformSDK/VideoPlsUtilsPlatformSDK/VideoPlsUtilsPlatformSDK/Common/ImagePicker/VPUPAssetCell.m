//
//  VPUPAssetCell.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPAssetCell.h"
#import "VPUPAssetModel.h"
#import "VPUPImagePickerManager.h"
#import "VPUPImagePickerController.h"
//#import "VPUPProgressView.h"


const static NSString *blackRightArrowString = @"iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAAAXNSR0IArs4c6QAAAAlwSFlzAAAhOAAAITgBRZYxYAAAABxpRE9UAAAAAgAAAAAAAAAYAAAAKAAAABgAAAAYAAABROVu6RQAAAEQSURBVGgFYmAYBaMhQN8QMDU1lTQ2Nt4CxF9NTEyOmpmZadHXBRTaBnT0BqDj/yPhN0AxPQqNpZ92UMgjOR7mkaHjCWBon8LiAZBHXg6J5AT0gCmOWAB54tmQ8ATQoY4EPKFCv0RNpk3A0sh1uHviETA5Df6YAOYJb2BM/AZiWImETD8CxpQ8mZFMP20EPHFvSHgCGAOBeGIC5AlJ+gUpmTYR8MStIeEJYHKKxBMT14eFJ8zNzUXJjGT6aYPGBHKJhMy+PlQ8EQ9MTsgOR2ZfGBKeAHogech7Apic0vB5wtraWpB+iZtMm4CeyMLlCaDcqSHhCaAHcvF5wsLCgpfM8KGfNqAHinF5Aig+l1SXAAAAAP//+F1D7gAAAS9JREFU7ZehDsIwEIaHIAiCQCB4jq3ZkiVzzPAQEyQIEtQ0chI7xzsgcBgMBoWbRyN4g/I36QxZyxVx2xKWLEva2913Xy9L5nktXEEQFL7vy4b71QKOW0khxBzgVQO8aqhyy8YcHYbhzAIvcTJLZiR6OQJ8Rs/GHKnh74axUea7Cx/H8RTgRnjsrZh90st9g4f5NT0bc6SCB+DNMjYbZiR6uSiKJjZ4NLWlZ2OO1PBXk3ms58xI9HJJkoxhvr/wsHsxmUdjO7oK5khlvrfwaZqOAH/upXkCfME8DPRyGv5kMd9p+CHAjfDY29NVMEfC/BBflKPJfKfhlSsFaIEvmX26lwP809BA9+H1CTwaGjhIKQfuOlp4A/OffTRQ9ga+9oUmBJrI8YO+qNf+zx8NvAGiigxu27BEaQAAAABJRU5ErkJggg==";

@interface VPUPAssetCell ()
@property (weak, nonatomic) UIImageView *imageView;       // The photo / 照片
@property (weak, nonatomic) UIImageView *selectImageView;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UILabel *timeLength;

@property (nonatomic, weak) UIImageView *videoImgView;
//@property (nonatomic, strong) VPUPProgressView *progressView;
@property (nonatomic, assign) int32_t bigImageRequestID;
@end

@implementation VPUPAssetCell

- (void)setModel:(VPUPAssetModel *)model {
    _model = model;
    self.representedAssetIdentifier = [[VPUPImagePickerManager manager] getAssetIdentifier:model.asset];
    
    int32_t imageRequestID = [[VPUPImagePickerManager manager] getPhotoWithAsset:model.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//        if (_progressView) {
//            self.progressView.hidden = YES;
//            self.imageView.alpha = 1.0;
//        }
        // Set the cell's thumbnail image if it's still showing the same asset.
        if ([self.representedAssetIdentifier isEqualToString:[[VPUPImagePickerManager manager] getAssetIdentifier:model.asset]]) {
            self.imageView.image = photo;
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
    self.type = (NSInteger)model.type;
    // 让宽度/高度小于 最小可选照片尺寸 的图片不能选中
    if (![[VPUPImagePickerManager manager] isPhotoSelectableWithAsset:model.asset]) {
        if (_selectImageView.hidden == NO) {
            self.selectPhotoButton.hidden = YES;
            _selectImageView.hidden = YES;
        }
    }
    // 如果用户选中了该图片，提前获取一下大图
    if (model.isSelected) {
        [self fetchBigImage];
    }
    [self setNeedsLayout];
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    if (!self.selectPhotoButton.hidden) {
        self.selectPhotoButton.hidden = !showSelectBtn;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = !showSelectBtn;
    }
}

- (void)setType:(VPUPAssetCellType)type {
    _type = type;
    if (type == VPUPAssetCellTypePhoto || type == VPUPAssetCellTypeLivePhoto || (type == VPUPAssetCellTypePhotoGif && !self.allowPickingGif) || self.allowPickingMultipleVideo) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else { // Video of Gif
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
    }
    
    if (type == VPUPAssetCellTypeVideo) {
        self.bottomView.hidden = NO;
        self.timeLength.text = _model.timeLength;
        self.videoImgView.hidden = NO;
        CGRect tempFrame = _timeLength.frame;
        tempFrame.origin.x = self.videoImgView.frame.origin.x + self.videoImgView.frame.size.width;
        _timeLength.frame = tempFrame;
        _timeLength.textAlignment = NSTextAlignmentRight;
    } else if (type == VPUPAssetCellTypePhotoGif && self.allowPickingGif) {
        self.bottomView.hidden = NO;
        self.timeLength.text = @"GIF";
        self.videoImgView.hidden = YES;
        CGRect tempFrame = _timeLength.frame;
        tempFrame.origin.x = 5;
        _timeLength.frame = tempFrame;
        _timeLength.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
    if (sender.isSelected) {
//        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:VPUPOscillatoryAnimationToBigger];
        // 用户选中了该图片，提前获取一下大图
        [self fetchBigImage];
    } else { // 取消选中，取消大图的获取
        if (_bigImageRequestID) {
            [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
            [self hideProgressView];
        }
    }
}

- (void)hideProgressView {
//    self.progressView.hidden = YES;
    self.imageView.alpha = 1.0;
}

- (void)fetchBigImage {
    _bigImageRequestID = [[VPUPImagePickerManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (_model.isSelected) {
            
        } else {
            *stop = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } networkAccessAllowed:YES];
}

#pragma mark - Lazy load
//现在除了imageView，其他不会用到，返回nil
- (UIButton *)selectPhotoButton {
    return nil;
    if (_selectImageView == nil) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectPhotoButton];
        _selectPhotoButton = selectPhotoButton;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    return nil;
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    return nil;
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        static NSInteger rgb = 0;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)videoImgView {
    return nil;
    if (_videoImgView == nil) {
        UIImageView *videoImgView = [[UIImageView alloc] init];
        [videoImgView setImage:[UIImage imageNamedFromMyBundle:@"VideoSendIcon"]];
        [self.bottomView addSubview:videoImgView];
        _videoImgView = videoImgView;
    }
    return _videoImgView;
}

- (UILabel *)timeLength {
    return nil;
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

//- (VPUPProgressView *)progressView {
//    if (_progressView == nil) {
//        _progressView = [[VPUPProgressView alloc] init];
//        _progressView.hidden = YES;
//        [self addSubview:_progressView];
//    }
//    return _progressView;
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.allowPreview) {
        _selectPhotoButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
    } else {
        _selectPhotoButton.frame = self.bounds;
    }
    _selectImageView.frame = CGRectMake(self.frame.size.width - 27, 0, 27, 27);
    _imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
//    static CGFloat progressWH = 20;
//    CGFloat progressXY = (self.frame.size.width - progressWH) / 2;
//    _progressView.frame = CGRectMake(progressXY, progressXY, progressWH, progressWH);
    
    _bottomView.frame = CGRectMake(0, self.frame.size.height - 17, self.frame.size.width, 17);
    _videoImgView.frame = CGRectMake(8, 0, 17, 17);
    _timeLength.frame = CGRectMake(self.videoImgView.frame.origin.x + self.videoImgView.frame.size.width, 0, self.frame.size.width - self.videoImgView.frame.origin.x - self.videoImgView.frame.size.width - 5, 17);
    
    self.type = (NSInteger)self.model.type;
    self.showSelectBtn = self.showSelectBtn;
}

@end

const float VPUPAlbumCellHeight = 80.0;
const float VPUPAlbumCellLabelSpace = 15.0;

@interface VPUPAlbumCell ()

@property (weak, nonatomic) UIImageView *posterImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *countLabel;

@end

@implementation VPUPAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSData *blackRightArrowData = [[NSData alloc] initWithBase64EncodedString:blackRightArrowString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:blackRightArrowData scale:3.0f];
    self.accessoryView = [[UIImageView alloc] initWithImage:image];
    
    return self;
}

- (void)setModel:(VPUPAlbumModel *)model {
    _model = model;
    
    self.titleLabel.text = _model.name;
    self.countLabel.text = [NSString stringWithFormat:@"%ld张",_model.count];

    [[VPUPImagePickerManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _selectedCountButton.frame = CGRectMake(self.frame.size.width - 24 - 30, 23, 24, 24);
    self.titleLabel.frame = CGRectMake(VPUPAlbumCellHeight + VPUPAlbumCellLabelSpace, 17.5, self.frame.size.width - 80 - VPUPAlbumCellLabelSpace - 50, 20);
    self.countLabel.frame = CGRectMake(VPUPAlbumCellHeight + VPUPAlbumCellLabelSpace, 40, self.frame.size.width - 80 - VPUPAlbumCellLabelSpace - 50, 20);
    self.posterImageView.frame = CGRectMake(0, 0, VPUPAlbumCellHeight, VPUPAlbumCellHeight);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
}

#pragma mark - Lazy load

- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //        titleLabel.frame = CGRectMake(80, 0, self.width - 80 - 50, self.height);
        titleLabel.frame = CGRectMake(VPUPAlbumCellHeight + VPUPAlbumCellLabelSpace, 17.5, self.frame.size.width - 80 - VPUPAlbumCellLabelSpace - 50, 20);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)countLabel {
    if (_countLabel == nil) {
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.font = [UIFont boldSystemFontOfSize:14];
        //        titleLabel.frame = CGRectMake(80, 0, self.width - 80 - 50, self.height);
        countLabel.frame = CGRectMake(VPUPAlbumCellHeight + VPUPAlbumCellLabelSpace, 40, self.frame.size.width - 80 - VPUPAlbumCellLabelSpace - 50, 20);
        countLabel.textColor = [UIColor lightGrayColor];
        countLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:countLabel];
        _countLabel = countLabel;
    }
    return _countLabel;
}

- (UIButton *)selectedCountButton {
    return nil;
    if (_selectedCountButton == nil) {
        UIButton *selectedCountButton = [[UIButton alloc] init];
        selectedCountButton.layer.cornerRadius = 12;
        selectedCountButton.clipsToBounds = YES;
        selectedCountButton.backgroundColor = [UIColor redColor];
        [selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:selectedCountButton];
        _selectedCountButton = selectedCountButton;
    }
    return _selectedCountButton;
}

@end



@implementation VPUPAssetCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

@end
