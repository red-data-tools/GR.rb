# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'ruby-gr'
  spec.version       = '0.0.0'
  spec.authors       = 'kojix2'
  spec.email         = '2xijok@gmail.com'

  spec.summary       = 'GR for Ruby'
  spec.description   = 'GR framework - the graphics library for visualisation - for Ruby'
  spec.homepage      = 'https://github.com/kojix2/GR.rb'
  spec.license       = 'MIT'

  spec.files         = Dir['*.{md,txt}', '{lib}/**/*']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'ffi'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'numo-narray'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
end
