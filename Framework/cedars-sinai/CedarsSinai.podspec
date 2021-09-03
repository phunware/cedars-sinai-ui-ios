#
#  Be sure to run `pod spec lint CedarsSinai.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "CedarsSinai"
  s.version      = "0.0.2"
  s.summary      = "Mapping module as framework for CedarsSinai."
  s.author       = "Phunware, Inc"
  s.homepage     = "https://phunware.com"

  s.platform     = :ios, "9.3"

  s.source       = { :git => "ssh://git@bitbucket.phunware.com:7999/services/sdk-cedars-sinai-ios.git", :tag => "#{s.version}" }

  s.vendored_frameworks = 'Framework/CedarsSinai.framework'

  s.dependency "PWMapKit", "~> 3.4"
  s.dependency "PWEngagement", "~> 3.4"
  s.dependency "Kingfisher", "~> 4.0"

end
