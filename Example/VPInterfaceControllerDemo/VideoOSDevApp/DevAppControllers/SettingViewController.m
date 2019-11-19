//
//  SettingViewController.m
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/9.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "SettingViewController.h"
#import "RTRootNavigationController.h"
#import <Masonry.h>
#import "UIButton+DevAppButton.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *setupButton;
@property (weak, nonatomic) IBOutlet UITextField *AppKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *AppSecretTextField;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNav];
    self.AppKeyTextField.text = [DevAppTool readUserDataWithKey:KDAAPPKEY];
    self.AppSecretTextField.text = [DevAppTool readUserDataWithKey:KDAAPPSECRET];
    // Do any additional setup after loading the view.
}
-(void)viewDidLayoutSubviews{
    [self.setupButton setGradientLayerForNormal];
}

- (IBAction)clickSetupButton:(UIButton *)sender {
    [self.AppKeyTextField resignFirstResponder];
    [self.AppSecretTextField resignFirstResponder];
    NSString* appkey = [self.AppKeyTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* appSecret = [self.AppSecretTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (appkey.length > 0 && appSecret.length == 16) {
        [DevAppTool writeUserDataWithKey:appkey forKey:KDAAPPKEY];
        [DevAppTool writeUserDataWithKey:appSecret forKey:KDAAPPSECRET];
        [self.rt_navigationController popViewControllerAnimated:true];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确格式的AppKey和AppSecret" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)setUpNav{
    self.title = @"配置应用信息";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (UIBarButtonItem *)rt_customBackItemWithTarget:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:target
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}


//支持旋转
- (BOOL)shouldAutorotate {
    return YES;
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait ;
}

//一开始的方向  很重要
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
