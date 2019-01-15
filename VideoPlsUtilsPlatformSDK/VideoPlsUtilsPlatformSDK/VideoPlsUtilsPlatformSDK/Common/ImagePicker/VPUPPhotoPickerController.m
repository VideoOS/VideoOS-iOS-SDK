//
//  VPUPPhotoPickerController.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPPhotoPickerController.h"
#import "VPUPImagePickerController.h"
//#import "VPUPPhotoPreviewController.h"
#import "VPUPAssetCell.h"
#import "VPUPAssetModel.h"
#import "VPUPImagePickerManager.h"
//#import "VPUPVideoPlayerController.h"
//#import "VPUPGifPhotoPreviewController.h"
#import "VPUPPhotoEditingController.h"

@interface VPUPPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,VPUPPhotoEditingControllerDelegate> {
    NSMutableArray *_models;
    
    UIView *_bottomToolBar;
    UIButton *_previewButton;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    UIView *_divideLine;
    
    BOOL _shouldScrollToBottom;
    BOOL _showTakePhotoBtn;
    
    CGFloat _offsetItemCount;
}
@property CGRect previousPreheatRect;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) VPUPCollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (strong, nonatomic) CLLocation *location;
@end

static CGSize AssetGridThumbnailSize;
static CGFloat itemMargin = 1;

