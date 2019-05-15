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
#import "VPTextField.h"

@interface VPVideoAppSettingView ()<UIGestureRecognizerDelegate>

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
    
    UITextField *appKeyTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 20, 240, 40)];
    appKeyTextField.borderStyle = UITextBorderStyleRoundedRect;
    [panel addSubview:appKeyTextField];
    self.appKeyTextField = appKeyTextField;
//    appKeyTextField.dataArray = nil;
    
    UILabel *urlTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 100, 30)];
    [urlTitle setText:@"AppSecret"];
    [panel addSubview:urlTitle];
    
    UITextField *appSecretTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 140, 240, 40)];
    appSecretTextField.borderStyle = UITextBorderStyleRoundedRect;
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

@end
