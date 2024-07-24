
platform :ios, '17.0'


target 'PoseFit' do
 
  use_frameworks!
 
  pod 'GoogleMLKit/PoseDetection'
  pod 'GoogleMLKit/PoseDetectionAccurate'
  pod 'GoogleMLKit/SegmentationSelfie'
  pod 'PromisesObjC'
  pod 'FirebaseAuth'
  pod 'FirebaseCore'
  pod 'FirebaseAppCheck'
  pod 'FirebaseFirestore'
  pod 'FirebaseAnalytics'
  pod 'SDWebImageSwiftUI'


 target 'PoseFitTests' do
         
inherit! :search_paths
      
    end
 
  
end








 post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
	config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
       xcconfig_path = config.base_configuration_reference.real_path
       xcconfig = File.read(xcconfig_path)
       xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
       File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
     end
   end
  
 end

