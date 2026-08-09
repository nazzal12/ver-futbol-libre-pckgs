# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'futbol-libre-hoy'
  spec.version       = '1.0.0'
  spec.authors       = ['NBK Devs']
  spec.email         = ['nazzal5448@gmail.com']
  spec.summary       = 'Futbol Libre Hoy — fixtures and live scores from Futbol Libre'
  spec.description   = 'CLI and library to list today\'s football matches from https://verfutbollibre.net'
  spec.homepage      = 'https://verfutbollibre.net'
  spec.license       = 'MIT'
  spec.files         = Dir['lib/**/*', 'bin/*', 'LICENSE', 'DISCLAIMER.md', 'README.md']
  spec.bindir        = 'bin'
  spec.executables   = ['futbol-libre-hoy']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.0'
  spec.metadata['homepage_uri'] = 'https://verfutbollibre.net'
  spec.metadata['source_code_uri'] = 'https://github.com/nazzal12/ver-fubtol-libre-pckgs'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
