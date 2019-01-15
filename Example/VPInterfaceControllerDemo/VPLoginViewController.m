//
//  VPLoginViewController.m
//  VPInterfaceControllerDemo
//
//  Created by peter on 2018/11/12.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLoginViewController.h"
#import <Masonry/Masonry.h>
#import "PrivateConfig.h"

@interface VPLoginViewController ()

@property (nonatomic, strong) UITextField *userIdTextField;
@property (nonatomic, strong) UITextField *userNameTextField;

@end

@implementation VPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) initView {
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vp_logo"]];
    [self.view addSubview:logo];
    
    UITextField *userIdTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    userIdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:userIdTextField];
    userIdTextField.text = @"120078661";
    userIdTextField.textAlignment = NSTextAlignmentCenter;
    self.userIdTextField = userIdTextField;
    
    UITextField *userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:userNameTextField];
    userNameTextField.text = @"元瑶";
    userNameTextField.textAlignment = NSTextAlignmentCenter;
    self.userNameTextField = userNameTextField;
    
    [logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).with.offset(100);
    }];
    
    [userIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(logo.mas_bottom).with.offset(40);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
    [userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(userIdTextField.mas_bottom).with.offset(20);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(0, 0, 200, 44);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [self.view addSubview:loginBtn];
    [loginBtn addTarget:self action:@selector(loginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setBackgroundColor:[UIColor colorWithRed:81.0/255.0 green:148.0/255.0 blue:241.0/255.0 alpha:1.0]];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(userNameTextField.mas_bottom).with.offset(40);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
}

- (void)loginBtnClicked:(id)pSender {
    
    if (self.userIdTextField.text && self.userIdTextField.text.length > 0) {
        [PrivateConfig shareConfig].userID = self.userIdTextField.text;
        if (self.complete) {
            self.complete();
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户Id不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

@end
