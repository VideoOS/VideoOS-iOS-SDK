//
//  VPUPImagePickerController.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPImagePickerController.h"
#import "VPUPPhotoPickerController.h"
//#import "VPUPPhotoPreviewController.h"
#import "VPUPAssetModel.h"
#import "VPUPAssetCell.h"
#import "VPUPImagePickerManager.h"
#import "math.h"
#import <sys/utsname.h>

@interface VPUPImagePickerController () {
    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingBtn;
    BOOL _pushPhotoPickerVc;
    BOOL _didPushPhotoPickerVc;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    
    UIStatusBarStyle _originStatusBarStyle;
}
/// Default is 4, Use in photos collectionView in VPUPPhotoPickerController
/// 默认4列, VPUPPhotoPickerController中的照片collectionView
@property (nonatomic, assign) NSInteger columnNumber;

@end

@implementation VPUPImagePickerController

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithMaxImagesCount:9 delegate:nil];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.needShowStatusBar = ![UIApplication sharedApplication].statusBarHidden;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [VPUPImagePickerManager manager].shouldFixOrientation = NO;
    
    // Default appearance, you can reset these after this method
    // 默认的外观，你可以在这个方法后重置
    self.oKButtonTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
    self.navigationBar.barTintColor = [UIColor colorWithRed:(49/255.0) green:(152/255.0) blue:(273/255.0) alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    if (self.needShowStatusBar) {
//        [UIApplication sharedApplication].statusBarHidden = NO;
//    }
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)setNaviBgColor:(UIColor *)naviBgColor {
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor {
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
}

- (void)setNaviTitleFont:(UIFont *)naviTitleFont {
    _naviTitleFont = naviTitleFont;
    [self configNaviTitleAppearance];
}

- (void)configNaviTitleAppearance {
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    if (self.naviTitleColor) {
        textAttrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    }
    if (self.naviTitleFont) {
        textAttrs[NSFontAttributeName] = self.naviTitleFont;
    }
    self.navigationBar.titleTextAttributes = textAttrs;
}

- (void)setBarItemTextFont:(UIFont *)barItemTextFont {
    _barItemTextFont = barItemTextFont;
    [self configBarButtonItemAppearance];
}

- (void)setBarItemTextColor:(UIColor *)barItemTextColor {
    _barItemTextColor = barItemTextColor;
    [self configBarButtonItemAppearance];
}

- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[VPUPImagePickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[VPUPImagePickerController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
    textAttrs[NSFontAttributeName] = self.barItemTextFont;
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
//    if (self.isStatusBarDefault) {
//        [UIApplication sharedApplication].statusBarStyle = iOS7Later ? UIStatusBarStyleDefault : UIStatusBarStyleBlackOpaque;
//    } else {
//        [UIApplication sharedApplication].statusBarStyle = iOS7Later ? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque;
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
    [self hideProgressHUD];
}

- (BOOL)shouldAutorotate
{
    return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.visibleViewController supportedInterfaceOrientations];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<VPUPImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<VPUPImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<VPUPImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc {
    _pushPhotoPickerVc = pushPhotoPickerVc;
    VPUPAlbumPickerController *albumPickerVc = [[VPUPAlbumPickerController alloc] init];
    [albumPickerVc hideBackBarButtonItemTitle];
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        
        // Allow user picking original photo, you also can set No after this method
        // 默认准许用户选择原图, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = NO;
        self.allowPickingImage = YES;
        self.allowPickingGif = NO;
        self.allowTakePicture = NO;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        [self configDefaultSetting];
        
        if (![[VPUPImagePickerManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.frame.size.width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
            if (!infoDict) {
                infoDict = [NSBundle mainBundle].infoDictionary;
            }
            NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [infoDict valueForKey:@"CFBundleName"];
            }
            NSString *tipText = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-照片\"选项中，\r允许%@访问你的手机相册",appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.frame.size.width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
        } else {
            [self pushPhotoPickerVc];
        }
    }
    return self;
}

/// This init method just for previewing photos / 用这个初始化方法以预览图片
//- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index{
//    VPUPPhotoPreviewController *previewVc = [[VPUPPhotoPreviewController alloc] init];
//    self = [super initWithRootViewController:previewVc];
//    if (self) {
//        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
//        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
//        [self configDefaultSetting];
//        
//        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
//        previewVc.currentIndex = index;
//        __weak typeof(self) weakSelf = self;
//        [previewVc setDoneButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            [strongSelf dismissViewControllerAnimated:YES completion:^{
//                if (!strongSelf) return;
//                if (strongSelf.didFinishPickingPhotosHandle) {
//                    strongSelf.didFinishPickingPhotosHandle(photos,assets,isSelectOriginalPhoto);
//                }
//            }];
//        }];
//    }
//    return self;
//}
//
///// This init method for crop photo / 用这个初始化方法以裁剪图片
//- (instancetype)initCropTypeWithAsset:(id)asset photo:(UIImage *)photo completion:(void (^)(UIImage *cropImage,id asset))completion {
//    VPUPPhotoPreviewController *previewVc = [[VPUPPhotoPreviewController alloc] init];
//    self = [super initWithRootViewController:previewVc];
//    if (self) {
//        self.maxImagesCount = 1;
//        self.allowCrop = YES;
//        self.selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
//        [self configDefaultSetting];
//        
//        previewVc.photos = [NSMutableArray arrayWithArray:@[photo]];
//        previewVc.isCropImage = YES;
//        previewVc.currentIndex = 0;
//        __weak typeof(self) weakSelf = self;
//        [previewVc setDoneButtonClickBlockCropMode:^(UIImage *cropImage, id asset) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            [strongSelf dismissViewControllerAnimated:YES completion:^{
//                if (completion) {
//                    completion(cropImage,asset);
//                }
//            }];
//        }];
//    }
//    return self;
//}

- (void)configDefaultSetting {
    self.timeout = 15;
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600;
    self.naviTitleColor = [UIColor whiteColor];
    self.naviTitleFont = [UIFont systemFontOfSize:17];
    self.barItemTextFont = [UIFont systemFontOfSize:15];
    self.barItemTextColor = [UIColor whiteColor];
    self.allowPreview = YES;
    
    [self configDefaultImageName];
    [self configDefaultBtnTitle];
    
    CGFloat cropViewWH = MIN(self.view.frame.size.width, self.view.frame.size.height) / 3 * 2;
    self.cropRect = CGRectMake((self.view.frame.size.width - cropViewWH) / 2, (self.view.frame.size.height - cropViewWH) / 2, cropViewWH, cropViewWH);
}

- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture";
    self.photoSelImageName = @"photo_sel_photoPickerVc";
    self.photoDefImageName = @"photo_def_photoPickerVc";
    self.photoNumberIconImageName = @"photo_number_icon";
    self.photoPreviewOriginDefImageName = @"preview_original_def";
    self.photoOriginDefImageName = @"photo_original_def";
    self.photoOriginSelImageName = @"photo_original_sel";
}

- (void)configDefaultBtnTitle {
    self.doneBtnTitleStr = @"完成";
    self.cancelBtnTitleStr = @"取消";
    self.previewBtnTitleStr = @"预览";
    self.fullImageBtnTitleStr = @"原图";
    self.settingBtnTitleStr = @"设置";
    self.processHintStr = @"正在处理...";
}

- (void)observeAuthrizationStatusChange {
    if ([[VPUPImagePickerManager manager] authorizationStatusAuthorized]) {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
        [self pushPhotoPickerVc];
    }
}

- (void)pushPhotoPickerVc {
    _didPushPhotoPickerVc = NO;
    //判断是否需要push到照片选择页，如果_pushPhotoPickerVc为NO,则不push
    if (!_didPushPhotoPickerVc && _pushPhotoPickerVc) {
        VPUPPhotoPickerController *photoPickerVc = [[VPUPPhotoPickerController alloc] init];
        photoPickerVc.isFirstAppear = YES;
        photoPickerVc.columnNumber = self.columnNumber;
        [[VPUPImagePickerManager manager] getCameraRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage completion:^(VPUPAlbumModel *model) {
            photoPickerVc.model = model;
            [self pushViewController:photoPickerVc animated:YES];
            _didPushPhotoPickerVc = YES;
        }];
    }
    
    VPUPAlbumPickerController *albumPickerVc = (VPUPAlbumPickerController *)self.visibleViewController;
    if ([albumPickerVc isKindOfClass:[VPUPAlbumPickerController class]]) {
        [albumPickerVc configTableView];
    }
}

- (id)showAlertWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (void)hideAlertView:(id)alertView {
    if ([alertView isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alertC = alertView;
        [alertC dismissViewControllerAnimated:YES completion:nil];
    } else if ([alertView isKindOfClass:[UIAlertView class]]) {
        UIAlertView *alertV = alertView;
        [alertV dismissWithClickedButtonIndex:0 animated:YES];
    }
    alertView = nil;
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = self.processHintStr;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    
    // if over time, dismiss HUD automatic
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideProgressHUD];
    });
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1) {
        _showSelectBtn = YES;
        _allowCrop = NO;
    }
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    // 多选模式下，不允许让showSelectBtn为NO
    if (!showSelectBtn && _maxImagesCount > 1) {
        _showSelectBtn = YES;
    }
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = _maxImagesCount > 1 ? NO : allowCrop;
    if (allowCrop) { // 允许裁剪的时候，不能选原图和GIF
        self.allowPickingOriginalPhoto = NO;
        self.allowPickingGif = NO;
    }
}

