
Pod::Spec.new do |s|
  s.name             = 'Ecoji'
  s.version          = '1.1.1'
  s.summary          = 'Provides a library for encoding and decoding data as a base-1024 sequence of emojis.'

  s.description      = <<-DESC
A Swift 5 implementation of the [Ecoji](https://github.com/keith-turner/ecoji) encoding standard.

Provides a library for encoding and decoding data as a base-1024 sequence of emojis

                       DESC

  s.homepage         = 'https://github.com/Robindiddams/ecoji-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE-MIT' }
  s.author           = { 'Robin Diddams' => 'robindiddams@gmail.com' }
  s.source           = { :git => 'https://github.com/Robindiddams/ecoji-swift.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source_files = 'Sources/Ecoji/**/*'
  
  # s.resource_bundles = {
  #   'Ecoji' => ['Ecoji/Assets/*.png']
  # }


end
