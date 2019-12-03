//
//  DebuggingViewController.m
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/10.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "DebuggingViewController.h"
#import "RTRootNavigationController.h"
#import "DevAppSettingView.h"
#import "DevAppPlayerViewController.h"
#import <VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>
#import <VideoOS/VideoPlsLuaViewManagerSDK/VPLuaSDK.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VPUPCommonInfo.h>
#import <VideoOS/VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DevLuaLoader.h"

@interface DebuggingViewController ()<DevAppSettingViewDelegate>
@property(nonatomic ,strong) DevAppSettingView* settingView;
@property (nonatomic, strong) id<VPUPHTTPAPIManager> httpManager;
@property(nonatomic ,strong) NSArray<NSString*>* resourceDataAry;
@property(nonatomic ,assign) BOOL isLocal;
@property(nonatomic,strong) MBProgressHUD* HUD;

@property(nonatomic,strong) NSString* interaction_templateLua;
@property (nonatomic ,strong) NSDictionary* interaction_Data;
@property (nonatomic ,strong) NSString* service_miniAppID;
@end

@implementation DebuggingViewController

-(id<VPUPHTTPAPIManager>)httpManager{
    if (!_httpManager) {
        _httpManager = [VPUPHTTPManagerFactory createHTTPAPIManagerWithType:VPUPHTTPManagerTypeAFN];
    }
    return _httpManager;
}


-(DevAppSettingView *)settingView{
    if (!_settingView) {
        _settingView = [[DevAppSettingView alloc] initWithFrame:self.view.bounds controllerType:self.controllerType];
        _settingView.delegate = self;
        _settingView.frame = self.view.bounds;
        [self.view addSubview:_settingView];
    }
    return _settingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    self.resourceDataAry = [NSArray new];
    // Do any additional setup after loading the view.
}

-(void)setUpNav{
    switch (self.controllerType) {
        case Type_Interaction:
            self.title = @"调试视频小工具";
            break;
        case Type_Service:
            self.title = @"调试视频小程序";
            break;
        default:
            self.title = @"调试小程序";
            break;
    }
    
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
- (IBAction)clickDebugBtn:(UIButton *)sender {
    self.settingView.hidden = false;
    [self.settingView fadeInAnimation];
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

#pragma mark DevAppSettingViewDelegate
-(void)settingViewDidCompleWithData:(NSArray<NSString *> *)data andIsOK:(BOOL)isOK andISLocaleModle:(BOOL)isLocal{
    if (!isOK) {
        return;
    }
    
    [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:KENVIRONMENT];
    [VPIConfigSDK setAppKey:[DevAppTool readUserDataWithKey:KDAAPPKEY] appSecret:[DevAppTool readUserDataWithKey:KDAAPPSECRET]];
    [VPIConfigSDK initSDK];
    
    self.resourceDataAry = data;
    self.isLocal = isLocal;
    if (isLocal) {
        [self pushVideoPlayerSegue];
    }else{
        
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.label.text = @"资源配置中...";
        [self getDevAppDebugInfoWithSubmitId:data.firstObject andAppletType:self.controllerType == Type_Interaction ? @"1" : @"2" AndHandelBlock:^(NSDictionary *responseObject, int code) {
            int resCode = [[responseObject objectForKey:@"resCode"] intValue];
            if (code != 0 || resCode!= 0 || !responseObject) {
                [self hudHiddenWithSucces:false];
                return ;
            }
            
            if (self.controllerType == Type_Interaction) {
                
                NSString* template = [responseObject objectForKey:@"template"];
                
                NSString* jsonURL  = data[1];
                NSError* error;
                NSString* jsonStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:jsonURL] encoding:NSUTF8StringEncoding error:&error];
                if (error) {
                    [self hudHiddenWithSucces:false];
                    return;
                }
                
                NSDictionary *adInfo = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                NSString *path =  [[DevAppTool devAPPBundle] pathForResource:@"devApp_json" ofType:@"json"];
                NSDictionary *devApp_Dic = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
                [devApp_Dic setValue:adInfo forKey:@"data"];
                [devApp_Dic setValue:template forKey:@"template"];
                self.interaction_Data = devApp_Dic;
//                self.interaction_Data = [NSDictionary dictionaryWithObjectsAndKeys:adInfo,@"data",template,@"template", nil];;
            }
            
            [self receiveResponseObject:responseObject];
            
        }];
    }
}

