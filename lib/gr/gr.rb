# frozen_string_literal: true

module GR
  # Define GR::FFI methods dynamically
  # GRBase is a private class.
  class GRBase
    gr_methods = FFI.public_methods.select do |gr_method|
      gr_method.to_s.start_with? 'gr_'
    end

    # define method
    gr_methods.each do |gr_method|
      ruby_method = gr_method.to_s.delete_prefix('gr_')
      define_method(ruby_method) do |*args|
        FFI.send(gr_method, *args)
      end
    end
  end
  private_constant :GRBase

  # Integrating with Ruby Objects
  class GR < GRBase
    def polyline(x, y)
      size = x.size
      raise if y.size != size

      px = ::FFI::MemoryPointer.new(:double, size)
      px.write_array_of_double(x)
      py = ::FFI::MemoryPointer.new(:double, size)
      py.write_array_of_double(y)
      super(size, px, py)
    end

    def version
      super.read_string
    end
  end
end
