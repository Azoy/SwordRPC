Pod::Spec.new do |s|
  s.name             = 'SwordRPC'
  s.version          = '0.2.0'
  s.summary          = 'A Discord Rich Presence Library for Swift'
  s.homepage         = 'https://github.com/Azoy/SwordRPC'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Azoy'
  s.source           = { :git => 'https://github.com/Azoy/SwordRPC.git', :tag => s.version }

  s.osx.deployment_target = '10.11'
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '4.0.0'
  }

  s.source_files = 'Sources/SwordRPC/*.swift', 'Sources/SwordRPC/Types/*.swift'
  s.dependency 'BlueSocket', '~> 1.0'
end
