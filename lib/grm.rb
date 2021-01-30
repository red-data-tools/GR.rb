# frozen_string_literal: true

# Check Fiddle version.
require 'fiddle'

# Check if fiddle supports variadic arguments.
# Fiddle is a standard Gem and may not have VERSION constant.
if !Fiddle.const_defined?(:VERSION) ||
   (Gem::Version.new(Fiddle::VERSION) <= Gem::Version.new('1.0.0'))
  raise LoadError, <<~MSG
    Failed to load GRM module
    Fiddle 1.0.1 or higher is required to run GRM.
    See https://github.com/ruby/fiddle
  MSG
end

module GRM
  class Error < StandardError; end

  class NotFoundError < Error; end

  class << self
    attr_accessor :ffi_lib
  end

  require_relative 'gr_commons/gr_commons'

  # Platforms |  path
  # Windows   |  bin/libGRM.dll
  # MacOSX    |  lib/libGRM.so (NOT .dylib)
  # Ubuntu    |  lib/libGRM.so
  self.ffi_lib = case RbConfig::CONFIG['host_os']
                 when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                   GRCommons::GRLib.search('libGRM.dll', 'grm')
                 when /darwin|mac os/
                   GRCommons::GRLib.search('libGRM.dylib', 'grm')
                 else
                   GRCommons::GRLib.search('libGRM.so', 'grm')
                 end

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
