# Uncomment the next line to define a global platform for your project
platform :ios, '9.3'

inhibit_all_warnings!

def shared_pods
    # SDK 需要
    sdk_pods
    # demo 需要
    pod 'MBProgressHUD'
    pod 'GDPerformanceView', '~> 1.3.1'
    
end

def sdk_pods
  # SDK 需要
  pod 'AFNetworking'
  pod 'Sentry'                    # 上报系统
  pod 'CocoaLumberjack'           # Log日志
  pod 'WebViewJavascriptBridge'
  pod 'MGJRouter', '~>0.9.0'
  pod 'YYModel', '~> 1.0.4'
  pod 'NEImage', '~> 1.0.0'
  pod 'MSWeakTimer', '~> 1.1.0'
end

target 'ALTSDK' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for ALTSDK
  shared_pods
end

target 'ALTAVSDK' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!
  
  # Pods for ALTSDK
  shared_pods
end

target 'ALTPlayerFramework' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!
  
  # Pods for ALTSDK
  shared_pods
end


#新scheme在pods里Debug模式无效解决方案：http://stackoverflow.com/questions/21046282/debug-preprocessor-macro-not-defined-for-cocoapods-targets
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.name != 'Release'
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=1']
                config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-DDEBUG']
            end
        end
    end
end
