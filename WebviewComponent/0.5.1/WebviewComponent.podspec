#
# Be sure to run `pod lib lint WebviewComponent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WebviewComponent'
  s.version          = '0.5.1'
  s.summary          = 'WebviewContainer for webviewloader & jsbridge.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://git.brightcns.cn/Liujiang'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'howoften' => 'forliujiang@126.com' }
  s.source           = { :git => 'https://git.brightcns.cn/iOS/webviewcomponent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'WebviewComponent/Classes/*.h'
  
  s.resource = 'WebviewComponent/Assets/WebviewComponent.bundle'

#   s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'WebKit'
   # s.dependency 'WebViewJavascriptBridge', '~> 6.0.2'


   s.subspec 'PAWebView' do |p|
       p.source_files = 'WebviewComponent/Classes/PAWebView/**/*'
   end
   
   s.subspec 'Network' do |network|
       network.source_files = 'WebviewComponent/Classes/Network/**/*'
   end
   
   s.subspec 'Tools' do |tool|
       tool.source_files = 'WebviewComponent/Classes/Tools/**/*'
   end
   
   s.subspec 'OAuth' do |auth|
       auth.source_files = 'WebviewComponent/Classes/OAuth/**/*'
       auth.dependency 'WebviewComponent/Tools'
       auth.dependency 'WebviewComponent/Network'
   end
 
   s.subspec 'WebJSBridgeManage' do |bridge|
       bridge.source_files = 'WebviewComponent/Classes/WebJSBridgeManage/**/*'
       bridge.dependency 'WebviewComponent/Tools'
       bridge.dependency 'WebViewJavascriptBridge', '~> 6.0.2'
   end

   s.subspec 'JSBridgeMessageHandle' do |handler|
       handler.source_files = 'WebviewComponent/Classes/JSBridgeMessageHandle/**/*'
       handler.dependency 'WebviewComponent/Tools'
       handler.dependency 'WebviewComponent/WebJSBridgeManage'
   end
   s.subspec 'WebViewLoader' do |loader|
       loader.source_files = 'WebviewComponent/Classes/WebViewLoader/**/*'
       loader.dependency 'WebviewComponent/PAWebView'
       loader.dependency 'WebviewComponent/OAuth'
       loader.dependency 'WebviewComponent/JSBridgeMessageHandle'
       loader.dependency 'WebviewComponent/Tools'
       loader.dependency 'WebviewComponent/WebJSBridgeManage'
   end
end
