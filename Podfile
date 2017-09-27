source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'Jarvis' do
	pod 'Alamofire'
	pod 'SwiftyJSON'
	pod 'Firebase/Core'
	pod 'Firebase/Auth'
	pod 'Firebase/Database'
	pod 'EZSwiftExtensions'
	pod 'SnapKit', '~> 3.2.0'
	pod 'FlexiblePageControl'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end