@implementation VPUPPhotoPickerController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        
        UIBarButtonItem *VPUPBarItem, *BarItem;
        if (iOS9Later) {
            VPUPBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[VPUPImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            VPUPBarItem = [UIBarButtonItem appearanceWhenContainedIn:[VPUPImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [VPUPBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    _isSelectOriginalPhoto = vpupImagePickerVc.isSelectOriginalPhoto;
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:vpupImagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:vpupImagePickerVc action:@selector(cancelButtonClick)];
//    if (vpupImagePickerVc.navLeftBarButtonSettingBlock) {
//        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        leftButton.frame = CGRectMake(0, 0, 44, 44);
//        [leftButton addTarget:self action:@selector(navLeftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
//        vpupImagePickerVc.navLeftBarButtonSettingBlock(leftButton);
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//    }
    //隐藏下级viewController显示时的返回title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    _showTakePhotoBtn = (_model.isCameraRoll && vpupImagePickerVc.allowTakePicture);
    // [self resetCachedAssets];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)fetchAssetModels {
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    if (_isFirstAppear) {
        [vpupImagePickerVc showProgressHUD];
    }
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        if (!vpupImagePickerVc.sortAscendingByModificationDate && _isFirstAppear) {
            [[VPUPImagePickerManager manager] getCameraRollAlbum:vpupImagePickerVc.allowPickingVideo allowPickingImage:vpupImagePickerVc.allowPickingImage completion:^(VPUPAlbumModel *model) {
                _model = model;
                _models = [NSMutableArray arrayWithArray:_model.models];
                [self initSubviews];
            }];
        } else {
            if (_showTakePhotoBtn || _isFirstAppear) {
                [[VPUPImagePickerManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:vpupImagePickerVc.allowPickingVideo allowPickingImage:vpupImagePickerVc.allowPickingImage completion:^(NSArray<VPUPAssetModel *> *models) {
                    _models = [NSMutableArray arrayWithArray:models];
                    [self initSubviews];
                }];
            } else {
                _models = [NSMutableArray arrayWithArray:_model.models];
                [self initSubviews];
            }
        }
    });
}

- (void)initSubviews {
    dispatch_async(dispatch_get_main_queue(), ^{
        VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
        [vpupImagePickerVc hideProgressHUD];
        
        [self checkSelectedModels];
        [self configCollectionView];
        _collectionView.hidden = YES;
//        [self configBottomToolBar];
        
        [self scrollCollectionViewToBottom];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    vpupImagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
}

#pragma mark - 状态栏
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)configCollectionView {
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[VPUPCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
    
    if (_showTakePhotoBtn && vpupImagePickerVc.allowTakePicture ) {
        _collectionView.contentSize = CGSizeMake(self.view.frame.size.width, ((_model.count + self.columnNumber) / self.columnNumber) * self.view.frame.size.width);
    } else {
        _collectionView.contentSize = CGSizeMake(self.view.frame.size.width, ((_model.count + self.columnNumber - 1) / self.columnNumber) * self.view.frame.size.width);
    }
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[VPUPAssetCell class] forCellWithReuseIdentifier:@"VPUPAssetCell"];
    [_collectionView registerClass:[VPUPAssetCameraCell class] forCellWithReuseIdentifier:@"VPUPAssetCameraCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) {
        scale = 1.0;
    }
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    if (!_models) {
        [self fetchAssetModels];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // [self updateCachedAssets];
}

- (void)configBottomToolBar {
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    if (!vpupImagePickerVc.showSelectBtn)
        return;
    
    _bottomToolBar = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat rgb = 253 / 255.0;
    _bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:vpupImagePickerVc.previewBtnTitleStr forState:UIControlStateNormal];
    [_previewButton setTitle:vpupImagePickerVc.previewBtnTitleStr forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = vpupImagePickerVc.selectedModels.count;
    
    if (vpupImagePickerVc.allowPickingOriginalPhoto) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalPhotoButton setTitle:vpupImagePickerVc.fullImageBtnTitleStr forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:vpupImagePickerVc.fullImageBtnTitleStr forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:vpupImagePickerVc.photoOriginDefImageName] forState:UIControlStateNormal];
        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:vpupImagePickerVc.photoOriginSelImageName] forState:UIControlStateSelected];
        _originalPhotoButton.selected = _isSelectOriginalPhoto;
        _originalPhotoButton.enabled = vpupImagePickerVc.selectedModels.count > 0;
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:16];
        _originalPhotoLabel.textColor = [UIColor blackColor];
        if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
    }
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:vpupImagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitle:vpupImagePickerVc.doneBtnTitleStr forState:UIControlStateDisabled];
    [_doneButton setTitleColor:vpupImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitleColor:vpupImagePickerVc.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
    _doneButton.enabled = vpupImagePickerVc.selectedModels.count || vpupImagePickerVc.alwaysEnableDoneBtn;
    
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedFromMyBundle:vpupImagePickerVc.photoNumberIconImageName]];
    _numberImageView.hidden = vpupImagePickerVc.selectedModels.count <= 0;
    _numberImageView.backgroundColor = [UIColor clearColor];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",vpupImagePickerVc.selectedModels.count];
    _numberLabel.hidden = vpupImagePickerVc.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    _divideLine = [[UIView alloc] init];
    CGFloat rgb2 = 222 / 255.0;
    _divideLine.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    
    [_bottomToolBar addSubview:_divideLine];
    [_bottomToolBar addSubview:_previewButton];
    [_bottomToolBar addSubview:_doneButton];
    [_bottomToolBar addSubview:_numberImageView];
    [_bottomToolBar addSubview:_numberLabel];
    [_bottomToolBar addSubview:_originalPhotoButton];
    [self.view addSubview:_bottomToolBar];
    [_originalPhotoButton addSubview:_originalPhotoLabel];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    
    CGFloat top = 0;
    CGFloat collectionViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.frame.size.height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    CGFloat toolBarHeight = 0;//[VPUPCommonTools vpup_isIPhoneX] ? 50 + (83 - 49) : 50;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden) {
            top += [VPUPCommonTools vpup_statusBarHeight];
        }
        collectionViewHeight = vpupImagePickerVc.showSelectBtn ? self.view.frame.size.height - toolBarHeight - top : self.view.frame.size.height - top;
    } else {
        collectionViewHeight = vpupImagePickerVc.showSelectBtn ? self.view.frame.size.height - toolBarHeight : self.view.frame.size.height;
    }
    _collectionView.frame = CGRectMake(0, top, self.view.frame.size.width, collectionViewHeight);
    CGFloat itemWH = (self.view.frame.size.width - (self.columnNumber + 1) * itemMargin) / self.columnNumber;
    _layout.itemSize = CGSizeMake(itemWH, itemWH);
    _layout.minimumInteritemSpacing = itemMargin;
    _layout.minimumLineSpacing = itemMargin;
    [_collectionView setCollectionViewLayout:_layout];
    if (_offsetItemCount > 0) {
        CGFloat offsetY = _offsetItemCount * (_layout.itemSize.height + _layout.minimumLineSpacing);
        [_collectionView setContentOffset:CGPointMake(0, offsetY)];
    }
    
    CGFloat toolBarTop = 0;
    if (!self.navigationController.navigationBar.isHidden) {
        toolBarTop = self.view.frame.size.height - toolBarHeight;
    } else {
        CGFloat navigationHeight = naviBarHeight;
        navigationHeight += [VPUPCommonTools vpup_statusBarHeight];
        toolBarTop = self.view.frame.size.height - toolBarHeight - navigationHeight;
    }
    _bottomToolBar.frame = CGRectMake(0, toolBarTop, self.view.frame.size.width, toolBarHeight);
    CGFloat previewWidth = [vpupImagePickerVc.previewBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 2;
    if (!vpupImagePickerVc.allowPreview) {
        previewWidth = 0.0;
    }
    _previewButton.frame = CGRectMake(10, 3, previewWidth, 44);
    CGRect tempFrame = _previewButton.frame;
    tempFrame.size.width = !vpupImagePickerVc.showSelectBtn ? 0 : previewWidth;
    _previewButton.frame = tempFrame;
    if (vpupImagePickerVc.allowPickingOriginalPhoto) {
        CGFloat fullImageWidth = [vpupImagePickerVc.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        _originalPhotoButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame), 0, fullImageWidth + 56, 50);
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, 50);
    }
    _doneButton.frame = CGRectMake(self.view.frame.size.width - 44 - 12, 3, 44, 44);
    _numberImageView.frame = CGRectMake(self.view.frame.size.width - 56 - 28, 10, 30, 30);
    _numberLabel.frame = _numberImageView.frame;
    _divideLine.frame = CGRectMake(0, 0, self.view.frame.size.width, 1);
    
    [VPUPImagePickerManager manager].columnNumber = [VPUPImagePickerManager manager].columnNumber;
    [self.collectionView reloadData];
}

