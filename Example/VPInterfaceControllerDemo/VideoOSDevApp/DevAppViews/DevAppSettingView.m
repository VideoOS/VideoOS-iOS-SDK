//
//  DevAppSettingView.m
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/10.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "DevAppSettingView.h"
#import "VPTextField.h"

@interface DevAppSettingView ()<UIScrollViewDelegate>

@property (assign, nonatomic) DebuggingControllerType DCT;
@property (strong, nonatomic) UIButton* leftButton;
@property (strong, nonatomic) UIButton* rightButton;
@property (strong, nonatomic) UIView* buttonGreenLineView;

@property (strong, nonatomic) UIView* leftBGView;
@property (strong, nonatomic) UITextField* leftTextFieldOne;
@property (strong, nonatomic) UITextField* leftTextFieldTwo;
@property (strong, nonatomic) VPTextField* leftVPTextField;

@property (strong, nonatomic) UIView* rightBGView;
@property (strong, nonatomic) UITextField* rigthTextFieldOne;
@property (strong, nonatomic) UITextField* rightTextFieldTwo;
@property (strong, nonatomic) VPTextField* rightVPTextField;

@property (strong, nonatomic) UIScrollView* contentScrollview;


@end

@implementation DevAppSettingView


- (instancetype)initWithFrame:(CGRect)frame controllerType:(DebuggingControllerType)type{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.DCT = type;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeOutAnimationWithOK:)];
        [self addGestureRecognizer:tapGesture];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
        [self initUI];
    }
    return self;
}

-(void)fadeInAnimation{
    float viewHeight = self.bounds.size.height;
    float viewWidth = self.bounds.size.width;
    self.frame = CGRectMake(0, viewHeight, viewWidth, viewHeight);
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    }];
    
}

-(void)resignALLFirstResponder{
    [self.leftTextFieldOne resignFirstResponder];
       [self.leftTextFieldTwo resignFirstResponder];
       [self.leftVPTextField resignFirstResponder];
       [self.rigthTextFieldOne resignFirstResponder];
       [self.rightTextFieldTwo resignFirstResponder];
       [self.rightVPTextField resignFirstResponder];
}


-(void)fadeOutAnimationWithOK:(BOOL)isOK{
    float viewHeight = self.bounds.size.height;
    float viewWidth = self.bounds.size.width;
    [self resignALLFirstResponder];
    
    self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0, viewHeight, viewWidth, viewHeight);
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(settingViewDidCompleWithData:andIsOK:andISLocaleModle:)]) {
            [self.delegate settingViewDidCompleWithData:[self getCompleData] andIsOK:isOK andISLocaleModle:self.leftButton.isSelected];
        }
    }];
}

