platform :ios, '12.0'
 use_frameworks!
 
 target 'YiHackStream' do
   pod 'MobileVLCKit', '~> 3.5'
 end


 post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Fix for Xcode 14+ sandbox issues
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
      config.build_settings['CODE_SIGN_ENTITLEMENTS'] = ''
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['ENABLE_HARDENED_RUNTIME'] = 'NO'
      
      # Fix for simulator builds
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end
  
  # Fix file permissions and sandbox issues
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  end
end