#pragma mark - Notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.y / (_layout.itemSize.height + _layout.minimumLineSpacing);
}

#pragma mark - Click Event
#pragma makr - Not Use
- (void)navLeftBarButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)previewButtonClick {
//    VPUPPhotoPreviewController *photoPreviewVc = [[VPUPPhotoPreviewController alloc] init];
//    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

- (void)doneButtonClick {
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    //判断是否满足最小必选张数的限制
    if (vpupImagePickerVc.minImagesCount && vpupImagePickerVc.selectedModels.count < vpupImagePickerVc.minImagesCount) {
        NSString *title = [NSString stringWithFormat:@"请至少选择%zd张照片", vpupImagePickerVc.minImagesCount];
        [vpupImagePickerVc showAlertWithTitle:title];
        return;
    }
    
    [vpupImagePickerVc showProgressHUD];
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSInteger i = 0; i < vpupImagePickerVc.selectedModels.count; i++) { [photos addObject:@1];[assets addObject:@1];[infoArr addObject:@1]; }
    
    __block BOOL havenotShowAlert = YES;
    [VPUPImagePickerManager manager].shouldFixOrientation = YES;
    __block id alertView;
    for (NSInteger i = 0; i < vpupImagePickerVc.selectedModels.count; i++) {
        VPUPAssetModel *model = vpupImagePickerVc.selectedModels[i];
        [[VPUPImagePickerManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return;
            if (photo) {
                photo = [self scaleImage:photo toSize:CGSizeMake(vpupImagePickerVc.photoWidth, (int)(vpupImagePickerVc.photoWidth * photo.size.height / photo.size.width))];
                [photos replaceObjectAtIndex:i withObject:photo];
            }
            if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
            [assets replaceObjectAtIndex:i withObject:model.asset];
            
            for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
            
            if (havenotShowAlert) {
                [vpupImagePickerVc hideAlertView:alertView];
//                [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
            }
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            // 如果图片正在从iCloud同步中,提醒用户
            if (progress < 1 && havenotShowAlert && !alertView) {
                [vpupImagePickerVc hideProgressHUD];
                alertView = [vpupImagePickerVc showAlertWithTitle:@"正在从iCloud同步照片"];
                havenotShowAlert = NO;
                return;
            }
            if (progress >= 1) {
                havenotShowAlert = YES;
            }
        } networkAccessAllowed:YES];
    }
    if (vpupImagePickerVc.selectedModels.count <= 0) {
//        [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
    }
}

//- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
//    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
//    [vpupImagePickerVc hideProgressHUD];
//
//    if (vpupImagePickerVc.autoDismiss) {
//        [self.navigationController dismissViewControllerAnimated:YES completion:^{
//            [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
//        }];
//    } else {
//        [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
//    }
//}

