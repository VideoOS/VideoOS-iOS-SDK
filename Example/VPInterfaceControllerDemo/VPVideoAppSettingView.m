//
//  VPVideoAppSettingView.m
//  VPInterfaceControllerDemo
//
//  Created by peter on 2019/4/22.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPVideoAppSettingView.h"
#import <Masonry/Masonry.h>
#import "PrivateConfig.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "VPConfigListData.h"
#import <AFNetworking/AFNetworking.h>

@interface VPVideoAppSettingView ()<UIGestureRecognizerDelegate, VPTextFieldSelectedDelegate>

@property (nonatomic, strong) NSDictionary *configData;

@end

@implementation VPVideoAppSettingView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithFrame:(CGRect)frame data:(NSDictionary *)configData {
    self = [super initWithFrame:frame];
    if (self) {
        self.configData = configData;
        self.backgroundColor = [UIColor clearColor];
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundView];
        backgroundView.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:0.5];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.mas_bottom);
            make.right.equalTo(self.mas_right);
        }];
        [self initUI];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)initUI {
    
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(20, 40, self.bounds.size.width - 20 * 2, self.bounds.size.height - 40 - 20)];
    panel.backgroundColor = [UIColor whiteColor];
    panel.layer.cornerRadius = 5;
    [self addSubview:panel];
    self.panel = panel;
    
    UILabel *platformIdTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 30)];
    [platformIdTitle setText:@"AppKey"];
    [panel addSubview:platformIdTitle];
    
    VPTextField *appKeyTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 20, 240, 40)];
    appKeyTextField.borderStyle = UITextBorderStyleRoundedRect;
    appKeyTextField.selectedDelegate = self;
    [panel addSubview:appKeyTextField];
    self.appKeyTextField = appKeyTextField;
//    appKeyTextField.dataArray = nil;
    
    UILabel *urlTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 100, 30)];
    [urlTitle setText:@"AppSecret"];
    [panel addSubview:urlTitle];
    
    VPTextField *appSecretTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 140, 240, 40)];
    appSecretTextField.borderStyle = UITextBorderStyleRoundedRect;
    appSecretTextField.selectedDelegate = self;
    [panel addSubview:appSecretTextField];
    self.appSecretTextField = appSecretTextField;
//    appSecretTextField.dataArray = [self.configData objectForKey:@"room_id"];
    
    NSArray *environmentArray = @[@"正式环境", @"预发布环境", @"测试环境", @"开发环境"];
    UISegmentedControl *environmentControl = [[UISegmentedControl alloc] initWithItems:environmentArray];
    [panel addSubview:environmentControl];
    self.environmentControl = environmentControl;
    environmentControl.selectedSegmentIndex = [PrivateConfig shareConfig].environment;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor whiteColor];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
    cancelButton.layer.borderWidth = 1;
    [panel addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(cancelButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setButton setTitle:@"应用设置" forState:UIControlStateNormal];
    setButton.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:156.0/255.0 blue:211.0/255.0 alpha:1];
    setButton.layer.cornerRadius = 5;
    [panel addSubview:setButton];
    self.applyButton = setButton;
    
    float widthSpace = 20.0;
    [panel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(widthSpace);
        make.right.equalTo(self.mas_right).with.offset(-widthSpace);
        make.top.equalTo(self.mas_top).with.offset(40);
        make.bottom.equalTo(setButton.mas_bottom).with.offset(20);
    }];
    
    //platformId
    [platformIdTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(panel.mas_top).with.offset(30);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [appKeyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(platformIdTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(platformIdTitle.mas_centerY);
    }];
    
    //roomId
    [urlTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(platformIdTitle.mas_bottom).with.offset(30);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [appSecretTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(urlTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(urlTitle.mas_centerY);
    }];
    
    //
    [environmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.top.equalTo(urlTitle.mas_bottom).with.offset(30);
        make.height.mas_equalTo(40);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(setButton.mas_width);
        make.height.mas_equalTo(40);
        make.left.equalTo(panel.mas_left).with.offset(20);
        make.right.equalTo(setButton.mas_left).with.offset(-10);
        make.top.equalTo(environmentControl.mas_bottom).with.offset(30);
    }];
    
    [setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(cancelButton.mas_width);
        make.height.mas_equalTo(40);
        make.right.equalTo(panel.mas_right).with.offset(-20);
        make.top.equalTo(environmentControl.mas_bottom).with.offset(30);
    }];
    
