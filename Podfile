# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'

target 'whatiread' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
   use_frameworks!

  # Pods for whatiread
	pod 'RateView'
	pod 'DatePickerDialog-ObjC', '~> 1.2'
	pod 'GKActionSheetPicker', '~> 0.5'
	pod 'AFNetworking', '~> 3.0'
	pod 'SDWebImage', '~> 4.0'
	pod 'MTBBarcodeScanner'
	pod 'TOCropViewController'
	pod 'TesseractOCRiOS'
	pod 'SyncKit/CoreData', '~> 0.6.3'
	pod 'Toast', '~> 3.1'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end