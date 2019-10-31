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
  require_relative 'gr/version'
  require_relative 'gr/ffi'
  require_relative 'gr/grbase'

  extend GRCommons::JupyterSupport
  extend GRBase

  # `double` is the default type in GR
  # A Ruby array or NArray passed to GR method is automatically converted to
  # a FFI::MemoryPointer in the GRBase class.

  class << self
    def initgr(*)
      super
    end

    def opengks(*)
      super
    end

    def closegks(*)
      super
    end

    # inqdspsize
    def inqdspsize
      inquiry %i[double double int int] do |*pts|
        super(*pts)
      end
    end

    # Open a graphical workstation.
    # @param workstation_id [Integer] A workstation identifier.
    # @param connection [String] A connection identifier.
    # @param workstation_type [Integer] The desired workstation type.
    #  * 5         : Workstation Independent Segment Storage
    #  * 7, 8      : Computer Graphics Metafile (CGM binary, clear text)
    #  * 41        : Windows GDI
    #  * 51        : Mac Quickdraw
    #  * 61 - 64   : PostScript (b/w, color)
    #  * 101, 102  : Portable Document Format (plain, compressed)
    #  * 210 - 213 : X Windows
    #  * 214       : Sun Raster file (RF)
    #  * 215, 218  : Graphics Interchange Format (GIF87, GIF89)
    #  * 216       : Motif User Interface Language (UIL)
    #  * 320       : Windows Bitmap (BMP)
    #  * 321       : JPEG image file
    #  * 322       : Portable Network Graphics file (PNG)
    #  * 323       : Tagged Image File Format (TIFF)
    #  * 370       : Xfig vector graphics file
    #  * 371       : Gtk
    #  * 380       : wxWidgets
    #  * 381       : Qt4
    #  * 382       : Scaleable Vector Graphics (SVG)
    #  * 390       : Windows Metafile
    #  * 400       : Quartz
    #  * 410       : Socket driver
    #  * 415       : 0MQ driver
    #  * 420       : OpenGL
    #  * 430       : HTML5 Canvas
    def openws(*)
      super
    end

    # Close the specified workstation.
    # @param workstation_id [Integer] A workstation identifier.
    def closews(*)
      super
    end

    # Activate the specified workstation.
    # @param workstation_id [Integer] A workstation identifier.
    def activatews(*)
      super
    end

    # Deactivate the specified workstation.
    # @param workstation_id [Integer] A workstation identifier.
    def deactivatews(*)
      super
    end

    def configurews(*)
      super
    end

    def clearws(*)
      super
    end

    def updatews(*)
      super
    end

    # Draw a polyline using the current line attributes,
    # starting from the first data point and ending at the last data point.
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    def polyline(x, y)
      n = equal_length(x, y)
      super(n, x, y)
    end

    # Draw marker symbols centered at the given data points.
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    def polymarker(x, y)
      n = equal_length(x, y)
      super(n, x, y)
    end

    # Draw a text at position `x`, `y` using the current text attributes.
    # @param x [Numeric] The X coordinate of starting position of the text string
    # @param y [Numeric] The Y coordinate of starting position of the text string
    # @param string [String] The text to be drawn
    #
    # The values for `x` and `y` are in normalized device coordinates.
    # The attributes that control the appearance of text are text font and precision,
    # character expansion factor, character spacing, text color index, character
    # height, character up vector, text path and text alignment.
    def text(*)
      super
    end

    def inqtext(x, y, string)
      inquiry [{ double: 4 }, { double: 4 }] do |tbx, tby|
        super(x, y, string, tbx, tby)
      end
    end

    # Allows you to specify a polygonal shape of an area to be filled.
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    #
    # The attributes that control the appearance of fill areas are fill area interior
    # style, fill area style index and fill area color index.
    def fillarea(x, y)
      n = equal_length(x, y)
      super(n, x, y)
    end

    # Display rasterlike images in a device-independent manner. The cell array
    # function partitions a rectangle given by two corner points into DIMX X DIMY
    # cells, each of them colored individually by the corresponding color index
    # of the given cell array.
    # @param xmin [Numeric] Lower left point of the rectangle
    # @param ymin [Numeric] Lower left point of the rectangle
    # @param xmax [Numeric] Upper right point of the rectangle
    # @param ymax [Numeric] Upper right point of the rectangle
    # @param dimx [Integer] X dimension of the color index array
    # @param dimy [Integer] Y dimension of the color index array
    # @param color [Array, NArray] Color index array
    #
    # The values for `xmin`, `xmax`, `ymin` and `ymax` are in world coordinates.
    def cellarray(xmin, xmax, ymin, ymax, dimx, dimy, color)
      super(xmin, xmax, ymin, ymax, dimx, dimy, 1, 1, dimx, dimy, int(color))
    end

    # Display a two dimensional color index array with nonuniform cell sizes.
    # @param x [Array, NArray] X coordinates of the cell edges
    # @param y [Array, NArray] Y coordinates of the cell edges
    # @param dimx [Integer] X dimension of the color index array
    # @param dimy [Integer] Y dimension of the color index array
    # @param color [Array, NArray] Color index array
    def nonuniformcellarray(x, y, dimx, dimy, color)
      raise ArgumentError unless x.length == dimx + 1 && y.length == dimy + 1

      super(x, y, dimx, dimy, 1, 1, dimx, dimy, int(color))
    end

    # Display a two dimensional color index array mapped to a disk using polar
    # coordinates.
    # @param xorg [Numeric] X coordinate of the disk center in world coordinates
    # @param yorg [Numeric] Y coordinate of the disk center in world coordinates
    # @param phimin [Numeric] start angle of the disk sector in degrees
    # @param phimax [Numeric] end angle of the disk sector in degrees
    # @param rmin [Numeric] inner radius of the punctured disk in world coordinates
    # @param rmax [Numeric] outer radius of the punctured disk in world coordinates
    # @param dimiphi [Integer] Phi (X) dimension of the color index array
    # @param dimr [Integer] iR (Y) dimension of the color index array
    # @param color [Array, NArray] Color index array
    #
    # The two dimensional color index array is mapped to the resulting image by
    # interpreting the X-axis of the array as the angle and the Y-axis as the raidus.
    # The center point of the resulting disk is located at `xorg`, `yorg` and the
    # radius of the disk is `rmax`.
    def polarcellarray(x_org, y_org, phimin, phimax, rmin, rmax, dimphi, dimr, color)
      super(x_org, y_org, phimin, phimax, rmin, rmax, dimphi, dimr, 1, 1, dimphi, dimr, int(color))
    end

    # Generates a generalized drawing primitive (GDP) of the type you specify,
    # using specified points and any additional information contained in a data
    # record.
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    # @param primid [Integer] Primitive identifier
    # @param datrec [Array, NArray] Primitive data record
    def gdp(x, y, primid, datrec)
      n = equal_length(x, y)
      ldr = datrec.length
      super(n, x, y, primid, ldr, datrec)
    end

    # Generate a cubic spline-fit,
    # starting from the first data point and ending at the last data point.
    def spline(px, py, m, method)
      n = equal_length(px, py)
      super(n, px, py, m, method)
    end

    def gridit(xd, yd, zd, nx, ny)
      nd = equal_length(xd, yd, zd)
      inquiry [{ double: nx }, { double: ny }, { double: nx * ny }] do |px, py, pz|
        super(nd, xd, yd, zd, nx, ny, px, py, pz)
      end
    end

    # Specify the line style for polylines.
    def setlinetype(*)
      super
    end

    def inqlinetype
      inquiry_int { |pt| super(pt) }
    end

    # Define the line width of subsequent polyline output primitives.
    def setlinewidth(*)
      super
    end

    def inqlinewidth
      inquiry_double { |pt| super(pt) }
    end

    # Define the color of subsequent polyline output primitives.
    def setlinecolorind(*)
      super
    end

    # inqlinecolorind
    def inqlinecolorind
      inquiry_int { |pt| super(pt) }
    end

    # Specifiy the marker type for polymarkers.
    def setmarkertype(*)
      super
    end

    def inqmarkertype
      inquiry_int { |pt| super(pt) }
    end

    # Specify the marker size for polymarkers.
    def setmarkersize(*)
      super
    end

    # Inquire the marker size for polymarkers.
    def inqmarkersize
      inquiry_double { |pt| super(pt) }
    end

    # Define the color of subsequent polymarker output primitives.
    def setmarkercolorind(*)
      super
    end

    def inqmarkercolorind
      inquiry_int { |pt| super(pt) }
    end

    # Specify the text font and precision for subsequent text output primitives.
    def settextfontprec(*)
      super
    end

    # Set the current character expansion factor (width to height ratio).
    def setcharexpan(*)
      super
    end

    def setcharspace(*)
      super
    end

    # Sets the current text color index.
    def settextcolorind(*)
      super
    end

    # Set the current character height.
    def setcharheight(*)
      super
    end

    # Set the current character text angle up vector.
    def setcharup(*)
      super
    end

    # Define the current direction in which subsequent text will be drawn.
    def settextpath(*)
      super
    end

    # Set the current horizontal and vertical alignment for text.
    def settextalign(*)
      super
    end

    # Set the fill area interior style to be used for fill areas.
    def setfillintstyle(*)
      super
    end

    # Returns the fill area interior style to be used for fill areas.
    def inqfillintstyle
      inquiry_int { |pt| super(pt) }
    end

    # Sets the fill style to be used for subsequent fill areas.
    def setfillstyle(*)
      super
    end

    # Returns the current fill area color index.
    def inqfillstyle
      inquiry_int { |pt| super(pt) }
    end

    # Sets the current fill area color index.
    def setfillcolorind(*)
      super
    end

    # Returns the current fill area color index.
    def inqfillcolorind
      inquiry_int { |pt| super(pt) }
    end

    # `setcolorrep` allows to redefine an existing color index representation by specifying
    # an RGB color triplet.
    def setcolorrep(*)
      super
    end

    # `setscale` sets the type of transformation to be used for subsequent GR output
    # primitives.
    def setscale(*)
      super
    end

    # inqscale
    def inqscale
      inquiry_int { |pt| super(pt) }
    end

    # `setwindow` establishes a window, or rectangular subspace, of world coordinates to be
    # plotted. If you desire log scaling or mirror-imaging of axes, use the SETSCALE function.
    def setwindow(*)
      super
    end

    # inqwindow
    def inqwindow
      inquiry %i[double double double double] do |*pts|
        super(*pts)
      end
    end

    # `setviewport` establishes a rectangular subspace of normalized device coordinates.
    def setviewport(*)
      super
    end

    # inqviewport
    def inqviewport
      inquiry %i[double double double double] do |*pts|
        super(*pts)
      end
    end

    # `selntran` selects a predefined transformation from world coordinates to normalized
    # device coordinates.
    def selntran(*)
      super
    end

    # Set the clipping indicator.
    def setclip(*)
      super
    end

    # Set the area of the NDC viewport that is to be drawn in the workstation window.
    def setwswindow(*)
      super
    end

    # Define the size of the workstation graphics window in meters.
    def setwsviewport(*)
      super
    end

    def createseg(*)
      super
    end

    def copysegws(*)
      super
    end

    def redrawsegws(*)
      super
    end

    def setsegtran(*)
      super
    end

    def closeseg(*)
      super
    end

    def emergencyclosegks(*)
      super
    end

    def updategks(*)
      super
    end

    # Set the abstract Z-space used for mapping three-dimensional output primitives into
    # the current world coordinate space.
    def setspace(*)
      super
    end

    def inqspace
      inquiry %i[double double int int] do |*pts|
        super(*pts)
      end
    end

    # Draw a text at position `x`, `y` using the current text attributes. Strings can be
    # defined to create basic mathematical expressions and Greek letters.
    def textext(*)
      super
    end

    # inqtextext
    def inqtextext(x, y, string)
      inquiry [{ double: 4 }, { double: 4 }] do |tbx, tby|
        super(x, y, string, tbx, tby)
      end
    end

    # Draw X and Y coordinate axes with linearly and/or logarithmically spaced tick marks.
    def axes(*)
      super
    end

    alias axes2d axes

    # Draw a linear and/or logarithmic grid.
    def grid(*)
      super
    end

    # Draw a linear and/or logarithmic grid.
    def grid3d(*)
      super
    end

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

    # Draw X, Y and Z coordinate axes with linearly and/or logarithmically
    # spaced tick marks.
    def axes3d(*)
      super
    end

    # Display axis titles just outside of their respective axes.
    def titles3d(*)
      super
    end

    # Draw a three-dimensional surface plot for the given data points.
    def surface(px, py, pz, option)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = px.length
      ny = py.length
      super(nx, ny, px, py, pz, option)
    end

    # Draw contours of a three-dimensional data set
    # whose values are specified over a rectangular mesh.
    # Contour lines may optionally be labeled.
    def contour(px, py, h, pz, major_h)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = px.length
      ny = py.length
      nh = h.length
      super(nx, ny, nh, px, py, h, pz, major_h)
    end

    # Draw filled contours of a three-dimensional data set
    # whose values are specified over a rectangular mesh.
    def contourf(px, py, h, pz, major_h)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = px.length
      ny = py.length
      nh = h.length
      super(nx, ny, nh, px, py, h, pz, major_h)
    end

    # Draw a contour plot for the given triangle mesh.
    def tricontour(x, y, z, levels)
      npoints = x.length # equal_length ?
      nlevels = levels.length
      super(npoints, x, y, z, nlevels, levels)
    end

    def hexbin(x, y, nbins)
      n = x.length
      super(n, x, y, nbins)
    end

    def setcolormap(*)
      super
    end

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
        raise if positions.length != n
      end
      super(n, r, g, b, positions)
    end

    def colorbar(*)
      super
    end

    # inqcolor
    def inqcolor(color)
      inquiry_int do |rgb|
        super(color, rgb)
      end
    end

    def inqcolorfromrgb(*)
      super
    end

    def hsvtorgb(h, s, v)
      inquiry %i[double double double] do |r, g, b|
        super(h, s, v, r, g, b)
      end
    end

    def tick(*)
      super
    end

    def validaterange(*)
      super
    end

    def adjustlimits(*)
      super
    end

    def adjustrange(*)
      super
    end

    # Open and activate a print device.
    def beginprint(*)
      super
    end

    # Open and activate a print device with the given layout attributes.
    def beginprintext(*)
      super
    end

    def endprint(*)
      super
    end

    def ndctowc(x, y)
      inquiry %i[double double] do |px, py|
        px.write_double x
        py.write_double y
        super(px, py)
      end
    end

    def wctondc(x, y)
      inquiry %i[double double] do |px, py|
        px.write_double x
        py.write_double y
        super(px, py)
      end
    end

    def wc3towc(x, y, z)
      inquiry %i[double double double] do |px, py, pz|
        px.write_double x
        py.write_double y
        pz.write_double z
        super(px, py, pz)
      end
    end

    # Draw a rectangle using the current line attributes.
    def drawrect(*)
      super
    end

    # Draw a filled rectangle using the current fill attributes.
    def fillrect(*)
      super
    end

    # Draw a circular or elliptical arc covering the specified rectangle.
    def drawarc(*)
      super
    end

    # Fill a circular or elliptical arc covering the specified rectangle.
    def fillarc(*)
      super
    end

    # Draw simple and compound outlines consisting of line segments and bezier curves.
    def drawpath(points, codes, fill)
      len = codes.length
      super(len, points, uint8(codes), fill)
    end

    # Set the arrow style to be used for subsequent arrow commands.
    def setarrowstyle(*)
      super
    end

    # Set the arrow size to be used for subsequent arrow commands.
    def setarrowsize(*)
      super
    end

    # Draw an arrow between two points.
    def drawarrow(*)
      super
    end

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

    def importgraphics(*)
      super
    end

    # `setshadow` allows drawing of shadows, realized by images painted underneath,
    # and offset from, graphics objects such that the shadow mimics the effect of a light
    # source cast on the graphics objects.
    def setshadow(*)
      super
    end

    # Set the value of the alpha component associated with GR colors.
    def settransparency(*)
      super
    end

    # Change the coordinate transformation according to the given matrix.
    def setcoordxform(mat)
      raise if mat.size != 6

      super(mat)
    end

    # Open a file for graphics output.
    def begingraphics(*)
      super
    end

    def endgraphics(*)
      super
    end

    def getgraphics(*)
      super
    end

    def drawgraphics(*)
      super
    end

    # Generate a character string starting at the given location. Strings can be defined
    # to create mathematical symbols and Greek letters using LaTeX syntax.
    def mathtex(*)
      super
    end

    # inqmathtex
    def inqmathtex(x, y, string)
      inquiry [{ double: 4 }, { double: 4 }] do |tbx, tby|
        super(x, y, string, tbx, tby)
      end
    end

    def beginselection(*)
      super
    end

    def endselection(*)
      super
    end

    def moveselection(*)
      super
    end

    def resizeselection(*)
      super
    end

    def inqbbox
      inquiry %i[double double double double] do |*pts|
        super(*pts)
      end
    end

    def precision(*)
      super
    end

    def setregenflags(*)
      super
    end

    def inqregenflags(*)
      super
    end

    def savestate(*)
      super
    end

    def restorestate(*)
      super
    end

    def selectcontext(*)
      super
    end

    def destroycontext(*)
      super
    end

    def uselinespec(*)
      super
    end

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
      n = [px, py, pz].map(&:length).min
      super(n, px, py, pz)
    end

    # gradient
    def gradient(x, y, z)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = x.length
      ny = y.length
      inquiry [{ double: nx * ny }, { double: nx * ny }] do |pu, pv|
        super(nx, ny, x, y, z, pu, pv)
      end
    end

    # Draw a quiver plot on a grid of nx*ny points.
    def quiver(x, y, u, v, color)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = x.length
      ny = y.length
      super(nx, ny, x, y, u, v, (color ? 1 : 0))
    end

    # Interpolation in two dimensions using one of four different methods. The
    # input points are located on a grid, described by `x`, `y` and `z`.
    # The target grid ist described by `xq` and `yq`.
    # Returns an array containing the resulting z-values.
    def interp2(x, y, z, xq, yq, method, extrapval) # flatten
      nx = x.length
      ny = y.length
      # nz = z.length
      nxq = xq.length
      nyq = yq.length
      inquiry(double: nxq * nyq) do |zq|
        super(nx, ny, x, y, z, nxq, nyq, xq, yq, zq, method, extrapval)
      end
    end

    # Returns the combined version strings of the GR runtime.
    def version
      super.read_string
    end

    # Display a point set as a aggregated and rasterized image.
    def shadepoints(x, y, dims: [1200, 1200], xform: 1)
      n = x.length
      w, h = dims
      super(n, x, y, xform, w, h)
    end

    # Display a line set as an aggregated and rasterized image.
    def shadelines(x, y, dims: [1200, 1200], xform: 1)
      n = x.length
      w, h = dims
      super(n, x, y, xform, w, h)
    end

    # panzoom
    def panzoom(x, y, zoom)
      inquiry %i[double double double double] do |xmin, xmax, ymin, ymax|
        super(x, y, zoom, zoom, xmin, xmax, ymin, ymax)
      end
    end

    # Set the resample method used for gr.drawimage().
    def setresamplemethod(*)
      super
    end

    # Inquire the resample method used for gr.drawimage().
    def inqresamplemethod
      inquiry_uint do |resample_method|
        super(resample_method)
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
