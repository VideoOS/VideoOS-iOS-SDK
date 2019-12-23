# If you've made changes to the SDK (such as file paths), consider using `pod lib lint` to lint locally and then using the :path option in your Podfile

Pod::Spec.new do |s|

  s.name         = "VideoOS"
  s.version      = "2.9.0"
  s.summary      = "Official VideoPls SDK for iOS to access VideoPls Platform with features like video os, and live os"

  s.description  = <<-DESC
                   The VideoPls SDK for iOS enables you to use VideoPls's Platform such as:
                   *video os
                   *live os
                   DESC

  s.homepage     = "http://videojj.com/videoos-open"
  s.license      = { :type => "GPL-3.0", :file => "LICENSE" }
  s.author       = 'VideoPls'

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/VideoOS/VideoOS-iOS-SDK.git",
                     :tag => s.version.to_s
                    }

  s.libraries = 'z', 'sqlite3'
  s.weak_frameworks = 'UIKit', 'Foundation','AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'ImageIO', 'MobileCoreServices', 'WebKit', 'Photos', 'CoreData', 'WebKit','CoreMedia','Accelerate'

  s.requires_arc = true
  s.default_subspec = 'Interface'
  s.dependency 'VPLuaViewSDK'
  s.resources    = "Resources/VideoPlsResources.bundle"

  s.subspec 'Platform' do |spec|
    spec.source_files   = "VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/**/*.{h,m,c}"
    #spec.exclude_files = "VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Internal/FBSDKDynamicFrameworkLoader.m"
    spec.public_header_files = "VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/**/*.{h}"
    spec.header_dir = "VideoPlsUtilsPlatformSDK"
    spec.dependency 'AFNetworking'
    spec.dependency 'SDWebImage'   #SDWebImage建议使用4.2.2，最新版本的SDWebImage会导致相同地址的gif在第二次加载时无法播放
    spec.dependency 'SVGAPlayer', '2.1.4'
    spec.dependency 'MQTTClient'
    spec.xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1'}
  end
  s.subspec 'LuaManager' do |spec|
   spec.source_files   = "VideoPlsLuaViewManagerSDK/VideoPlsLuaViewManagerSDK/**/*.{h,m}"
   spec.public_header_files = "VideoPlsLuaViewManagerSDK/VideoPlsLuaViewManagerSDK/**/*.{h}"
   spec.header_dir = "VideoPlsLuaViewManagerSDK"
   spec.dependency 'VideoOS/Platform'
  end
  s.subspec 'Interface' do |spec|
   spec.source_files   = "VideoPlsInterfaceControllerSDK/VideoPlsInterfaceControllerSDK/**/*.{h,m}"
   spec.public_header_files = "VideoPlsInterfaceControllerSDK/VideoPlsInterfaceControllerSDK/**/*.{h}"
   spec.exclude_files = "VideoPlsInterfaceControllerSDK/VideoPlsInterfaceControllerSDK/VideoPlsInterfaceControllerSDK/{VPIPubWebView,VPIStoreAPIConfig}.{h,m}"
   spec.header_dir = "VideoPlsInterfaceControllerSDK"
   spec.dependency 'VideoOS/LuaManager'
  end

end
