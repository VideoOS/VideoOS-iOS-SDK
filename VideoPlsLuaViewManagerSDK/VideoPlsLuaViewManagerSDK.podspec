#
# Be sure to run `pod lib lint VideoPlsLiveSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VideoPlsLuaViewManagerSDK'
  s.version          = '1.0.0'
  s.summary          = 'VideoPls Lua View Manager.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                      'VideoPls Lua View Manager for iOS to show within backend'
                       DESC

  s.homepage         = 'https://git.coding.net/Zard1096/VideoPlsWorkspace.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'VideoPlsLuaViewManagerSDK/LICENSE' }
  s.author           = { 'Zard1096'     => 'mr.zardqi@gmail.com',
                         'LiShaoshuai'  => 'lishaoshuai1990@gmail.com',   
                         'Bill'         => 'fuleiac@gmail.com'          }
  s.source           = { :git => 'https://gitlab.videojj.com/Mobile/VideoPls-iOS-SDK', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'VideoPlsLuaViewManagerSDK/VideoPlsLuaViewManagerSDK/**/*.{h,m}'
  #s.public_header_files = ['VideoPlsLuaViewSDK/VideoPlsLuaViewSDK/VPLua/**/*.h']

  s.dependency 'VideoPlsUtilsPlatformSDK', '0.0.1'
  s.dependency 'VPLuaViewSDK'
  s.frameworks = 'WebKit','CoreMedia'
  s.library = 'sqlite3','z'

  
  # s.resource_bundles = {
  #   'VideoPlsLiveSDK' => ['VideoPlsLiveSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
