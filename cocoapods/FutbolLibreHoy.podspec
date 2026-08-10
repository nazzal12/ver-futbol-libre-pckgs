Pod::Spec.new do |s|
  s.name             = 'FutbolLibreHoy'
  s.version          = '1.0.0'
  s.summary          = 'Futbol Libre Hoy - today football fixtures from Futbol Libre'
  s.description      = <<-DESC
    Small Swift client for the public Futbol Libre matchday calendar feed.
    Formats scores, filters live games, and groups fixtures by competition.
  DESC
  s.homepage         = 'https://verfutbollibre.net'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NBK Devs' => 'nazzal5448@gmail.com' }
  s.source           = {
    :git => 'https://github.com/nazzal12/ver-futbol-libre-pckgs.git',
    :tag => "cocoapods-#{s.version}"
  }
  s.social_media_url = 'https://verfutbollibre.net'

  s.ios.deployment_target  = '13.0'
  s.osx.deployment_target  = '10.15'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'

  s.swift_versions = ['5.7', '5.8', '5.9', '5.10']
  s.source_files = 'Sources/FutbolLibreHoy/**/*.swift'
  s.frameworks = 'Foundation'
end
