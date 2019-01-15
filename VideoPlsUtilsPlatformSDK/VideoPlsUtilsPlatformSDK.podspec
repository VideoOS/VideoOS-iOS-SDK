#
# Be sure to run `pod lib lint VideoPlsUtilsPlatformSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VideoPlsUtilsPlatformSDK'
  s.version          = '1.0.0'
  s.summary          = 'A private Utils Platform framework for VideoPls.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        A private Utils Platform framework for VideoPls.Including Networking, LoadImage, MQTT, Encryption
                       DESC

  s.homepage         = 'https://git.coding.net/Zard1096/VideoPlsWorkspace.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'VideoPlsUtilsPlatformSDK/LICENSE' }
  s.author           = { 'Zard1096'     => 'mr.zardqi@gmail.com',
                         'LiShaoshuai'  => 'lishaoshuai1990@gmail.com',   
                         'Bill'         => 'fuleiac@gmail.com'          }
  s.source           = { :git => 'https://gitlab.videojj.com/Mobile/VideoPls-iOS-SDK', :tag => s.version.to_s }
  #s.source           = { :git => 'https://git.coding.net/Zard1096/VideoPlsUtilsPlatformPod.git', :branch => 'build' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.libraries = 'z', 'sqlite3'
  s.frameworks = 'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'ImageIO', 'MobileCoreServices', 'WebKit', 'Photos'

  #s.dependency 'AFNetworking', '~>2.0'
  #s.dependency 'SDWebImage', '4.2.2'

  #s.dependency 'VPLuaViewSDK'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h', 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/{Common,Project}/**/*.{h,m,c}', 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/**/*.{h,m,c}'
    core.public_header_files = [
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/{VPUPDebugSwitch,VPUPGeneralInfo,VPUPSDKInfo,VPUPLifeCycle,VPUPLogUtil,VPUPServerUTCDate,VPUPRandomUtil,VPUPValidator,VPUPAutoNumberIDUtil,VPUPNotificationCenter,VPUPReachability,VPUPJsonUtil,VPUPPathUtil,VPUPUtils,VPUPViewScaleUtil,VPUPTopViewController,VPUPDeviceUtil}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/Encryption/{VPUPEncryption,VPUPCommonEncryption,VPUPBase64Util,VPUPMD5Util,VPUPSHAUtil,VPUPAESUtil,VPUPGZIPUtil}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/WebImage/{VPUPLoadImageHeader,VPUPLoadImageFactory,VPUPLoadImageManager,VPUPLoadImageBaseConfig,VPUPLoadImageButtonConfig,VPUPLoadImageFrameListConfig}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Report/{VPUPReportHeader,VPUPReportEnum,VPUPReport}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/PrefetchManager/{VPUPPrefetchHeader,VPUPPrefetchManager,VPUPPrefetchImageManager,VPUPPrefetchVideoManager}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/HTTP/**/{VPUPHTTPNetworking,VPUPHTTPAPIEnum,VPUPHTTPManagerFactory,VPUPHTTPAPIManager,VPUPHTTPManagerConfig,VPUPNetworkErrorObserverProtocol,VPUPHTTPBaseAPI,VPUPHTTPBatchAPIs,VPUPHTTPGeneralAPI,VPUPHTTPBusinessAPI}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/MQTT/{VPUPMQTTHeader,VPUPMQTTObserverProtocol,VPUPPersistentConnectionDelegate,VPUPMessageTransferStation,VPUPPersistentConnectionFactory}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Player/{VPUPPlayer,VPUPVideoClip,VPUPVideo}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Database/**/*.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Route/**/*.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/DataService/**/*.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/WebView/VPUPBasicWebView.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/NormalView/VPUPClickThroughView.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/DownLoad/{VPUPDownloadHeader,VPUPDownloadRequest,VPUPDownloadBatchRequest,VPUPDownloaderManager,VPUPResumeDownloader}.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/ImagePicker/VPUPImagePickerController.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/SVGA/**/*.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/FLAnimatedImage/{VPUPFLAnimatedImageView.h,VPUPFLAnimatedImage.h}',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/FLAnimatedImage/FrameList/*.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/HexColors/HexColors/VPUPHexColors.h',
        'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/OrderedDictionary/VPUPOrderedDictionary.h'
    ]
  end  

  s.subspec 'SVGA' do |svga|
    svga.dependency 'VideoPlsUtilsPlatformSDK/Core'
    svga.dependency 'SVGAPlayer', '2.1.1'
    svga.source_files = [
      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/SVGA/*.{h,m,c}'
    ]
    svga.public_header_files = [

    ]
  end  

  s.subspec 'HTTP' do |http|
    http.dependency 'VideoPlsUtilsPlatformSDK/Core'
    http.dependency 'AFNetworking', '~>2.0'
    http.source_files = [
      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/HTTP/*.{h,m,c}'
    ]
    http.public_header_files = [
      
    ]
  end

  s.subspec 'Image' do |image|
    image.dependency 'VideoPlsUtilsPlatformSDK/Core'
    image.dependency 'SDWebImage', '4.2.2'
    image.source_files = [
      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/Image/*.{h,m,c}',
      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/Image/FrameList/*.{h,m,c}',
      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/Image/VPUPSDWebImage/*.{h,m,c}'
    ]
    image.public_header_files = [
      
    ]
  end

  s.subspec 'MQTT' do |mqtt|
    mqtt.dependency 'VideoPlsUtilsPlatformSDK/Core'
    mqtt.source_files = [
      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/MQTT/**/*.{h,m,c}'
    ]
    mqtt.public_header_files = [
      
    ]
  end

  #s.default_subspec = 'Common'


