# frozen_string_literal: true

require 'ffi'

module GR
  class GR3
    class << self
      attr_reader :ffi_lib
    end

    gr3_lib_name = "libGR3.#{::FFI::Platform::LIBSUFFIX}"
    if ENV['GRDIR']
      gr3_lib = File.expand_path("lib/#{gr3_lib_name}", ENV['GRDIR'])
      ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
      @ffi_lib = gr3_lib
    else
      raise 'Please set env variable GRDIR'
    end
  end
end

require 'gr/gr3/ffi'
require 'gr/gr3/gr3module'

module GR
  # Integrating with Ruby Objects
  class GR3
    include GR3Module

    private

    def length(pt, dtype)
      case dtype
      when :int
        pt.size / ::FFI::Type::INT.size
      when :double
        pt.size / ::FFI::Type::DOUBLE.size
      else
        raise "Unknown type: #{dtype}"
      end
    end

    def pointer(dtype, data)
      data = data.to_a if narray?(data)
      case dtype
      when :int, :double
        pt = ::FFI::MemoryPointer.new(dtype, data.size)
        pt.send("write_array_of_#{dtype}", data)
      else
        raise "Unknown type: #{dtype}"
      end
    end

    def narray?(data)
      defined?(Numo::NArray) && data.is_a?(Numo::NArray)
    end
  end
end