-(NSArray<NSString*>*)getCompleData{
    NSMutableArray<NSString*>* ary = [NSMutableArray array];
    switch (self.DCT) {
        case Type_Interaction:
        {
            if (self.leftButton.isSelected) {
                [ary addObject:self.leftTextFieldOne.text];
                [ary addObject:self.leftTextFieldTwo.text];
                [ary addObject:self.leftVPTextField.text];
            }else{
                [ary addObject:self.rigthTextFieldOne.text];
               [ary addObject:self.rightTextFieldTwo.text];
               [ary addObject:self.rightVPTextField.text];
                [DevAppTool writeUserDataWithKey:[self.rigthTextFieldOne.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:KITERACTIONID];
                [DevAppTool writeUserDataWithKey:[self.rightTextFieldTwo.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:KITERACTIONJSON];
                
            }
        }
            break;
        case Type_Service:
        {
            if (self.leftButton.isSelected) {
                [ary addObject:self.leftTextFieldOne.text];
                [ary addObject:self.leftVPTextField.text];
            }else{
                [ary addObject:self.rigthTextFieldOne.text];
                [ary addObject:self.rightVPTextField.text];
                [DevAppTool writeUserDataWithKey:[self.rigthTextFieldOne.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:KSERVICEID];
            }
        }
            break;
            
        default:
            break;
    }
    
    return ary;
}

-(void)noneFunction{
    
}

-(void)initUI{
    
    UIView* bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomView.backgroundColor = [UIColor colorWithRed:43/255.0 green:45/255.0 blue:56/255.0 alpha:1/1.0];
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@(100));
    }];
    
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noneFunction)];
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectZero];
    [bgView addGestureRecognizer:tapGesture];
    bgView.backgroundColor = [UIColor colorWithRed:43/255.0 green:45/255.0 blue:56/255.0 alpha:1/1.0];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomMargin);
        make.left.right.equalTo(self);
        make.height.equalTo(@(self.DCT == Type_Interaction ? 368 : 308));
    }];
    bgView.layer.cornerRadius = 10;
    
    UIButton* cancleBtn = [[UIButton alloc] init];
    [cancleBtn addTarget:self action:@selector(clickCancleButton:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:@"立即取消" forState:UIControlStateNormal];
    [cancleBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    cancleBtn.backgroundColor = [UIColor clearColor];
    [bgView addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(bgView);
        make.height.equalTo(@50);
    }];
    
    UIView* bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
    bottomLine.backgroundColor = [UIColor colorWithRed:55/255.0 green:57/255.0 blue:71/255.0 alpha:1/1.0];
    [bgView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(cancleBtn.mas_top);
        make.left.right.equalTo(bgView);
        make.height.equalTo(@1);
    }];
    
    UIButton* okBtn = [[UIButton alloc] init];
    [okBtn addTarget:self action:@selector(clickOKButton:) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTitle:@"确认应用" forState:UIControlStateNormal];
    [okBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
    [okBtn setTitleColor:[UIColor colorWithRed:39/255.0 green:209/255.0 blue:148/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    okBtn.backgroundColor = [UIColor clearColor];
    [bgView addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bgView);
        make.bottom.equalTo(bottomLine.mas_top);
        make.height.equalTo(@50);
    }];
    
    UIView* middleLine = [[UIView alloc] initWithFrame:CGRectZero];
    middleLine.backgroundColor = [UIColor colorWithRed:55/255.0 green:57/255.0 blue:71/255.0 alpha:1/1.0];
    [bgView addSubview:middleLine];
    [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(okBtn.mas_top);
        make.left.right.equalTo(bgView);
        make.height.equalTo(@4);
    }];
    
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.leftButton addTarget:self action:@selector(clickLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton setTitle:@"配置本地调试" forState:UIControlStateNormal];
    [self.leftButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
    [self.leftButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.leftButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.leftButton.backgroundColor = [UIColor clearColor];
    [bgView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(bgView);
        make.height.equalTo(@50);
    }];
    self.leftButton.selected = true;
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.rightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setTitle:@"配置在线调试" forState:UIControlStateNormal];
    [self.rightButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
    [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.rightButton.backgroundColor = [UIColor clearColor];
    [bgView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(bgView);
        make.height.equalTo(@50);
        make.width.equalTo(self.leftButton);
        make.left.equalTo(self.leftButton.mas_right);
    }];
    
    UIView* topLineVIew = [UIView new];
    topLineVIew.backgroundColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1/10.0];
    [bgView addSubview:topLineVIew];
    [topLineVIew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).offset(50);
        make.left.right.equalTo(bgView);
        make.height.equalTo(@1);
    }];
    
    
    self.contentScrollview = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.contentScrollview.delegate = self;
    self.contentScrollview.pagingEnabled = YES;
    self.contentScrollview.showsVerticalScrollIndicator = NO;
    self.contentScrollview.showsHorizontalScrollIndicator = NO;
    float contentScrollviewHeight = self.DCT == Type_Interaction ? 212 : 152;
    self.contentScrollview.contentSize = CGSizeMake(self.bounds.size.width * 2.0, contentScrollviewHeight);
    self.leftBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, contentScrollviewHeight)];
//    self.leftBGView.backgroundColor = [UIColor redColor];

    self.rightBGView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, contentScrollviewHeight)];
