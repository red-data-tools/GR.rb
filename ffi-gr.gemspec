# frozen_string_literal: true

require_relative 'lib/gr/version'

Gem::Specification.new do |spec|
  spec.name          = 'ffi-gr'
  spec.version       = GR::VERSION
  spec.authors       = 'kojix2'
  spec.email         = '2xijok@gmail.com'

  spec.summary       = 'GR for Ruby'
  spec.description   = 'GR for Ruby'
  spec.homepage      = 'https://github.com/kojix2/ffi-gr'
  spec.license       = 'MIT'

  spec.files         = Dir['*.{md,txt}', '{lib}/**/*']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'ffi'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake', '~> 10.0'
end
