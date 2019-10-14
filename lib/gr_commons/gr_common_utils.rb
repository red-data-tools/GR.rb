# frozen_string_literal: true

module GRCommons
  module GRCommonUtils
    private

    def equal_length(*args)
      lengths = args.map { |arg| length(arg) }
      if lengths.all? { |l| l == lengths[0] }
        lengths[0]
      else
        raise ArgumentError, 'Sequences must have same length.'
      end
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

    def int(data)
      data = data.to_a.flatten
      pt = ::FFI::MemoryPointer.new(:int, data.size)
      pt.write_array_of_int data
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
  end
end