//    self.rightBGView.backgroundColor = [UIColor yellowColor];
    [bgView addSubview:self.contentScrollview];
    [self.contentScrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bgView);
        make.top.equalTo(bgView).offset(51);
        make.height.equalTo(@(contentScrollviewHeight));
    }];
    [self.contentScrollview addSubview:self.leftBGView];
    [self.contentScrollview addSubview:self.rightBGView];
    
    self.buttonGreenLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 48, 96, 2)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.buttonGreenLineView.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:47/255.0 green:228/255.0 blue:173/255.0 alpha:1.0].CGColor , (id)[UIColor colorWithRed:31/255.0 green:187/255.0 blue:120/255.0 alpha:1.0].CGColor];
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.cornerRadius = gradient.frame.size.height / 2.0;
    [self.buttonGreenLineView.layer insertSublayer:gradient atIndex:0];
    [bgView addSubview:self.buttonGreenLineView];
    [self moveButtonGreenLineView];
    
//    self.leftBGView;
    
    UIColor* subBGColor = [UIColor colorWithRed:63/255.0 green:66/255.0 blue:82/255.0 alpha:1/1.0];
    UIView* leftSubBg_one = [UIView new];
    leftSubBg_one.backgroundColor = subBGColor;
    leftSubBg_one.layer.cornerRadius = 6;
    [self.leftBGView addSubview:leftSubBg_one];
    [leftSubBg_one mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftBGView).offset(24);
        make.left.equalTo(self.leftBGView).offset(14);
        make.right.equalTo(self.leftBGView).offset(-14);
        make.height.equalTo(@44);
    }];
    
    UILabel* leftLabel_one = [[UILabel alloc] initWithFrame:CGRectZero];
    leftLabel_one.text = @"lua路径";
    leftLabel_one.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    leftLabel_one.textColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/1.0];
    [leftSubBg_one addSubview:leftLabel_one];
    [leftLabel_one mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(leftSubBg_one);
        make.left.equalTo(leftSubBg_one).offset(10);
    }];
    
    UIView *leftLineView_one = [[UIView alloc] init];
    leftLineView_one.backgroundColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/10.0];
    [leftSubBg_one addSubview:leftLineView_one];
    [leftLineView_one mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftSubBg_one).offset(77);
        make.centerY.equalTo(leftSubBg_one);
        make.height.equalTo(@26);
        make.width.equalTo(@1);
    }];
    
    self.leftTextFieldOne = [[UITextField alloc] init];
    [leftSubBg_one addSubview:self.leftTextFieldOne];
    self.leftTextFieldOne.textColor = [UIColor colorWithRed:173/255.0 green:175/255.0 blue:179/255.0 alpha:1/1.0];
    self.leftTextFieldOne.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.leftTextFieldOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(leftSubBg_one);
        make.left.equalTo(leftLineView_one).offset(15);
        make.right.equalTo(leftSubBg_one).offset(-5);
    }];
    
    
    
    UIView* leftSubBg_three = [UIView new];
    leftSubBg_three.backgroundColor = subBGColor;
    leftSubBg_three.layer.cornerRadius = 6;
    [self.leftBGView addSubview:leftSubBg_three];
    [leftSubBg_three mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.leftBGView).offset(-24);
        make.left.equalTo(self.leftBGView).offset(14);
        make.right.equalTo(self.leftBGView).offset(-14);
        make.height.equalTo(@44);
    }];
    
    UILabel* leftLabel_three = [[UILabel alloc] initWithFrame:CGRectZero];
    leftLabel_three.text = @"视频路径";
    leftLabel_three.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    leftLabel_three.textColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/1.0];
    [leftSubBg_three addSubview:leftLabel_three];
    [leftLabel_three mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(leftSubBg_three);
      make.left.equalTo(leftSubBg_three).offset(10);
    }];

    UIView *leftLineView_three = [[UIView alloc] init];
    leftLineView_three.backgroundColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/10.0];
    [leftSubBg_three addSubview:leftLineView_three];
    [leftLineView_three mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(leftSubBg_three).offset(77);
      make.centerY.equalTo(leftSubBg_three);
      make.height.equalTo(@26);
      make.width.equalTo(@1);
    }];
    
    UIImageView* leftIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconset0417"]];
    [leftSubBg_three addSubview:leftIcon];
    [leftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(leftSubBg_three);
        make.right.equalTo(leftSubBg_three).offset(-7);
        make.width.height.equalTo(@15);
    }];

    self.leftVPTextField = [[VPTextField alloc] init];
    self.leftVPTextField.showCellCount = 6;
     NSString* localFile = [[NSBundle mainBundle] pathForResource:@"zelear.mp4" ofType:nil];
    NSURL* localURL = [NSURL fileURLWithPath:localFile];
    NSString* localFileUrlstring = [localURL absoluteString];
    self.leftVPTextField.dataArray = [NSArray arrayWithObjects:localFileUrlstring,@"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/demo/car.mp4",@"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/demo/ec.mp4",@"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/demo/food.mp4", nil];
    [leftSubBg_three addSubview:self.leftVPTextField];
    self.leftVPTextField.isDevApp = true;
    self.leftVPTextField.textColor = [UIColor colorWithRed:173/255.0 green:175/255.0 blue:179/255.0 alpha:1/1.0];
    self.leftVPTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.leftVPTextField mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(leftSubBg_three);
      make.left.equalTo(leftLineView_three).offset(15);
      make.right.equalTo(leftSubBg_three).offset(-5);
    }];
    
