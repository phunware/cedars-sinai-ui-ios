Pod::Spec.new do |s|

  s.name         = "CedarsSinai"
  s.version      = "0.0.21"
  s.summary      = "Mapping module as framework for CedarsSinai."
  s.author       = "Phunware, Inc"
  s.homepage     = "https://phunware.com"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/gmorales-phunware/CedarsSinai", :tag => "#{s.version}" }
  s.requires_arc = true
  s.ios.vendored_frameworks = "Framework/*.framework"
  s.dependency "PWMapKit", "~> 3.4.0"
  s.dependency "PWEngagement", "~> 3.4.0"
  s.dependency "Kingfisher", "~> 4.0"
  s.dependency "SDCAlertView", "~> 8.0"
end

