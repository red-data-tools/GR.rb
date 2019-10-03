# frozen_string_literal: true

require 'ffi'

module GR3
  class << self
    attr_reader :ffi_lib
  end

  # Platforms |  path
  # Windows   |  bin/libgr3.dll
  # MacOSX    |  lib/libGR3.so (NOT .dylib)
  # Ubuntu    |  lib/libGR3.so

  gr3_lib_name = case RbConfig::CONFIG['host_os']
                 when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                   'bin/libGR3.dll'
                 else
                   'lib/libGR3.so'
                end
  if ENV['GRDIR']
    gr3_lib = File.expand_path(gr3_lib_name, ENV['GRDIR'])
    ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
    @ffi_lib = gr3_lib
  else
    raise 'Please set env variable GRDIR'
  end
end

require_relative 'gr_commons'
require 'gr3/ffi'
require 'gr3/gr3base'

module GR3
  include GRCommons::SupportIRuby
  extend GR3Base

  # 1. double is the default type
  # 2. don't check size (for now)
  class << self
    private

    def inquiry_int(&block)
      inquiry([:int], &block)[0]
    end

    def inquiry_double(&block)
      inquiry([:double], &block)[0]
    end

    def inquiry(types)
      pts = types.map do |type|
        case type
        when Hash
          typ = type.keys[0]
          len = type.values[0]
          ::FFI::MemoryPointer.new(typ, len)
        else
          ::FFI::MemoryPointer.new(type)
        end
      end
      yield(*pts)
      pts.zip(types).map do |pt, type|
        case type
        when Hash
          typ = type.keys[0]
          len = type.values[0]
          pt.send("read_array_of_#{typ}", len)
        else
          pt.send("read_#{type}")
        end
      end
    end
  end
end
