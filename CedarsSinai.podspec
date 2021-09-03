Pod::Spec.new do |s|

  s.name         = "CedarsSinai"
  s.version      = "0.0.46"
  s.summary      = "Mapping module as framework for CedarsSinai."
  s.author       = "Phunware, Inc"
  s.homepage     = "https://phunware.com"
  s.platform     = :ios, "10.1"
  s.source       = { :git => "https://github.com/phunware/cedars-sinai-ui-ios", :tag => "#{s.version}" }
  s.requires_arc = true
  s.ios.vendored_frameworks = "Framework/*.framework"
  s.dependency "PWMapKit/NoAds", "3.9.1"
  s.dependency "PWEngagement/NoAds", "3.7.4"
  s.dependency "Kingfisher", "5.7.1"
  s.dependency "SDCAlertView", "11.1.2"
end