-(void)hudHiddenWithSucces:(BOOL)isSucess{
    if (!isSucess) {
        self.HUD.label.text = @"出错了，请检查配置信息是否正确";
    }
    [self.HUD hideAnimated:true afterDelay:isSucess ? 0 : 1.25];
}

-(void)receiveResponseObject:(NSDictionary *)responseObject{
    if (self.controllerType == Type_Interaction) {
        self.interaction_templateLua = [responseObject objectForKey:@"template"];
        //downloatLuas
        DevLuaLoader * loader =[DevLuaLoader sharedLoader];
        NSArray* luaList = [responseObject objectForKey:@"luaList"];
        
        [loader checkAndDownloadFilesList:luaList resumePath:[VPUPPathUtil luaOSPath] complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList * _Nonnull trafficList) {
            if (error) {
                NSLog(@"error : %@",error);
                [self hudHiddenWithSucces:false];
                return ;
            }
            [self pushVideoPlayerSegue];
        }];
        
        
    }else{
        
        DevLuaLoader * loader =[DevLuaLoader sharedLoader];
        NSArray* luaList = [responseObject objectForKey:@"luaList"];
        
        self.service_miniAppID = [responseObject objectForKey:@"miniAppId"];
        NSString* jsonStr = [self convertToJsonData:responseObject];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[VPUPPathUtil appDevConfigPath]]) {
            NSLog(@"config 文件存在 删除");
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[VPUPPathUtil appDevConfigPath]] error:nil];
        }
        NSError *error;
        [jsonStr writeToFile:[VPUPPathUtil appDevConfigPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            [self hudHiddenWithSucces:false];
            NSLog(@"config写入失败");
            return;
        }else {
            NSLog(@"config写入成功");
        }
        
        
        [loader checkAndDownloadFilesList:luaList resumePath:[VPUPPathUtil subPathOfLuaApplets:self.service_miniAppID] complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList * _Nonnull trafficList) {
            if (error) {
                NSLog(@"error : %@",error);
                [self hudHiddenWithSucces:false];
                return ;
            }
            [self pushVideoPlayerSegue];
        }];
        
    }
}

-(NSString *)convertToJsonData:(NSDictionary *)dict

{

    NSError *error;



    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    NSString *jsonString;

    if (!jsonData) {

        NSLog(@"%@",error);

    }else{

        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格

    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符

    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;

}


-(void)pushVideoPlayerSegue{
    [self hudHiddenWithSucces:true];
    [self performSegueWithIdentifier:@"videoPlayerSegue" sender:self];
    [self setNewOrientation:self.controllerType == Type_Service ? true : false];
}

- (void)setNewOrientation:(BOOL)fullscreen{
    

    if (fullscreen) {
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
        
    }else{
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"videoPlayerSegue"]) {
        DevAppPlayerViewController* cor = segue.destinationViewController;
        cor.controllerType = self.controllerType;
        cor.videoFile = self.resourceDataAry.lastObject;
        if (self.controllerType == Type_Interaction) {
            if (self.isLocal == true) {
                //copy 文件至指定目录
                [DevAppTool copyLuaFile:[DevAppTool getInteractionLuaPath] ToFilePath:[VPUPPathUtil luaOSPath]];
                cor.interaction_templateLua = [self.resourceDataAry.firstObject lastPathComponent];
                NSString *path =  [[DevAppTool devAPPBundle] pathForResource:@"devApp_json" ofType:@"json"];
                NSDictionary *adInfo = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
                cor.interaction_Data = adInfo;
            }else{
                cor.interaction_templateLua = self.interaction_templateLua;
                cor.interaction_Data = self.interaction_Data;
            }
            
        }else{
            if (self.isLocal == true) {
                //copy 文件至指定目录
                NSString *path =  [[DevAppTool devAPPBundle] pathForResource:@"config" ofType:@"json"];
                NSDictionary *config = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
                NSString* miniAppId = [config objectForKey:@"miniAppId"];
                
                NSArray *luaList = [config objectForKey:@"luaList"];
                for (NSDictionary* fileDic in luaList) {
                    NSString* luaFile = [fileDic objectForKey:@"url"];
                    
                    
                    
                    [DevAppTool copyLuaFile:[[DevAppTool devAPPBundle] pathForResource:luaFile ofType:nil] ToFilePath:[[VPUPPathUtil subPathOfLuaApplets:miniAppId] stringByAppendingPathComponent:luaFile]];
                    
                }
                [DevAppTool copyLuaFile:path ToFilePath:[VPUPPathUtil appDevConfigPath]];
                cor.service_miniAppID = miniAppId;
                cor.service_screenType = @"1";
                cor.service_appType = @"1";

            }else{
                cor.service_miniAppID = self.service_miniAppID;
                cor.service_screenType = @"1";
                cor.service_appType = @"1";
            }
        }

    }
}