//    self.rightBGView;
    
    UIView* rightSubBg_one = [UIView new];
    rightSubBg_one.backgroundColor = subBGColor;
    rightSubBg_one.layer.cornerRadius = 6;
    [self.rightBGView addSubview:rightSubBg_one];
    [rightSubBg_one mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rightBGView).offset(24);
        make.left.equalTo(self.rightBGView).offset(14);
        make.right.equalTo(self.rightBGView).offset(-14);
        make.height.equalTo(@44);
    }];
    
    
    UILabel* rightLabel_one = [[UILabel alloc] initWithFrame:CGRectZero];
    rightLabel_one.text = @"提交ID";
    rightLabel_one.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    rightLabel_one.textColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/1.0];
    [rightSubBg_one addSubview:rightLabel_one];
    [rightLabel_one mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(rightSubBg_one);
        make.left.equalTo(rightSubBg_one).offset(10);
    }];
    
    UIView *rightLineView_one = [[UIView alloc] init];
    rightLineView_one.backgroundColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/10.0];
    [rightSubBg_one addSubview:rightLineView_one];
    [rightLineView_one mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightSubBg_one).offset(77);
        make.centerY.equalTo(rightSubBg_one);
        make.height.equalTo(@26);
        make.width.equalTo(@1);
    }];
    
    self.rigthTextFieldOne = [[UITextField alloc] init];
    [rightSubBg_one addSubview:self.rigthTextFieldOne];
    self.rigthTextFieldOne.textColor = [UIColor colorWithRed:173/255.0 green:175/255.0 blue:179/255.0 alpha:1/1.0];
    self.rigthTextFieldOne.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.rigthTextFieldOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(rightSubBg_one);
        make.left.equalTo(rightLineView_one).offset(15);
        make.right.equalTo(rightSubBg_one).offset(-5);
    }];
    
    UIView* rightSubBg_three = [UIView new];
    rightSubBg_three.backgroundColor = subBGColor;
    rightSubBg_three.layer.cornerRadius = 6;
    [self.rightBGView addSubview:rightSubBg_three];
    [rightSubBg_three mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.rightBGView).offset(-24);
        make.left.equalTo(self.rightBGView).offset(14);
        make.right.equalTo(self.rightBGView).offset(-14);
        make.height.equalTo(@44);
    }];
    
    UILabel* rightLabel_three = [[UILabel alloc] initWithFrame:CGRectZero];
    rightLabel_three.text = @"视频网址";
    rightLabel_three.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    rightLabel_three.textColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/1.0];
    [rightSubBg_three addSubview:rightLabel_three];
    [rightLabel_three mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(rightSubBg_three);
      make.left.equalTo(rightSubBg_three).offset(10);
    }];

    UIView *rightLineView_three = [[UIView alloc] init];
    rightLineView_three.backgroundColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/10.0];
    [rightSubBg_three addSubview:rightLineView_three];
    [rightLineView_three mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(rightSubBg_three).offset(77);
      make.centerY.equalTo(rightSubBg_three);
      make.height.equalTo(@26);
      make.width.equalTo(@1);
    }];
    
    UIImageView* rightIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconset0417"]];
    [rightSubBg_three addSubview:rightIcon];
    [rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(rightSubBg_three);
        make.right.equalTo(rightSubBg_three).offset(-7);
        make.width.height.equalTo(@15);
    }];
    

    self.rightVPTextField = [[VPTextField alloc] init];
    self.rightVPTextField.showCellCount = 6;
    self.rightVPTextField.dataArray = [NSArray arrayWithObjects:localFileUrlstring,@"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/demo/car.mp4",@"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/demo/ec.mp4",@"https://videojj-mobile.oss-cn-beijing.aliyuncs.com/resource/demo/food.mp4", nil];
    [rightSubBg_three addSubview:self.rightVPTextField];
    self.rightVPTextField.isDevApp = true;
    self.rightVPTextField.textColor = [UIColor colorWithRed:173/255.0 green:175/255.0 blue:179/255.0 alpha:1/1.0];
    self.rightVPTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.rightVPTextField mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(rightSubBg_three);
      make.left.equalTo(rightLineView_three).offset(15);
      make.right.equalTo(rightSubBg_three).offset(-5);
    }];
    
    
    UILabel* leftLabel_two = [[UILabel alloc] initWithFrame:CGRectZero];
    UILabel* rightLabel_two = [[UILabel alloc] initWithFrame:CGRectZero];
    if (self.DCT == Type_Interaction) {
        
        UIView* leftSubBg_two = [UIView new];
        leftSubBg_two.backgroundColor = subBGColor;
        leftSubBg_two.layer.cornerRadius = 6;
        [self.leftBGView addSubview:leftSubBg_two];
        [leftSubBg_two mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(leftSubBg_three.mas_top).offset(-16);
            make.left.equalTo(self.leftBGView).offset(14);
            make.right.equalTo(self.leftBGView).offset(-14);
            make.height.equalTo(@44);
        }];
        
        
        leftLabel_two.text = @"Json路径";
        leftLabel_two.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        leftLabel_two.textColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/1.0];
        [leftSubBg_two addSubview:leftLabel_two];
        [leftLabel_two mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(leftSubBg_two);
            make.left.equalTo(leftSubBg_two).offset(10);
        }];
        
        UIView *leftLineView_two = [[UIView alloc] init];
        leftLineView_two.backgroundColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/10.0];
        [leftSubBg_two addSubview:leftLineView_two];
        [leftLineView_two mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftSubBg_two).offset(77);
            make.centerY.equalTo(leftSubBg_two);
            make.height.equalTo(@26);
            make.width.equalTo(@1);
        }];
        
        self.leftTextFieldTwo = [[UITextField alloc] init];
        [leftSubBg_two addSubview:self.leftTextFieldTwo];
        self.leftTextFieldTwo.textColor = [UIColor colorWithRed:173/255.0 green:175/255.0 blue:179/255.0 alpha:1/1.0];
        self.leftTextFieldTwo.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.leftTextFieldTwo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(leftSubBg_two);
            make.left.equalTo(leftLineView_two).offset(15);
            make.right.equalTo(leftSubBg_two).offset(-5);
        }];
        
        
        UIView* rightSubBg_two = [UIView new];
        rightSubBg_two.backgroundColor = subBGColor;
        rightSubBg_two.layer.cornerRadius = 6;
        [self.rightBGView addSubview:rightSubBg_two];
        [rightSubBg_two mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(rightSubBg_three.mas_top).offset(-16);
            make.left.equalTo(self.rightBGView).offset(14);
            make.right.equalTo(self.rightBGView).offset(-14);
            make.height.equalTo(@44);
        }];
        
        
        
        rightLabel_two.text = @"Json网址";
        rightLabel_two.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        rightLabel_two.textColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/1.0];
        [rightSubBg_two addSubview:rightLabel_two];
        [rightLabel_two mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(rightSubBg_two);
            make.left.equalTo(rightSubBg_two).offset(10);
        }];
        
        UIView *rightLineView_two = [[UIView alloc] init];
        rightLineView_two.backgroundColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1/10.0];
        [rightSubBg_two addSubview:rightLineView_two];
        [rightLineView_two mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(rightSubBg_two).offset(77);
            make.centerY.equalTo(rightSubBg_two);
            make.height.equalTo(@26);
            make.width.equalTo(@1);
        }];
        
        self.rightTextFieldTwo = [[UITextField alloc] init];
        [rightSubBg_two addSubview:self.rightTextFieldTwo];
        self.rightTextFieldTwo.textColor = [UIColor colorWithRed:173/255.0 green:175/255.0 blue:179/255.0 alpha:1/1.0];
        self.rightTextFieldTwo.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.rightTextFieldTwo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(rightSubBg_two);
            make.left.equalTo(rightLineView_two).offset(15);
            make.right.equalTo(rightSubBg_two).offset(-5);
        }];
    }
    
    switch (self.DCT) {
        case Type_Interaction:
            leftLabel_one.text = @"lua路径";
            leftLabel_two.text = @"Json路径";
            leftLabel_three.text = @"视频路径";
            rightLabel_one.text = @"提交ID";
            rightLabel_two.text = @"Json网址";
            rightLabel_three.text = @"视频网址";
            break;
        case Type_Service:
            leftLabel_one.text = @"lua路径";
            leftLabel_two.text = @"";
            leftLabel_three.text = @"视频路径";
            rightLabel_one.text = @"提交ID";
            rightLabel_two.text = @"";
            rightLabel_three.text = @"视频网址";
            break;
            
        default:
            break;
    }
    
    [self setUPNormalContent];
    
}

