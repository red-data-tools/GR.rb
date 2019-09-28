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
      inq_ [{double: 4}, {double, 4}] do |tbx, tby|
        super(x, y, string, tbx, tby)
      end
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

      inq_ %i[{double: nx}, {double: ny}, {double: nx * ny}] do |px, py, pz|
        super(nd, xd, yd, zd, nx, ny, px, py, pz)
        # NOTE: this method return an Array of FFI::MemoryPointer itself!
        return [px, py, pz]
      end
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
      inq_ [{double: 4}, {double: 4}] do |tbx, tby|
        super(x, y, string, tbx, tby)
      end
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

    def inqcolormap
      inq_int { |pt| super(pt) }
    end

    def inqcolor(color)
      inq_int do |rgb|
        super(color, rgb)
      end
    end

    def hsvtorgb(h, s, v)
      inq_ %i[double double double] do |r, g, b|
        super(h, s, v, r, g, b)
      end
    end

    def ndctowc(x, y)
      inq_ %i[double double] do |px, py|
        px.write_double x
        py.write_double y
        super(px, py)
      end
    end

    def wctondc(x, y)
      inq_ %i[double double] do |px, py|
        px.write_double x
        py.write_double y
        super(px, py)
      end
    end

    def wc3towc(x, y, z)
      inq_ %i[double double double] do |px, py, pz|
        px.write_double x
        py.write_double y
        pz.write_double z
        super(px, py, pz)
      end
    end

    def inqbbox
      inq_ %i[double double double double] do |*pts|
        super(*pts)
      end
    end

    def adjustlimits(amin, amax)


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
        case type
        when Hash
          typ = type.keys[0]
          len = type.values[0]
          ::FFI::MemoryPointer.new(typ, len)
        else
          ::FFI::MemoryPointer.new(type)
        end
      end
      yield(*pts)
      pts.zip(types).map do |pt, type|
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
end
