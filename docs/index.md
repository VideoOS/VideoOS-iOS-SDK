# VideoOS iOS SDK

## SDK集成
有两种方式将VideoOS添加到你的工程：

- 使用CocoaPods
- 手动添加framework

### 使用CocosPods

[CocoaPods](http://cocoapods.org/) 是 Objective-C 的依赖管理工具, 利用它可以让在项目中使用第三方库的过程变成简单和自动化。具体请参考 [Get Started](http://cocoapods.org/#get_started)。

##### Podfile
```
platform :ios, '8.0'
pod 'VideoOS'
```
如果你使用的是swift开发，请确保添加 `use_frameworks!` 
```
platform :ios, '8.0'
use_frameworks!
```
### 手动添加framework
#### 快速集成SDK
1. 将下载的SDK解压后导入您的工程中  (注:请务必在此步骤中选择“Create groups”单选按钮组, 因该SDK体积过大，不要勾选“Copy items if needed”。用这种方式仅引用该SDK,避免引起项目体积过大的问题)
<img src="https://vplscdn.videojj.com/docs/img/docs_ios_2.png" style="max-width: 600px;width: 100%;"/>

2. 设置项目的Framework Search Paths  (注:由于我们采用了Reference的方式，所以此处必须在Framework Search Paths里面添加SDK在本机所在的路径，路径从Users开始),如图：
<img src="https://vplscdn.videojj.com/docs/img/docs_ios_3.png" style="max-width: 600px;width: 100%;"/>

3. 添加依赖库(Xcode 7 下 `*.dylib` 库后缀名更改为 `*.tbd` ),请确保已添加以下 依赖库:

```
libz.tbd
libsqlite3.tbd
MediaPlayer.framework
WebKit.framework
ImageIO.framework
Security.framework
CoreMedia.framework
AVFoundation.framework
MobileCoreService.framework
Accelerate.framework
CoreTelephony.framework
SystemConfiguration.framework
AssetsLibrary.framework
Photos.framework
```

4. 设置 Other Linker flags.  
在 Other Linker Flags 中添加 –ObjC,如图(注意:如果项目中加载多个静态库有冲突，并使用了`-force_load` 的，不能添加`-ObjC`，且相 应此库也需要加入 `force_load`，对应路径需要指定到 `VideoPlsCytronSDK.framework/VideoPlsCytronSDK.h`):
<img src="https://vplscdn.videojj.com/docs/img/docs_ios_4.png" style="max-width: 600px;width: 100%;"/>
	  
	  
5. 可能依赖的第三方库(具体视平台不同而不一致)

```
'AFNetworking' 
'SDWebImage', '4.2.2' #如果用最新版本SDWebImage，请确认gif是否可以播放
```
	  
## 互动层对接	

### SDK初始化
在 `AppDelegate.m` 文件中导入 `<VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>` ，并在 `application:didFinishLaunchingWithOptions:` 方法中初始化SDK，SaaS版本需要设置AppKey和AppSecret，开源版本不需要。

示例代码：

```objective-c
#import <VideoPlsInterfaceControllerSDK/VPIConfigSDK.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{ 
    //other code
    [VPIConfigSDK setAppKey:@"550ec7d2-6cb0-4f46-b2df-2a1505ec82d8" appSecret:@"d0bf7873f7fa42a6"];//SaaS版本需要设置AppKey和AppSecret，开源版本不需要
    [VPIConfigSDK initSDK];
    //other code
}
```
### 对接`VPInterfaceController`
	
1. 根据需要接入的`SDK`创建`VPInterfaceControllerConfig`，将`SDK`需要的信息配置在`config`中。
	
	* identifier 为点播视频url或直播房间号
	* types 为视频类型（点播or直播），默认为点播（注：`VPInterfaceControllerTypeVideoOS` 表示点播，`VPInterfaceControllerTypeLiveOS` 表示直播）

2. 利用生成的`config`初始化`InterfaceController`， `interfaceController.view`就是生成的互动层，将这个`view`添加到播放器层之上就可以了。根据接入的`SDK`的需求可能有一些特殊的接口，放在相应的文件中，如需要调用，将对应文件`import`就可以调用了,详细作用请看注释。

```objective-c
    //配置信息
    VPInterfaceControllerConfig *config = [[VPInterfaceControllerConfig alloc] init];
    config.identifier = videoUrl; //or roomId
    config.types = VPInterfaceControllerTypeVideoOS; //or VPInterfaceControllerTypeLiveOS
    //扩展信息
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:@"lol" forKey:@"category"];
    config.extendDict = dict;
    
    //播放器size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    VPIVideoPlayerSize *videoPlayerSize = [[VPIVideoPlayerSize alloc] init];
    videoPlayerSize.portraitFullScreenWidth = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    videoPlayerSize.portraitFullScreenHeight = screenSize.width < screenSize.height ? screenSize.height : screenSize.width;
    videoPlayerSize.portraitSmallScreenHeight = videoPlayerSize.portraitFullScreenWidth * 9.0/16.0;
    videoPlayerSize.portraitSmallScreenOriginY = 0.0;
    
    VPInterfaceController  *interfaceController = [[VPInterfaceController alloc] initWithFrame:self.view.bounds config:config videoPlayerSize:videoPlayerSize];
    
    interfaceController.delegate = self;
    interfaceController.userDelegate = self;
    interfaceController.videoPlayerDelegate = self;
    
    [self.view addSubview:interfaceController.view];
```
 
3. 接着，设置当前互动层显示区域，代码如下所示

```objective-c
    [interfaceController notifyVideoScreenChanged:type];
```
互动层加载完成、视频加载完成，建议调用更新方法，旋转横竖屏之后必须调用更新方法
  
4. 全部完成之后调用`start`，开启互动层。
5. 获取互动层状态信息需要遵守`VPInterfaceStatusNotifyDelegate`协议，详见注释
6. 如需深度对接账号系统需要遵守`VPUPUserLoginInterface`协议，详见注释
7. 如退出播放页面或直播间，调用`stop`方法

#### 用户对接相关
1. VPIUserLoginInterface 和 VPIUserInfo, VPIUserInfo用来组装用户实例, VPIUserLoginInterface 用来获取关于用户数据的回调; 
	* ```- (VPIUserInfo *)vp_getUserInfo``` 通过平台方得到你们的userInfo
 	* ```- (void)vp_userLogined:(VPIUserInfo *) userInfo``` 通过sdk的webView登陆后会给你们对应的用户信息
 	* ```- (void)vp_notifyScreenChange:(NSString *)url``` 当需要切成竖屏时会发出这个通知,传入的url需要打开 ```VPIPubWebView``` 并调用`loadUrl`

#### 获取互动层状态信息
VPInterfaceStatusNotifyDelegate ```- (void)vp_interfaceActionNotify```, 会回传互动层状态和需要的操作

* adID 为广告的唯一标识
* adName 为广告名
* eventType 为广告触发的事件，包括展示、点击、关闭等
* actionType 为对接方需要做的操作，包括打开外链，暂停视频，播放视频
* url 为外链地址

#### 注意事项

1. VPInterfaceControllerConfig identifier参数为视频的标识(原url),可以用url作为参数 或 使用拼接 ID的方式来识别。
2. 文档中的代码仅供参考，实际参数请根据项目自行配置。
3. 互动层会向下层 view 发放点击手势，不用担心控制器界面会被阻挡手势。
4. 请将互动层置于合适位置以防阻挡手势。
5. 最佳位置为加载控制栏的下方,并且于手势层的上方,请不要将 cytronView 放 入包含手势操作的 View 中。
6. `SDK`目前支持系统为 ios8 以上。
7. 存在bundle包时请将bundle包放入资源文件中,使SDK能正常调用。
8. SDWebImage不兼容问题,可以在Pods的工程中VideoOS Target中添加宏VPUPSDWebImage=1解决

#### 常见问题

### 1、点位投放以后再页面中看不到投放的点位
请检查`- (NSTimeInterval)videoPlayerCurrentTime`是否对接正确，注意当前播放时间, 单位为秒, 包括小数

### 2、点位位置不正确
请检查`- (VPIVideoPlayerSize *)videoPlayerSize`是否对接正确，如果该方法对接正确，请检查页面横竖屏切换时，是否更新了VPInterfaceController方向`- (void)notifyVideoScreenChanged:(VPIVideoPlayerOrientation)type`

### 3、点击页面以后，没有打开链接
VideoOS所有的链接打开都由对接平台打开，通过`- (void)vp_interfaceActionNotify:(NSDictionary *)actionDictionary`方法传递给对接平台，`VPIActionTypeOpenUrl`表示需要对接平台打开链接

### 4、各种应用显示、点击、关闭是否有事件通知
有，大部分的事件由`- (void)vp_interfaceActionNotify:(NSDictionary *)actionDictionary`方法传递给对接平台

```objective-c
/**
 *  事件发送通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPIEventType) {
    VPIEventTypePrepareShow = 1,       //
    VPIEventTypeShow,                  // 显示
    VPIEventTypeClick,                 // 点击
    VPIEventTypeClose,                 // 关闭
    VPIEventTypeBack,                  // 中插返回
};

/**
 *  事件处理通知类型枚举
 */
typedef NS_ENUM(NSUInteger, VPIActionType) {
    VPIActionTypeNone = 0,          //
    VPIActionTypeOpenUrl,           // 打开外链
    VPIActionTypePauseVideo,        // 暂停视频
    VPIActionTypePlayVideo,         // 播放视频
    VPIActionTypeGetItem,           // 获得物品
};

/**
 *  事件监控通知
 *  @param actionDictionary 参数字典
 *  对应
 *  Key:    adID
 *  Value:  string
 *
 *  Key:    adName
 *  Value:  string
 *
 *  Key:    eventType
 *  Value:  VPIEventType
 *
 *  Key:    actionType
 *  Value:  VPIActionType
 *
 *  Key:    actionString
 *  Value:  string
 *  注：VPIActionTypeOpenUrl对应Url，VPIActionTypeGetItem对应ItemId
 */
-  (void)vp_interfaceActionNotify:(NSDictionary *)actionDictionary;
```
 
#### 5、中插广告视频的返回按钮怎么处理
中插广告视频的返回按钮，通过`VPIEventTypeBack`通知对接平台，请按照视频的控制器的返回按钮相同的方法处理

#### 6、中插视频打开外链以后，关闭外链，怎么继续中插播放
中插广告开始播放，会返回`VPIActionTypePauseVideo`事件，需要暂停视频；
中插广告结束或被关闭，会返回`VPIActionTypePlayVideo`事件，需要重新播放视频；
打开中插外链，会返回`VPIActionTypeOpenUrl`事件，此时中插广告是暂停的，打开的外外链关闭以后，需要调用`platformCloseActionWebView`，继续播放中插广告。

#### 7、云图/卡牌/投票 竖屏到全屏，图片显示有问题

`-(void)notifyVideoScreenChanged:(VPIVideoPlayerOrientation)type` 方法在切换屏幕前调用
#### 8、在刘海屏 UI显示有问题
  （1）要确保` _interfaceController = [[VPInterfaceController alloc] initWithFrame:self.view.bounds config:config videoPlayerSize:videoPlayerSize]; `中的 self.view 为全屏 
  
  （2）`VPIVideoPlayerSize` 要正确
  
  （3）适配刘海屏顶部的44像素
## 本地化部署配置（开源版本）

### host配置
修改`VPLuaSDK.m`中的`host`地址

注：现在`VPLuaSDK.m`中的`host`为SaaS版本的地址
### 加密key设置
修改`VPLuaCommonInfo.m`中的加密key
