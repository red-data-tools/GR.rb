# frozen_string_literal: true

require 'ffi'

module GR
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

require 'gr/ffi'
require 'gr/grbase'

module GR
  extend GRBase

  class << self
    def inqdspsize
      inq_ %i[double double int int] do |*pts|
        super(*pts)
      end
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

    def inqtext(x, y, string)
      tbx = ::FFI::MemoryPointer.new(:double, 4)
      tby = ::FFI::MemoryPointer.new(:double, 4)
      super(x, y, string, tbx, tby)
      [tbx.read_array_of_double(4), tby.read_array_of_double(4)]
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

    def polarcellarray(x_org, y_org, phimin, phimax, rmin, rmax, dimphi, dimr, color)
      pcolor = pointer(:int, color)
      super(x_org, y_org, phimin, phimax, rmin, rmax, dimphi, dimr, 1, 1, dimphi, dimr, pcolor)
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

    def inqlinetype
      inq_int { |pt| super(pt) }
    end

    def inqlinewidth
      inq_double { |pt| super(pt) }
    end

    def inqlinecolorind
      inq_int { |pt| super(pt) }
    end

    def inqmarkertype
      inq_int { |pt| super(pt) }
    end

    def inqmarkercolorind
      inq_int { |pt| super(pt) }
    end

    def inqfillintstyle
      inq_int { |pt| super(pt) }
    end

    def inqfillstyle
      inq_int { |pt| super(pt) }
    end

    def inqfillcolorind
      inq_int { |pt| super(pt) }
    end

    def inqscale
      inq_int { |pt| super(pt) }
    end

    def inqtextext(x, y, string)
      tbx = ::FFI::MemoryPointer.new(:double, 4)
      tby = ::FFI::MemoryPointer.new(:double, 4)
      super(x, y, string, tbx, tby)
      [tbx.read_array_of_double(4), tby.read_array_of_double(4)]
    end

    def inqwindow
      inq_ %i[double double double double] do |*pts|
        super(*pts)
      end
    end

    def inqspace
      inq_ %i[double double int int] do |*pts|
        super(*pts)
      end
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

    private

    def inq_int(&block)
      inq_([:int], &block)[0]
    end

    def inq_double(&block)
      inq_([:double], &block)[0]
    end

    def inq_(types)
      pts = types.map do |type|
        ::FFI::MemoryPointer.new(type)
      end
      yield(*pts)
      pts.zip(types).map do |pt, type|
        pt.send("read_#{type}")
      end
    end
  end
end
