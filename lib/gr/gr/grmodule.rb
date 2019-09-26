# frozen_string_literal: true

module GR
  class GR
    # Define GR::FFI methods dynamically
    # GRBase is a private class.
    module GRModule
      gr_methods = FFI.public_methods.select do |gr_method|
        gr_method.to_s.start_with? 'gr_'
      end

      # define method
      gr_methods.each do |gr_method|
        ruby_method = gr_method.to_s.delete_prefix('gr_')

        define_method(ruby_method) do |*args|
          args.map! do |arg|
            case arg
            when Array
              pointer(:double, arg)
            when ->(x) { narray? x }
              pointer(:double, arg)
            else
              arg
            end
          end
          FFI.send(gr_method, *args)
        end
      end
    end
    private_constant :GRModule

    private

    def length(pt, dtype)
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

    def pointer(dtype, data)
      data = data.to_a
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