-(void)setUPNormalContent{

    
    NSBundle *bundle = [DevAppTool devAPPBundle];
    switch (self.DCT) {
        case Type_Interaction:
        {
            
            NSString *path =  [[DevAppTool devAPPBundle] pathForResource:@"devApp_json" ofType:@"json"];
            NSDictionary *adInfo = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
//            NSArray* launchInfoList = (NSArray*)[adInfo objectForKey:@"launchInfoList"];
//
            NSDictionary* launchInfo = adInfo;
            
            
            NSString *json_path = [bundle pathForResource:@"devApp_json" ofType:@"json"];
            NSString* lua_path = [[DevAppTool getInteractionLuaPath] stringByAppendingPathComponent:[launchInfo objectForKey:@"template"]];
            
            self.leftTextFieldOne.text = lua_path;
            self.leftTextFieldTwo.text = json_path;
            
            self.rigthTextFieldOne.text = [DevAppTool readUserDataWithKey:KITERACTIONID];
            self.rightTextFieldTwo.text = [DevAppTool readUserDataWithKey:KITERACTIONJSON];
            
        }
            break;
            
        case Type_Service:
        {
            NSString *path =  [[DevAppTool devAPPBundle] pathForResource:@"config" ofType:@"json"];
            NSDictionary *config = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
            
             self.leftTextFieldOne.text = [[DevAppTool devAPPBundle] pathForResource:[config objectForKey:@"template"] ofType:nil];
            
            self.rigthTextFieldOne.text = [DevAppTool readUserDataWithKey:KSERVICEID];
        }

            
            break;
            
        default:
            break;
    }
    
    self.leftVPTextField.text = self.leftVPTextField.dataArray.firstObject;
    self.rightVPTextField.text = self.rightVPTextField.dataArray.firstObject;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self resignALLFirstResponder];
}



