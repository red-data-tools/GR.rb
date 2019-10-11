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
  if ENV['GRDIR']
    ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
    @ffi_lib = case RbConfig::CONFIG['host_os']
               when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                 File.expand_path('bin/libgr3.dll', ENV['GRDIR'])
                     .gsub('/', '\\') # windows backslash
               else
                 File.expand_path('lib/libGR3.so', ENV['GRDIR'])
               end
  else
    raise 'Please set env variable GRDIR'
  end
end

require_relative 'gr_commons'
require 'gr3/ffi'
require 'gr3/gr3base'

module GR3
  extend GRCommons::JupyterSupport
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

  IA_END_OF_LIST = 0
  IA_FRAMEBUFFER_WIDTH = 1
  IA_FRAMEBUFFER_HEIGHT = 2

  ERROR_NONE = 0
  ERROR_INVALID_VALUE = 1
  ERROR_INVALID_ATTRIBUTE = 2
  ERROR_INIT_FAILED = 3
  ERROR_OPENGL_ERR = 4
  ERROR_OUT_OF_MEM = 5
  ERROR_NOT_INITIALIZED = 6
  ERROR_CAMERA_NOT_INITIALIZED = 7
  ERROR_UNKNOWN_FILE_EXTENSION = 8
  ERROR_CANNOT_OPEN_FILE = 9
  ERROR_EXPORT = 10

  QUALITY_OPENGL_NO_SSAA  = 0
  QUALITY_OPENGL_2X_SSAA  = 2
  QUALITY_OPENGL_4X_SSAA  = 4
  QUALITY_OPENGL_8X_SSAA  = 8
  QUALITY_OPENGL_16X_SSAA = 16
  QUALITY_POVRAY_NO_SSAA  = 0 + 1
  QUALITY_POVRAY_2X_SSAA  = 2 + 1
  QUALITY_POVRAY_4X_SSAA  = 4 + 1
  QUALITY_POVRAY_8X_SSAA  = 8 + 1
  QUALITY_POVRAY_16X_SSAA = 16 + 1

  DRAWABLE_OPENGL = 1
  DRAWABLE_GKS = 2

  SURFACE_DEFAULT     =  0
  SURFACE_NORMALS     =  1
  SURFACE_FLAT        =  2
  SURFACE_GRTRANSFORM =  4
  SURFACE_GRCOLOR     =  8
  SURFACE_GRZSHADED   = 16
end
