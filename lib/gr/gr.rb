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
      px = pointer(:double, x)
      py = pointer(:double, y)
      super(size, px, py)
    end

    def polymarker(n, x, y)
      px = pointer(:double, x)
      py = pointer(:double, y)
      super(n, px, py)
    end

    def gridit(nd, xd, yd, zd, nx, ny)
      pxd = pointer(:double, xd)
      pyd = pointer(:double, yd)
      pzd = pointer(:double, zd)
      @px  ||= ::FFI::MemoryPointer.new(:double, nx)
      @py  ||= ::FFI::MemoryPointer.new(:double, ny)
      @pz  ||= ::FFI::MemoryPointer.new(:double, nx * ny)
      super(nd, pxd, pyd, pzd, nx, ny, @px, @py, @pz)
    end

    def surface(nx, ny, option)
      @px  ||= ::FFI::MemoryPointer.new(:double, nx)
      @py  ||= ::FFI::MemoryPointer.new(:double, ny)
      @pz  ||= ::FFI::MemoryPointer.new(:double, nx * ny)
      super(nx, ny, @px, @py, @pz, option)
    end

    def contour(nx, ny, h, major_h)
      nh = h.size
      ph = pointer(:double, h)
      @px  ||= ::FFI::MemoryPointer.new(:double, nx)
      @py  ||= ::FFI::MemoryPointer.new(:double, ny)
      @pz  ||= ::FFI::MemoryPointer.new(:double, nx * ny)
      super(nx, ny, nh, @px, @py, ph, @pz, major_h)
    end

    def version
      super.read_string
    end

    private

    def pointer(dtype, data)
      if narray?(data)
        data = data.to_a
      end
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