///  network
- (void)getDevAppDebugInfoWithSubmitId:(NSString*)submitId andAppletType:(NSString*)appletType AndHandelBlock:(void (^)(NSDictionary* responseObject, int code))block{
        NSString* VERSION = [[VPUPCommonInfo commonParam] objectForKey:@"VERSION"];
        NSString* PHONE_MODEL = [[VPUPCommonInfo commonParam] objectForKey:@"PHONE_MODEL"];
        NSString* LANGUAGE = [[VPUPCommonInfo commonParam] objectForKey:@"LANGUAGE"];
        NSString* SDK_VERSION = [[VPUPCommonInfo commonParam] objectForKey:@"SDK_VERSION"];
        NSString* UD_ID = [[VPUPCommonInfo commonParam] objectForKey:@"UD_ID"];
        NSString* NETWORK = @"WIFI";
        NSString* PHONE_PROVIDER =[[VPUPCommonInfo commonParam] objectForKey:@"PHONE_PROVIDER"];
        NSString* IP = [[VPUPCommonInfo commonParam] objectForKey:@"IP"];
        NSString* SYSTEM_TIME =[[VPUPCommonInfo commonParam] objectForKey:@"SYSTEM_TIME"];
        NSString* OS_VERSION =[[VPUPCommonInfo commonParam] objectForKey:@"OS_VERSION"];
        NSString* parameterStr = [NSString stringWithFormat:@"{\"appletType\":\"%@\",\"submitId\":\"%@\",\"commonParam\":{\"VERSION\":\"%@\",\"PHONE_MODEL\":\"%@\",\"LANGUAGE\":\"%@\",\"SDK_VERSION\":\"%@\",\"UD_ID\":\"%@\",\"NETWORK\":\"%@\",\"PHONE_PROVIDER\":\"%@\",\"IP\":\"%@\",\"SYSTEM_TIME\":\"%@\",\"OS_VERSION\":\"%@\"}}",appletType,submitId,VERSION,PHONE_MODEL,LANGUAGE,SDK_VERSION,UD_ID,NETWORK,PHONE_PROVIDER,IP,SYSTEM_TIME,OS_VERSION];
        NSLog(@"parameterStr = %@",parameterStr);
        NSString *aesStr = [VPUPAESUtil aesEncryptString:parameterStr key:[DevAppTool readUserDataWithKey:KDAAPPSECRET] initVector:[DevAppTool readUserDataWithKey:KDAAPPSECRET]];
        VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
        api.baseUrl = @"https://dev-os-saas.videojj.com/";
        api.requestMethod = @"os-api-saas/api/getDevAppDebugInfo";
        api.apiRequestMethodType = VPUPRequestMethodTypePOST;
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"videoos", @"bu_id",
                              aesStr, @"data",
                               @1, @"device_type",
                               @"", @"target_id",nil];
        
        [api setRequestParameters:data];
        api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
            NSLog(@"responseObject %@",responseObject);
            
            if (![responseObject objectForKey:@"encryptData"] && [[responseObject objectForKey:@"encryptData"] isKindOfClass:[NSNull class]]) {
                block(nil,100);
                return ;
            }
            NSString* responseStr = [responseObject objectForKey:@"encryptData"];
            NSString *resultJson = [VPUPAESUtil aesDecryptString:responseStr key:[DevAppTool readUserDataWithKey:KDAAPPSECRET] initVector:[DevAppTool readUserDataWithKey:KDAAPPSECRET]];
            NSLog(@"responseStr %@",resultJson);
            NSData *jsonData = [resultJson dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
            if(err)
            {
                NSLog(@"json解析失败：%@",err);
                block(nil,100);
                return ;
            }
            block(jsonDic,0);
            
            
        };
        [self.httpManager sendAPIRequest:api];
        
        
    }


@end