#  s.subspec 'libvpupwebp' do |webp|
#    webp.ios.deployment_target = '7.0'
#    webp.requires_arc = false
#    webp.compiler_flags = '-D_THREAD_SAFE'

#    webp.subspec 'webp' do |webp|
#      webp.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/SDWebImage/libwebp/src/webp/*.{h}'
#      webp.header_dir = 'webp'
#    end

#    webp.subspec 'core' do |core|
#      core.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/SDWebImage/libwebp/src/{utils,dsp,enc,dec}/*.{h,c}'
#      core.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/libvpupwebp/webp'
#    end

#    webp.subspec 'utils' do |utils|
#      utils.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/libvpupwebp/core'
#    end

#    webp.subspec 'dsp' do |dsp|
#      dsp.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/libvpupwebp/core'
#    end

#    webp.subspec 'enc' do |enc|
#      enc.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/libvpupwebp/core'
#    end

#    webp.subspec 'dec' do |dec|
#      dec.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/libvpupwebp/core'
#    end

#    webp.subspec 'demux' do |demux|
#      demux.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/SDWebImage/libwebp/src/demux/*.{h,c}'
#      demux.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/libvpupwebp/core'
#    end

#    webp.subspec 'mux' do |mux|
#      mux.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/SDWebImage/libwebp/src/mux/*.{h,c}'
#      mux.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/libvpupwebp/core'
#    end
#

#  end


#s.subspec 'libvpupwebp' do |webp|
#  webp.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/SDWebImage/libwebp/include/*.h'
#  webp.vendored_libraries  = 'VideoPlsUtilsPlatform/Vendor/SDWebImage/libwebp/libvpupwebp.a'
#end

#  s.xcconfig = { 
#      'USER_HEADER_SEARCH_PATHS' => '$(inherited) $(SRCROOT)/Vendor/SDWebImage/libwebp/include'
#    }

#Vendor

#s.subspec 'Vendor' do |vendor|
#  vendor.subspec 'VPUPYYImage' do |yyimage|
#    yyimage.ios.deployment_target = '7.0'
#    yyimage.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/SDWebImage/YYImage/*.{h,m}'
#    yyimage.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/SDWebImage/YYImage/VPUPYYAnimatedImageView.h'
#    yyimage.header_dir = 'VideoPlsUtilsPlatformSDK'
#    yyimage.libraries = 'z'
#  end

