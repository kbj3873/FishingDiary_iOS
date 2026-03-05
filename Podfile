# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

platform :ios, '13.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'SeaThermo' do
    use_frameworks!

    pod 'KakaoMapsSDK', '2.6.3'
    pod 'RealmSwift'

    # 필수: Analytics
    pod 'FirebaseAnalytics'
  
    # 추천: 크래시 추적 및 원격 구성
    pod 'FirebaseCrashlytics'
    pod 'FirebaseRemoteConfig'

    post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
          config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
          config.build_settings['CODE_SIGN_IDENTITY'] = ""
        end
      end
    end
end
