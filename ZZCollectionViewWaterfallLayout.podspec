#
# Be sure to run `pod lib lint ZZCollectionViewWaterfallLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ZZCollectionViewWaterfallLayout"
  s.version          = "1.0.2"
  s.summary          = "A Collectionview waterfall layout in OC for iOS"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Make it easy to use OC for writing waterfall layout with any colums you want.
                       DESC

  s.homepage         = "https://github.com/October-zhuo/ZZCollectionViewWaterfallLayout.git"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "zhuo" => "chenlizhuo10@163.com" }
  s.source           = { :git => "https://github.com/October-zhuo/ZZCollectionViewWaterfallLayout.git", :tag => s.version.to_s }
  s.ios.deployment_target = "7.0"
  s.source_files = "ZZCollectionViewWaterfallLayout/*.{h,m}"
  s.frameworks = "UIkit"
end