- (void)setCircleCropRadius:(NSInteger)circleCropRadius {
    _circleCropRadius = circleCropRadius;
    self.cropRect = CGRectMake(self.view.frame.size.width / 2 - circleCropRadius, self.view.frame.size.height / 2 - _circleCropRadius, _circleCropRadius * 2, _circleCropRadius * 2);
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _cropRectPortrait = cropRect;
    CGFloat widthHeight = cropRect.size.width;
    _cropRectLandscape = CGRectMake((self.view.frame.size.height - widthHeight) / 2, cropRect.origin.x, widthHeight, widthHeight);
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 60) {
        _timeout = 60;
    }
}

- (void)setPickerDelegate:(id<VPUPImagePickerControllerDelegate>)pickerDelegate {
    _pickerDelegate = pickerDelegate;
    [VPUPImagePickerManager manager].pickerDelegate = pickerDelegate;
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
    VPUPAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
    albumPickerVc.columnNumber = _columnNumber;
    [VPUPImagePickerManager manager].columnNumber = _columnNumber;
}

- (void)setMinPhotoWidthSelectable:(NSInteger)minPhotoWidthSelectable {
    _minPhotoWidthSelectable = minPhotoWidthSelectable;
    [VPUPImagePickerManager manager].minPhotoWidthSelectable = minPhotoWidthSelectable;
}

