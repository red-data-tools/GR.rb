# frozen_string_literal: true

# OverView of GR.rb
#
# +--------------------+  +--------------------+
# | GR module          |  | GR3 module         |
# | +----------------+ |  | +----------------+ |
# | | GR::FFI        | |  | | GR3::FFI       | |
# | | +   libGR.so   | |  | | +    libGR3.so | |
# | +----------------+ |  | +----------------+ |
# |   | define_method  |  |   | define_method  |
# | +----------------+ |  | +----------------+ |
# | | | GR::GRBase   | |  | | | GR3::GR3Base | |
# | | v  (Pri^ate)   | |  | | v  (Pri^ate)   | |
# | +++--------------+ |  | +++--------------+ |
# |  | Extend          |  |  | Extend          |
# |  v                 |  |  v       +-------+ |
# |      +-----------+ |  |          | Check | |
# |      | GR::Plot  | |  |       <--+ Error | |
# |      +-----------+ |  |          +-------+ |
# +--------------------+  +----------+---------+
#           ^                        ^
#           |  +------------------+  |
#    Extend |  | GRCommons module |  | Extend
#           |  | +--------------+ |  |
#           |  | |    Fiddley   | |  |
#           |  | +--------------+ |  |
#           |  | +--------------+ |  |
#           +----+ CommonUtils  +----+
#           |  | +--------------+ |  |
#           |  | +--------------+ |  |
#           +----+    Version   +----+
#           |  | +--------------+ |
#           |  | +--------------+ |
#           +----+JupyterSupport| |
#              | +--------------+ |
#              +------------------+
#
# (You can edit the above AA diagram with http://asciiflow.com/))
#
# Fiddley is Ruby-FFI compatible API layer for Fiddle.
#
# The GR module works without Numo::Narrray.
# GR3 and GR::Plot depends on numo-narray.
#
# This is a procedural interface to the GR plotting library,
# https://github.com/sciapp/gr
module GR
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  raise Error, 'Please set env variable GRDIR' unless ENV['GRDIR']

  # Platforms |  path
  # Windows   |  bin/libgr.dll
  # MacOSX    |  lib/libGR.so (NOT .dylib)
  # Ubuntu    |  lib/libGR.so
  if Object.const_defined?(:RubyInstaller)
    self.ffi_lib = File.expand_path('bin/libgr.dll', ENV['GRDIR'])
    RubyInstaller::Runtime.add_dll_directory(File.dirname(ffi_lib))
  else
    self.ffi_lib = File.expand_path('lib/libGR.so', ENV['GRDIR'])
  end

  # Change the default encoding to UTF-8.
  ENV['GKS_ENCODING'] ||= 'utf8'

  require_relative 'gr_commons/gr_commons'
  require_relative 'gr/version'
  require_relative 'gr/ffi'
  require_relative 'gr/grbase'

  # `inquiry` methods etc. are defined here.
  extend GRCommons::GRCommonUtils

  # Support for Jupyter Notebook / Lab.
  extend GRCommons::JupyterSupport

  # `double` is the default type in GR.
  # A Ruby array or NArray passed to GR method is automatically converted to
  # a Fiddley::MemoryPointer in the GRBase class.
  extend GRBase

  # Now you can see a lot of methods just calling super here.
  # They are written to help the yard generate the documentation.
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
    # The values for `x` and `y` are in world coordinates. `x` must contain 
    # `dimx` + 1 elements and `y` must contain `dimy` + 1 elements. The elements
    # i and i+1 are respectively the edges of the i-th cell in X and Y direction.
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
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    # @param m [Integer] The number of points in the polygon to be drawn (`m` > len(`x`))
    # @param method [Integer] The smoothing method
    #  * If `method` is > 0, then a generalized cross-validated smoothing spline is calculated.
    #  * If `method` is 0, then an interpolating natural cubic spline is calculated.
    #  * If `method` is < -1, then a cubic B-spline is calculated.
    # The values for `x` and `y` are in world coordinates. The attributes that
    # control the appearance of a spline-fit are linetype, linewidth and color
    # index.
    def spline(x, y, m, method)
      n = equal_length(x, y)
      super(n, x, y, m, method)
    end

    def gridit(xd, yd, zd, nx, ny)
      nd = equal_length(xd, yd, zd)
      inquiry [{ double: nx }, { double: ny }, { double: nx * ny }] do |px, py, pz|
        super(nd, xd, yd, zd, nx, ny, px, py, pz)
      end
    end

    # Specify the line style for polylines.
    # @param style [Integer] The polyline line style
    #  * 1  : LINETYPE_SOLID
    #    *    Solid line
    #  * 2  : LINETYPE_DASHED
    #    *    Dashed line
    #  * 3  : LINETYPE_DOTTED
    #    *    Dotted line
    #  * 4  : LINETYPE_DASHED_DOTTED
    #    *    Dashed-dotted line
    #  * -1 : LINETYPE_DASH_2_DOT
    #    *    Sequence of one dash followed by two dots
    #  * -2 : LINETYPE_DASH_3_DOT
    #    *    Sequence of one dash followed by three dots
    #  * -3 : LINETYPE_LONG_DASH
    #    *    Sequence of long dashes
    #  * -4 : LINETYPE_LONG_SHORT_DASH
    #    *    Sequence of a long dash followed by a short dash
    #  * -5 : LINETYPE_SPACED_DASH
    #    *    Sequence of dashes double spaced
    #  * -6 : LINETYPE_SPACED_DOT
    #    *    Sequence of dots double spaced
    #  * -7 : LINETYPE_DOUBLE_DOT
    #    *    Sequence of pairs of dots
    #  * -8 : LINETYPE_TRIPLE_DOT
    #    *    Sequence of groups of three dots
    def setlinetype(*)
      super
    end

    def inqlinetype
      inquiry_int { |pt| super(pt) }
    end

    # Define the line width of subsequent polyline output primitives.
    # @param width [Numeric] The polyline line width scale factor
    # The line width is calculated as the nominal line width generated
    # on the workstation multiplied by the line width scale factor.
    # This value is mapped by the workstation to the nearest available line width.
    # The default line width is 1.0, or 1 times the line width generated on the graphics device.
    def setlinewidth(*)
      super
    end

    def inqlinewidth
      inquiry_double { |pt| super(pt) }
    end

    # Define the color of subsequent polyline output primitives.
    # @param color [Integer] The polyline color index (COLOR < 1256)
    def setlinecolorind(*)
      super
    end

    # inqlinecolorind
    def inqlinecolorind
      inquiry_int { |pt| super(pt) }
    end

    # Specifiy the marker type for polymarkers.
    # @param style [Integer] The polymarker marker type
    #  * 1   : MARKERTYPE_DOT
    #    *     Smallest displayable dot
    #  * 2   : MARKERTYPE_PLUS
    #    *     Plus sign
    #  * 3   : MARKERTYPE_ASTERISK
    #    *     Asterisk
    #  * 4   : MARKERTYPE_CIRCLE
    #    *     Hollow circle
    #  * 5   : MARKERTYPE_DIAGONAL_CROSS
    #    *     Diagonal cross
    #  * -1  : MARKERTYPE_SOLID_CIRCLE
    #    *     Filled circle
    #  * -2  : MARKERTYPE_TRIANGLE_UP
    #    *     Hollow triangle pointing upward
    #  * -3  : MARKERTYPE_SOLID_TRI_UP
    #    *     Filled triangle pointing upward
    #  * -4  : MARKERTYPE_TRIANGLE_DOWN
    #    *     Hollow triangle pointing downward
    #  * -5  : MARKERTYPE_SOLID_TRI_DOWN
    #    *     Filled triangle pointing downward
    #  * -6  : MARKERTYPE_SQUARE
    #    *     Hollow square
    #  * -7  : MARKERTYPE_SOLID_SQUARE
    #    *     Filled square
    #  * -8  : MARKERTYPE_BOWTIE
    #    *     Hollow bowtie
    #  * -9  : MARKERTYPE_SOLID_BOWTIE
    #    *     Filled bowtie
    #  * -10 : MARKERTYPE_HGLASS
    #    *     Hollow hourglass
    #  * -11 : MARKERTYPE_SOLID_HGLASS
    #    *     Filled hourglass
    #  * -12 : MARKERTYPE_DIAMOND
    #    *     Hollow diamond
    #  * -13 : MARKERTYPE_SOLID_DIAMOND
    #    *     Filled Diamond
    #  * -14 : MARKERTYPE_STAR
    #    *     Hollow star
    #  * -15 : MARKERTYPE_SOLID_STAR
    #    *     Filled Star
    #  * -16 : MARKERTYPE_TRI_UP_DOWN
    #    *     Hollow triangles pointing up and down overlaid
    #  * -17 : MARKERTYPE_SOLID_TRI_RIGHT
    #    *     Filled triangle point right
    #  * -18 : MARKERTYPE_SOLID_TRI_LEFT
    #    *     Filled triangle pointing left
    #  * -19 : MARKERTYPE_HOLLOW PLUS
    #    *     Hollow plus sign
    #  * -20 : MARKERTYPE_SOLID PLUS
    #    *     Solid plus sign
    #  * -21 : MARKERTYPE_PENTAGON
    #    *     Pentagon
    #  * -22 : MARKERTYPE_HEXAGON
    #    *     Hexagon
    #  * -23 : MARKERTYPE_HEPTAGON
    #    *     Heptagon
    #  * -24 : MARKERTYPE_OCTAGON
    #    *     Octagon
    #  * -25 : MARKERTYPE_STAR_4
    #    *     4-pointed star
    #  * -26 : MARKERTYPE_STAR_5
    #    *     5-pointed star (pentagram)
    #  * -27 : MARKERTYPE_STAR_6
    #    *     6-pointed star (hexagram)
    #  * -28 : MARKERTYPE_STAR_7
    #    *     7-pointed star (heptagram)
    #  * -29 : MARKERTYPE_STAR_8
    #    *     8-pointed star (octagram)
    #  * -30 : MARKERTYPE_VLINE
    #    *     verical line
    #  * -31 : MARKERTYPE_HLINE
    #    *     horizontal line
    #  * -32 : MARKERTYPE_OMARK
    #    *     o-mark
    # Polymarkers appear centered over their specified coordinates.
    def setmarkertype(*)
      super
    end

    def inqmarkertype
      inquiry_int { |pt| super(pt) }
    end

    # Specify the marker size for polymarkers.
    # @param size [Numeric] Scale factor applied to the nominal marker size
    # The polymarker size is calculated as the nominal size generated on the graphics device
    # multiplied by the marker size scale factor.
    def setmarkersize(*)
      super
    end

    # Inquire the marker size for polymarkers.
    def inqmarkersize
      inquiry_double { |pt| super(pt) }
    end

    # Define the color of subsequent polymarker output primitives.
    # @param color [Integer] The polymarker color index (COLOR < 1256)
    def setmarkercolorind(*)
      super
    end

    def inqmarkercolorind
      inquiry_int { |pt| super(pt) }
    end

    # Specify the text font and precision for subsequent text output primitives.
    # @param font [Integer] Text font
    #  * 101 : FONT_TIMES_ROMAN
    #  * 102 : FONT_TIMES_ITALIC
    #  * 103 : FONT_TIMES_BOLD
    #  * 104 : FONT_TIMES_BOLDITALIC
    #  * 105 : FONT_HELVETICA
    #  * 106 : FONT_HELVETICA_OBLIQUE
    #  * 107 : FONT_HELVETICA_BOLD
    #  * 108 : FONT_HELVETICA_BOLDOBLIQUE
    #  * 109 : FONT_COURIER
    #  * 110 : FONT_COURIER_OBLIQUE
    #  * 111 : FONT_COURIER_BOLD
    #  * 112 : FONT_COURIER_BOLDOBLIQUE
    #  * 113 : FONT_SYMBOL
    #  * 114 : FONT_BOOKMAN_LIGHT
    #  * 115 : FONT_BOOKMAN_LIGHTITALIC
    #  * 116 : FONT_BOOKMAN_DEMI
    #  * 117 : FONT_BOOKMAN_DEMIITALIC
    #  * 118 : FONT_NEWCENTURYSCHLBK_ROMAN
    #  * 119 : FONT_NEWCENTURYSCHLBK_ITALIC
    #  * 120 : FONT_NEWCENTURYSCHLBK_BOLD
    #  * 121 : FONT_NEWCENTURYSCHLBK_BOLDITALIC
    #  * 122 : FONT_AVANTGARDE_BOOK
    #  * 123 : FONT_AVANTGARDE_BOOKOBLIQUE
    #  * 124 : FONT_AVANTGARDE_DEMI
    #  * 125 : FONT_AVANTGARDE_DEMIOBLIQUE
    #  * 126 : FONT_PALATINO_ROMAN
    #  * 127 : FONT_PALATINO_ITALIC
    #  * 128 : FONT_PALATINO_BOLD
    #  * 129 : FONT_PALATINO_BOLDITALIC
    #  * 130 : FONT_ZAPFCHANCERY_MEDIUMITALIC
    #  * 131 : FONT_ZAPFDINGBATS
    # @param precision [Integer] Text precision
    #  * 0 : TEXT_PRECISION_STRING
    #    *   String precision (higher quality)
    #  * 1 : TEXT_PRECISION_CHAR
    #    *   Character precision (medium quality)
    #  * 2 : TEXT_PRECISION_STROKE
    #    *   Stroke precision (lower quality)
    # The appearance of a font depends on the text precision value specified.
    # STRING, CHARACTER or STROKE precision allows for a greater or lesser
    # realization of the text primitives, for efficiency. STRING is the default
    # precision for GR and produces the highest quality output.
    def settextfontprec(*)
      super
    end

    # Set the current character expansion factor (width to height ratio).
    # @param factor [Numeric] Text expansion factor applied to the nominal text width-to-height ratio
    # `setcharexpan` defines the width of subsequent text output primitives. The expansion
    # factor alters the width of the generated characters, but not their height. The default
    # text expansion factor is 1, or one times the normal width-to-height ratio of the text.
    def setcharexpan(*)
      super
    end

    def setcharspace(*)
      super
    end

    # Sets the current text color index.
    # @param color [Integer] The text color index (COLOR < 1256)
    # `settextcolorind` defines the color of subsequent text output primitives.
    # GR uses the default foreground color (black=1) for the default text color index.
    def settextcolorind(*)
      super
    end

    # Gets the current text color index.
    # This function gets the color of text output primitives.
    # @return [Integer] color The text color index (COLOR < 1256)
    def inqtextcolorind
      inquiry_int { |pt| super(pt) }
    end

    # Set the current character height.
    # @param height [Numeric] Text height value
    # `setcharheight` defines the height of subsequent text output primitives. Text height
    # is defined as a percentage of the default window. GR uses the default text height of
    # 0.027 (2.7% of the height of the default window).
    def setcharheight(*)
      super
    end

    # Set the current character text angle up vector.
    # @param ux [Numeric] Text up vector
    # @param uy [Numeric] Text up vector
    # `setcharup` defines the vertical rotation of subsequent text output primitives.
    # The text up vector is initially set to (0, 1), horizontal to the baseline.
    def setcharup(*)
      super
    end

    # Define the current direction in which subsequent text will be drawn.
    # @param path [Integer] Text path
    #  * 0 : TEXT_PATH_RIGHT
    #    *   left-to-right
    #  * 1 : TEXT_PATH_LEFT
    #    *   right-to-left
    #  * 2 : TEXT_PATH_UP
    #    *   downside-up
    #  * 3 : TEXT_PATH_DOWN
    #    *   upside-down
    def settextpath(*)
      super
    end

    # Set the current horizontal and vertical alignment for text.
    # @param horizontal [Integer] Horizontal text alignment
    #  * 0 : TEXT_HALIGN_NORMAL
    #  * 1 : TEXT_HALIGN_LEFT
    #    *   Left justify
    #  * 2 : TEXT_HALIGN_CENTER
    #    *   Center justify
    #  * 3 : TEXT_HALIGN_RIGHT
    #    *   Right justify
    # @param vertical [Integer] Vertical text alignment
    #  * 0 : TEXT_VALIGN_NORMAL   
    #  * 1 : TEXT_VALIGN_TOP
    #    *   Align with the top of the characters
    #  * 2 : TEXT_VALIGN_CAP
    #    *   Aligned with the cap of the characters
    #  * 3 : TEXT_VALIGN_HALF
    #    *   Aligned with the half line of the characters
    #  * 4 : TEXT_VALIGN_BASE
    #    *   Aligned with the base line of the characters
    #  * 5 : TEXT_VALIGN_BOTTOM
    #    *   Aligned with the bottom line of the characters
    # `settextalign` specifies how the characters in a text primitive will be aligned
    # in horizontal and vertical space. The default text alignment indicates horizontal left
    # alignment and vertical baseline alignment.
    def settextalign(*)
      super
    end

    # Set the fill area interior style to be used for fill areas.
    # @param style [Integer] The style of fill to be used
    #  * 0 : HOLLOW
    #    *   No filling. Just draw the bounding polyline
    #  * 1 : SOLID
    #    *   Fill the interior of the polygon using the fill color index
    #  * 2 : PATTERN
    #    *   Fill the interior of the polygon using the style index as a pattern index
    #  * 3 : HATCH
    #    *   Fill the interior of the polygon using the style index as a cross-hatched style
    # `setfillintstyle` defines the interior style  for subsequent fill area output
    # primitives. The default interior style is HOLLOW.
    def setfillintstyle(*)
      super
    end

    # Returns the fill area interior style to be used for fill areas.
    def inqfillintstyle
      inquiry_int { |pt| super(pt) }
    end

    # Sets the fill style to be used for subsequent fill areas.
    # @param index [Integer] The fill style index to be used
    # `setfillstyle` specifies an index when PATTERN fill or HATCH fill is requested by the
    # `setfillintstyle` function. If the interior style is set to PATTERN, the fill style
    # index points to a device-independent pattern table. If interior style is set to HATCH
    # the fill style index indicates different hatch styles. If HOLLOW or SOLID is specified
    # for the interior style, the fill style index is unused.
    def setfillstyle(*)
      super
    end

    # Returns the current fill area color index.
    def inqfillstyle
      inquiry_int { |pt| super(pt) }
    end

    # Sets the current fill area color index.
    # @param color [Integer] The text color index (COLOR < 1256)
    # `setfillcolorind` defines the color of subsequent fill area output primitives.
    # GR uses the default foreground color (black=1) for the default fill area color index.
    def setfillcolorind(*)
      super
    end

    # Returns the current fill area color index.
    def inqfillcolorind
      inquiry_int { |pt| super(pt) }
    end

    # `setcolorrep` allows to redefine an existing color index representation by specifying
    # an RGB color triplet.
    # @param index [Integer] Color index in the range 0 to 1256
    # @param red [Numeric] Red intensity in the range 0.0 to 1.0
    # @param green [Numeric] Green intensity in the range 0.0 to 1.0
    # @param blue [Numeric] Blue intensity in the range 0.0 to 1.0
    def setcolorrep(*)
      super
    end

    # `setwindow` establishes a window, or rectangular subspace, of world coordinates to be
    # plotted. If you desire log scaling or mirror-imaging of axes, use the SETSCALE function.
    # @param xmin [Numeric] The left horizontal coordinate of the window (`xmin` < `xmax`).
    # @param xmax [Numeric] The right horizontal coordinate of the window.
    # @param ymin [Numeric] The bottom vertical coordinate of the window (`ymin` < `ymax`).
    # @param ymax [Numeric] The top vertical coordinate of the window.
    # `setwindow` defines the rectangular portion of the World Coordinate space (WC) to be
    # associated with the specified normalization transformation. The WC window and the
    # Normalized Device Coordinates (NDC) viewport define the normalization transformation
    # through which all output primitives are mapped. The WC window is mapped onto the
    # rectangular NDC viewport which is, in turn, mapped onto the display surface of the
    # open and active workstation, in device coordinates. By default, GR uses the range
    # \[0,1] x [0,1], in world coordinates, as the normalization transformation window.
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
    # @param xmin [Numeric] The left horizontal coordinate of the viewport.
    # @param xmax [Numeric] The right horizontal coordinate of the viewport (0 <= `xmin` < `xmax` <= 1).
    # @param ymin [Numeric] The bottom vertical coordinate of the viewport.
    # @param ymax [Numeric] The top vertical coordinate of the viewport (0 <= `ymin` < `ymax` <= 1).
    # `setviewport` defines the rectangular portion of the Normalized Device Coordinate
    # (NDC) space to be associated with the specified normalization transformation. The
    # NDC viewport and World Coordinate (WC) window define the normalization transformation
    # through which all output primitives pass. The WC window is mapped onto the rectangular
    # NDC viewport which is, in turn, mapped onto the display surface of the open and active
    # workstation, in device coordinates.
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
    # @param transform [Integer] A normalization transformation number.
    #  * 0    : Selects the identity transformation in which both the window and viewport have the range of 0 to 1
    #  * >= 1 : Selects a normalization transformation as defined by `setwindow` and `setviewport`
    def selntran(*)
      super
    end

    # Set the clipping indicator.
    # @params indicator [Integer] An indicator specifying whether clipping is on or off.
    # * 0 : Clipping is off. Data outside of the window will be drawn.
    # * 1 : Clipping is on. Data outside of the window will not be drawn.
    # `setclip` enables or disables clipping of the image drawn in the current window.
    # Clipping is defined as the removal of those portions of the graph that lie outside of
    # the defined viewport. If clipping is on, GR does not draw generated output primitives
    # past the viewport boundaries. If clipping is off, primitives may exceed the viewport
    # boundaries, and they will be drawn to the edge of the workstation window.
    # By default, clipping is on.
    def setclip(*)
      super
    end

    # Set the area of the NDC viewport that is to be drawn in the workstation window.
    # @param xmin [Numeric] The left horizontal coordinate of the workstation window.
    # @param xmax [Numeric] The right horizontal coordinate of the workstation window (0 <= `xmin` < `xmax` <= 1).
    # @param ymin [Numeric] The bottom vertical coordinate of the workstation window.
    # @param ymax [Numeric] The top vertical coordinate of the workstation window (0 <= `ymin` < `ymax` <= 1).
    # `setwswindow` defines the rectangular area of the Normalized Device Coordinate space
    # to be output to the device. By default, the workstation transformation will map the
    # range [0,1] x [0,1] in NDC onto the largest square on the workstation’s display
    # surface. The aspect ratio of the workstation window is maintained at 1 to 1.
    def setwswindow(*)
      super
    end

    # Define the size of the workstation graphics window in meters.
    # @param xmin [Numeric] The left horizontal coordinate of the workstation viewport.
    # @param xmax [Numeric] The right horizontal coordinate of the workstation viewport.
    # @param ymin [Numeric] The bottom vertical coordinate of the workstation viewport.
    # @param ymax [Numeric] The top vertical coordinate of the workstation viewport.
    # `setwsviewport` places a workstation window on the display of the specified size in
    # meters. This command allows the workstation window to be accurately sized for a
    # display or hardcopy device, and is often useful for sizing graphs for desktop
    # publishing applications.
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
    # @param zmin [Numeric] Minimum value for the Z-axis.
    # @param zmax [Numeric] Maximum value for the Z-axis.
    # @param rotation [Integer] Angle for the rotation of the X axis, in degrees.
    # @param tilt [integer] Viewing angle of the Z axis in degrees.
    # @return [Integer]
    # `setspace` establishes the limits of an abstract Z-axis and defines the angles for
    # rotation and for the viewing angle (tilt) of a simulated three-dimensional graph,
    # used for mapping corresponding output primitives into the current window.
    # These settings are used for all subsequent three-dimensional output primitives until
    # other values are specified. Angles of rotation and viewing angle must be specified
    # between 0° and 90°.
    def setspace(*)
      super
    end

    def inqspace
      inquiry %i[double double int int] do |*pts|
        super(*pts)
      end
    end

    # `setscale` sets the type of transformation to be used for subsequent GR output
    # primitives.
    # @param options [Integer] Scale specification
    #  * 1 :  OPTION_X_LOG
    #    *    Logarithmic X-axis
    #  * 2 :  OPTION_Y_LOG
    #    *    Logarithmic Y-axis
    #  * 4 :  OPTION_Z_LOG
    #    *    Logarithmic Z-axis
    #  * 8 :  OPTION_FLIP_X
    #    *    Flip X-axis
    #  * 16 : OPTION_FLIP_Y
    #    *    Flip Y-axis
    #  * 32 : OPTION_FLIP_Z
    #    *    Flip Z-axis
    # @return [Integer]
    # `setscale` defines the current transformation according to the given scale
    # specification which may be or'ed together using any of the above options. GR uses
    # these options for all subsequent output primitives until another value is provided.
    # The scale options are used to transform points from an abstract logarithmic or
    # semi-logarithmic coordinate system, which may be flipped along each axis, into the
    # world coordinate system.
    # Note: When applying a logarithmic transformation to a specific axis, the system
    # assumes that the axes limits are greater than zero.
    def setscale(*)
      super
    end

    # inqscale
    def inqscale
      inquiry_int { |pt| super(pt) }
    end

    # Draw a text at position `x`, `y` using the current text attributes. Strings can be
    # defined to create basic mathematical expressions and Greek letters.
    # @param x [Numeric] The X coordinate of starting position of the text string
    # @param y [Numeric] The Y coordinate of starting position of the text string
    # @param string [String] The text to be drawn
    # @return [Integer]
    #
    # The values for X and Y are in normalized device coordinates.
    # The attributes that control the appearance of text are text font and precision,
    # character expansion factor, character spacing, text color index, character
    # height, character up vector, text path and text alignment.
    #
    # The character string is interpreted to be a simple mathematical formula.
    # The following notations apply:
    #
    # Subscripts and superscripts: These are indicated by carets ('^') and underscores
    # \('_'). If the sub/superscript contains more than one character, it must be enclosed
    # in curly braces ('{}').
    #
    # Fractions are typeset with A '/' B, where A stands for the numerator and B for the
    # denominator.
    #
    # To include a Greek letter you must specify the corresponding keyword after a
    # backslash ('\') character. The text translator produces uppercase or lowercase
    # Greek letters depending on the case of the keyword.
    #  * Α α - alpha
    #  * Β β - beta
    #  * Γ γ - gamma
    #  * Δ δ - delta
    #  * Ε ε - epsilon
    #  * Ζ ζ - zeta
    #  * Η η - eta
    #  * Θ θ - theta
    #  * Ι ι - iota
    #  * Κ κ - kappa
    #  * Λ λ - lambda
    #  * Μ μ - mu
    #  * Ν ν - Nu / v
    #  * Ξ ξ - xi
    #  * Ο ο - omicron
    #  * Π π - pi
    #  * Ρ ρ - rho
    #  * Σ σ - sigma
    #  * Τ τ - tau
    #  * Υ υ - upsilon
    #  * Φ φ - phi
    #  * Χ χ - chi
    #  * Ψ ψ - psi
    #  * Ω ω - omega
    # Note: `\v` is a replacement for `\nu` which would conflict with `\n` (newline)
    # For more sophisticated mathematical formulas, you should use the `gr.mathtex`
    # function.
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
    # @param x_tick [Numeric] The interval between minor tick marks on the X axis.
    # @param y_tick [Numeric] The interval between minor tick marks on the Y axis.
    # @param x_org [Numeric] The world coordinates of the origin (point of intersection) of the X axis.
    # @param y_org [Numeric] The world coordinates of the origin (point of intersection) of the Y axis.
    # @param major_x [Integer]
    #   Unitless integer values specifying the number of minor tick intervals
    #   between major tick marks. Values of 0 or 1 imply no minor ticks.
    #   Negative values specify no labels will be drawn for the associated axis.
    # @param major_y [Integer]
    #   Unitless integer values specifying the number of minor tick intervals
    #   between major tick marks. Values of 0 or 1 imply no minor ticks.
    #   Negative values specify no labels will be drawn for the associated axis.
    # @param tick_size [Numeric]
    #   The length of minor tick marks specified in a normalized device
    #   coordinate unit. Major tick marks are twice as long as minor tick marks.
    #   A negative value reverses the tick marks on the axes from inward facing
    #   to outward facing (or vice versa).
    def axes(*)
      super
    end

    alias axes2d axes

    def axeslbl(*)
      super
    end

    # Draw a linear and/or logarithmic grid.
    # @param x_tick [Numeric] The length in world coordinates of the interval between minor grid lines.
    # @param y_tick [Numeric] The length in world coordinates of the interval between minor grid lines.
    # @param x_org [Numeric] The world coordinates of the origin (point of intersection) of the grid.
    # @param y_org [Numeric] The world coordinates of the origin (point of intersection) of the grid.
    # @param major_x [Integer]
    #   Unitless integer values specifying the number of minor grid lines
    #   between major grid lines. Values of 0 or 1 imply no grid lines.
    # @param major_y [Integer]
    #   Unitless integer values specifying the number of minor grid lines
    #   between major grid lines. Values of 0 or 1 imply no grid lines.
    #
    # Major grid lines correspond to the axes origin and major tick marks whether visible
    # or not. Minor grid lines are drawn at points equal to minor tick marks. Major grid
    # lines are drawn using black lines and minor grid lines are drawn using gray lines.
    def grid(*)
      super
    end

    # Draw a linear and/or logarithmic grid.
    # @param x_tick [Numeric] The length in world coordinates of the interval between minor grid lines.
    # @param y_tick [Numeric] The length in world coordinates of the interval between minor grid lines.
    # @param z_tick [Numeric] The length in world coordinates of the interval between minor grid lines.
    # @param x_org [Numeric] The world coordinates of the origin (point of intersection) of the grid.
    # @param y_org [Numeric] The world coordinates of the origin (point of intersection) of the grid.
    # @param z_org [Numeric] The world coordinates of the origin (point of intersection) of the grid.
    # @param major_x [Integer]
    #   Unitless integer values specifying the number of minor grid lines
    #   between major grid lines. Values of 0 or 1 imply no grid lines.
    # @param major_y [Integer]
    #   Unitless integer values specifying the number of minor grid lines
    #   between major grid lines. Values of 0 or 1 imply no grid lines.
    # @param major_z [Integer]
    #   Unitless integer values specifying the number of minor grid lines
    #   between major grid lines. Values of 0 or 1 imply no grid lines.
    #
    # Major grid lines correspond to the axes origin and major tick marks whether visible
    # or not. Minor grid lines are drawn at points equal to minor tick marks. Major grid
    # lines are drawn using black lines and minor grid lines are drawn using gray lines.
    def grid3d(*)
      super
    end

    # Draw a standard vertical error bar graph.
    # @param x [Array, NArray] A list of length N containing the X coordinates
    # @param y [Array, NArray] A list of length N containing the Y coordinates
    # @param e1 [Array, NArray] The absolute values of the lower error bar data
    # @param e2 [Array, NArray] The absolute values of the lower error bar data
    def verrorbars(x, y, e1, e2)
      n = equal_length(x, y, e1, e2)
      super(n, x, y, e1, e2)
    end

    # Draw a standard horizontal error bar graph.
    # @param x [Array, NArray] A list of length N containing the X coordinates
    # @param y [Array, NArray] A list of length N containing the Y coordinates
    # @param e1 [Array, NArray] The absolute values of the lower error bar data
    # @param e2 [Array, NArray] The absolute values of the lower error bar data
    def herrorbars(x, y, e1, e2)
      n = equal_length(x, y, e1, e2)
      super(n, x, y, e1, e2)
    end

    # Draw a 3D curve using the current line attributes,
    # starting from the first data point and ending at the last data point.
    # @param x [Array, NArray] A list of length N containing the X coordinates
    # @param y [Array, NArray] A list of length N containing the Y coordinates
    # @param z [Array, NArray] A list of length N containing the Z coordinates
    # The values for `x`, `y` and `z` are in world coordinates. The attributes that
    # control the appearance of a polyline are linetype, linewidth and color
    # index.
    def polyline3d(x, y, z)
      n = equal_length(x, y, z)
      super(n, x, y, z)
    end

    # Draw marker symbols centered at the given 3D data points.
    # @param x [Array, NArray] A list of length N containing the X coordinates
    # @param y [Array, NArray] A list of length N containing the Y coordinates
    # @param z [Array, NArray] A list of length N containing the Z coordinates
    # The values for `x`, `y` and `z` are in world coordinates. The attributes
    # that control the appearance of a polymarker are marker type, marker size
    # scale factor and color index.
    def polymarker3d(x, y, z)
      n = equal_length(x, y, z)
      super(n, x, y, z)
    end

    # Draw X, Y and Z coordinate axes with linearly and/or logarithmically
    # spaced tick marks.
    # @param x_tick [Numeric] The interval between minor tick marks on the X axis.
    # @param y_tick [Numeric] The interval between minor tick marks on the Y axis.
    # @param z_tick [Numeric] The interval between minor tick marks on the Z axis.
    # @param x_org [Numeric] The world coordinates of the origin (point of intersection) of the X axes.
    # @param y_org [Numeric] The world coordinates of the origin (point of intersection) of the Y axes.
    # @param z_org [Numeric] The world coordinates of the origin (point of intersection) of the Z axes.
    # @param major_x [Integer]
    #   Unitless integer values specifying the number of minor tick intervals
    #   between major tick marks. Values of 0 or 1 imply no minor ticks.
    #   Negative values specify no labels will be drawn for the associated axis.
    # @param major_y [Integer]
    #   Unitless integer values specifying the number of minor tick intervals
    #   between major tick marks. Values of 0 or 1 imply no minor ticks.
    #   Negative values specify no labels will be drawn for the associated axis.
    # @param major_z [Integer]
    #   Unitless integer values specifying the number of minor tick intervals
    #   between major tick marks. Values of 0 or 1 imply no minor ticks.
    #   Negative values specify no labels will be drawn for the associated axis.
    # @param [Numeric] tick_size
    #   The length of minor tick marks specified in a normalized device
    #   coordinate unit. Major tick marks are twice as long as minor tick marks.
    #   A negative value reverses the tick marks on the axes from inward facing
    #   to outward facing (or vice versa).
    # Tick marks are positioned along each axis so that major tick marks fall on the axes
    # origin (whether visible or not). Major tick marks are labeled with the corresponding
    # data values. Axes are drawn according to the scale of the window. Axes and tick marks
    # are drawn using solid lines; line color and width can be modified using the
    # `setlinetype` and `setlinewidth` functions. Axes are drawn according to
    # the linear or logarithmic transformation established by the `setscale` function.
    def axes3d(*)
      super
    end

    # Display axis titles just outside of their respective axes.
    # @param x_title [String] The text to be displayed on the X axis
    # @param x_title [String] The text to be displayed on the Y axis
    # @param x_title [String] The text to be displayed on the Z axis
    def titles3d(*)
      super
    end

    # Draw a three-dimensional surface plot for the given data points.
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    # @param z [Array, NArray]
    #   A list of length `len(x)` * `len(y)` or an appropriately dimensioned
    #   array containing the Z coordinates
    # @param option [Integer] Surface display option
    #  * 0 LINES
    #    * Use X Y polylines to denote the surface
    #  * 1 MESH
    #    * Use a wire grid to denote the surface
    #  * 2 FILLED_MESH
    #    * Applies an opaque grid to the surface
    #  * 3 Z_SHADED_MESH
    #    * Applies Z-value shading to the surface
    #  * 4 COLORED_MESH
    #    * Applies a colored grid to the surface
    #  * 5 CELL_ARRAY
    #    * Applies a grid of individually-colored cells to the surface
    #  * 6 SHADED_MESH
    #    * Applies light source shading to the 3-D surface
    # `x` and `y` define a grid. `z` is a singly dimensioned array containing at least
    # `nx` * `ny` data points. Z describes the surface height at each point on the grid.
    # Data is ordered as shown in the table:
    def surface(x, y, z, option)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = x.length
      ny = y.length
      super(nx, ny, x, y, z, option)
    end

    # Draw contours of a three-dimensional data set
    # whose values are specified over a rectangular mesh.
    # Contour lines may optionally be labeled.
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    # @param h [Array, NArray] A list containing the Z coordinate for the height values
    # @param z [Array, NArray]
    #   A list containing the Z coordinate for the height values
    #   A list of length `len(x)` * `len(y)` or an appropriately dimensioned
    #   array containing the Z coordinates
    # @param major_h [Integer]
    #   Directs GR to label contour lines. For example, a value of 3 would label
    #   every third line. A value of 1 will label every line. A value of 0
    #   produces no labels. To produce colored contour lines, add an offset
    #   of 1000 to `major_h`.
    def contour(x, y, h, z, major_h)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = x.length
      ny = y.length
      nh = h.length
      super(nx, ny, nh, x, y, h, z, major_h)
    end

    # Draw filled contours of a three-dimensional data set
    # whose values are specified over a rectangular mesh.
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    # @param h [Array, NArray]
    #   A list containing the Z coordinate for the height values or the number
    #   of contour lines which will be evenly distributed between minimum and
    #   maximum Z value
    # @param z [Array, NArray]
    #   A list of length `len(x)` * `len(y)` or an appropriately dimensioned
    #   array containing the Z coordinates
    def contourf(x, y, h, z, major_h)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = x.length
      ny = y.length
      nh = h.length
      super(nx, ny, nh, x, y, h, z, major_h)
    end

    # Draw a contour plot for the given triangle mesh.
    def tricontour(x, y, z, levels)
      npoints = x.length # equal_length ?
      nlevels = levels.length
      super(npoints, x, y, z, nlevels, levels)
    end

    # @return [Integer]
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

    # TODO: GR.jl python-gr different API
    def setcolormapfromrgb(r, g, b, positions: nil)
      n = equal_length(r, g, b)
      if positions.nil?
        positions = Fiddle::NULL
      elsif positions.length != n
        raise
      end
      super(n, r, g, b, positions)
    end

    def colorbar(*)
      super
    end

    def inqcolor(color)
      inquiry_int do |rgb|
        super(color, rgb)
      end
    end

    # @return [Integer]
    def inqcolorfromrgb(*)
      super
    end

    def hsvtorgb(h, s, v)
      inquiry %i[double double double] do |r, g, b|
        super(h, s, v, r, g, b)
      end
    end

    # @return [Numeric]
    def tick(*)
      super
    end

    # @return [Integer]
    def validaterange(*)
      super
    end

    def adjustlimits(amin, amax)
      inquiry %i[double double] do |pamin, pamax|
        pamin.write_double amin
        pamax.write_double amax
        super(pamin, pamax)
      end
    end

    def adjustrange(amin, amax)
      inquiry %i[double double] do |pamin, pamax|
        pamin.write_double amin
        pamax.write_double amax
        super(pamin, pamax)
      end
    end

    # Open and activate a print device.
    # @param pathname [String] Filename for the print device.
    #  The following file types are supported:
    #  * .ps, .eps : PostScript
    #  * .pdf : Portable Document Format
    #  * .bmp : Windows Bitmap (BMP)
    #  * .jpeg, .jpg : JPEG image file
    #  * .png : Portable Network Graphics file (PNG)
    #  * .tiff, .tif : Tagged Image File Format (TIFF)
    #  * .fig : Xfig vector graphics file
    #  * .svg : Scalable Vector Graphics
    #  * .wmf : Windows Metafile
    # `beginprint` opens an additional graphics output device. The device type is obtained
    # from the given file extension.
    def beginprint(*)
      super
    end

    # Open and activate a print device with the given layout attributes.
    # @param pathname [String] Filename for the print device.
    # @param mode [String] Output mode (Color, GrayScale)
    # @param fmt [String] Output format
    #  The available formats are:
    #  * A4 : 0.210 x 0.297
    #  * B5 : 0.176 x 0.250
    #  * Letter : 0.216 x 0.279
    #  * Legal : 0.216 x 0.356
    #  * Executive : 0.191 x 0.254
    #  * A0 : 0.841 x 1.189
    #  * A1 : 0.594 x 0.841
    #  * A2 : 0.420 x 0.594
    #  * A3 : 0.297 x 0.420
    #  * A5 : 0.148 x 0.210
    #  * A6 : 0.105 x 0.148
    #  * A7 : 0.074 x 0.105
    #  * A8 : 0.052 x 0.074
    #  * A9 : 0.037 x 0.052
    #  * B0 : 1.000 x 1.414
    #  * B1 : 0.500 x 0.707
    #  * B10 : 0.031 x 0.044
    #  * B2 : 0.500 x 0.707
    #  * B3 : 0.353 x 0.500
    #  * B4 : 0.250 x 0.353
    #  * B6 : 0.125 x 0.176
    #  * B7 : 0.088 x 0.125
    #  * B8 : 0.062 x 0.088
    #  * B9 : 0.044 x 0.062
    #  * C5E : 0.163 x 0.229
    #  * Comm10E : 0.105 x 0.241
    #  * DLE : 0.110 x 0.220
    #  * Folio : 0.210 x 0.330
    #  * Ledger : 0.432 x 0.279
    #  * Tabloid : 0.279 x 0.432
    # @param orientation [String] Page orientation (Landscape, Portait)
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
    # @param xmin [Numeric] Lower left edge of the rectangle
    # @param xmax [Numeric] Lower right edge of the rectangle
    # @param ymin [Numeric] Upper left edge of the rectangle
    # @param ymax [Numeric] Upper right edge of the rectangle
    def drawrect(*)
      super
    end

    # Draw a filled rectangle using the current fill attributes.
    # @param xmin [Numeric] Lower left edge of the rectangle
    # @param xmax [Numeric] Lower right edge of the rectangle
    # @param ymin [Numeric] Upper left edge of the rectangle
    # @param ymax [Numeric] Upper right edge of the rectangle
    def fillrect(*)
      super
    end

    # Draw a circular or elliptical arc covering the specified rectangle.
    # @param xmin [Numeric] Lower left edge of the rectangle
    # @param xmax [Numeric] Lower right edge of the rectangle
    # @param ymin [Numeric] Upper left edge of the rectangle
    # @param ymax [Numeric] Upper right edge of the rectangle
    # @param a1 [Numeric] The start angle
    # @param a2 [Numeric] The end angle
    # The resulting arc begins at `a1` and ends at `a2` degrees. Angles are interpreted
    # such that 0 degrees is at the 3 o'clock position. The center of the arc is the center
    # of the given rectangle.
    def drawarc(*)
      super
    end

    # Fill a circular or elliptical arc covering the specified rectangle.
    # @param xmin [Numeric] Lower left edge of the rectangle
    # @param xmax [Numeric] Lower right edge of the rectangle
    # @param ymin [Numeric] Upper left edge of the rectangle
    # @param ymax [Numeric] Upper right edge of the rectangle
    # @param a1 [Numeric] The start angle
    # @param a2 [Numeric] The end angle
    # The resulting arc begins at `a1` and ends at `a2` degrees. Angles are interpreted
    # such that 0 degrees is at the 3 o'clock position. The center of the arc is the center
    # of the given rectangle.
    def fillarc(*)
      super
    end

    # Draw simple and compound outlines consisting of line segments and bezier curves.
    # @param points [Array, NArray] (N, 2) array of (x, y) vertices
    # @parm codes [Array, NArray] N-length array of path codes
    #  *  STOP : end the entire path
    #  *  MOVETO : move to the given vertex
    #  *  LINETO : draw a line from the current position to the given vertex
    #  *  CURVE3 : draw a quadratic Bézier curve
    #  *  CURVE4 : draw a cubic Bézier curve
    #  *  CLOSEPOLY : draw a line segment to the start point of the current path
    # @parm fill [Integer] A flag indication whether resulting path is to be filled or not
    def drawpath(points, codes, fill)
      len = codes.length
      super(len, points, uint8(codes), fill)
    end

    # Set the arrow style to be used for subsequent arrow commands.
    # @param style [Integer] The arrow style to be used
    #  The default arrow style is 1.
    #  * 1  : simple, single-ended
    #  * 2  : simple, single-ended, acute head
    #  * 3  : hollow, single-ended
    #  * 4  : filled, single-ended
    #  * 5  : triangle, single-ended
    #  * 6  : filled triangle, single-ended
    #  * 7  : kite, single-ended
    #  * 8  : filled kite, single-ended
    #  * 9  : simple, double-ended
    #  * 10 : simple, double-ended, acute head
    #  * 11 : hollow, double-ended
    #  * 12 : filled, double-ended
    #  * 13 : triangle, double-ended
    #  * 14 : filled triangle, double-ended
    #  * 15 : kite, double-ended
    #  * 16 : filled kite, double-ended
    #  * 17 : double line, single-ended
    #  * 18 : double line, double-ended
    # `setarrowstyle` defines the arrow style for subsequent arrow primitives.
    def setarrowstyle(*)
      super
    end

    # Set the arrow size to be used for subsequent arrow commands.
    # @param size [Numeric] The arrow size to be used
    # `setarrowsize` defines the arrow size for subsequent arrow primitives.
    # The default arrow size is 1.
    def setarrowsize(*)
      super
    end

    # Draw an arrow between two points.
    # @param x1 [Numeric] Starting point of the arrow (tail)
    # @param y1 [Numeric] Starting point of the arrow (tail)
    # @param x2 [Numeric] Head of the arrow
    # @param y2 [Numeric] Head of the arrow
    # Different arrow styles (angles between arrow tail and wing, optionally filled
    # heads, double headed arrows) are available and can be set with the `setarrowstyle`
    # function.
    def drawarrow(*)
      super
    end

    # @return [Integer]
    def readimage(path)
      # Feel free to make a pull request if you catch a mistake
      # or you have an idea to improve it.
      data = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INTPTR_T)
      w, h = inquiry [:int, :int] do |width, height|
        # data is a pointer of a pointer
        super(path, width, height, data.ref)
      end
      d = data.to_str(w * h * Fiddle::SIZEOF_INT).unpack('L*') # UInt32
      [w, h, d]
    end

    # Draw an image into a given rectangular area.
    # @param xmin [Numeric] First corner point of the rectangle
    # @param ymin [Numeric] First corner point of the rectangle
    # @param xmax [Numeric] Second corner point of the rectangle
    # @param ymax [Numeric] Second corner point of the rectangle
    # @param width [Integer] The width and the height of the image
    # @param height [Integer] The width and the height of the image
    # @param data [Array, NArray] An array of color values dimensioned `width` by `height`
    # @param model [Integer] Color model ( default = 0 )
    #  The available color models are:
    #  * 0 : MODEL_RGB
    #    *   AABBGGRR
    #  * 1 : MODEL_HSV
    #    *   AAVVSSHH
    # The points (`xmin`, `ymin`) and (`xmax`, `ymax`) are world coordinates defining
    # diagonally opposite corner points of a rectangle. This rectangle is divided into
    # `width` by `height` cells. The two-dimensional array `data` specifies colors
    # for each cell.
    def drawimage(xmin, xmax, ymin, ymax, width, height, data, model = 0)
      super(xmin, xmax, ymin, ymax, width, height, uint(data), model)
    end

    # @return [Integer]
    def importgraphics(*)
      super
    end

    # `setshadow` allows drawing of shadows, realized by images painted underneath,
    # and offset from, graphics objects such that the shadow mimics the effect of a light
    # source cast on the graphics objects.
    # @param offsetx [Numeric]
    #   An x-offset, which specifies how far in the horizontal direction the
    #   shadow is offset from the object
    # @param offsety [Numeric]
    #   A y-offset, which specifies how far in the vertical direction the shadow
    #   is offset from the object
    # @param blur [Numeric]
    #   A blur value, which specifies whether the object has a hard or a diffuse edge
    def setshadow(*)
      super
    end

    # Set the value of the alpha component associated with GR colors.
    # @param alpha [Numeric] An alpha value (0.0 - 1.0)
    def settransparency(*)
      super
    end

    # Change the coordinate transformation according to the given matrix.
    # @param mat [Array, NArray] 2D transformation matrix
    def setcoordxform(mat)
      raise if mat.size != 6

      super(mat)
    end

    # Open a file for graphics output.
    # @param path [String] Filename for the graphics file.
    # `begingraphics` allows to write all graphics output into a XML-formatted file until
    # the `endgraphics` functions is called. The resulting file may later be imported with
    # the `importgraphics` function.
    def begingraphics(*)
      super
    end

    def endgraphics(*)
      super
    end

    # @return [String]
    def getgraphics(*)
      super.to_s
    end

    # @return [Integer]
    def drawgraphics(*)
      super
    end

    # Generate a character string starting at the given location. Strings can be defined
    # to create mathematical symbols and Greek letters using LaTeX syntax.
    # @param x [Numeric] Position of the text string specified in world coordinates
    # @param y [Numeric] Position of the text string specified in world coordinates
    # @param string [String] The text string to be drawn
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

    # @return [Numeric]
    def precision(*)
      super
    end

    def setregenflags(*)
      super
    end

    # @return [Integer]
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

    # @return [Integer]
    def uselinespec(*)
      super
    end

    def delaunay(x, y)
      # Feel free to make a pull request if you catch a mistake
      # or you have an idea to improve it.
      npoints = equal_length(x, y)
      triangles = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INTPTR_T)
      dim = 3
      n_tri = inquiry_int do |ntri|
        super(npoints, x, y, ntri, triangles.ref)
      end
      if n_tri > 0
        tri = triangles.to_str(3 * n_tri * Fiddle::SIZEOF_INT).unpack('l*') # Int32
        # Ruby  : 0-based indexing
        # Julia : 1-based indexing
        tri = tri.each_slice(3).to_a
        [n_tri, tri]
      else
        0
      end
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
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    # @param z [Array, NArray] A list containing the Z coordinates
    def trisurface(x, y, z)
      n = [x, y, z].map(&:length).min
      super(n, x, y, z)
    end

    # @deprecated
    def gradient(x, y, z)
      # TODO: check: Arrays have incorrect length or dimension.
      nx = x.length
      ny = y.length
      inquiry [{ double: nx * ny }, { double: nx * ny }] do |pu, pv|
        super(nx, ny, x, y, z, pu, pv)
      end
    end

    # Draw a quiver plot on a grid of nx*ny points.
    # @param nx [Integer] The number of points along the x-axis of the grid
    # @param ny [Integer] The number of points along the y-axis of the grid
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    # @param u [Array, NArray] A list containing the U component for each point on the grid
    # @param v [Array, NArray] A list containing the V component for each point on the grid
    # @param color [Integer]
    #   A bool to indicate whether or not the arrows should be colored using
    #   the current colormap
    # The values for `x` and `y` are in world coordinates.
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
    # @param x [Array, NArray] Array containing the input grid's x-values
    # @param y [Array, NArray] Array containing the input grid's y-values
    # @param z [Array, NArray] Array containing the input grid's z-values (number of values: nx * ny)
    # @param xq [Array, NArray] Array containing the target grid's x-values
    # @param yq [Array, NArray] Array containing the target grid's y-values
    # @param method [Integer] Used method for interpolation
    #  The available methods for interpolation are the following:
    #  * 0 : INTERP2_NEAREST
    #    *   Nearest neighbour interpolation
    #  * 1 : INTERP2_LINEAR
    #    *   Linear interpolation
    #  * 2 : INTERP_2_SPLINE
    #    *   Interpolation using natural cubic splines
    #  * 3 : INTERP2_CUBIC
    #    *   Cubic interpolation
    # @param extrapval [Numeric] The extrapolation value
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
    # @return [String]
    def version
      super.to_s
    end

    def shade(*)
      super
    end

    # Display a point set as a aggregated and rasterized image.
    # @param x [Array, NArray] A pointer to the X coordinates
    # @param y [Array, NArray] A pointer to the Y coordinates
    # @param dims [Array, NArray] The size of the grid used for rasterization
    # @param xform [Integer] The transformation type used for color mapping
    #  The available transformation types are:
    #  * 0 : XFORM_BOOLEAN
    #    *   boolean
    #  * 1 : XFORM_LINEAR
    #    *   linear
    #  * 2 : XFORM_LOG
    #    *   logarithmic
    #  * 3 : XFORM_LOGLOG
    #    *   double logarithmic
    #  * 4 : XFORM_CUBIC
    #    *   cubic
    #  * 5 : XFORM_EQUALIZED
    #    *   histogram equalized
    # The values for `x` and `y` are in world coordinates.
    def shadepoints(x, y, dims: [1200, 1200], xform: 1)
      n = x.length
      w, h = dims
      super(n, x, y, xform, w, h)
    end

    # Display a line set as an aggregated and rasterized image.
    # @param x [Array, NArray] A pointer to the X coordinates
    # @param y [Array, NArray] A pointer to the Y coordinates
    # @param dims [Array, NArray] The size of the grid used for rasterization
    # @param xform [Integer] The transformation type used for color mapping
    #  The available transformation types are:
    #  * 0 : XFORM_BOOLEAN
    #    *   boolean
    #  * 1 : XFORM_LINEAR
    #    *   linear
    #  * 2 : XFORM_LOG
    #    *   logarithmic
    #  * 3 : XFORM_LOGLOG
    #    *   double logarithmic
    #  * 4 : XFORM_CUBIC
    #    *   cubic
    #  * 5 : XFORM_EQUALIZED
    #    *   histogram equalized
    # The values for `x` and `y` are in world coordinates.
    # NaN values can be used to separate the point set into line segments.
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
    # @param resample_method [Integer] the new resample method.
    #  The available options are:
    #  * 0x00000000 : RESAMPLE_DEFAULT
    #    *            default
    #  * 0x01010101 : RESAMPLE_NEAREST
    #    *            nearest neighbour
    #  * 0x02020202 : RESAMPLE_LINEAR
    #    *            linear
    #  * 0x03030303 : RESAMPLE_LANCZOS
    #    *            Lanczos
    #  Alternatively, combinations of these methods can be selected for horizontal or vertical upsampling or downsampling:
    #  * 0x00000000 : UPSAMPLE_VERTICAL_DEFAULT
    #    *            default for vertical upsampling
    #  * 0x00000000 : UPSAMPLE_HORIZONTAL_DEFAULT
    #    *            default for horizontal upsampling
    #  * 0x00000000 : DOWNSAMPLE_VERTICAL_DEFAULT
    #    *            default for vertical downsampling
    #  * 0x00000000 : DOWNSAMPLE_HORIZONTAL_DEFAULT
    #    *            default for horizontal downsampling
    #  * 0x00000001 : UPSAMPLE_VERTICAL_NEAREST
    #    *            nearest neighbor for vertical upsampling
    #  * 0x00000100 : UPSAMPLE_HORIZONTAL_NEAREST
    #    *            nearest neighbor for horizontal upsampling
    #  * 0x00010000 : DOWNSAMPLE_VERTICAL_NEAREST
    #    *            nearest neighbor for vertical downsampling
    #  * 0x01000000 : DOWNSAMPLE_HORIZONTAL_NEAREST
    #    *            nearest neighbor for horizontal downsampling
    #  * 0x00000002 : UPSAMPLE_VERTICAL_LINEAR
    #    *            linear for vertical upsampling
    #  * 0x00000200 : UPSAMPLE_HORIZONTAL_LINEAR
    #    *            linear for horizontal upsampling
    #  * 0x00020000 : DOWNSAMPLE_VERTICAL_LINEAR
    #    *            linear for vertical downsampling
    #  * 0x02000000 : DOWNSAMPLE_HORIZONTAL_LINEAR
    #    *            linear for horizontal downsampling
    #  * 0x00000003 : UPSAMPLE_VERTICAL_LANCZOS
    #    *            lanczos for vertical upsampling
    #  * 0x00000300 : UPSAMPLE_HORIZONTAL_LANCZOS
    #    *            lanczos for horizontal upsampling
    #  * 0x00030000 : DOWNSAMPLE_VERTICAL_LANCZOS
    #    *            lanczos for vertical downsampling
    #  * 0x03000000 : DOWNSAMPLE_HORIZONTAL_LANCZOS
    #    *            lanczos for horizontal downsampling
    def setresamplemethod(*)
      super
    end

    # Inquire the resample method used for gr.drawimage().
    def inqresamplemethod
      inquiry_uint do |resample_method|
        super(resample_method)
      end
    end

    # Draw paths using the given vertices and path codes.
    # @param x [Array, NArray] A list containing the X coordinates
    # @param y [Array, NArray] A list containing the Y coordinates
    # @param codes [String] A list containing the path codes
    #  The following path codes are recognized:
    #  * M, m
    #    * moveto                      x, y
    #  * L, l
    #    * lineto                      x, y
    #  * Q, q
    #    * quadratic Bézier            x1, x2  y1, y2
    #  * C, c
    #    * cubic Bézier                x1, x2, x3  y1, y2, y3
    #  * A, a
    #    * arc                         rx, a1, reserved  ry, a2, reserved
    #  * Z
    #    * close path                  -
    #  * s
    #    * stroke                      -
    #  * s
    #    * close path and stroke       -
    #  * f
    #    * close path and fill         -
    #  * F
    #    * close path, fill and stroke -
    # See https://gr-framework.org/python-gr.html#gr.path for more details.
    def path(x, y, codes)
      n = equal_length(x, y)
      super(n, x, y, codes)
    end

    # Define the border width of subsequent path output primitives.
    # @param width [Numeric] The border width scale factor
    def setborderwidth(*)
      super
    end

    def inqborderwidth
      inquiry_double { |pt| super(pt) }
    end

    # Define the color of subsequent path output primitives.
    # @param color [Integer] The border color index (COLOR < 1256)
    def setbordercolorind(*)
      super
    end

    def inqbordercolorind
      inquiry_int { |pt| super(pt) }
    end

    # Set the projection type with this flag.
    # @param flag [Integer] projection type
    #  The available options are:
    #  * 0 : GR_PROJECTION_DEFAULT
    #    * default
    #  * 1 : GR_PROJECTION_ORTHOGRAPHIC
    #    * orthographic
    #  * 2 : GR_PROJECTION_PERSPECTIVE
    #    * perspective
    def setprojectiontype(*)
      super
    end

    # Return the projection type.
    def inqprojectiontype
      inquiry_int { |pt| super(pt) }
    end

    # Method to set the camera position, the upward facing direction and the
    # focus point of the shown volume.
    # @param camera_pos_x [Numeric] x component of the cameraposition in world coordinates
    # @param camera_pos_y [Numeric] y component of the cameraposition in world coordinates
    # @param camera_pos_z [Numeric] z component of the cameraposition in world coordinates
    # @param up_x [Numeric] x component of the up vector
    # @param up_y [Numeric] y component of the up vector
    # @param up_z [Numeric] z component of the up vector
    # @param focus_point_x [Numeric] x component of focus-point inside volume
    # @param focus_point_y [Numeric] y component of focus-point inside volume
    # @param focus_point_z [Numeric] z component of focus-point inside volume
    def settransformationparameters(*)
      super
    end

    # Return the camera position, up vector and focus point.
    def inqtransformationparameters
      inquiry([:double] * 9) do |*pts|
        super(*pts)
      end
    end

    # Set the far and near clipping plane for perspective projection and the
    # vertical field ov view.
    # Switches projection type to perspective.
    # @param near_plane [Numeric] distance to near clipping plane
    # @param far_plane [Numeric] distance to far clipping plane
    # @param fov [Numeric] vertical field of view, input must be between 0 and 180 degrees
    def setperspectiveprojection(*)
      super
    end

    # Return the parameters for the perspective projection.
    def inqperspectiveprojection
      inquiry %i[double double double] do |*pts|
        super(*pts)
      end
    end

    # Set parameters for orthographic transformation.
    # Switches projection type to orthographic.
    # @param left [Numeric] xmin of the volume in worldcoordinates
    # @param right [Numeric] xmax of volume in worldcoordinates
    # @param bottom [Numeric] ymin of volume in worldcoordinates
    # @param top [Numeric] ymax of volume in worldcoordinates
    # @param near_plane [Numeric] distance to near clipping plane
    # @param far_plane [Numeric] distance to far clipping plane
    def setorthographicprojection(*)
      super
    end

    # Return the camera position, up vector and focus point.
    def inqorthographicprojection
      inquiry([:double] * 6) do |*pts|
        super(*pts)
      end
    end

    # Interface for interaction with the rotation of the model.
    # For this a virtual Arcball is used.
    # @param start_mouse_pos_x [Numeric] x component of the start mouse position
    # @param start_mouse_pos_y [Numeric] y component of the start mouse position
    # @param end_mouse_pos_x [Numeric] x component of the end mouse position
    # @param end_mouse_pos_y [Numeric] y component of the end mouse position
    def camerainteraction(*)
      super
    end

    # Set the three dimensional window. Only used for perspective and orthographic projection.
    # @param xmin [Numeric] min x-value
    # @param xmax [Numeric] max x-value
    # @param ymin [Numeric] min y-value
    # @param ymax [Numeric] max y-value
    # @param zmin [Numeric] min z-value
    # @param zmax [Numeric] max z-value
    def setwindow3d(*)
      super
    end

    # Return the three dimensional window.
    def inqwindow3d
      inquiry([:double] * 6) do |*pts|
        super(*pts)
      end
    end

    # Set the scale factor for each axis. A one means no scale.
    # All factor have to be != 0.
    # @param x_axis_scale [Numeric] factor for scaling the x-axis
    # @param y_axis_scale [Numeric] factor for scaling the y-axis
    # @param z_axis_scale [Numeric] factor for scaling the z-axis
    def setscalefactors3d(*)
      super
    end

    # Returns the scale factors for each axis.
    def inqscalefactors3d
      inquiry %i[double double double] do |*opts|
        super(*opts)
      end
    end

    # This is an interface for REPL based languages to enable an easier way to
    # rotate around an object.
    # The center of the 3d window is used as the focus point and the camera is
    # positioned relative to it, using spherical coordinates. This function can
    # therefore also be used if the user prefers spherical coordinates to setting
    # the direct camera position, but with reduced functionality in comparison
    # to gr.settransformationparameters, gr.setperspectiveprojection and
    # gr.setorthographicprojection.
    # @param phi [Numeric] phi angle of the spherical coordinates
    # @param theta [Numeric] theta angle of the spherical coordinates
    # @param fov [Numeric] vertical field of view (0 or NaN for orthographic projection)
    # @param radius [Numeric] distance between the camera and the focus point
    #   (0 or NaN for the radius of the object's smallest bounding sphere)
    def transformationinterfaceforrepl(*)
      super
    end

    def setspace3d(*)
      super
    end

    def text3d(*)
      super
    end

    def inqtext3d(x, y, z, string, axis)
      inquiry [{double: 16}, {double: 16}] do |tbx, tby|
        super(x, y, z, string, axis, tbx, tby)
      end
    end

    def settextencoding(*)
      super
    end

    def inqtextencoding
      inquiry_int do |encoding|
        super(encoding)
      end
    end
  end

  ASF_BUNDLED    = 0
  ASF_INDIVIDUAL = 1

  NOCLIP = 0
  CLIP   = 1

  COORDINATES_WC  = 0
  COORDINATES_NDC = 1

  INTSTYLE_HOLLOW  = 0
  INTSTYLE_SOLID   = 1
  INTSTYLE_PATTERN = 2
  INTSTYLE_HATCH   = 3

  TEXT_HALIGN_NORMAL = 0
  TEXT_HALIGN_LEFT   = 1
  TEXT_HALIGN_CENTER = 2
  TEXT_HALIGN_RIGHT  = 3
  TEXT_VALIGN_NORMAL = 0
  TEXT_VALIGN_TOP    = 1
  TEXT_VALIGN_CAP    = 2
  TEXT_VALIGN_HALF   = 3
  TEXT_VALIGN_BASE   = 4
  TEXT_VALIGN_BOTTOM = 5

  TEXT_PATH_RIGHT = 0
  TEXT_PATH_LEFT  = 1
  TEXT_PATH_UP    = 2
  TEXT_PATH_DOWN  = 3

  TEXT_PRECISION_STRING = 0
  TEXT_PRECISION_CHAR   = 1
  TEXT_PRECISION_STROKE = 2

  LINETYPE_SOLID           =  1
  LINETYPE_DASHED          =  2
  LINETYPE_DOTTED          =  3
  LINETYPE_DASHED_DOTTED   =  4
  LINETYPE_DASH_2_DOT      = -1
  LINETYPE_DASH_3_DOT      = -2
  LINETYPE_LONG_DASH       = -3
  LINETYPE_LONG_SHORT_DASH = -4
  LINETYPE_SPACED_DASH     = -5
  LINETYPE_SPACED_DOT      = -6
  LINETYPE_DOUBLE_DOT      = -7
  LINETYPE_TRIPLE_DOT      = -8

  MARKERTYPE_DOT             =   1
  MARKERTYPE_PLUS            =   2
  MARKERTYPE_ASTERISK        =   3
  MARKERTYPE_CIRCLE          =   4
  MARKERTYPE_DIAGONAL_CROSS  =   5
  MARKERTYPE_SOLID_CIRCLE    =  -1
  MARKERTYPE_TRIANGLE_UP     =  -2
  MARKERTYPE_SOLID_TRI_UP    =  -3
  MARKERTYPE_TRIANGLE_DOWN   =  -4
  MARKERTYPE_SOLID_TRI_DOWN  =  -5
  MARKERTYPE_SQUARE          =  -6
  MARKERTYPE_SOLID_SQUARE    =  -7
  MARKERTYPE_BOWTIE          =  -8
  MARKERTYPE_SOLID_BOWTIE    =  -9
  MARKERTYPE_HOURGLASS       = -10
  MARKERTYPE_SOLID_HGLASS    = -11
  MARKERTYPE_DIAMOND         = -12
  MARKERTYPE_SOLID_DIAMOND   = -13
  MARKERTYPE_STAR            = -14
  MARKERTYPE_SOLID_STAR      = -15
  MARKERTYPE_TRI_UP_DOWN     = -16
  MARKERTYPE_SOLID_TRI_RIGHT = -17
  MARKERTYPE_SOLID_TRI_LEFT  = -18
  MARKERTYPE_HOLLOW_PLUS     = -19
  MARKERTYPE_SOLID_PLUS      = -20
  MARKERTYPE_PENTAGON        = -21
  MARKERTYPE_HEXAGON         = -22
  MARKERTYPE_HEPTAGON        = -23
  MARKERTYPE_OCTAGON         = -24
  MARKERTYPE_STAR_4          = -25
  MARKERTYPE_STAR_5          = -26
  MARKERTYPE_STAR_6          = -27
  MARKERTYPE_STAR_7          = -28
  MARKERTYPE_STAR_8          = -29
  MARKERTYPE_VLINE           = -30
  MARKERTYPE_HLINE           = -31
  MARKERTYPE_OMARK           = -32

  OPTION_X_LOG  =  1
  OPTION_Y_LOG  =  2
  OPTION_Z_LOG  =  4
  OPTION_FLIP_X =  8
  OPTION_FLIP_Y = 16
  OPTION_FLIP_Z = 32

  OPTION_LINES         = 0
  OPTION_MESH          = 1
  OPTION_FILLED_MESH   = 2
  OPTION_Z_SHADED_MESH = 3
  OPTION_COLORED_MESH  = 4
  OPTION_CELL_ARRAY    = 5
  OPTION_SHADED_MESH   = 6

  MODEL_RGB = 0
  MODEL_HSV = 1

  COLORMAP_UNIFORM      =  0
  COLORMAP_TEMPERATURE  =  1
  COLORMAP_GRAYSCALE    =  2
  COLORMAP_GLOWING      =  3
  COLORMAP_RAINBOWLIKE  =  4
  COLORMAP_GEOLOGIC     =  5
  COLORMAP_GREENSCALE   =  6
  COLORMAP_CYANSCALE    =  7
  COLORMAP_BLUESCALE    =  8
  COLORMAP_MAGENTASCALE =  9
  COLORMAP_REDSCALE     = 10
  COLORMAP_FLAME        = 11
  COLORMAP_BROWNSCALE   = 12
  COLORMAP_PILATUS      = 13
  COLORMAP_AUTUMN       = 14
  COLORMAP_BONE         = 15
  COLORMAP_COOL         = 16
  COLORMAP_COPPER       = 17
  COLORMAP_GRAY         = 18
  COLORMAP_HOT          = 19
  COLORMAP_HSV          = 20
  COLORMAP_JET          = 21
  COLORMAP_PINK         = 22
  COLORMAP_SPECTRAL     = 23
  COLORMAP_SPRING       = 24
  COLORMAP_SUMMER       = 25
  COLORMAP_WINTER       = 26
  COLORMAP_GIST_EARTH   = 27
  COLORMAP_GIST_HEAT    = 28
  COLORMAP_GIST_NCAR    = 29
  COLORMAP_GIST_RAINBOW = 30
  COLORMAP_GIST_STERN   = 31
  COLORMAP_AFMHOT       = 32
  COLORMAP_BRG          = 33
  COLORMAP_BWR          = 34
  COLORMAP_COOLWARM     = 35
  COLORMAP_CMRMAP       = 36
  COLORMAP_CUBEHELIX    = 37
  COLORMAP_GNUPLOT      = 38
  COLORMAP_GNUPLOT2     = 39
  COLORMAP_OCEAN        = 40
  COLORMAP_RAINBOW      = 41
  COLORMAP_SEISMIC      = 42
  COLORMAP_TERRAIN      = 43
  COLORMAP_VIRIDIS      = 44
  COLORMAP_INFERNO      = 45
  COLORMAP_PLASMA       = 46
  COLORMAP_MAGMA        = 47

  FONT_TIMES_ROMAN                 = 101
  FONT_TIMES_ITALIC                = 102
  FONT_TIMES_BOLD                  = 103
  FONT_TIMES_BOLDITALIC            = 104
  FONT_HELVETICA                   = 105
  FONT_HELVETICA_OBLIQUE           = 106
  FONT_HELVETICA_BOLD              = 107
  FONT_HELVETICA_BOLDOBLIQUE       = 108
  FONT_COURIER                     = 109
  FONT_COURIER_OBLIQUE             = 110
  FONT_COURIER_BOLD                = 111
  FONT_COURIER_BOLDOBLIQUE         = 112
  FONT_SYMBOL                      = 113
  FONT_BOOKMAN_LIGHT               = 114
  FONT_BOOKMAN_LIGHTITALIC         = 115
  FONT_BOOKMAN_DEMI                = 116
  FONT_BOOKMAN_DEMIITALIC          = 117
  FONT_NEWCENTURYSCHLBK_ROMAN      = 118
  FONT_NEWCENTURYSCHLBK_ITALIC     = 119
  FONT_NEWCENTURYSCHLBK_BOLD       = 120
  FONT_NEWCENTURYSCHLBK_BOLDITALIC = 121
  FONT_AVANTGARDE_BOOK             = 122
  FONT_AVANTGARDE_BOOKOBLIQUE      = 123
  FONT_AVANTGARDE_DEMI             = 124
  FONT_AVANTGARDE_DEMIOBLIQUE      = 125
  FONT_PALATINO_ROMAN              = 126
  FONT_PALATINO_ITALIC             = 127
  FONT_PALATINO_BOLD               = 128
  FONT_PALATINO_BOLDITALIC         = 129
  FONT_ZAPFCHANCERY_MEDIUMITALIC   = 130
  FONT_ZAPFDINGBATS                = 131

  # GR.beginprint types
  PRINT_PS   = 'ps'
  PRINT_EPS  = 'eps'
  PRINT_PDF  = 'pdf'
  PRINT_PGF  = 'pgf'
  PRINT_BMP  = 'bmp'
  PRINT_JPEG = 'jpeg'
  PRINT_JPG  = 'jpg'
  PRINT_PNG  = 'png'
  PRINT_TIFF = 'tiff'
  PRINT_TIF  = 'tif'
  PRINT_FIG  = 'fig'
  PRINT_SVG  = 'svg'
  PRINT_WMF  = 'wmf'

  PATH_STOP      = 0x00
  PATH_MOVETO    = 0x01
  PATH_LINETO    = 0x02
  PATH_CURVE3    = 0x03
  PATH_CURVE4    = 0x04
  PATH_CLOSEPOLY = 0x4f

  MPL_SUPPRESS_CLEAR  = 1
  MPL_POSTPONE_UPDATE = 2

  XFORM_BOOLEAN   = 0
  XFORM_LINEAR    = 1
  XFORM_LOG       = 2
  XFORM_LOGLOG    = 3
  XFORM_CUBIC     = 4
  XFORM_EQUALIZED = 5

  ENCODING_LATIN1 = 300
  ENCODING_UTF8 = 301

  UPSAMPLE_VERTICAL_DEFAULT     = 0x00000000
  UPSAMPLE_HORIZONTAL_DEFAULT   = 0x00000000
  DOWNSAMPLE_VERTICAL_DEFAULT   = 0x00000000
  DOWNSAMPLE_HORIZONTAL_DEFAULT = 0x00000000
  UPSAMPLE_VERTICAL_NEAREST     = 0x00000001
  UPSAMPLE_HORIZONTAL_NEAREST   = 0x00000100
  DOWNSAMPLE_VERTICAL_NEAREST   = 0x00010000
  DOWNSAMPLE_HORIZONTAL_NEAREST = 0x01000000
  UPSAMPLE_VERTICAL_LINEAR      = 0x00000002
  UPSAMPLE_HORIZONTAL_LINEAR    = 0x00000200
  DOWNSAMPLE_VERTICAL_LINEAR    = 0x00020000
  DOWNSAMPLE_HORIZONTAL_LINEAR  = 0x02000000
  UPSAMPLE_VERTICAL_LANCZOS     = 0x00000003
  UPSAMPLE_HORIZONTAL_LANCZOS   = 0x00000300
  DOWNSAMPLE_VERTICAL_LANCZOS   = 0x00030000
  DOWNSAMPLE_HORIZONTAL_LANCZOS = 0x03000000

  RESAMPLE_DEFAULT =
    (UPSAMPLE_VERTICAL_DEFAULT | UPSAMPLE_HORIZONTAL_DEFAULT |
     DOWNSAMPLE_VERTICAL_DEFAULT | DOWNSAMPLE_HORIZONTAL_DEFAULT)
  RESAMPLE_NEAREST =
    (UPSAMPLE_VERTICAL_NEAREST | UPSAMPLE_HORIZONTAL_NEAREST |
     DOWNSAMPLE_VERTICAL_NEAREST | DOWNSAMPLE_HORIZONTAL_NEAREST)
  RESAMPLE_LINEAR =
    (UPSAMPLE_VERTICAL_LINEAR | UPSAMPLE_HORIZONTAL_LINEAR |
     DOWNSAMPLE_VERTICAL_LINEAR | DOWNSAMPLE_HORIZONTAL_LINEAR)
  RESAMPLE_LANCZOS =
    (UPSAMPLE_VERTICAL_LANCZOS | UPSAMPLE_HORIZONTAL_LANCZOS |
     DOWNSAMPLE_VERTICAL_LANCZOS | DOWNSAMPLE_HORIZONTAL_LANCZOS)

  PROJECTION_DEFAULT = 0
  PROJECTION_ORTHOGRAPHIC = 1
  PROJECTION_PERSPECTIVE = 2
end
