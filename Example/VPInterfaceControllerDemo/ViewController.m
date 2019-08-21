//
//  ViewController.m
//  VPInterfaceViewDemeo
//
//  Created by 李少帅 on 2017/7/9.
//  Copyright © 2017年 李少帅. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VPSinglePlayerViewController.h"
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>
#import "PrivateConfig.h"

#import "VPLiveTypeSelectViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *liveButton;
@property (strong, nonatomic) NSDictionary *mockConfigData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //阴影
    self.videoButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.videoButton.layer.shadowOpacity = 0.5;
    self.videoButton.layer.shadowRadius = 1.0f;
    self.videoButton.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    
    self.liveButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.liveButton.layer.shadowOpacity = 0.5;
    self.liveButton.layer.shadowRadius = 1.0f;
    self.liveButton.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    self.mockConfigData = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (IBAction)videoButtonDidClick:(UIButton *)sender {
    
    if (![PrivateConfig shareConfig].identifier) {
        [PrivateConfig shareConfig].identifier = @"http://7xr5j6.com1.z0.glb.clouddn.com/hunantv0129.mp4?v=20180518";        
        
//        if (self.mockConfigData) {
//            [PrivateConfig shareConfig].identifier = [[self.mockConfigData objectForKey:@"room_id"] objectAtIndex:0];
//        }
    }
    [PrivateConfig shareConfig].live = NO;
    [PrivateConfig shareConfig].cytron = YES;

    VPSinglePlayerViewController *playerVC = [[VPSinglePlayerViewController alloc] initWithUrlString:[PrivateConfig shareConfig].videoUrl platformUserID:[PrivateConfig shareConfig].platformID isLive:NO];
//    playerVC.mockConfigData = self.mockConfigData;
    [self presentViewController:playerVC animated:YES completion:nil];
}

- (IBAction)liveButtonDidClick:(UIButton *)sender {
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    VPLiveTypeSelectViewController *selectViewController = [[VPLiveTypeSelectViewController alloc] init];
    selectViewController.configData = self.mockConfigData;
    [PrivateConfig shareConfig].live = YES;
    [PrivateConfig shareConfig].cytron = NO;
    [self.navigationController pushViewController:selectViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