- (void)setMinPhotoHeightSelectable:(NSInteger)minPhotoHeightSelectable {
    _minPhotoHeightSelectable = minPhotoHeightSelectable;
    [VPUPImagePickerManager manager].minPhotoHeightSelectable = minPhotoHeightSelectable;
}

- (void)setHideWhenCanNotSelect:(BOOL)hideWhenCanNotSelect {
    _hideWhenCanNotSelect = hideWhenCanNotSelect;
    [VPUPImagePickerManager manager].hideWhenCanNotSelect = hideWhenCanNotSelect;
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [VPUPImagePickerManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setPhotoWidth:(CGFloat)photoWidth {
    _photoWidth = photoWidth;
    [VPUPImagePickerManager manager].photoWidth = photoWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    for (id asset in selectedAssets) {
        VPUPAssetModel *model = [VPUPAssetModel modelWithAsset:asset type:[[VPUPImagePickerManager manager] getAssetType:asset]];
        model.isSelected = YES;
        [_selectedModels addObject:model];
    }
}

- (void)setAllowPickingImage:(BOOL)allowPickingImage {
    _allowPickingImage = allowPickingImage;
    NSString *allowPickingImageStr = _allowPickingImage ? @"1" : @"0";
    [[NSUserDefaults standardUserDefaults] setObject:allowPickingImageStr forKey:@"VPUP_allowPickingImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;
    NSString *allowPickingVideoStr = _allowPickingVideo ? @"1" : @"0";
    [[NSUserDefaults standardUserDefaults] setObject:allowPickingVideoStr forKey:@"VPUP_allowPickingVideo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate {
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [VPUPImagePickerManager manager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}

- (void)settingBtnClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)dealloc {
    [VPUPImagePickerManager deallocManager];
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

#pragma mark - UIContentContainer

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self willInterfaceOrientionChange];
    if (size.width > size.height) {
        _cropRect = _cropRectLandscape;
    } else {
        _cropRect = _cropRectPortrait;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self willInterfaceOrientionChange];
    if (toInterfaceOrientation >= 3) {
        _cropRect = _cropRectLandscape;
    } else {
        _cropRect = _cropRectPortrait;
    }
}

- (void)willInterfaceOrientionChange {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![UIApplication sharedApplication].statusBarHidden) {
            if (self.needShowStatusBar)
                [UIApplication sharedApplication].statusBarHidden = NO;
        }
    });
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _HUDContainer.frame = CGRectMake((self.view.frame.size.width - 120) / 2, (self.view.frame.size.height - 90) / 2, 120, 90);
    _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
    _HUDLabel.frame = CGRectMake(0,40, 120, 50);
}

