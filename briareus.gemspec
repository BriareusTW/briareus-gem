# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'briareus/version'

Gem::Specification.new do |spec|
  spec.name          = 'briareus'
  spec.version       = Briareus::VERSION
  spec.authors       = ['ayaya']
  spec.email         = ['ayaya@briareus.tw']
  spec.description   = %q{Briareus service}
  spec.summary       = %q{Briareus service}
  spec.homepage      = ''
  spec.license       = 'PRIVATE'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
