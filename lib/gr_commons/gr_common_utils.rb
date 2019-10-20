# frozen_string_literal: true

module GRCommons
  module GRCommonUtils
    private

    def equal_length(*args)
      lengths = args.map { |arg| length(arg) }
      raise ArgumentError, 'Sequences must have same length.' unless lengths.all? { |l| l == lengths[0] }

      lengths[0]
    end

    def length(pt, dtype = :double)
      case pt
      when Array
        pt.size
      when ->(x) { narray? x }
        pt.size
      when ::FFI::MemoryPointer
        case dtype
        when :int
          pt.size / ::FFI::Type::INT.size
        when :double
          pt.size / ::FFI::Type::DOUBLE.size
        else
          raise "Unknown type: #{dtype}"
        end
      else
        raise
      end
    end

    def uint8(data)
      data = data.to_a.flatten
      pt = ::FFI::MemoryPointer.new(:uint8, data.size)
      pt.write_array_of_uint8 data
    end

    def int(data)
      data = data.to_a.flatten
      pt = ::FFI::MemoryPointer.new(:int, data.size)
      pt.write_array_of_int data
    end

    def uint(data)
      data = data.to_a.flatten
      pt = ::FFI::MemoryPointer.new(:uint, data.size)
      pt.write_array_of_uint data
    end

    def double(data)
      data = data.to_a.flatten
      pt = ::FFI::MemoryPointer.new(:double, data.size)
      pt.write_array_of_double data
    end

    def float(data)
      data = data.to_a.flatten
      pt = ::FFI::MemoryPointer.new(:float, data.size)
      pt.write_array_of_float data
    end

    def narray?(data)
      defined?(Numo::NArray) && data.is_a?(Numo::NArray)
    end

    def inquiry_int(&block)
      inquiry(:int, &block)
    end

    def inquiry_double(&block)
      inquiry(:double, &block)
    end

    def inquiry(types)
      case types
      when Hash, Symbol
        pt = create_ffi_pointer(types)
        yield(pt)
        read_ffi_pointer(pt, types)
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
        ::FFI::MemoryPointer.new(typ, len)
      else
        ::FFI::MemoryPointer.new(type)
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
  end
end
