#
# Be sure to run `pod lib lint VideoPlsUtilsPlatformSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VideoPlsUtilsPlatformSDKImage'
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
  s.source           = { :git => 'https://git.coding.net/shshjing/VideoPlsUtilsPlatformSDK.git', :tag => s.version.to_s }
  #s.source           = { :git => 'https://git.coding.net/Zard1096/VideoPlsUtilsPlatformPod.git', :branch => 'build' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.requires_arc = true
  s.ios.deployment_target = '8.0'
    

  s.dependency 'VideoPlsUtilsPlatformSDK/Core', '0.0.1'
  s.dependency 'SDWebImage', '4.2.2' 
  s.source_files = [
    'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/Image/*.{h,m,c}',
    'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/Image/FrameList/*.{h,m,c}',
    'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/Image/VPUPSDWebImage/*.{h,m,c}'
  ]
  s.public_header_files = [
    'VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK/Subspec/Image/*.h'
  ]

end
