# frozen_string_literal: true

require 'gr_commons/fiddley'

module GRCommons
  # This module provides functionality common to GR and GR3.
  module GRCommonUtils
    private

    def equal_length(*args)
      lengths = args.map(&:length)
      unless lengths.all? { |l| l == lengths[0] }
        raise ArgumentError,
              'Sequences must have same length.'
      end

      lengths[0]
    end

    # This constants is used in the test.
    SUPPORTED_TYPES = %i[uint8 uint16 int uint double float].freeze

    # convert Ruby Array or NArray into packed string.
    def uint8(data)
      if narray?(data)
        Numo::UInt8.cast(data).to_binary
      else
        Fiddley::Utils.array2str(:uint8, data.to_a.flatten)
      end
    end

    # convert Ruby Array or NArray into packed string.
    def uint16(data)
      if narray?(data)
        Numo::UInt16.cast(data).to_binary
      else
        Fiddley::Utils.array2str(:uint16, data.to_a.flatten)
      end
    end

    # convert Ruby Array or NArray into packed string.
    def int(data)
      if narray?(data)
        Numo::Int32.cast(data).to_binary
      else
        Fiddley::Utils.array2str(:int32, data.to_a.flatten)
      end
    end

    # convert Ruby Array or NArray into packed string.
    def uint(data)
      if narray?(data)
        Numo::UInt32.cast(data).to_binary
      else
        Fiddley::Utils.array2str(:uint, data.to_a.flatten)
      end
    end

    # convert Ruby Array or NArray into packed string.
    def double(data)
      if narray?(data)
        Numo::DFloat.cast(data).to_binary
      else
        Fiddley::Utils.array2str(:double, data.to_a.flatten)
      end
    end

    # convert Ruby Array or NArray into packed string.
    def float(data)
      if narray?(data)
        Numo::SFloat.cast(data).to_binary
      else
        Fiddley::Utils.array2str(:float, data.to_a.flatten)
      end
    end

    def inquiry_int(&block)
      inquiry(:int, &block)
    end

    def inquiry_uint(&block)
      inquiry(:uint, &block)
    end

    def inquiry_double(&block)
      inquiry(:double, &block)
    end

    def inquiry(types)
      case types
      when Hash, Symbol
        ptr = create_ffi_pointer(types)
        yield(ptr)
        read_ffi_pointer(ptr, types)
      when Array
        pts = types.map { |type| create_ffi_pointer(type) }
        yield(*pts)
        pts.zip(types).map { |pt, type| read_ffi_pointer(pt, type) }
      else
        raise ArgumentError
      end
    end

    def create_ffi_pointer(type)
      case type
      when Hash
        typ = type.keys[0]
        len = type.values[0]
        Fiddley::MemoryPointer.new(typ, len)
      else
        Fiddley::MemoryPointer.new(type)
      end
    end

    def read_ffi_pointer(pt, type)
      case type
      when Hash
        typ = type.keys[0]
        len = type.values[0]
        pt.send("read_array_of_#{typ}", len)
      else
        pt.send("read_#{type}")
      end
    end

    def narray?(data)
      defined?(Numo::NArray) && data.is_a?(Numo::NArray)
    end
  end
end
