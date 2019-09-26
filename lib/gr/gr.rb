# frozen_string_literal: true

require 'ffi'

module GR
  class GR
    class << self
      attr_reader :ffi_lib
    end

    gr_lib_name = "libGR.#{::FFI::Platform::LIBSUFFIX}"
    if ENV['GRDIR']
      gr_lib = File.expand_path("lib/#{gr_lib_name}", ENV['GRDIR'])
      ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
      @ffi_lib = gr_lib
    else
      raise 'Please set env variable GRDIR'
    end
  end
end

require 'gr/gr/ffi'
require 'gr/gr/grmodule'

module GR
  # Integrating with Ruby Objects
  class GR
    include GRModule

    def inqdspsize
      mwidth  = ::FFI::MemoryPointer.new(:double)
      mheight = ::FFI::MemoryPointer.new(:double)
      width   = ::FFI::MemoryPointer.new(:int)
      height  = ::FFI::MemoryPointer.new(:int)
      super(mwidth, mheight, width, height)
      [mwidth.read_double, mheight.read_double, width.read_int, height.read_int]
    end

    def polyline(x, y)
      n = x.size
      raise if y.size != n

      super(n, x, y)
    end

    def polymarker(x, y)
      n = x.size
      raise if y.size != n

      super(n, x, y)
    end

    def fillarea(x, y)
      n = x.size
      raise if y.size != n

      super(n, x, y)
    end

    def cellarray(xmin, xmax, ymin, ymax, dimx, dimy, color)
      pcolor = pointer(:int, color)
      super(xmin, xmax, ymin, ymax, dimx, dimy, 1, 1, dimx, dimy, pcolor)
    end

    def gridit(xd, yd, zd, nx, ny)
      nd = xd.size
      raise if (yd.size != nd) || (zd.size != nd)

      px = ::FFI::MemoryPointer.new(:double, nx)
      py = ::FFI::MemoryPointer.new(:double, ny)
      pz = ::FFI::MemoryPointer.new(:double, nx * ny)
      super(nd, xd, yd, zd, nx, ny, px, py, pz)
      [px, py, pz]
    end

    def verrorbars(px, py, e1, e2)
      n = length(px, :double)
      super(n, px, py, e1, e2)
    end

    def herrorbars(px, py, e1, e2)
      n = length(px, :double)
      super(n, px, py, e1, e2)
    end

    def polyline3d(px, py, pz)
      n = length(px, :double)
      super(n, px, py, pz)
    end

    def polymarker3d(px, py, pz)
      n = length(px, :double)
      super(n, px, py, pz)
    end

    def surface(px, py, pz, option)
      nx = length(px, :double)
      ny = length(py, :double)
      super(nx, ny, px, py, pz, option)
    end

    def contour(px, py, h, pz, major_h)
      nx = length(px, :double)
      ny = length(py, :double)
      nh = h.size
      super(nx, ny, nh, px, py, h, pz, major_h)
    end

    def version
      super.read_string
    end

    # For IRuby Notebook
    def initialize
      if defined? IRuby
        require 'tempfile'
        ENV['GKSwstype'] = 'svg'
        @tempfile_svg = Tempfile.open(['plot', '.svg'])
        ENV['GKS_FILEPATH'] = @tempfile_svg.path
      end
    end

    if defined? IRuby
      def show
        emergencyclosegks
        sleep 1
        svg = File.read(@tempfile_svg.path)
        IRuby.display(svg, mime: 'image/svg+xml')
        self
      end
    end
  end
end
