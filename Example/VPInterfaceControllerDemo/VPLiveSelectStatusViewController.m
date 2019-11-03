//
//  VPLiveSelectStatusViewController.m
//  VPInterfaceControllerDemo
//
//  Created by peter on 2018/6/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLiveSelectStatusViewController.h"
#import <Masonry/Masonry.h>
#import "VPSinglePlayerViewController.h"
#import "PrivateConfig.h"

@interface VPLiveSelectStatusViewController ()

@end

@implementation VPLiveSelectStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择直播状态";
    self.view.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1];
    
    
    UIButton *presetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    presetButton.titleLabel.font = [UIFont systemFontOfSize:32];
    [presetButton setTitle:@"预设置" forState:UIControlStateNormal];
    [presetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    presetButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:presetButton];
    [presetButton addTarget:self action:@selector(presetButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    //阴影
    presetButton.layer.shadowColor = [UIColor blackColor].CGColor;
    presetButton.layer.shadowOpacity = 0.5;
    presetButton.layer.shadowRadius = 1.0f;
    presetButton.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    
    UIButton *portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [portraitButton setTitle:@"竖屏推流" forState:UIControlStateNormal];
    [portraitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    portraitButton.titleLabel.textColor = [UIColor blackColor];
    portraitButton.titleLabel.font = [UIFont systemFontOfSize:32];
    portraitButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:portraitButton];
    [portraitButton addTarget:self action:@selector(portraitButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    //阴影
    portraitButton.layer.shadowColor = [UIColor blackColor].CGColor;
    portraitButton.layer.shadowOpacity = 0.5;
    portraitButton.layer.shadowRadius = 1.0f;
    portraitButton.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    
    UIButton *landscapeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [landscapeButton setTitle:@"横屏推流" forState:UIControlStateNormal];
    [landscapeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    landscapeButton.titleLabel.textColor = [UIColor blackColor];
    landscapeButton.titleLabel.font = [UIFont systemFontOfSize:32];
    landscapeButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:landscapeButton];
    [landscapeButton addTarget:self action:@selector(landscapeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    //阴影
    landscapeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    landscapeButton.layer.shadowOpacity = 0.5;
    landscapeButton.layer.shadowRadius = 1.0f;
    landscapeButton.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    
    [presetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(320);
        make.height.mas_equalTo(80);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).with.offset(self.navigationController.navigationBar.frame.size.height + 64);
    }];
    
    [portraitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(320);
        make.height.mas_equalTo(80);
        make.centerX.equalTo(self.view);
        make.top.equalTo(presetButton.mas_bottom).with.offset(20);
    }];
    
    [landscapeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(320);
        make.height.mas_equalTo(80);
        make.centerX.equalTo(self.view);
        make.top.equalTo(portraitButton.mas_bottom).with.offset(20);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presetButtonDidClicked:(UIButton *)sender {
    
}

- (IBAction)portraitButtonDidClicked:(UIButton *)sender {
    [PrivateConfig shareConfig].verticalFullScreen = YES;
    VPSinglePlayerViewController *playerVC = [[VPSinglePlayerViewController alloc] initWithUrlString:@"http://qa-video.oss-cn-beijing.aliyuncs.com/mp4/mby02.mp4" platformUserID:[PrivateConfig shareConfig].identifier isLive:YES];
    playerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:playerVC animated:YES completion:nil];
}

- (IBAction)landscapeButtonDidClicked:(UIButton *)sender {
    [PrivateConfig shareConfig].verticalFullScreen = NO;
    VPSinglePlayerViewController *playerVC = [[VPSinglePlayerViewController alloc] initWithUrlString:@"http://qa-video.oss-cn-beijing.aliyuncs.com/mp4/mby02.mp4" platformUserID:[PrivateConfig shareConfig].identifier isLive:YES];
    [self presentViewController:playerVC animated:YES completion:nil];
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
