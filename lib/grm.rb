# frozen_string_literal: true

# Check Fiddle version.
require 'fiddle'

if !Fiddle.const_defined?(:VERSION) ||
   (Gem::Version.new(Fiddle::VERSION) <= Gem::Version.new('1.0.0'))
  warn 'You need the latest version of fiddle to make GRM work. '
  warn 'GRM will end without loading.'
  return
end

module GRM
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  # Platforms |  path
  # Windows   |  bin/libGRM.dll
  # MacOSX    |  lib/libGRM.so (NOT .dylib)
  # Ubuntu    |  lib/libGRM.so
  if Object.const_defined?(:RubyInstaller)
    ENV['GRDIR'] ||= [
      RubyInstaller::Runtime.msys2_installation.msys_path,
      RubyInstaller::Runtime.msys2_installation.mingwarch
    ].join(File::ALT_SEPARATOR)
    self.ffi_lib = File.expand_path('bin/libGRM.dll', ENV['GRDIR'])
    RubyInstaller::Runtime.add_dll_directory(File.dirname(ffi_lib))
  else
    raise Error, 'Please set env variable GRDIR' unless ENV['GRDIR']

    self.ffi_lib = File.expand_path('lib/libGRM.so', ENV['GRDIR'])
  end

  # change the default encoding to UTF-8.
  ENV['GKS_ENCODING'] ||= 'utf8'

  require_relative 'gr_commons/gr_commons'
  require_relative 'grm/version'
  require_relative 'grm/ffi'
  require_relative 'grm/grmbase'

  # `inquiry` methods etc. are defined here.
  extend GRCommons::GRCommonUtils

  # `XXX` is the default type in GR.
  # A Ruby array or NArray passed to GR method is automatically converted to
  # a Fiddley::MemoryPointer in the GRBase class.
  extend GRMBase

  class << self
  end
end