//- (void)callDelegateMethodWithPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
//    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
//    if ([vpupImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:)]) {
//        [vpupImagePickerVc.pickerDelegate imagePickerController:vpupImagePickerVc didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto];
//    }
//    if ([vpupImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:)]) {
//        [vpupImagePickerVc.pickerDelegate imagePickerController:vpupImagePickerVc didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto infos:infoArr];
//    }
//    if (vpupImagePickerVc.didFinishPickingPhotosHandle) {
//        vpupImagePickerVc.didFinishPickingPhotosHandle(photos,assets,_isSelectOriginalPhoto);
//    }
//    if (vpupImagePickerVc.didFinishPickingPhotosWithInfosHandle) {
//        vpupImagePickerVc.didFinishPickingPhotosWithInfosHandle(photos,assets,_isSelectOriginalPhoto,infoArr);
//    }
//}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_showTakePhotoBtn) {
        VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
        if (vpupImagePickerVc.allowPickingImage && vpupImagePickerVc.allowTakePicture) {
            return _models.count + 1;
        }
    }
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // the cell lead to take a picture / 去拍照的cell
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    if (((vpupImagePickerVc.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!vpupImagePickerVc.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoBtn) {
        VPUPAssetCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VPUPAssetCameraCell" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamedFromMyBundle:vpupImagePickerVc.takePictureImageName];
        return cell;
    }
    // the cell dipaly photo or video / 展示照片或视频的cell
    VPUPAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VPUPAssetCell" forIndexPath:indexPath];
    cell.allowPickingMultipleVideo = vpupImagePickerVc.allowPickingMultipleVideo;
    cell.photoDefImageName = vpupImagePickerVc.photoDefImageName;
    cell.photoSelImageName = vpupImagePickerVc.photoSelImageName;
    VPUPAssetModel *model;
    if (vpupImagePickerVc.sortAscendingByModificationDate || !_showTakePhotoBtn) {
        model = _models[indexPath.row];
    } else {
        model = _models[indexPath.row - 1];
    }
    cell.allowPickingGif = vpupImagePickerVc.allowPickingGif;
    cell.model = model;
    cell.showSelectBtn = vpupImagePickerVc.showSelectBtn;
    cell.allowPreview = vpupImagePickerVc.allowPreview;
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        __strong typeof(weakCell) strongCell = weakCell;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(weakLayer) strongLayer = weakLayer;
        VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)strongSelf.navigationController;
        // 1. cancel select / 取消选择
        if (isSelected) {
            strongCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:vpupImagePickerVc.selectedModels];
            for (VPUPAssetModel *model_item in selectedModels) {
                if ([[[VPUPImagePickerManager manager] getAssetIdentifier:model.asset] isEqualToString:[[VPUPImagePickerManager manager] getAssetIdentifier:model_item.asset]]) {
                    [vpupImagePickerVc.selectedModels removeObject:model_item];
                    break;
                }
            }
            [strongSelf refreshBottomToolBarStatus];
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            if (vpupImagePickerVc.selectedModels.count < vpupImagePickerVc.maxImagesCount) {
                strongCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [vpupImagePickerVc.selectedModels addObject:model];
                [strongSelf refreshBottomToolBarStatus];
            } else {
                NSString *title = [NSString stringWithFormat:@"你最多只能选择%zd张照片", vpupImagePickerVc.maxImagesCount];
                [vpupImagePickerVc showAlertWithTitle:title];
            }
        }
