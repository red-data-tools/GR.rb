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

    SupportedTypes = %i[uint8 uint16 int uint double float].freeze

    # NOTE: The following method converts Ruby Array or NArray into packed string.
    SupportedTypes.each do |type|
      define_method(type) do |data|
        # FIXME: Use NArray#to_string
        data = data.to_a.flatten
        Fiddley::Utils.array2str(type, data)
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

# Ruby 2.4.0 introduces Comparable#clamp
if RUBY_VERSION.to_f <= 2.3
  class Numeric
    def clamp(min, max)
      [[self, max].min, min].max
    end
  end
end
