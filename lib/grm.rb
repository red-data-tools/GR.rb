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

  require_relative 'gr_commons/gr_commons'
  extend GRCommons::SearchSharedLibrary

  # Platforms |  path
  # Windows   |  bin/libGRM.dll
  # MacOSX    |  lib/libGRM.so (NOT .dylib)
  # Ubuntu    |  lib/libGRM.so
  self.ffi_lib = case RbConfig::CONFIG['host_os']
                 when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                   search_shared_library('libGRM.dll')
                 else
                   search_shared_library('libGRM.so')
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