//        [UIView showOscillatoryAnimationWithLayer:strongLayer type:VPUPOscillatoryAnimationToSmaller];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // take a photo / 去拍照
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    if (((vpupImagePickerVc.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!vpupImagePickerVc.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoBtn)  {
        [self takePhoto]; return;
    }
    // preview phote or video / 预览照片或视频
    NSInteger index = indexPath.row;
    if (!vpupImagePickerVc.sortAscendingByModificationDate && _showTakePhotoBtn) {
        index = indexPath.row - 1;
    }
    VPUPAssetModel *model = _models[index];
    
    if (model.type == VPUPAssetModelMediaTypePhoto || model.type == VPUPAssetModelMediaTypeLivePhoto) {
        VPUPPhotoEditingController *photoEditingVC = [[VPUPPhotoEditingController alloc] init];
        photoEditingVC.model = model;
        photoEditingVC.delegate = self;
        [vpupImagePickerVc pushViewController:photoEditingVC animated:NO];
    }
    
//    if (model.type == VPUPAssetModelMediaTypeVideo && !vpupImagePickerVc.allowPickingMultipleVideo) {
//        if (vpupImagePickerVc.selectedModels.count > 0) {
//            VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
//            [imagePickerVc showAlertWithTitle:@"选择照片时不能选择视频"];
//        } else {
//            VPUPVideoPlayerController *videoPlayerVc = [[VPUPVideoPlayerController alloc] init];
//            videoPlayerVc.model = model;
//            [self.navigationController pushViewController:videoPlayerVc animated:YES];
//        }
//    } else if (model.type == VPUPAssetModelMediaTypePhotoGif && vpupImagePickerVc.allowPickingGif && !vpupImagePickerVc.allowPickingMultipleVideo) {
//        if (vpupImagePickerVc.selectedModels.count > 0) {
//            VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
//            [imagePickerVc showAlertWithTitle:@"选择照片时不能选择GIF"];
//        } else {
//            VPUPGifPhotoPreviewController *gifPreviewVc = [[VPUPGifPhotoPreviewController alloc] init];
//            gifPreviewVc.model = model;
//            [self.navigationController pushViewController:gifPreviewVc animated:YES];
//        }
//    } else {
//        VPUPPhotoPreviewController *photoPreviewVc = [[VPUPPhotoPreviewController alloc] init];
//        photoPreviewVc.currentIndex = index;
//        photoPreviewVc.models = _models;
//        [self pushPhotoPrevireViewController:photoPreviewVc];
//    }
}


#pragma mark - 图片裁剪执行代理
#pragma mark VPUPPhotoEditingControllerDelegate methods
- (void)vpup_photoEditingController:(VPUPPhotoEditingController *)photoEditingVC didFinishPhotoEditImagePath:(NSString *)imagePath
{
    VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (imagePickerVc.autoDismiss) {
            [imagePickerVc dismissViewControllerAnimated:YES completion:^{
                [self callDelegateMethodWithResultImagePath:imagePath];
            }];
        } else {
            [self callDelegateMethodWithResultImagePath:imagePath];
        }
    });
}

- (void)callDelegateMethodWithResultImagePath:(NSString*)imagePath {
    
    VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
    id <VPUPImagePickerControllerDelegate> pickerDelegate = (id <VPUPImagePickerControllerDelegate>)imagePickerVc.pickerDelegate;
    [imagePickerVc hideProgressHUD];
    if (imagePickerVc.didFinishPickingPhotosWithFilePathHandle) {
        imagePickerVc.didFinishPickingPhotosWithFilePathHandle(imagePath);
    } else if ([pickerDelegate respondsToSelector:@selector(vpup_imagePickerController:didFinishPickingPhotosWithFilePath:)]) {
        [pickerDelegate vpup_imagePickerController:imagePickerVc didFinishPickingPhotosWithFilePath:imagePath];
    }
//    if (imagePickerVc.didFinishPickingImagePathResultHandle) {
//        imagePickerVc.didFinishPickingImagePathResultHandle(imagePath);
//    } else if ([pickerDelegate respondsToSelector:@selector(lf_imagePickerController:didFinishPickingImagePathResult:)]) {
//        [pickerDelegate lf_imagePickerController:imagePickerVc didFinishPickingImagePathResult:imagePath];
//    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // [self updateCachedAssets];
}

