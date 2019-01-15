### Video++互动层对接
##### 1. 获取Appkey和Bundle ID (注:如何在我们的官网注册应用得到appkey和BundleID请点击链接查看我们的[十分钟玩转控制台教程](//videojj.com/blog/57c559c9e4e7fd450076f325)。)
#### 2. 下载SDK并压缩
#### 3. 快速集成
1.	将下载的SDK解压后导入您的工程中  (注:请务必在此步骤中选择“Create groups”单选按钮组, 因该SDK体积过大，不要勾选“Copy items if needed”。用这种方式仅引用该SDK,避免引起项目体积过大的问题)
	 <img src="https://vplscdn.videojj.com/docs/img/docs_ios_2.png" style="max-width: 600px;width: 100%;"/>

2. 设置项目的Framework Search Paths  (注:由于我们采用了Reference的方式，所以此处必须在Framework Search Paths里面添加SDK在本机所在的路径，路径从Users开始),如图：
   <img src="https://vplscdn.videojj.com/docs/img/docs_ios_3.png" style="max-width: 600px;width: 100%;"/>

3.	添加依赖库(Xcode 7 下 `*.dylib` 库后缀名更改为 `*.tbd` ),请确保已添加以下 依赖库:

    ```js
    libz.tbd
    libsqlite3.tbd
    MediaPlayer.framework,
    WebKit.framework,
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
 'AFNetworking', '~>2.0'
 'SDWebImage', '4.2.2'
```
	  
#### 4. 创建`InterfaceController`
	
| SDK		      | 特殊配置项   | 特殊方法文件 |
| ------------- |-------------| -----|
| 点播(VideoOS)  | VPInterfaceControllerConfigVideoOS | VPInterfaceController+VideoOS |
| 直播(LiveOS)   | VPInterfaceControllerConfigLiveOS  | VPInterfaceController+LiveOS  | 
| 子商城(Mall) 	| VPInterfaceControllerConfigMall    | VPInterfaceController+Mall    |
| 互娱(Enjoy)		| VPInterfaceControllerConfigEnjoy   | VPInterfaceController+Enjoy   |
	
	
1. 根据需要接入的`SDK`创建相应的`VPInterfaceControllerConfig`的子类，将`SDK`需要的信息配置在`config`中。
	
	* Appkey 和 platformID 获取见本文最上方
	* platformUserID 为房间号
	* isAnchor 为是否为主播

2. 利用生成的`config`初始化`InterfaceController`， `interfaceController.view`就是生成的互动层，将这个`view`添加到播放器层之上就可以了。根据接入的`SDK`的需求可能有一些特殊的接口，放在相应的文件中，如需要调用，将对应文件`import`就可以调用了,详细作用请看注释。
	* 互娱项目目前`c`端需要复用直播项目的长链接通道，因此需要初始化直播项目，主播端用户可直接初始化互娱项目
 
3. 接着，设置互动层显示区域，代码如下所示

	```
 	[interfaceController updateFrame:self.view.bounds videoRect:self.view.bounds isFullScreen:YES];
	```
	
	* frame 与播放器实际位置一致,videoRect 与视频实际显示区域一致,isFullScreen 控制 全屏\小窗口，全屏显示互动。参数根据需要自行调整，可参考头文件
	* 互动层加载完成、视频加载完成，建议调用更新方法，旋转横竖屏之后必须调用更新方法
  
4. 全部完成之后调用`startLoading`，开启互动层。
5. 获取互动层状态信息需要遵守`VPInterfaceStatusNotifyDelegate`协议，详见注释
6. 如需深度对接账号系统需要遵守`VPUPUserLoginInterface`协议，详见注释
7. 如推出直播间，调用`stop`方法，暂停请调用`pauseInterfaceView`方法

#### 5.用户对接相关
1. VPIUserLoginInterface 和 VPIUserInfo, VPIUserInfo用来组装用户实例, VPIUserLoginInterface 用来获取关于用户数据的回调; 
	* ```- (VPIUserInfo *)vp_getUserInfo``` 通过平台方得到你们的userInfo
 	* ```- (void)vp_userLogined:(VPIUserInfo *) userInfo``` 通过sdk的webView登陆后会给你们对应的用户信息
 	* ```- (void)vp_notifyScreenChange:(NSString *)url``` 当需要切成竖屏时会发出这个通知,传入的url需要打开 ```VPIPubWebView``` 并调用loadUrl

#### 6.子商城相关
1. VPInterfaceController ```- (void)openGoodsList```, 用来打开子商城侧边栏,关闭点击空白区域即可
2. VPIPubWebView , sdk通用webView需要调用生成
	* `userDelegate`, 对应 `VPIUserLoginInterface` 的接口,详见上方
	* ```- (void)closeAndRemoveFromSuperView``` 关闭并销毁webView
	* ```- (void)loadUrl:(NSString *)url``` 父类方法,加载Url

#### 7.互娱相关
1.  互娱项目目前`c`端需要复用直播项目的长链接通道，因此需要使用`VPInterfaceControllerConfigLiveOS`，会同时加载互娱项目，无需再次创建`interfaceController`；主播端则使用`VPInterfaceControllerConfigEnjoy`。
2. VPInterfaceController```- (void)openEnjoyConfigPage:(BOOL)isFullScreen```，用于打开互娱配置页面。`isFullScreen`为`YES`时，打开的是全屏配置页，只能配置，不能投放；为`NO`时，打开半屏配置页，可以配置和投放。 

#### 8.注意事项

1. videoIdentifier参数为视频的标识(原url),可以用url作为参数 或 使用拼接 ID的方式来识别(前提为与pc对接并通过)。
2. 文档中的代码仅供参考，实际参数请根据项目自行配置。
3. 互动层会向下层 view 发放点击手势，不用担心控制器界面会被阻挡手势。
4. 请将互动层置于合适位置以防阻挡手势。
5. 最佳位置为加载控制栏的下方,并且于手势层的上方,请不要将 cytronView 放 入包含手势操作的 View 中。
6. `SDK`目前支持系统为 ios* 以上。
7. 旧版本互动层 SDK 只可以用旧版本 video++后台打点，Cytron 是新版本互 动层，新版本 SDK 只可以用新版本 videoOS 后台打点，新版本与旧版本后台 热点数据不互通。
8. 存在bundle包时请将bundle包放入资源文件中,使SDK能正常调用。
 