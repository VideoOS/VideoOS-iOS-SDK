#
# Be sure to run `pod lib lint VideoPlsInterfaceViewSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VideoPlsInterfaceControllerSDK'
  s.version          = '1.0.0'
  s.summary          = 'VideoPls Public Interface Controller.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                      'VideoPls Interface Controller for easy using VideoOS and LiveOS.'
                       DESC

  s.homepage         = 'https://git.coding.net/Zard1096/VideoPlsWorkspace.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'VideoPlsInterfaceControllerSDK/LICENSE' }
  s.author           = { 'Zard1096'     => 'mr.zardqi@gmail.com',
                         'LiShaoshuai'  => 'lishaoshuai1990@gmail.com',   
                         'Bill'         => 'fuleiac@gmail.com'          }
  s.source           = { :git => 'https://gitlab.videojj.com/Mobile/VideoPls-iOS-SDK', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = [
      'VideoPlsInterfaceControllerSDK/**/VPIConfigSDK.h',
      'VideoPlsInterfaceControllerSDK/**/VPIConfigSDK.m',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceClickThroughView.h',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceClickThroughView.m',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceController.h',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceController.m',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceController+NSNotification.h',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceController+NSNotification.m',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceControllerConfig.h',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceControllerConfig.m',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceStatusNotifyDelegate.h',
      'VideoPlsInterfaceControllerSDK/**/VPIUserLoginInterface.h',
      'VideoPlsInterfaceControllerSDK/**/VPIUserInfo.h',
      'VideoPlsInterfaceControllerSDK/**/VPIUserInfo.m',
      'VideoPlsInterfaceControllerSDK/**/VPIVideoPlayerSize.h',
      'VideoPlsInterfaceControllerSDK/**/VPIVideoPlayerSize.m',
      'VideoPlsInterfaceControllerSDK/**/VPIVideoPlayerDelegate.h',
      'VideoPlsInterfaceControllerSDK/**/VPIServiceManager.h',
      'VideoPlsInterfaceControllerSDK/**/VPIServiceManager.m',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceController+Deprecated.h',
    ]
    core.public_header_files = [
      'VideoPlsInterfaceControllerSDK/**/VPIConfigSDK.h',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceController.h',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceControllerConfig.h',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceStatusNotifyDelegate.h',
      'VideoPlsInterfaceControllerSDK/**/VPIUserLoginInterface.h',
      'VideoPlsInterfaceControllerSDK/**/VPIUserInfo.h',
      'VideoPlsInterfaceControllerSDK/**/VPIVideoPlayerDelegate.h',
      'VideoPlsInterfaceControllerSDK/**/VPIVideoPlayerSize.h',
      'VideoPlsInterfaceControllerSDK/**/VPIVideoPlayerDelegate.h',
      'VideoPlsInterfaceControllerSDK/**/VPIServiceManager.h',
      'VideoPlsInterfaceControllerSDK/**/VPInterfaceController+Deprecated.h',
    ]
  end

  s.dependency 'VideoPlsLuaViewManagerSDK', '0.0.1'
  s.dependency 'VideoPlsUtilsPlatformSDK/HTTP', '0.0.1'
  s.dependency 'VideoPlsUtilsPlatformSDK/Image', '0.0.1'
  s.dependency 'VideoPlsUtilsPlatformSDK/SVGA', '0.0.1'
  s.dependency 'VideoPlsUtilsPlatformSDK/MQTT', '0.0.1'
  # s.resource_bundles = {
  #   'VideoPlsInterfaceViewSDK' => ['VideoPlsInterfaceViewSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