#pragma mark - Private Method
#pragma mark - Not Use
/// 拍照按钮点击事件
- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)) {
        // 无权限 做一个友好的提示
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) {
            appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        }
        NSString *message = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"中允许%@访问相机",appName];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法使用相机" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self pushImagePickerController];
                });
            }
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)refreshBottomToolBarStatus {
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    
    _previewButton.enabled = vpupImagePickerVc.selectedModels.count > 0;
    _doneButton.enabled = vpupImagePickerVc.selectedModels.count > 0 || vpupImagePickerVc.alwaysEnableDoneBtn;
    
    _numberImageView.hidden = vpupImagePickerVc.selectedModels.count <= 0;
    _numberLabel.hidden = vpupImagePickerVc.selectedModels.count <= 0;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",vpupImagePickerVc.selectedModels.count];
    
    _originalPhotoButton.enabled = vpupImagePickerVc.selectedModels.count > 0;
    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLabel.hidden = (!_originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
}

//- (void)pushPhotoPrevireViewController:(VPUPPhotoPreviewController *)photoPreviewVc {
//    __weak typeof(self) weakSelf = self;
//    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
//    [photoPreviewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
//        [strongSelf.collectionView reloadData];
//        [strongSelf refreshBottomToolBarStatus];
//    }];
//    [photoPreviewVc setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
//        [strongSelf doneButtonClick];
//    }];
//    [photoPreviewVc setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, id asset) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf didGetAllPhotos:@[cropedImage] assets:@[asset] infoArr:nil];
//    }];
//    [self.navigationController pushViewController:photoPreviewVc animated:YES];
//}

- (void)getSelectedPhotoBytes {
    VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
    [[VPUPImagePickerManager manager] getPhotosBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytes) {
        _originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

/// Scale image / 缩放图片
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width < size.width) {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)scrollCollectionViewToBottom {
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    if (_shouldScrollToBottom && _models.count > 0) {
        NSInteger item = 0;
        if (vpupImagePickerVc.sortAscendingByModificationDate) {
            item = _models.count - 1;
            if (_showTakePhotoBtn) {
                VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
                if (vpupImagePickerVc.allowPickingImage && vpupImagePickerVc.allowTakePicture) {
                    item += 1;
                }
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            _shouldScrollToBottom = NO;
            _collectionView.hidden = NO;
        });
    } else {
        _collectionView.hidden = NO;
    }
}

- (void)checkSelectedModels {
    for (VPUPAssetModel *model in _models) {
        model.isSelected = NO;
        NSMutableArray *selectedAssets = [NSMutableArray array];
        VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
        for (VPUPAssetModel *model in vpupImagePickerVc.selectedModels) {
            [selectedAssets addObject:model.asset];
        }
        if ([[VPUPImagePickerManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
            model.isSelected = YES;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
        [imagePickerVc showProgressHUD];
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (photo) {
            [[VPUPImagePickerManager manager] savePhotoWithImage:photo location:self.location completion:^(NSError *error){
                if (!error) {
                    [self reloadPhotoArray];
                }
            }];
            self.location = nil;
        }
    }
}

- (void)reloadPhotoArray {
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    [[VPUPImagePickerManager manager] getCameraRollAlbum:vpupImagePickerVc.allowPickingVideo allowPickingImage:vpupImagePickerVc.allowPickingImage completion:^(VPUPAlbumModel *model) {
        _model = model;
        [[VPUPImagePickerManager manager] getAssetsFromFetchResult:_model.result allowPickingVideo:vpupImagePickerVc.allowPickingVideo allowPickingImage:vpupImagePickerVc.allowPickingImage completion:^(NSArray<VPUPAssetModel *> *models) {
            [vpupImagePickerVc hideProgressHUD];
            
            VPUPAssetModel *assetModel;
            if (vpupImagePickerVc.sortAscendingByModificationDate) {
                assetModel = [models lastObject];
                [_models addObject:assetModel];
            } else {
                assetModel = [models firstObject];
                [_models insertObject:assetModel atIndex:0];
            }
            
            if (vpupImagePickerVc.maxImagesCount <= 1) {
                if (vpupImagePickerVc.allowCrop) {
//                    VPUPPhotoPreviewController *photoPreviewVc = [[VPUPPhotoPreviewController alloc] init];
//                    if (vpupImagePickerVc.sortAscendingByModificationDate) {
//                        photoPreviewVc.currentIndex = _models.count - 1;
//                    } else {
//                        photoPreviewVc.currentIndex = 0;
//                    }
//                    photoPreviewVc.models = _models;
//                    [self pushPhotoPrevireViewController:photoPreviewVc];
                } else {
                    [vpupImagePickerVc.selectedModels addObject:assetModel];
                    [self doneButtonClick];
                }
                return;
            }
            
            if (vpupImagePickerVc.selectedModels.count < vpupImagePickerVc.maxImagesCount) {
                assetModel.isSelected = YES;
                [vpupImagePickerVc.selectedModels addObject:assetModel];
                [self refreshBottomToolBarStatus];
            }
            _collectionView.hidden = YES;
            [_collectionView reloadData];
            
            _shouldScrollToBottom = YES;
            [self scrollCollectionViewToBottom];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [[VPUPImagePickerManager manager].cachingImageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) {
        return;
    }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [[VPUPImagePickerManager manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching
                                                                       targetSize:AssetGridThumbnailSize
                                                                      contentMode:PHImageContentModeAspectFill
                                                                          options:nil];
        [[VPUPImagePickerManager manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching
                                                                      targetSize:AssetGridThumbnailSize
                                                                     contentMode:PHImageContentModeAspectFill
                                                                         options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) {
        return nil;
    }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < _models.count) {
            VPUPAssetModel *model = _models[indexPath.item];
            [assets addObject:model.asset];
        }
    }
    
    return assets;
}

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) {
        return nil;
    }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
#pragma clang diagnostic pop

@end



@implementation VPUPCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
