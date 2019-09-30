# frozen_string_literal: true

module GR
  # Define GR::FFI methods dynamically
  # GRBase is a private class.
  module GRBase
    gr_methods = FFI.public_methods.select do |gr_method|
      gr_method.to_s.start_with? 'gr_'
    end

    # define method
    gr_methods.each do |gr_method|
      # delete_prefix (Ruby >= 2.5)
      ruby_method = gr_method.to_s.sub(/^gr_/, '')

      define_method(ruby_method) do |*args|
        args.map! do |arg|
          case arg
          when Array
            double(arg)
          when ->(x) { narray? x }
            double(arg)
          else
            arg
          end
        end
        FFI.send(gr_method, *args)
      end
    end
  end
  private_constant :GRBase

  class << self
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

    def int(data)
      data = data.to_a # .flatten
      pt = ::FFI::MemoryPointer.new(:int, data.size)
      pt.write_array_of_int data
    end

    def double(data)
      data = data.to_a # .flatten
      pt = ::FFI::MemoryPointer.new(:double, data.size)
      pt.write_array_of_double data
    end

    def narray?(data)
      defined?(Numo::NArray) && data.is_a?(Numo::NArray)
    end
  end
end
