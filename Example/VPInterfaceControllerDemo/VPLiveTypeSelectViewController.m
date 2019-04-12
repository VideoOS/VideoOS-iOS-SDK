//
//  VPLiveTypeSelectViewController.m
//  VPInterfaceControllerDemo
//
//  Created by peter on 2018/6/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLiveTypeSelectViewController.h"
#import <Masonry/Masonry.h>
#import "VPLiveSelectStatusViewController.h"
#import "PrivateConfig.h"
#import "VPSinglePlayerViewController.h"
#import "VPTextField.h"

#import <VideoOS-iOS-SDK/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>


@interface VPLiveSettingView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *panel;
@property (nonatomic, weak) VPTextField *userIdTextField;
@property (nonatomic, weak) VPTextField *roomIdTextField;
@property (nonatomic, weak) VPTextField *platformIdTextField;
@property (nonatomic, weak) VPTextField *categoryTextField;
@property (nonatomic, weak) UISegmentedControl *environmentControl;
@property (nonatomic, strong) NSDictionary *configData;

@end

@implementation VPLiveSettingView

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
    
    UILabel *settingTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 30)];
    [settingTitle setText:@"配置开关"];
    [panel addSubview:settingTitle];
    
    UISwitch *settingSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(240, 20, 40, 20)];
    [panel addSubview:settingSwitch];
    
    UILabel *userIdTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 100, 30)];
    [userIdTitle setText:@"用户Id"];
    [panel addSubview:userIdTitle];
    
    VPTextField *userIdTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 70, 240, 40)];
    userIdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:userIdTextField];
    self.userIdTextField = userIdTextField;
    userIdTextField.dataArray = [self.configData objectForKey:@"user_id"];
    
    UILabel *roomIdTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 100, 30)];
    [roomIdTitle setText:@"roomId"];
    [panel addSubview:roomIdTitle];
    
    VPTextField *roomIdTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 140, 240, 40)];
    roomIdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:roomIdTextField];
    self.roomIdTextField = roomIdTextField;
    roomIdTextField.dataArray = [self.configData objectForKey:@"room_id"];
    
    UILabel *platformIdTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 210, 100, 30)];
    [platformIdTitle setText:@"素材名称"];
    [panel addSubview:platformIdTitle];
    
    VPTextField *platformIdTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 210, 240, 40)];
    platformIdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:platformIdTextField];
    self.platformIdTextField = platformIdTextField;
    platformIdTextField.dataArray = nil;
    
    UILabel *categoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 280, 100, 30)];
    [categoryTitle setText:@"分区"];
    [panel addSubview:categoryTitle];
    
    VPTextField *categoryTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 280, 240, 40)];
    categoryTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:categoryTextField];
    self.categoryTextField = categoryTextField;
    categoryTextField.dataArray = [self.configData objectForKey:@"cate"];
    
    NSArray *environmentArray = @[@"正式环境", @"预发布环境", @"测试环境", @"开发环境"];
    UISegmentedControl *environmentControl = [[UISegmentedControl alloc] initWithItems:environmentArray];
    [panel addSubview:environmentControl];
    self.environmentControl = environmentControl;
    environmentControl.selectedSegmentIndex = 2;
    
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
    [setButton addTarget:self action:@selector(setButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    float widthSpace = 20.0;
    [panel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(widthSpace);
        make.right.equalTo(self.mas_right).with.offset(-widthSpace);
        make.top.equalTo(self.mas_top).with.offset(40);
        make.bottom.equalTo(setButton.mas_bottom).with.offset(20);
    }];
    
    //
    [settingTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(panel.mas_top).with.offset(20);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(30);
    }];
    
    [settingSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-30);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(settingTitle.mas_centerY);
    }];
    
    //用户Id
    [userIdTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(settingTitle.mas_bottom).with.offset(20);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [userIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(userIdTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(userIdTitle.mas_centerY);
    }];
    
    //roomId
    [roomIdTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(userIdTitle.mas_bottom).with.offset(30);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [roomIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(roomIdTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(roomIdTitle.mas_centerY);
    }];
    
    //platformId
    [platformIdTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(roomIdTitle.mas_bottom).with.offset(30);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [platformIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(platformIdTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(platformIdTitle.mas_centerY);
    }];
    
    //分区
    [categoryTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(platformIdTitle.mas_bottom).with.offset(30);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [categoryTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(categoryTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(categoryTitle.mas_centerY);
    }];
    
    //
    [environmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.top.equalTo(categoryTitle.mas_bottom).with.offset(30);
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
    
    if (self.configData) {
        //用户Id
        if ([PrivateConfig shareConfig].userID) {
            self.userIdTextField.text = [PrivateConfig shareConfig].userID;
        }
        else {
            self.userIdTextField.text = [[self.configData objectForKey:@"user_id"] objectAtIndex:0];
        }
        //room id
        if ([PrivateConfig shareConfig].identifier) {
            self.roomIdTextField.text = [PrivateConfig shareConfig].identifier;
        }
        else {
            self.roomIdTextField.text = [[self.configData objectForKey:@"room_id"] objectAtIndex:0];
        }
        //素材
        if ([PrivateConfig shareConfig].creativeName) {
            self.platformIdTextField.text = [PrivateConfig shareConfig].creativeName;
        }
        //分区
        if ([PrivateConfig shareConfig].cate) {
            self.categoryTextField.text = [PrivateConfig shareConfig].cate;
        }
        else {
            self.categoryTextField.text = [[self.configData objectForKey:@"cate"] objectAtIndex:0];
        }
    }
    else {
        self.userIdTextField.text = [PrivateConfig shareConfig].userID;
        self.roomIdTextField.text = [PrivateConfig shareConfig].identifier;
        self.platformIdTextField.text = [PrivateConfig shareConfig].creativeName;
        self.categoryTextField.text = [PrivateConfig shareConfig].cate;
    }
}

- (IBAction)cancelButtonDidClicked:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)setButtonDidClicked:(UIButton *)sender {
    [PrivateConfig shareConfig].userID = self.userIdTextField.text;
    [PrivateConfig shareConfig].identifier = self.roomIdTextField.text;
    [PrivateConfig shareConfig].creativeName = self.platformIdTextField.text;
    [PrivateConfig shareConfig].cate = self.categoryTextField.text;
    [PrivateConfig shareConfig].cytron = NO;
    [PrivateConfig shareConfig].live = YES;
    [PrivateConfig shareConfig].enjoy = YES;
    [PrivateConfig shareConfig].environment = self.environmentControl.selectedSegmentIndex;
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:[PrivateConfig shareConfig].environment];
    [self removeFromSuperview];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)viewTapped:(id)sender {
    [self.userIdTextField resignFirstResponder];
    [self.roomIdTextField resignFirstResponder];
    [self.platformIdTextField resignFirstResponder];
    [self.categoryTextField resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    //如果点击视图为uitableview 则忽略手势
    if([NSStringFromClass([touch.view class]) isEqual:@"UITableViewCellContentView"]){
        return NO;
    }
    return YES;
}

@end


@interface VPLiveTypeSelectViewController ()

@property (nonatomic, weak) UIButton *mallButton;
@property (nonatomic, weak) UIButton *liveButton;

@end

@implementation VPLiveTypeSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择直播属性";
    self.view.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1];
    
    
    UIButton *anchorButton = [UIButton buttonWithType:UIButtonTypeSystem];
    anchorButton.titleLabel.textColor = [UIColor blackColor];
    anchorButton.titleLabel.font = [UIFont systemFontOfSize:32];
    [anchorButton setTitle:@"主播" forState:UIControlStateNormal];
    [anchorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    anchorButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:anchorButton];
    [anchorButton addTarget:self action:@selector(anchorButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    //阴影
    anchorButton.layer.shadowColor = [UIColor blackColor].CGColor;
    anchorButton.layer.shadowOpacity = 0.5;
    anchorButton.layer.shadowRadius = 1.0f;
    anchorButton.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    
    
    UIButton *audienceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [audienceButton setTitle:@"观众" forState:UIControlStateNormal];
    [audienceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    audienceButton.titleLabel.textColor = [UIColor blackColor];
    audienceButton.titleLabel.font = [UIFont systemFontOfSize:32];
    audienceButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:audienceButton];
    [audienceButton addTarget:self action:@selector(audienceButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    //阴影
    audienceButton.layer.shadowColor = [UIColor blackColor].CGColor;
    audienceButton.layer.shadowOpacity = 0.5;
    audienceButton.layer.shadowRadius = 1.0f;
    audienceButton.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setButton setImage:[UIImage imageNamed:@"button_set"] forState:UIControlStateNormal];
    [self.view addSubview:setButton];
    [setButton addTarget:self action:@selector(setButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *whiteImage = [UIImage imageNamed:@"button_white"];
    UIButton *mallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mallButton setImage:whiteImage forState:UIControlStateNormal];
    [self.view addSubview:mallButton];
    [mallButton addTarget:self action:@selector(mallButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mallButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [mallButton setTitle:@"电商" forState:UIControlStateNormal];
    mallButton.titleEdgeInsets = UIEdgeInsetsMake(0, -whiteImage.size.width, 0, 0);
    self.mallButton = mallButton;
    
    UIButton *liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [liveButton setImage:whiteImage forState:UIControlStateNormal];
    [liveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [liveButton setTitle:@"live" forState:UIControlStateNormal];
    liveButton.titleEdgeInsets = UIEdgeInsetsMake(0, -whiteImage.size.width, 0, 0);
    [self.view addSubview:liveButton];
    [liveButton addTarget:self action:@selector(liveButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.liveButton = liveButton;
    
    [anchorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(320);
        make.height.mas_equalTo(80);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).with.offset(self.navigationController.navigationBar.frame.size.height + 64);
    }];
    
    [audienceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(320);
        make.height.mas_equalTo(80);
        make.centerX.equalTo(self.view);
        make.top.equalTo(anchorButton.mas_bottom).with.offset(20);
    }];
    
    [setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [liveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(whiteImage.size.width);
        make.height.mas_equalTo(whiteImage.size.height);
        make.centerX.equalTo(setButton.mas_centerX);
        make.bottom.equalTo(setButton.mas_top).with.offset(10);
    }];
    
    [mallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(whiteImage.size.width);
        make.height.mas_equalTo(whiteImage.size.height);
        make.centerX.equalTo(setButton.mas_centerX);
        make.bottom.equalTo(liveButton.mas_top).with.offset(-10);
    }];
    liveButton.hidden = YES;
    mallButton.hidden = YES;
    
    [PrivateConfig shareConfig].platformID = @"556c38e7ec69d5bf655a0fb2";
    [PrivateConfig shareConfig].identifier = @"40";
    [PrivateConfig shareConfig].userID = @"120078661";
    [PrivateConfig shareConfig].cate = @"全部";
    [PrivateConfig shareConfig].live = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)anchorButtonDidClicked:(UIButton *)sender {
    [PrivateConfig shareConfig].anchor = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    VPLiveSelectStatusViewController *selectViewController = [[VPLiveSelectStatusViewController alloc] init];
    [self.navigationController pushViewController:selectViewController animated:YES];
}

- (IBAction)audienceButtonDidClicked:(UIButton *)sender {
    [PrivateConfig shareConfig].anchor = NO;
    VPSinglePlayerViewController *playerVC = [[VPSinglePlayerViewController alloc] initWithUrlString:@"http://qa-video.oss-cn-beijing.aliyuncs.com/mp4/mby02.mp4" platformUserID:[PrivateConfig shareConfig].identifier isLive:YES];
    [self presentViewController:playerVC animated:YES completion:nil];
}

- (IBAction)setButtonDidClicked:(UIButton *)sender {
    if (self.mallButton.hidden == YES) {
        self.mallButton.hidden = NO;
        self.liveButton.hidden = NO;
    }
    else {
        self.mallButton.hidden = YES;
        self.liveButton.hidden = YES;
    }
}

- (IBAction)mallButtonDidClicked:(UIButton *)sender {
    
}

- (IBAction)liveButtonDidClicked:(UIButton *)sender {
    VPLiveSettingView *settingView = [[VPLiveSettingView alloc] initWithFrame:self.view.bounds data:self.configData];
    [self.view addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationController.navigationBar.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
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