#  vendor.subspec 'VPUPSDWebImage' do |sdimage|
#    sdimage.ios.deployment_target = '7.0'
#    sdimage.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/SDWebImage/SDWebImage/**/*.{h,m}'
#    sdimage.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/VPUPYYImage'
##    sdimage.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/libvpupwebp'
#    sdimage.frameworks = 'ImageIO'
#  end

#  vendor.subspec 'VPUPMQTT' do |mqtt|
#    mqtt.ios.deployment_target = '7.0'

#    mqtt.subspec 'libvpupmosquitto' do |mosq|
#        mosq.ios.deployment_target = '7.0'
#        mosq.compiler_flags = '-D_THREAD_SAFE'
#        mosq.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/MQTTbyMosquitto/libmosquitto/*.{h,c}'
#    end

#    mqtt.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/MQTTbyMosquitto/*.{h,m}'
#  end

#  vendor.subspec 'VPUPHexColors' do |hc|
#    hc.ios.deployment_target = '7.0'
#    hc.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/HexColors/**/*.{h,m}'
#  end

#  vendor.subspec 'VPUPFMDB' do |fmdb|
#    fmdb.ios.deployment_target = '7.0'
#    fmdb.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/FMDB/fmdb/*.{h,m}'
#    fmdb.library = 'sqlite3'
#  end

#  vendor.subspec 'VPUPAFNetworking' do |afn|
#    afn.ios.deployment_target = '7.0'
#    afn.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/AFNetworking/AFNetworking/*.{h,m}'
#    afn.frameworks = 'MobileCoreServices', 'CoreGraphics', 'Security'
#  end
#end

#project
#s.subspec 'Common' do |common|
#  common.ios.deployment_target = '7.0'
#  common.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor'
#  common.libraries = 'z', 'bz2'
#  common.frameworks = 'AVFoundation'
#  common.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h', 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/**/*.{h,m,c}'
#  common.public_header_files = [
#      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h',
#      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/{VPUPDebugSwitch,VPUPGeneralInfo,VPUPSDKInfo,VPUPLifeCycle,VPUPLogUtil,VPUPServerUTCDate,VPUPRandomUtil,VPUPValidator,VPUPAutoNumberIDUtil,VPUPNotificationCenter,VPUPReachability,VPUPUtils}.h',
#      #'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/VPUPUtils.h',
#      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/Encryption/{VPUPEncryption,VPUPCommonEncryption,VPUPBase64Util,VPUPMD5Util,VPUPSHAUtil,VPUPAESUtil,VPUPGZIPUtil}.h',
#      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/WebImage/{VPUPLoadImageHeader,VPUPLoadImageFactory,VPUPLoadImageManager,VPUPLoadImageBaseConfig,VPUPLoadImageButtonConfig}.h',
#      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Report/{VPUPReportHeader,VPUPReportEnum,VPUPReport}.h',
#      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/PrefetchManager/{VPUPPrefetchHeader,VPUPPrefetchManager,VPUPPrefetchImageManager,VPUPPrefetchVideoManager}.h',
#      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/HTTP/**/{VPUPHTTPNetworking,VPUPHTTPAPIEnum,VPUPHTTPManagerFactory,VPUPHTTPAPIManager,VPUPHTTPManagerConfig,VPUPNetworkErrorObserverProtocol,VPUPHTTPBaseAPI,VPUPHTTPBatchAPIs,VPUPHTTPGeneralAPI,VPUPHTTPBusinessAPI}.h',
#      'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/MQTT/{VPUPMQTTHeader,VPUPMQTTManager,VPUPMQTTObserverProtocol,VPUPMQTTManagerFactory,VPUPMQTTConfig}.h',
#  ]
#end

  #s.ios.deployment_target = '7.0'
  #s.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor'


#s.subspec 'Common' do |common|
#  common.ios.deployment_target = '7.0'
#   # common.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/**/*.{h,m,c}'
#  common.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor'
#   # common.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPAFNetworking'
#   # common.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPFMDB'
#   # common.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPMQTT'
#   # common.frameworks = 'UIKit', 'Foundation'
#  common.libraries = 'z', 'bz2'