//    if ([PrivateConfig shareConfig].creativeName) {
//        self.appKeyTextField.text = [PrivateConfig shareConfig].creativeName;
//        self.appSecretTextField.text = [PrivateConfig shareConfig].identifier;
//    }
//    else {
//        self.appSecretTextField.text = [[self.configData objectForKey:@"room_id"] objectAtIndex:0];
//    }
    
    NSInteger index = [VPConfigListData shared].selectedIndex;
    if (index >= 0) {
        self.appKeyTextField.text = self.appKeyTextField.dataArray[index];
        self.appSecretTextField.text = self.appSecretTextField.dataArray[index];
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard.string) {
        NSArray *appInfo = [pasteboard.string componentsSeparatedByString:@" "];
        if (appInfo && appInfo.count == 2) {
            NSString *string1 = [appInfo objectAtIndex:0];
            NSString *string2 = [appInfo objectAtIndex:1];
            
            if ((string1.length == 36 && string2.length == 12)) {
                self.appKeyTextField.text = string1;
                self.appSecretTextField.text = string2;
                [self showCopyToast];
            }
            else if (string1.length == 12 && string2.length == 36) {
                self.appKeyTextField.text = string2;
                self.appSecretTextField.text = string1;
                [self showCopyToast];
            }
        }
    }
    [self getMockAppData];
}

- (IBAction)cancelButtonDidClicked:(UIButton *)sender {
    [self resignFirstResponder];
    [self removeFromSuperview];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)viewTapped:(id)sender {
    [self resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    //如果点击视图为uitableview 则忽略手势
    if([NSStringFromClass([touch.view class]) isEqual:@"UITableViewCellContentView"]){
        return NO;
    }
    return YES;
}

- (BOOL)resignFirstResponder {
    [self.appKeyTextField resignFirstResponder];
    [self.appSecretTextField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)showCopyToast {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"已填入剪贴板中的密钥";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self animated:YES];
    });
}

- (void)getMockAppData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://mock.videojj.com/mock/5c8224a5380a47002f43f740/asmpapi/videoos_test_demo_appinfo" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"data"] && [[responseObject objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSArray *apps = [[responseObject objectForKey:@"data"] objectForKey:@"apps"];
            if (apps && [apps isKindOfClass:[NSArray class]]) {
                for (NSDictionary *app in apps) {
                    VPConfigData *config = [[VPConfigData alloc] init];
                    config.appKey = [app objectForKey:@"appKey"];
                    config.appSecret = [app objectForKey:@"appSecret"];
                    [[VPConfigListData shared] addConfigData:config];
                }
                self.appKeyTextField.dataArray = [VPConfigListData shared].appKeyArray;
                self.appSecretTextField.dataArray = [VPConfigListData shared].appSecretArray;
                if (self.appKeyTextField.text.length < 1 &&  self.appSecretTextField.text.length < 1) {
                    NSInteger index = [VPConfigListData shared].selectedIndex = 0;
                    if (index >= 0) {
                        self.appKeyTextField.text = self.appKeyTextField.dataArray[index];
                        self.appSecretTextField.text = self.appSecretTextField.dataArray[index];
                    }
                }
            }
            [MBProgressHUD hideHUDForView:self animated:YES];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self animated:YES];
    }];
}


- (void)alertMessage:(NSString *)message {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
//    [alert addAction:action];
//    
//    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)updateButtonTapped:(id)sender {
    if (self.appKeyTextField.text == nil || [self.appKeyTextField.text isEqualToString:@""]) {
        [self alertMessage:@"AppKey不能为空"];
        return;
    }
    if (self.appSecretTextField.text == nil || [self.appSecretTextField.text isEqualToString:@""]) {
        [self alertMessage:@"AppSecret不能为空"];
        return;
    }
    
    VPConfigData *config = [[VPConfigData alloc] init];
    config.appKey = self.appKeyTextField.text;
    config.appSecret = self.appSecretTextField.text;
    
    [[VPConfigListData shared] addConfigData:config];
    
    self.appKeyTextField.dataArray = [VPConfigListData shared].appKeyArray;
    self.appSecretTextField.dataArray = [VPConfigListData shared].appSecretArray;
//    [VPIConfigSDK setAppKey:config.appKey appSecret:config.appSecret];
    
}

- (void)dataArraySelectedIndex:(NSInteger)index target:(id)target {
    [VPConfigListData shared].selectedIndex = index;
    if (target == self.appKeyTextField) {
        self.appSecretTextField.text = self.appSecretTextField.dataArray[index];
    } else {
        self.appKeyTextField.text = self.appKeyTextField.dataArray[index];
    }
}

@end
