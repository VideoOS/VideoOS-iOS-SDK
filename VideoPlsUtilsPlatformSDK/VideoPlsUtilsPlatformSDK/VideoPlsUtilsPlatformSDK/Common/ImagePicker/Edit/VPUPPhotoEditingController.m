//
//  VPUPPhotoEditingController.m
//  VPUPImagePickerController
//
//  Created by peter on 23/12/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VPUPPhotoEditingController.h"
#import "VPUPEditingView.h"
#import "VPUPImagePickerManager.h"
#import "VPUPImagePickerController.h"
#import "VPUPPathUtil.h"
#import "VPUPMD5Util.h"

@interface VPUPPhotoEditingController () <VPUPEditingViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>
{
    /** 编辑模式 */
    VPUPEditingView *_EditingView;
}

/** 隐藏控件 */
@property (nonatomic, assign) BOOL isHideNaviBar;
@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation VPUPPhotoEditingController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    }
    return self;
}

- (void)setEditImage:(UIImage *)editImage
{
    _editImage = editImage;
    /** GIF图片仅支持编辑第一帧 */
    if (editImage.images.count) {
        editImage = editImage.images.firstObject;
    }
    _EditingView.image = editImage;
}

- (void)setModel:(VPUPAssetModel *)model
{
    _model = model;
    
    void (^completion)(id data,NSDictionary *info,BOOL isDegraded) = ^(id data,NSDictionary *info,BOOL isDegraded){
        if (!isDegraded)
        {
            if ([data isKindOfClass:[UIImage class]]) {
                self.editImage = (UIImage *)data;
                CGSize size = self.editImage.size;
                NSLog(@"size width : %f height : %f", size.width, size.height);
                dispatch_async(dispatch_get_main_queue(),^{
                    [self configUI];
                });
            }
        }
    };
    
    [[VPUPImagePickerManager manager] getPhotoWithAsset:model.asset photoWidth:[UIScreen mainScreen].bounds.size.width completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    // Do any additional setup after loading the view.
}

- (void)configUI
{
    [self configScrollView];
    VPUPImagePickerController *vpupImagePickerVc = (VPUPImagePickerController *)self.navigationController;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:vpupImagePickerVc.doneBtnTitleStr style:UIBarButtonItemStylePlain target:self action:@selector(finishButtonClick)];
    [_EditingView setIsClipping:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    /** 必须要为YES，开启接受屏幕方向转换，否则会受到其他能横屏的界面影响，无法更正回来 */
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //不支持当前方向旋转
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskPortrait;
    switch (self.orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            mask = UIInterfaceOrientationMaskLandscape;
            break;
        case UIInterfaceOrientationLandscapeRight:
            mask = UIInterfaceOrientationMaskLandscape;
            break;
        default:
            break;
    }
    return mask;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 创建视图
- (void)configScrollView
{
    _EditingView = [[VPUPEditingView alloc] initWithFrame:self.view.bounds];
    _EditingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _EditingView.clippingDelegate = self;
    [self setEditImage:_editImage];
    [self.view addSubview:_EditingView];
}

- (void)finishButtonClick
{
    [_EditingView setIsClipping:NO animated:YES];
    [_EditingView setAspectRatio:nil];
    
    /** 处理编辑图片 */
    __block NSString *imagePath = nil;
    UIImage *image = nil;
    image = [_EditingView createEditImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (image) {
            NSString *path = [VPUPPathUtil pathByPlaceholder:@"upload"];
            NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[VPUPMD5Util md5HashString:[NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSince1970]]];
            imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]];
            [UIImageJPEGRepresentation(image,0.5) writeToFile:imagePath atomically:YES];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(vpup_photoEditingController:didFinishPhotoEditImagePath:)]) {
                [self.delegate vpup_photoEditingController:self didFinishPhotoEditImagePath:imagePath];
            }
        });
    });
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_EditingView]) {
        return YES;
    }
    return NO;
}

#pragma clang diagnostic pop

#pragma mark - LFEditingViewDelegate
/** 剪裁发生变化后 */
- (void)vpup_EditingViewDidEndZooming:(VPUPEditingView *)EditingView
{
    
}
/** 剪裁目标移动后 */
- (void)vpup_EditingViewEndDecelerating:(VPUPEditingView *)EditingView
{
    
}

@end
