#
# Be sure to run `pod lib lint LWZComponents.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWZComponents'
  s.version          = '1.0.0'
  s.summary          = '一些组件库.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "https://github.com/changsanjiang/LWZComponents/blob/master/README.md"

  s.homepage         = 'https://github.com/changsanjiang/LWZComponents'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'changsanjiang' => 'changsanjiang@gmail.com' }
  s.source           = { :git => 'https://github.com/changsanjiang/LWZComponents.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'LWZComponents/*.{h,m}'
  
  s.subspec 'LWZCollectionViewComponents' do |ss|
    ss.source_files = 'LWZComponents/LWZCollectionViewComponents/**/*.{h,m}'
  end
end
