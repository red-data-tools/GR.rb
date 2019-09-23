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

      px = pointer(:double, x)
      py = pointer(:double, y)
      super(size, px, py)
    end

    def polymarker(x, y)
      size = x.size
      raise if y.size != size

      px = pointer(:double, x)
      py = pointer(:double, y)
      super(size, px, py)
    end

    def gridit(xd, yd, zd, nx, ny)
      size = xd.size
      raise if (yd.size != size) || (zd.size != size)

      pxd = pointer(:double, xd)
      pyd = pointer(:double, yd)
      pzd = pointer(:double, zd)
      px = ::FFI::MemoryPointer.new(:double, nx)
      py = ::FFI::MemoryPointer.new(:double, ny)
      pz = ::FFI::MemoryPointer.new(:double, nx * ny)
      super(size, pxd, pyd, pzd, nx, ny, px, py, pz)
      [px, py, pz]
    end

    def surface(px, py, pz, option)
      nx = length(px, :double)
      ny = length(py, :double)
      super(nx, ny, px, py, pz, option)
    end

    def contour(px, py, h, pz, major_h)
      nx = length(px, :double)
      ny = length(py, :double)
      nz = length(pz, :double)
      nh = h.size
      ph = pointer(:double, h)
      super(nx, ny, nh, px, py, ph, pz, major_h)
    end

    def version
      super.read_string
    end

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