-(void)transformView:(NSNotification *)aNSNotification
{
    //获取键盘弹出前的Rect
    NSValue *keyBoardBeginBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyBoardBeginBounds CGRectValue];
    
    //获取键盘弹出后的Rect
    NSValue *keyBoardEndBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect  endRect=[keyBoardEndBounds CGRectValue];
    
    //获取键盘位置变化前后纵坐标Y的变化值
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    NSLog(@"看看这个变化的Y值:%f",deltaY);
    
    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
    float bottomHeight;
    if (@available(iOS 11.0, *)) {
        bottomHeight = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    } else {
        bottomHeight = 0;
        // Fallback on earlier versions
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+deltaY, self.frame.size.width, self.frame.size.height)];
        
        self.leftVPTextField.holdView.frame = CGRectMake(self.leftVPTextField.holdView.frame.origin.x, self.leftVPTextField.holdView.frame.origin.y + deltaY + 17 + bottomHeight, self.leftVPTextField.holdView.frame.size.width, self.leftVPTextField.holdView.frame.size.height);
        self.leftVPTextField.tableView.frame = CGRectMake(self.leftVPTextField.tableView.frame.origin.x, self.leftVPTextField.tableView.frame.origin.y + deltaY + 17 + bottomHeight, self.leftVPTextField.tableView.frame.size.width, self.leftVPTextField.tableView.frame.size.height);
        
        self.rightVPTextField.holdView.frame = CGRectMake(self.rightVPTextField.holdView.frame.origin.x, self.rightVPTextField.holdView.frame.origin.y + deltaY + 17 + bottomHeight, self.rightVPTextField.holdView.frame.size.width, self.rightVPTextField.holdView.frame.size.height);
        self.rightVPTextField.tableView.frame = CGRectMake(self.rightVPTextField.tableView.frame.origin.x, self.rightVPTextField.tableView.frame.origin.y + deltaY + 17 + bottomHeight, self.rightVPTextField.tableView.frame.size.width, self.rightVPTextField.tableView.frame.size.height);
    }];

}

