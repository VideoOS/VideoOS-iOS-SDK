//
//  VPVideoSettingView.m
//  VPInterfaceControllerDemo
//
//  Created by peter on 2018/6/5.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPVideoSettingView.h"
#import <Masonry/Masonry.h>
#import "PrivateConfig.h"
#import "VPTextField.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "VPVideoListData.h"

@interface VPVideoSettingView ()<UIGestureRecognizerDelegate, VPTextFieldSelectedDelegate>

@property (nonatomic, strong) NSDictionary *configData;

@end

@implementation VPVideoSettingView

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
    [platformIdTitle setText:@"素材名称"];
    [panel addSubview:platformIdTitle];
    
    VPTextField *platformIdTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 20, 240, 40)];
    platformIdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:platformIdTextField];
    self.platformIdTextField = platformIdTextField;
    platformIdTextField.dataArray = nil;
    
    UILabel *videoIdTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 100, 30)];
    [videoIdTitle setText:@"videoId"];
    [panel addSubview:videoIdTitle];
    
    VPTextField *videoIdTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 140, 240, 40)];
    videoIdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:videoIdTextField];
    videoIdTextField.selectedDelegate = self;
    self.videoIdTextField = videoIdTextField;
    videoIdTextField.dataArray = [VPVideoListData shared].videoIdArray;
    
    UILabel *urlTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 100, 30)];
    [urlTitle setText:@"videoUrl"];
    [panel addSubview:urlTitle];
    
    VPTextField *urlTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 140, 240, 40)];
    urlTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:urlTextField];
    urlTextField.selectedDelegate = self;
    self.urlTextField = urlTextField;
    urlTextField.dataArray = [VPVideoListData shared].videoUrlArray;
    
    UILabel *categoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 30)];
    [categoryTitle setText:@"分类"];
    [panel addSubview:categoryTitle];
    
    VPTextField *categoryTextField = [[VPTextField alloc] initWithFrame:CGRectMake(90, 20, 240, 40)];
    categoryTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:categoryTextField];
    self.categoryTextField = categoryTextField;
    categoryTextField.dataArray = nil;

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
        make.top.equalTo(panel.mas_top).with.offset(20);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [platformIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(platformIdTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(platformIdTitle.mas_centerY);
    }];
    
    //roomId
    [urlTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(platformIdTitle.mas_bottom).with.offset(20);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [urlTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(urlTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(urlTitle.mas_centerY);
    }];
    
    [videoIdTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(urlTitle.mas_bottom).with.offset(20);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    
    [videoIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(panel.mas_right).with.offset(-widthSpace);
        make.left.equalTo(videoIdTitle.mas_right).with.offset(10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(videoIdTitle.mas_centerY);
    }];
    
    [categoryTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(panel.mas_left).with.offset(widthSpace);
        make.top.equalTo(videoIdTitle.mas_bottom).with.offset(20);
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
    
    if ([PrivateConfig shareConfig].creativeName) {
        self.platformIdTextField.text = [PrivateConfig shareConfig].creativeName;
//        self.urlTextField.text = [PrivateConfig shareConfig].identifier;
    }
    else {
//        self.urlTextField.text = [[self.configData objectForKey:@"room_id"] objectAtIndex:0];
    }
    
    if ([VPVideoListData shared].selectedIndex >= 0) {
        NSInteger selectedIndex = [VPVideoListData shared].selectedIndex;
        urlTextField.text = [VPVideoListData shared].videoUrlArray[selectedIndex];
        videoIdTextField.text = [VPVideoListData shared].videoIdArray[selectedIndex];
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
    [self.platformIdTextField resignFirstResponder];
    [self.urlTextField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)getMockAppData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://mock.videojj.com/mock/5c8224a5380a47002f43f740/asmpapi/videoos_test_videoinfo" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"data"] && [[responseObject objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSArray *videos = [[responseObject objectForKey:@"data"] objectForKey:@"videos"];
            if (videos && [videos isKindOfClass:[NSArray class]]) {
                for (NSDictionary *video in videos) {
                    VPVideoData *config = [[VPVideoData alloc] init];
                    config.videoUrl = [video objectForKey:@"videoUrl"];
                    config.videoId = [video objectForKey:@"videoId"];
                    [[VPVideoListData shared] addVideoData:config];
                }
                self.videoIdTextField.dataArray = [VPVideoListData shared].videoIdArray;
                self.urlTextField.dataArray = [VPVideoListData shared].videoUrlArray;
                if (self.videoIdTextField.text.length < 1 &&  self.urlTextField.text.length < 1) {
                    NSInteger index = [VPVideoListData shared].selectedIndex = 0;
                    if (index >= 0) {
                        self.videoIdTextField.text = self.videoIdTextField.dataArray[index];
                        self.urlTextField.text = self.urlTextField.dataArray[index];
                    }
                }
            }
            [MBProgressHUD hideHUDForView:self animated:YES];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self animated:YES];
    }];
}

- (void)dataArraySelectedIndex:(NSInteger)index target:(id)target {
    [VPVideoListData shared].selectedIndex = index;
    if (target == self.videoIdTextField) {
        self.urlTextField.text = self.urlTextField.dataArray[index];
    } else {
        self.videoIdTextField.text = self.videoIdTextField.dataArray[index];
    }
}

@end