#pragma mark - Public

- (void)cancelButtonClick {
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

- (void)callDelegateMethod {
    if (self.imagePickerControllerDidCancelHandle) {
        self.imagePickerControllerDidCancelHandle();
    }
    else if ([self.pickerDelegate respondsToSelector:@selector(vpup_imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate vpup_imagePickerControllerDidCancel:self];
    }
}

#pragma mark - 状态栏
- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.topViewController;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end


@interface VPUPAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *albumArr;
@property (assign, nonatomic) BOOL isFirstAppear;
@end

@implementation VPUPAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstAppear = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
    //隐藏下级viewController显示时的返回title
    [self hideBackBarButtonItemTitle];
}

- (void)hideBackBarButtonItemTitle
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
    [imagePickerVc hideProgressHUD];
    if (imagePickerVc.allowTakePicture) {
        self.navigationItem.title = @"照片";
    } else if (imagePickerVc.allowPickingVideo) {
        self.navigationItem.title = @"视频";
    }
    
    if (self.isFirstAppear && !imagePickerVc.navLeftBarButtonSettingBlock) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.isFirstAppear = NO;
    }
    
    [self configTableView];
}

- (void)configTableView {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
        [[VPUPImagePickerManager manager] getAllAlbums:imagePickerVc.allowPickingVideo allowPickingImage:imagePickerVc.allowPickingImage completion:^(NSArray<VPUPAlbumModel *> *models) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _albumArr = [NSMutableArray arrayWithArray:models];
                for (VPUPAlbumModel *albumModel in _albumArr) {
                    albumModel.selectedModels = imagePickerVc.selectedModels;
                }
                if (!_tableView) {
                    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                    _tableView.rowHeight = 80;
                    _tableView.tableFooterView = [[UIView alloc] init];
                    _tableView.dataSource = self;
                    _tableView.delegate = self;
                    [_tableView registerClass:[VPUPAlbumCell class] forCellReuseIdentifier:@"VPUPAlbumCell"];
                    [self.view addSubview:_tableView];
                } else {
                    [_tableView reloadData];
                }
            });
        }];
    });
}

- (void)dealloc {
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = 0;
    CGFloat tableViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.frame.size.height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden) {
            top += [VPUPCommonTools vpup_statusBarHeight];
        }
        tableViewHeight = self.view.frame.size.height - top;
    } else {
        tableViewHeight = self.view.frame.size.height;
    }
    _tableView.frame = CGRectMake(0, top, self.view.frame.size.width, tableViewHeight);
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VPUPAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VPUPAlbumCell"];
    VPUPImagePickerController *imagePickerVc = (VPUPImagePickerController *)self.navigationController;
    cell.selectedCountButton.backgroundColor = imagePickerVc.oKButtonTitleColorNormal;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VPUPPhotoPickerController *photoPickerVc = [[VPUPPhotoPickerController alloc] init];
    photoPickerVc.columnNumber = self.columnNumber;
    VPUPAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma clang diagnostic pop

@end


@implementation UIImage (MyBundle)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name {
    NSBundle *imageBundle = [NSBundle mainBundle];//[NSBundle VPUP_imagePickerBundle];
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end

@implementation VPUPCommonTools

+ (BOOL)vpup_isIPhoneX {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
        // 模拟器下采用屏幕的高度来判断
        return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
                CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)));
    }
    // iPhone10,6是美版iPhoneX 感谢hegelsu指出：https://github.com/banchichen/VPUPImagePickerController/issues/635
    BOOL isIPhoneX = [platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"];
    return isIPhoneX;
}

+ (CGFloat)vpup_statusBarHeight {
    return [self vpup_isIPhoneX] ? 44 : 20;
}

@end