-(void)moveButtonGreenLineView{
    CGPoint center = self.buttonGreenLineView.center;
    
    float offectx = self.contentScrollview.contentOffset.x;
    float scale = offectx / self.contentScrollview.contentSize.width;
    
    
    self.buttonGreenLineView.center = CGPointMake(self.bounds.size.width  * scale +  self.bounds.size.width / 4.0, center.y);
}

-(void)clickLeftButton:(UIButton*)button{
    button.selected = true;
    self.rightButton.selected = false;
    [self.contentScrollview scrollRectToVisible:CGRectMake(0, 0, self.contentScrollview.bounds.size.width, self.contentScrollview.bounds.size.height) animated:true];
}
-(void)clickRightButton:(UIButton*)button{
    button.selected = true;
    self.leftButton.selected = false;
    [self.contentScrollview scrollRectToVisible:CGRectMake(self.contentScrollview.bounds.size.width, 0, self.contentScrollview.bounds.size.width, self.contentScrollview.bounds.size.height) animated:true];
    
}

-(void)clickOKButton:(UIButton*)button{
    [self fadeOutAnimationWithOK:true];
}

-(void)clickCancleButton:(UIButton*)button{
    if (self.tag == 101) {
        [self resignALLFirstResponder];
    }else{
        [self fadeOutAnimationWithOK:false];
    }
    
}

-(void)keyboardDidShow{

self.tag = 101;

}

-(void)keyboardDidHide{

self.tag = 102;

}


#pragma mark UIScrollViewDelegate

//滚动时就会执行该方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self moveButtonGreenLineView];
}

//即将开始滚动
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self moveButtonGreenLineView];
}

//滚动已经完成
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self moveButtonGreenLineView];
}

//即将滚动完成
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self moveButtonGreenLineView];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
