//
//  DevMainViewController.m
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/9.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "DevMainViewController.h"
#import "RTRootNavigationController.h"
#import <Masonry.h>
#import "SettingViewController.h"
#import "DebuggingViewController.h"
#import "UIButton+DevAppButton.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DevMainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *bottomTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *interactionButton;
@property (weak, nonatomic) IBOutlet UIButton *serviceButton;
@property (assign, nonatomic) DebuggingControllerType DCT;
@property(nonatomic,strong) MBProgressHUD* HUD;

@end

@implementation DevMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bottomTipLabel.text = [NSString stringWithFormat:@"VideoOS开发者工具V%@\n本APP用于调试视联网各种功能",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [self setUpNav];
    [self.interactionButton setGradientLayerForNormal];
    [self.serviceButton setGradientLayerForNormal];
    

    // Do any additional setup after loading the view.
}

-(void)setUpNav{
    self.title = @"";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    UIButton* settingBtn = [UIButton new];
//    [settingBtn setTitle:@"配置" forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"setting_icon"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:settingBtn];
    [settingBtn addTarget:self action:@selector(clickSettingBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    settingBtn.frame = CGRectMake(self.navigationController.navigationBar.bounds.size.width - 88, 0, 44, 44);
//    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.equalTo(self.navigationController.navigationBar);
//        make.right.equalTo(self.navigationController.navigationBar).offset(-8);
//        make.width.equalTo(@80);
//    }];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)clickSettingBtnAction:(UIButton*)btn{
    [self performSegueWithIdentifier:@"SettingSegue" sender:self];
}
- (IBAction)clickInteractionBtn:(UIButton *)sender {
    NSString* appkey = [DevAppTool readUserDataWithKey:KDAAPPKEY];
    NSString* appSecret = [DevAppTool readUserDataWithKey:KDAAPPSECRET];
    if (appkey == nil || appkey.length == 0 || appSecret == nil || appSecret.length == 0) {
        
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.HUD.mode = MBProgressHUDModeText;
        self.HUD.label.text = @"请先填写后台的应用信息再调试";
        [self.HUD hideAnimated:true afterDelay:1.25];
        __weak typeof(self) weakSelf = self;
        self.HUD.completionBlock = ^{
            [weakSelf clickSettingBtnAction:nil];
        };
           
        
        
        
        return;
    }
    
    self.DCT = Type_Interaction;
    [self performSegueWithIdentifier:@"DebuggingSegue" sender:self];
}
- (IBAction)clickServiceBtn:(UIButton *)sender {
    NSString* appkey = [DevAppTool readUserDataWithKey:KDAAPPKEY];
    NSString* appSecret = [DevAppTool readUserDataWithKey:KDAAPPSECRET];
    if (appkey == nil || appkey.length == 0 || appSecret == nil || appSecret.length == 0) {
        
         self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         self.HUD.mode = MBProgressHUDModeText;
         self.HUD.label.text = @"请先填写后台的应用信息再调试";
         [self.HUD hideAnimated:true afterDelay:1.25];
         __weak typeof(self) weakSelf = self;
         self.HUD.completionBlock = ^{
             [weakSelf clickSettingBtnAction:nil];
         };
        
        
        return;
    }
    self.DCT = Type_Service;
    [self performSegueWithIdentifier:@"DebuggingSegue" sender:self];
}

//- (UIBarButtonItem *)rt_customBackItemWithTarget:(id)target action:(SEL)action
//{
//
//}
//支持旋转
- (BOOL)shouldAutorotate {
    return NO;
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait ;
}

//一开始的方向  很重要
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DebuggingSegue"]) {
        DebuggingViewController* cor = segue.destinationViewController;
        cor.controllerType = self.DCT;
    }
}


@end
