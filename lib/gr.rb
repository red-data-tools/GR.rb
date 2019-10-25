# frozen_string_literal: true

require 'ffi'

module GR
  class Error < StandardError; end

  class << self
    attr_reader :ffi_lib
  end

  # Platforms |  path
  # Windows   |  bin/libgr.dll
  # MacOSX    |  lib/libGR.so (NOT .dylib)
  # Ubuntu    |  lib/libGR.so
  raise Error, 'Please set env variable GRDIR' unless ENV['GRDIR']

  ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
  @ffi_lib = case RbConfig::CONFIG['host_os']
             when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
               File.expand_path('bin/libgr.dll', ENV['GRDIR'])
                   .gsub('/', '\\') # windows backslash
             else
               File.expand_path('lib/libGR.so', ENV['GRDIR'])
             end

  require_relative 'gr_commons'
  require_relative 'gr/ffi'
  require_relative 'gr/grbase'

  extend GRCommons::JupyterSupport
  extend GRBase

  # `double` is the default type in GR
  # A Ruby array or NArray passed to GR method is automatically converted to
  # a FFI::MemoryPointer in the GRBase class.

  class << self
    # @!method initgr
    # @!method opengks
    # @!method closegks

    # inqdspsize
    def inqdspsize
      inquiry %i[double double int int] do |*pts|
        super(*pts)
      end
    end

    # @!method openws
    # @!method closews
    # @!method activatews
    # @!method deactivatews
    # @!method configurews
    # @!method clearws
    # @!method updatews

    # Draw a polyline using the current line attributes,
    # starting from the first data point and ending at the last data point.
    def polyline(x, y)
      n = equal_length(x, y)
      super(n, x, y)
    end

    # Draw marker symbols centered at the given data points.
    def polymarker(x, y)
      n = equal_length(x, y)
      super(n, x, y)
    end

    # @!method text

    # inqtext
    def inqtext(x, y, string)
      inquiry [{ double: 4 }, { double: 4 }] do |tbx, tby|
        super(x, y, string, tbx, tby)
      end
    end

    # Allows you to specify a polygonal shape of an area to be filled.
    def fillarea(x, y)
      n = equal_length(x, y)
      super(n, x, y)
    end

    # Display rasterlike images in a device-independent manner.
    # The cell array function partitions a rectangle given by two corner points into DIMX X DIMY cells,
    # each of them colored individually by the corresponding color index of the given cell array.
    def cellarray(xmin, xmax, ymin, ymax, dimx, dimy, color)
      super(xmin, xmax, ymin, ymax, dimx, dimy, 1, 1, dimx, dimy, int(color))
    end

    # Display a two dimensional color index array with nonuniform cell sizes.
    def nonuniformcellarray(x, y, dimx, dimy, color)
      raise ArgumentError unless length(x) == dimx + 1 && length(y) == dimy + 1

      super(x, y, dimx, dimy, 1, 1, dimx, dimy, int(color))
    end

    # Display a two dimensional color index array mapped to a disk using polar coordinates.
    def polarcellarray(x_org, y_org, phimin, phimax, rmin, rmax, dimphi, dimr, color)
      super(x_org, y_org, phimin, phimax, rmin, rmax, dimphi, dimr, 1, 1, dimphi, dimr, int(color))
    end

    # Generates a generalized drawing primitive (GDP) of the type you specify,
    # using specified points and any additional information contained in a data record.
    def gdp(x, y, primid, datrec)
      n = equal_length(x, y)
      ldr = length(datrec, :int)
      super(n, x, y, primid, ldr, datrec)
    end

    # Generate a cubic spline-fit,
    # starting from the first data point and ending at the last data point.
    def spline(px, py, m, method)
      n = equal_length(px, py)
      super(n, px, py, m, method)
    end

    # gridit
    def gridit(xd, yd, zd, nx, ny)
      nd = equal_length(xd, yd, zd)
      inquiry [{ double: nx }, { double: ny }, { double: nx * ny }] do |px, py, pz|
        super(nd, xd, yd, zd, nx, ny, px, py, pz)
      end
    end

    # @!method setlinetype

    # inqlinetype
    def inqlinetype
      inquiry_int { |pt| super(pt) }
    end

    # @!method setlinewidth

    # inqlinewidth
    def inqlinewidth
      inquiry_double { |pt| super(pt) }
    end

    # @!method setlinecolorind

    # inqlinecolorind
    def inqlinecolorind
      inquiry_int { |pt| super(pt) }
    end

    # @!method setmarkertype

    # inqmarkertype
    def inqmarkertype
      inquiry_int { |pt| super(pt) }
    end

    # @!method setmarkersize

    # inqmarkersize
    def inqmarkersize
      inquiry_double { |pt| super(pt) }
    end

    # @!method setmarkercolorind

    # inqmarkercolorind
    def inqmarkercolorind
      inquiry_int { |pt| super(pt) }
    end

    # @!method settextfontprec
    # @!method setcharexpan
    # @!method setcharspace
    # @!method settextcolorind
    # @!method setcharheight
    # @!method setcharup
    # @!method settextpath
    # @!method settextalign
    # @!method setfillintstyle

    # inqfillintstyle
    def inqfillintstyle
      inquiry_int { |pt| super(pt) }
    end

    # @!method setfillstyle

    # inqfillstyle
    def inqfillstyle
      inquiry_int { |pt| super(pt) }
    end

    # @!method setfillcolorind

    # inqfillcolorind
    def inqfillcolorind
      inquiry_int { |pt| super(pt) }
    end

    # @!method setcolorrep
    # @!method setscale

    # inqscale
    def inqscale
      inquiry_int { |pt| super(pt) }
    end

    # @!method setwindow

    # inqwindow
    def inqwindow
      inquiry %i[double double double double] do |*pts|
        super(*pts)
      end
    end

    # @!method setviewport

    # inqviewport
    def inqviewport
      inquiry %i[double double double double] do |*pts|
        super(*pts)
      end
    end

    # @!method selntran
    # @!method setclip
    # @!method setwswindow
    # @!method setwsviewport
    # @!method createseg
    # @!method copysegws
    # @!method redrawsegws
    # @!method setsegtran
    # @!method closeseg
    # @!method emergencyclosegks
    # @!method updategks
    # @!method setspace

    # inqspace
    def inqspace
      inquiry %i[double double int int] do |*pts|
        super(*pts)
      end
    end

    # @!method textext

    # inqtextext
    def inqtextext(x, y, string)
      inquiry [{ double: 4 }, { double: 4 }] do |tbx, tby|
        super(x, y, string, tbx, tby)
      end
    end

    # @!method axes

    alias axes2d axes

    # @!method grid
    # @!method grid3d

    # Draw a standard vertical error bar graph.
    def verrorbars(px, py, e1, e2)
      n = equal_length(px, py, e1, e2)
      super(n, px, py, e1, e2)
    end

    # Draw a standard horizontal error bar graph.
    def herrorbars(px, py, e1, e2)
      n = equal_length(px, py, e1, e2)
      super(n, px, py, e1, e2)
    end

    # Draw a 3D curve using the current line attributes,
    # starting from the first data point and ending at the last data point.
    def polyline3d(px, py, pz)
      n = equal_length(px, py, pz)
      super(n, px, py, pz)
    end

    # Draw marker symbols centered at the given 3D data points.
    def polymarker3d(px, py, pz)
      n = equal_length(px, py, pz)
      super(n, px, py, pz)
    end

    # @!method axes3d
    # @!method titles3d

    # Draw a three-dimensional surface plot for the given data points.
    def surface(px, py, pz, option)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = length(px)
      ny = length(py)
      super(nx, ny, px, py, pz, option)
    end

    # Draw contours of a three-dimensional data set
    # whose values are specified over a rectangular mesh.
    # Contour lines may optionally be labeled.
    def contour(px, py, h, pz, major_h)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = length(px)
      ny = length(py)
      nh = h.size
      super(nx, ny, nh, px, py, h, pz, major_h)
    end

    # Draw filled contours of a three-dimensional data set
    # whose values are specified over a rectangular mesh.
    def contourf(px, py, h, pz, major_h)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = length(px)
      ny = length(py)
      nh = h.size
      super(nx, ny, nh, px, py, h, pz, major_h)
    end

    # Draw a contour plot for the given triangle mesh.
    def tricontour(x, y, z, levels)
      npoints = length(x) # equal_length ?
      nlevels = length(levels)
      super(npoints, x, y, z, nlevels, levels)
    end

    # hexbin
    def hexbin(x, y, nbins)
      n = length(x)
      super(n, x, y, nbins)
    end

    # @!method setcolormap

    # inqcolormap
    def inqcolormap
      inquiry_int { |pt| super(pt) }
    end

    # Define a linear interpolated colormap by a list of RGB colors.
    def setcolormapfromrgb(r, g, b, positions: nil)
      n = equal_length(r, g, b)
      if positions.nil?
        positions = ::FFI::Pointer::NULL
      else
        raise if length(positions) != n
      end
      super(n, r, g, b, positions)
    end

    # @!method colorbar

    # inqcolor
    def inqcolor(color)
      inquiry_int do |rgb|
        super(color, rgb)
      end
    end

    # @!method inqcolorfromrgb

    # hsvtorgb
    def hsvtorgb(h, s, v)
      inquiry %i[double double double] do |r, g, b|
        super(h, s, v, r, g, b)
      end
    end

    # @!method tick
    # @!method validaterange
    # @!method adjustlimits
    # @!method adjustrange
    # @!method beginprint
    # @!method beginprintext
    # @!method endprint

    # ndctowc
    def ndctowc(x, y)
      inquiry %i[double double] do |px, py|
        px.write_double x
        py.write_double y
        super(px, py)
      end
    end

    # wctondc
    def wctondc(x, y)
      inquiry %i[double double] do |px, py|
        px.write_double x
        py.write_double y
        super(px, py)
      end
    end

    # wc3towc
    def wc3towc(x, y, z)
      inquiry %i[double double double] do |px, py, pz|
        px.write_double x
        py.write_double y
        pz.write_double z
        super(px, py, pz)
      end
    end

    # @!method drawrect
    # @!method fillrect
    # @!method drawarc
    # @!method fillarc

    # Draw simple and compound outlines consisting of line segments and bezier curves.
    def drawpath(points, codes, fill)
      len = length(codes)
      super(len, points, uint8(codes), fill)
    end

    # @!method setarrowstyle
    # @!method setarrowsize
    # @!method drawarrow

    # readimage
    def readimage(path)
      w, h, d = inquiry [:int, :int, :pointer] do |width, height, data|
        # data is a pointer of a pointer
        super(path, width, height, data)
      end
      [w, h, d.read_array_of_uint(w * h)]
    end

    # Draw an image into a given rectangular area.
    def drawimage(xmin, xmax, ymin, ymax, width, height, data, model = 0)
      super(xmin, xmax, ymin, ymax, width, height, uint(data), model)
    end

    # @!method importgraphics
    # @!method setshadow
    # @!method settransparency

    # Change the coordinate transformation according to the given matrix.
    def setcoordxform(mat)
      raise if mat.size != 6

      super(mat)
    end

    # @!method begingraphics
    # @!method endgraphics
    # @!method getgraphics
    # @!method drawgraphics
    # @!method mathtex

    # inqmathtex
    def inqmathtex(x, y, string)
      inquiry [{ double: 4 }, { double: 4 }] do |tbx, tby|
        super(x, y, string, tbx, tby)
      end
    end

    # @!method beginselection
    # @!method endselection
    # @!method moveselection
    # @!method resizeselection

    # inqbbox
    def inqbbox
      inquiry %i[double double double double] do |*pts|
        super(*pts)
      end
    end

    # @!method precision
    # @!method setregenflags
    # @!method inqregenflags
    # @!method savestate
    # @!method restorestate
    # @!method selectcontext
    # @!method destroycontext
    # @!method uselinespec

    # Reduces the number of points of the x and y array.
    def reducepoints(xd, yd, n)
      nd = equal_length(xd, yd)
      inquiry [{ double: n }, { double: n }] do |x, y|
        # Different from Julia. x, y are initialized zero.
        super(nd, xd, yd, n, x, y)
      end
    end

    # Draw a triangular surface plot for the given data points.
    def trisurface(px, py, pz)
      n = [length(px), length(py), length(pz)].min
      super(n, px, py, pz)
    end

    # gradient
    def gradient(x, y, z)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = length(x)
      ny = length(y)
      inquiry [{ double: nx * ny }, { double: nx * ny }] do |pu, pv|
        super(nx, ny, x, y, z, pu, pv)
      end
    end

    # quiver
    def quiver(x, y, u, v, color)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = length(x)
      ny = length(y)
      super(nx, ny, x, y, u, v, (color ? 1 : 0))
    end

    # interp2
    def interp2(x, y, z, xq, yq, method, extrapval) # flatten
      nx = length(x)
      ny = length(y)
      # nz = length(z)
      nxq = length(xq)
      nyq = length(yq)
      inquiry(double: nxq * nyq) do |zq|
        super(nx, ny, x, y, z, nxq, nyq, xq, yq, zq, method, extrapval)
      end
    end

    # version
    def version
      super.read_string
    end

    # Display a point set as a aggregated and rasterized image.
    def shadepoints(x, y, dims: [1200, 1200], xform: 1)
      n = length(x)
      w, h = dims
      super(n, x, y, xform, w, h)
    end

    # Display a line set as an aggregated and rasterized image.
    def shadelines(x, y, dims: [1200, 1200], xform: 1)
      n = length(x)
      w, h = dims
      super(n, x, y, xform, w, h)
    end

    # @!method panzoom

    # panzoom
    def panzoom(x, y, zoom)
      inquiry %i[double double double double] do |xmin, xmax, ymin, ymax|
        super(x, y, zoom, zoom, xmin, xmax, ymin, ymax)
      end
    end
  end

  # Constants - imported from GR.jl

  ASF_BUNDLED = 0
  ASF_INDIVIDUAL = 1

  NOCLIP = 0
  CLIP = 1

  COORDINATES_WC = 0
  COORDINATES_NDC = 1

  INTSTYLE_HOLLOW = 0
  INTSTYLE_SOLID = 1
  INTSTYLE_PATTERN = 2
  INTSTYLE_HATCH = 3

  TEXT_HALIGN_NORMAL = 0
  TEXT_HALIGN_LEFT = 1
  TEXT_HALIGN_CENTER = 2
  TEXT_HALIGN_RIGHT = 3
  TEXT_VALIGN_NORMAL = 0
  TEXT_VALIGN_TOP = 1
  TEXT_VALIGN_CAP = 2
  TEXT_VALIGN_HALF = 3
  TEXT_VALIGN_BASE = 4
  TEXT_VALIGN_BOTTOM = 5

  TEXT_PATH_RIGHT = 0
  TEXT_PATH_LEFT = 1
  TEXT_PATH_UP = 2
  TEXT_PATH_DOWN = 3

  TEXT_PRECISION_STRING = 0
  TEXT_PRECISION_CHAR = 1
  TEXT_PRECISION_STROKE = 2

  LINETYPE_SOLID = 1
  LINETYPE_DASHED = 2
  LINETYPE_DOTTED = 3
  LINETYPE_DASHED_DOTTED = 4
  LINETYPE_DASH_2_DOT = -1
  LINETYPE_DASH_3_DOT = -2
  LINETYPE_LONG_DASH = -3
  LINETYPE_LONG_SHORT_DASH = -4
  LINETYPE_SPACED_DASH = -5
  LINETYPE_SPACED_DOT = -6
  LINETYPE_DOUBLE_DOT = -7
  LINETYPE_TRIPLE_DOT = -8

  MARKERTYPE_DOT = 1
  MARKERTYPE_PLUS = 2
  MARKERTYPE_ASTERISK = 3
  MARKERTYPE_CIRCLE = 4
  MARKERTYPE_DIAGONAL_CROSS = 5
  MARKERTYPE_SOLID_CIRCLE = -1
  MARKERTYPE_TRIANGLE_UP = -2
  MARKERTYPE_SOLID_TRI_UP = -3
  MARKERTYPE_TRIANGLE_DOWN = -4
  MARKERTYPE_SOLID_TRI_DOWN = -5
  MARKERTYPE_SQUARE = -6
  MARKERTYPE_SOLID_SQUARE = -7
  MARKERTYPE_BOWTIE = -8
  MARKERTYPE_SOLID_BOWTIE = -9
  MARKERTYPE_HOURGLASS = -10
  MARKERTYPE_SOLID_HGLASS = -11
  MARKERTYPE_DIAMOND = -12
  MARKERTYPE_SOLID_DIAMOND = -13
  MARKERTYPE_STAR = -14
  MARKERTYPE_SOLID_STAR = -15
  MARKERTYPE_TRI_UP_DOWN = -16
  MARKERTYPE_SOLID_TRI_RIGHT = -17
  MARKERTYPE_SOLID_TRI_LEFT = -18
  MARKERTYPE_HOLLOW_PLUS = -19
  MARKERTYPE_SOLID_PLUS = -20
  MARKERTYPE_PENTAGON = -21
  MARKERTYPE_HEXAGON = -22
  MARKERTYPE_HEPTAGON = -23
  MARKERTYPE_OCTAGON = -24
  MARKERTYPE_STAR_4 = -25
  MARKERTYPE_STAR_5 = -26
  MARKERTYPE_STAR_6 = -27
  MARKERTYPE_STAR_7 = -28
  MARKERTYPE_STAR_8 = -29
  MARKERTYPE_VLINE = -30
  MARKERTYPE_HLINE = -31
  MARKERTYPE_OMARK = -32

  OPTION_X_LOG = 1
  OPTION_Y_LOG = 2
  OPTION_Z_LOG = 4
  OPTION_FLIP_X = 8
  OPTION_FLIP_Y = 16
  OPTION_FLIP_Z = 32

  OPTION_LINES = 0
  OPTION_MESH = 1
  OPTION_FILLED_MESH = 2
  OPTION_Z_SHADED_MESH = 3
  OPTION_COLORED_MESH = 4
  OPTION_CELL_ARRAY = 5
  OPTION_SHADED_MESH = 6

  MODEL_RGB = 0
  MODEL_HSV = 1

  COLORMAP_UNIFORM = 0
  COLORMAP_TEMPERATURE = 1
  COLORMAP_GRAYSCALE = 2
  COLORMAP_GLOWING = 3
  COLORMAP_RAINBOWLIKE = 4
  COLORMAP_GEOLOGIC = 5
  COLORMAP_GREENSCALE = 6
  COLORMAP_CYANSCALE = 7
  COLORMAP_BLUESCALE = 8
  COLORMAP_MAGENTASCALE = 9
  COLORMAP_REDSCALE = 10
  COLORMAP_FLAME = 11
  COLORMAP_BROWNSCALE = 12
  COLORMAP_PILATUS = 13
  COLORMAP_AUTUMN = 14
  COLORMAP_BONE = 15
  COLORMAP_COOL = 16
  COLORMAP_COPPER = 17
  COLORMAP_GRAY = 18
  COLORMAP_HOT = 19
  COLORMAP_HSV = 20
  COLORMAP_JET = 21
  COLORMAP_PINK = 22
  COLORMAP_SPECTRAL = 23
  COLORMAP_SPRING = 24
  COLORMAP_SUMMER = 25
  COLORMAP_WINTER = 26
  COLORMAP_GIST_EARTH = 27
  COLORMAP_GIST_HEAT = 28
  COLORMAP_GIST_NCAR = 29
  COLORMAP_GIST_RAINBOW = 30
  COLORMAP_GIST_STERN = 31
  COLORMAP_AFMHOT = 32
  COLORMAP_BRG = 33
  COLORMAP_BWR = 34
  COLORMAP_COOLWARM = 35
  COLORMAP_CMRMAP = 36
  COLORMAP_CUBEHELIX = 37
  COLORMAP_GNUPLOT = 38
  COLORMAP_GNUPLOT2 = 39
  COLORMAP_OCEAN = 40
  COLORMAP_RAINBOW = 41
  COLORMAP_SEISMIC = 42
  COLORMAP_TERRAIN = 43
  COLORMAP_VIRIDIS = 44
  COLORMAP_INFERNO = 45
  COLORMAP_PLASMA = 46
  COLORMAP_MAGMA = 47

  FONT_TIMES_ROMAN = 101
  FONT_TIMES_ITALIC = 102
  FONT_TIMES_BOLD = 103
  FONT_TIMES_BOLDITALIC = 104
  FONT_HELVETICA = 105
  FONT_HELVETICA_OBLIQUE = 106
  FONT_HELVETICA_BOLD = 107
  FONT_HELVETICA_BOLDOBLIQUE = 108
  FONT_COURIER = 109
  FONT_COURIER_OBLIQUE = 110
  FONT_COURIER_BOLD = 111
  FONT_COURIER_BOLDOBLIQUE = 112
  FONT_SYMBOL = 113
  FONT_BOOKMAN_LIGHT = 114
  FONT_BOOKMAN_LIGHTITALIC = 115
  FONT_BOOKMAN_DEMI = 116
  FONT_BOOKMAN_DEMIITALIC = 117
  FONT_NEWCENTURYSCHLBK_ROMAN = 118
  FONT_NEWCENTURYSCHLBK_ITALIC = 119
  FONT_NEWCENTURYSCHLBK_BOLD = 120
  FONT_NEWCENTURYSCHLBK_BOLDITALIC = 121
  FONT_AVANTGARDE_BOOK = 122
  FONT_AVANTGARDE_BOOKOBLIQUE = 123
  FONT_AVANTGARDE_DEMI = 124
  FONT_AVANTGARDE_DEMIOBLIQUE = 125
  FONT_PALATINO_ROMAN = 126
  FONT_PALATINO_ITALIC = 127
  FONT_PALATINO_BOLD = 128
  FONT_PALATINO_BOLDITALIC = 129
  FONT_ZAPFCHANCERY_MEDIUMITALIC = 130
  FONT_ZAPFDINGBATS = 131

  PATH_STOP      = 0x00
  PATH_MOVETO    = 0x01
  PATH_LINETO    = 0x02
  PATH_CURVE3    = 0x03
  PATH_CURVE4    = 0x04
  PATH_CLOSEPOLY = 0x4f

  MPL_SUPPRESS_CLEAR = 1
  MPL_POSTPONE_UPDATE = 2

  XFORM_BOOLEAN = 0
  XFORM_LINEAR = 1
  XFORM_LOG = 2
  XFORM_LOGLOG = 3
  XFORM_CUBIC = 4
  XFORM_EQUALIZED = 5
end
