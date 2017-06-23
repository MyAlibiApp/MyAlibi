# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

use_frameworks!

target 'FloatNote' do

  	pod 'HDAugmentedReality', :git => 'https://github.com/DanijelHuis/HDAugmentedReality.git'

	pod 'Firebase/Core'
	
	pod 'Firebase/Database’	

end

target 'FloatNoteTests' do
    
end

target 'FloatNoteUITests' do
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