#  common.subspec 'Utils' do |util|
#    util.ios.deployment_target = '7.0'
#    util.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/*.{h,m}'
#    #util.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/VPUPUtils.h'
# #   util.frameworks = 'UIKit', 'Foundation'
# #   util.libraries = 'z', 'bz2'

#  end

#  common.subspec 'Encryption' do |enc|
#    enc.ios.deployment_target = '7.0'
#    enc.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/Encryption/*.{h,m,c}'
#    #enc.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/Encryption/VPUPEncryption.h'
#    enc.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils'
##    image.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPSDWebImage'
#  end

#  common.subspec 'WebImage' do |image|
#    image.ios.deployment_target = '7.0'
#    image.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/WebImage/*.{h,m}'
#    #image.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/WebImage/VPUPLoadImageHeader.h'
#    image.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils'
##    image.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPSDWebImage'
#  end

#  common.subspec 'HTTP' do |http|
#    http.ios.deployment_target = '7.0'
#    http.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/HTTP/**/*.{h,m}'
#    #http.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/HTTP/VPUPHTTPNetworking.h'
#    http.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils'
#    http.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Encryption'
# #   http.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPAFNetworking'
#  end

#  common.subspec 'MQTT' do |mqtt|
#    mqtt.ios.deployment_target = '7.0'
#    mqtt.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/MQTT/*.{h,m,c}'
#    #mqtt.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/MQTT/VPUPMQTTHeader.h'
#    mqtt.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils'
#    mqtt.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Encryption'
#  #  mqtt.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPMQTT'
#  end

#  common.subspec 'Prefetch' do |pre|
#    pre.ios.deployment_target = '7.0'
#    pre.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/PrefetchManager/*.{h,m}'
#    #pre.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/PrefetchManager/VPUPPrefetchManager.h'
#    pre.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/HTTP'
#    pre.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/WebImage'
#  #  mqtt.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPMQTT'
#  end

#  common.subspec 'Database' do |db|
#    db.ios.deployment_target = '7.0'
#    db.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Database/**/*.{h,m}'
#    db.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils'
#    #db.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/HTTP'
#    #db.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Vendor/VPUPFMDB'
#  end

#  common.subspec 'Report' do |report|
#    report.ios.deployment_target = '7.0'
#    report.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Report/*.{h,m}'
#    #report.public_header_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Report/VPUPReportHeader.h'
#    report.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils'
#    report.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/HTTP'
#    report.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Database'
#    report.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Encryption'
#  end

#  common.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/*.h'
#end


#s.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/*.h'
#s.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common'


#  s.subspec 'Utils' do |util|
#    util.ios.deployment_target = '7.0'
#    util.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Utils/**/*.{h,m,c}'
#    util.frameworks = 'UIKit', 'Foundation'
#    util.libraries = 'z', 'bz2'
#  end
#
#  s.subspec 'WebImage' do |image|
#    image.ios.deployment_target = '7.0'
#    image.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/WebImage/*.{h,m}'
#    image.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Utils'
#    image.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPSDWebImage'
#  end
#
#  s.subspec 'HTTP' do |http|
#    http.ios.deployment_target = '7.0'
#    http.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/HTTP/**/*.{h,m}'
#    http.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Utils'
#    http.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPAFNetworking'
#  end
#
#  s.subspec 'MQTT' do |mqtt|
#    mqtt.ios.deployment_target = '7.0'
#    mqtt.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/MQTT/**/*.{h,m,c}'
#    mqtt.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Utils'
#    mqtt.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPMQTT'
#  end
#
#  s.subspec 'Database' do |db|
#    db.ios.deployment_target = '7.0'
#    db.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Database/**/*.{h,m}'
#    db.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Utils'
#    db.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/HTTP'
#    db.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/VPUPFMDB'
#  end
#
#  s.subspec 'Report' do |report|
#    report.ios.deployment_target = '7.0'
#    report.source_files = 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Common/Report/*.{h,m}'
#    report.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Utils'
#    report.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/HTTP'
#    report.dependency 'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Database'
#  end

  # s.resource_bundles = {
  #   'VideoPlsUtilsPlatformSDK' => ['VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'

end
