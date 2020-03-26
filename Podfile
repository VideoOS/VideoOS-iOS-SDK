# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'
install! 'cocoapods', :deterministic_uuids => false

source 'https://github.com/CocoaPods/Specs.git'
#source 'https://git.coding.net/Zard1096/VideoPlsPodsRepo.git'


workspace 'VideoPlsWorkspace'

project 'Example/VPInterfaceControllerDemo'

target 'VPInterfaceControllerDemo' do

pod 'VideoOS', :path => '.'
pod 'VideoOS/ACRCloud', :path => '.'

pod 'Bugly'
pod 'UMengAnalytics-NO-IDFA'
pod 'Masonry'
pod 'MBProgressHUD'
pod 'SVGAPlayer'
end

target 'VideoOSDevApp' do

pod 'VideoOS', :path => '.'
pod 'VideoOS/ACRCloud', :path => '.'

pod 'Bugly'
pod 'UMengAnalytics-NO-IDFA'
pod 'Masonry'
pod 'MBProgressHUD'
pod 'SVGAPlayer'
end

# 加入这些配置
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "Masonry"
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
      end
    end
  end
end
  
