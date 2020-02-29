# frozen_string_literal: true

require_relative 'lib/gr_commons/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby-gr'
  spec.version       = GRCommons::VERSION
  spec.authors       = 'kojix2'
  spec.email         = '2xijok@gmail.com'

  spec.summary       = 'GR for Ruby'
  spec.description   = 'GR framework - the graphics library for visualisation - for Ruby'
  spec.homepage      = 'https://github.com/red-data-tools/GR.rb'
  spec.license       = 'MIT'

  spec.files         = Dir['*.{md,txt}', '{lib}/**/*']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'histogram'
  spec.add_development_dependency 'numo-narray'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'test-unit'
end
