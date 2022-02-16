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

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'fiddle'
  spec.add_dependency 'histogram'
  spec.add_dependency 'numo-narray'
  spec.add_dependency 'pkg-config'

  spec.metadata['msys2_mingw_dependencies'] = 'gr'
end
