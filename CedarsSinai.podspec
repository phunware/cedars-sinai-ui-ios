Pod::Spec.new do |s|

  s.name         = "CedarsSinai"
  s.version      = "0.0.33"
  s.summary      = "Mapping module as framework for CedarsSinai."
  s.author       = "Phunware, Inc"
  s.homepage     = "https://phunware.com"
  s.platform     = :ios, "10.1"
  s.source       = { :git => "https://github.com/phunware/cedars-sinai-ui-ios", :tag => "#{s.version}" }
  s.requires_arc = true
  s.ios.vendored_frameworks = "Framework/*.framework"
  s.dependency "PWCore", "3.8.6"
  s.dependency "PWLocation", "3.8.1"
  s.dependency "PWMapKit", "3.8.1"
  s.dependency "PWEngagement", "3.7.2"
  s.dependency "Kingfisher", "~> 4.0"
  s.dependency "SDCAlertView", "~> 9.0"
end

