Pod::Spec.new do |s|
  s.name         = "SibcheStoreKit"
  s.version      = "3.0.0"
  s.summary      = "Sibche StoreKit library for mobile apps"
  s.homepage     = "https://sibche.com"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Mehdi" => "mehdi.h@sibche.com"}
  s.source       = { :git => "https://github.com/sibche/SibcheStoreKit.git", :tag => s.version.to_s }
  s.platform     = :ios, "8.0"
  s.requires_arc = true

  s.ios.vendored_frameworks = 'SibcheStoreKit/Framework/SibcheStoreKit.framework'
  s.framework               = 'UIKit'
end
