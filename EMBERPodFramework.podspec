#
# Be sure to run `pod lib lint EMBERPodFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'EMBERPodFramework'
    s.version          = '0.1.11'
    s.summary          = 'A short description of EMBERPodFramework. This pod to expose some of the EMBER App feature to commercial use'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    A short description of EMBERPodFramework. This pod to expose some of the EMBER App feature to commercial use
    DESC
    
    s.homepage         = 'https://github.com/EnasAhmedZaki/EMBERPodFramework'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'EnasAhmedZaki' => 'enas@embermed.com' }
    
    s.ios.deployment_target = '11.0'
    s.ios.vendored_frameworks = 'EMBERPodFramework.framework'
    
    s.source           = { :git => 'https://github.com/EnasAhmedZaki/EMBERPodFramework.git', :tag => s.version.to_s }
    #s.source            = { :http => 'https://drive.google.com/file/d/1roLDjc-ZZCnAwLxRoGyJzRYPlVirtUAj/view?usp=sharing' }
    #s.resource = 'EMBERPodFramework/TestResourceBundle.bundle'


    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    

    #s.source_files = "EMBERPodFramework/**/*.{swift}"
    #s.exclude_files = "EMBERPodFramework/**/*.plist"

    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'OpenTok'
    s.dependency 'Firebase'
    s.dependency 'SendBirdSDK'
    s.dependency 'RxAlamofire'
    s.dependency 'ObjectMapper'
    s.dependency 'NotificationBannerSwift'
    s.dependency 'ImageViewer'
    s.dependency 'AMShimmer'
    s.dependency 'RSKImageCropper'
    s.dependency 'WXImageCompress', '~> 0.1.1'
    s.dependency 'SkyFloatingLabelTextField'
    s.dependency 'RxCocoa'
    #s.swift_version    = '5.0'
    #s.platform         = :ios, "11.0"
    #s.static_framework = true
    
end
