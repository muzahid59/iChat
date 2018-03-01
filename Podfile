# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

def common_pods
    pod 'Firebase/Storage'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'JSQMessagesViewController'
    pod 'IQKeyboardManagerSwift'
end 

target 'iChat' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    
    common_pods
end

target 'iChatTests' do
    inherit! :search_paths
    common_pods
end

target 'iChatUITests' do
    inherit! :search_paths
    # Pods for testing
end

