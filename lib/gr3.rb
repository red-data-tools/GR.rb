# frozen_string_literal: true

require 'ffi'

module GR3
  class Error < StandardError; end

  class << self
    attr_reader :ffi_lib
  end

  # Platforms |  path
  # Windows   |  bin/libgr3.dll
  # MacOSX    |  lib/libGR3.so (NOT .dylib)
  # Ubuntu    |  lib/libGR3.so
  raise Error, 'Please set env variable GRDIR' unless ENV['GRDIR']

  ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
  @ffi_lib = case RbConfig::CONFIG['host_os']
             when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
               File.expand_path('bin/libgr3.dll', ENV['GRDIR'])
                   .gsub('/', '\\') # windows backslash
             else
               File.expand_path('lib/libGR3.so', ENV['GRDIR'])
             end

  require_relative 'gr_commons'
  require_relative 'gr3/ffi'
  require_relative 'gr3/gr3base'

  extend GRCommons::JupyterSupport
  extend GR3Base

  # `float` is the default type in GR3
  # A Ruby array or NArray passed to GR3 method is automatically converted to
  # a FFI::MemoryPointer in the GR3Base class.

  module CheckError
    FFI.ffi_methods.each do |method|
      method_name = method.to_s.sub(/^gr3_/, '')
      next if method_name == 'geterror'

      define_method(method_name) do |*args|
        values = super(*args)
        GR3Base.check_error
        values
      end
    end
  end
  extend CheckError

  class << self
    # @!method gr3_init
    # @!method free
    # @!method terminate
    # @!method geterror
    # @!method getrenderpathstring
    # @!method geterrorstring
    # @!method clear
    # @!method usecurrentframebuffer
    # @!method useframebuffer
    # @!method setquality

    # getimage
    def getimage(width, height, use_alpha = true)
      bpp = use_alpha ? 4 : 3
      inquiry(uint8: width * height * bpp) do |bitmap|
        super(width, height, (use_alpha ? 1 : 0), bitmap)
      end
    end

    # @!method export
    # @!method drawimage

    # createmesh_nocopy
    def createmesh_nocopy(_n, vertices, normals, colors)
      inquiry_int do |mesh|
        super(mesh, vertices, normals, colors)
      end
    end

    # createmesh
    def createmesh(_n, vertices, normals, colors)
      inquiry_int do |mesh|
        super(mesh, vertices, normals, colors)
      end
    end

    # createindexedmesh_nocopy
    def createindexedmesh_nocopy(num_vertices, vertices, normals, colors, num_indices, indices)
      inquiry_int do |mesh|
        super(mesh, num_vertices, vertices, normals, colors, num_indices, indices)
      end
    end

    # createindexedmesh
    def createindexedmesh(num_vertices, vertices, normals, colors, num_indices, indices)
      inquiry_int do |mesh|
        super(mesh, num_vertices, vertices, normals, colors, num_indices, indices)
      end
    end

    # @!method drawmesh
    # @!method deletemesh
    # @!method cameralookat
    # @!method setcameraprojectionparameters
    # @!method getcameraprojectionparameters
    # @!method setlightdirection
    # @!method setbackgroundcolor
    # @!method createheightmapmesh
    # @!method drawheightmap
    # @!method drawconemesh
    # @!method drawcylindermesh
    # @!method drawspheremesh
    # @!method drawcubemesh
    # @!method setobjectid
    # @!method selectid
    # @!method getviewmatrix
    # @!method setviewmatrix
    # @!method getprojectiontype
    # @!method setprojectiontype

    # createsurfacemesh
    def createsurfacemesh(nx, ny, px, py, pz, option = 0)
      inquiry_int do |mesh|
        super(mesh, nx, ny, px, py, pz, option)
      end
    end

    # @!method drawmesh_grlike
    # @!method drawsurface

    # surface
    def surface(px, py, pz, _option)
      nx = length(px)
      ny = length(py)
      # TODO: Check out_of_bounds
      super(nx, ny, px, py, pz, ption)
    end

    # drawtubemesh
    def drawtubemesh(n, points, colors, radii, num_steps = 10, num_segments = 20)
      super(n, points, colors, radii, num_steps, num_segments)
    end

    # createtubemesh
    def createtubemesh(n, points, colors, radii, num_steps = 10, num_segments = 20)
      inquiry_uint do |mesh| # mesh should be Int?
        super(mesh, n, points, colors, radii, num_steps, num_segments)
      end
    end

    # drawspins
    def drawspins(positions, directions, colors = nil,
                  cone_radius = 0.4, cylinder_radius = 0.2,
                  cone_height = 1.0, cylinder_height = 1.0)
      n = length(positions)
      colors = [1] * n * 3 if colors.nil?
      super(n, positions, directions, colors, cone_radius, cylinder_radius, cone_height, cylinder_height)
    end

    # drawmolecule
    def drawmolecule(positions, colors = nil, radii = nil, spins = nil,
                     bond_radius = nil, bond_color = nil, bond_delta = nil,
                     set_camera = true, rotation = 0, tilt = 0)
      # Should `drawmolecule` take keyword arguments?
      # Setting default values later for now.

      # Should it be RubyArray instead of Narray?
      # If NArray is required, add no NArray error.
      positions = Numo::SFloat.cast(positions)
      n = positions.shape[0]

      colors = if colors.nil?
                 Numo::SFloat.ones(n, 3)
               else
                 Numo::SFloat.cast(colors).reshape(n, 3)
               end

      radii = if radii.nil?
                Numo::SFloat.new(n).fill(0.3)
              else
                Numo::SFloat.cast(radii).reshape(n)
              end

      bond_color ||= [0.8, 0.8, 0.8]
      bond_color = Numo::SFloat.cast(bond_color).reshape(3)
      bond_delta ||= 1.0
      bond_radius ||= 0.1

      if set_camera
        deg2rad = ->(degree) { degree * Math::PI / 180 } # room for improvement
        cx, cy, cz = *positions.mean(axis: 0)
        dx, dy, dz = *positions.ptp(axis: 0)
        d = [dx, dy].max / 2 / 0.4142 + 3
        r = dz / 2 + d
        rx = r * Math.sin(deg2rad.call(tilt)) * Math.sin(deg2rad.call(rotation))
        ry = r * Math.sin(deg2rad.call(tilt)) * Math.cos(deg2rad.call(rotation))
        rz = r * Math.cos(deg2rad.call(tilt))
        ux = Math.sin(deg2rad.call(tilt + 90)) * Math.sin(deg2rad.call(rotation))
        uy = Math.sin(deg2rad.call(tilt + 90)) * Math.cos(deg2rad.call(rotation))
        uz = Math.cos(deg2rad.call(tilt + 90))
        cameralookat(cx + rx, cy + ry, cz + rz, cx, cy, cz, ux, uy, uz)
        setcameraprojectionparameters(45, d - radii.max - 3, d + dz + radii.max + 3)
      end

      super(n, positions, colors, radii, bond_radius, bond_color, bond_delta)

      if spins
        spins = Numo::SFloat.cast(spins).reshape(n, 3)
        drawspins(positions, spins, colors)
      end
    end
  end

  # Constants - imported from GR.jl

  IA_END_OF_LIST = 0
  IA_FRAMEBUFFER_WIDTH = 1
  IA_FRAMEBUFFER_HEIGHT = 2

  ERROR_NONE = 0
  ERROR_INVALID_VALUE = 1
  ERROR_INVALID_ATTRIBUTE = 2
  ERROR_INIT_FAILED = 3
  ERROR_OPENGL_ERR = 4
  ERROR_OUT_OF_MEM = 5
  ERROR_NOT_INITIALIZED = 6
  ERROR_CAMERA_NOT_INITIALIZED = 7
  ERROR_UNKNOWN_FILE_EXTENSION = 8
  ERROR_CANNOT_OPEN_FILE = 9
  ERROR_EXPORT = 10

  QUALITY_OPENGL_NO_SSAA  = 0
  QUALITY_OPENGL_2X_SSAA  = 2
  QUALITY_OPENGL_4X_SSAA  = 4
  QUALITY_OPENGL_8X_SSAA  = 8
  QUALITY_OPENGL_16X_SSAA = 16
  QUALITY_POVRAY_NO_SSAA  = 0 + 1
  QUALITY_POVRAY_2X_SSAA  = 2 + 1
  QUALITY_POVRAY_4X_SSAA  = 4 + 1
  QUALITY_POVRAY_8X_SSAA  = 8 + 1
  QUALITY_POVRAY_16X_SSAA = 16 + 1

  DRAWABLE_OPENGL = 1
  DRAWABLE_GKS = 2

  SURFACE_DEFAULT     =  0
  SURFACE_NORMALS     =  1
  SURFACE_FLAT        =  2
  SURFACE_GRTRANSFORM =  4
  SURFACE_GRCOLOR     =  8
  SURFACE_GRZSHADED   = 16

  ATOM_COLORS = [[0, 0, 0],
                 [255, 255, 255], [217, 255, 255], [204, 128, 255],
                 [194, 255, 0], [255, 181, 181], [144, 144, 144],
                 [48, 80, 248], [255, 13, 13], [144, 224, 80],
                 [179, 227, 245], [171, 92, 242], [138, 255, 0],
                 [191, 166, 166], [240, 200, 160], [255, 128, 0],
                 [255, 255, 48], [31, 240, 31], [128, 209, 227],
                 [143, 64, 212], [61, 225, 0], [230, 230, 230],
                 [191, 194, 199], [166, 166, 171], [138, 153, 199],
                 [156, 122, 199], [224, 102, 51], [240, 144, 160],
                 [80, 208, 80], [200, 128, 51], [125, 128, 176],
                 [194, 143, 143], [102, 143, 143], [189, 128, 227],
                 [225, 161, 0], [166, 41, 41], [92, 184, 209],
                 [112, 46, 176], [0, 255, 0], [148, 255, 255],
                 [148, 224, 224], [115, 194, 201], [84, 181, 181],
                 [59, 158, 158], [36, 143, 143], [10, 125, 140],
                 [0, 105, 133], [192, 192, 192], [255, 217, 143],
                 [166, 117, 115], [102, 128, 128], [158, 99, 181],
                 [212, 122, 0], [148, 0, 148], [66, 158, 176],
                 [87, 23, 143], [0, 201, 0], [112, 212, 255],
                 [255, 255, 199], [217, 225, 199], [199, 225, 199],
                 [163, 225, 199], [143, 225, 199], [97, 225, 199],
                 [69, 225, 199], [48, 225, 199], [31, 225, 199],
                 [0, 225, 156], [0, 230, 117], [0, 212, 82],
                 [0, 191, 56], [0, 171, 36], [77, 194, 255],
                 [77, 166, 255], [33, 148, 214], [38, 125, 171],
                 [38, 102, 150], [23, 84, 135], [208, 208, 224],
                 [255, 209, 35], [184, 184, 208], [166, 84, 77],
                 [87, 89, 97], [158, 79, 181], [171, 92, 0],
                 [117, 79, 69], [66, 130, 150], [66, 0, 102],
                 [0, 125, 0], [112, 171, 250], [0, 186, 255],
                 [0, 161, 255], [0, 143, 255], [0, 128, 255],
                 [0, 107, 255], [84, 92, 242], [120, 92, 227],
                 [138, 79, 227], [161, 54, 212], [179, 31, 212],
                 [179, 31, 186], [179, 13, 166], [189, 13, 135],
                 [199, 0, 102], [204, 0, 89], [209, 0, 79],
                 [217, 0, 69], [224, 0, 56], [230, 0, 46],
                 [235, 0, 38], [255, 0, 255], [255, 0, 255],
                 [255, 0, 255], [255, 0, 255], [255, 0, 255],
                 [255, 0, 255], [255, 0, 255], [255, 0, 255],
                 [255, 0, 255]].map! { |i| i.map! { |j| j / 255.0 } }

  ATOM_NUMBERS = { H: 1, HE: 2, LI: 3, BE: 4, B: 5, C: 6, N: 7, # should keys be string?
                   O: 8, F: 9, NE: 10, NA: 11, MG: 12, AL: 13,
                   SI: 14, P: 15, S: 16, CL: 17, AR: 18, K: 19,
                   CA: 20, SC: 21, TI: 22, V: 23, CR: 24, MN: 25,
                   FE: 26, CO: 27, NI: 28, CU: 29, ZN: 30, GA: 31,
                   GE: 32, AS: 33, SE: 34, BR: 35, KR: 36, RB: 37,
                   SR: 38, Y: 39, ZR: 40, NB: 41, MO: 42, TC: 43,
                   RU: 44, RH: 45, PD: 46, AG: 47, CD: 48, IN: 49,
                   SN: 50, SB: 51, TE: 52, I: 53, XE: 54, CS: 55,
                   BA: 56, LA: 57, CE: 58, PR: 59, ND: 60, PM: 61,
                   SM: 62, EU: 63, GD: 64, TB: 65, DY: 66, HO: 67,
                   ER: 68, TM: 69, YB: 70, LU: 71, HF: 72, TA: 73,
                   W: 74, RE: 75, OS: 76, IR: 77, PT: 78, AU: 79,
                   HG: 80, TL: 81, PB: 82, BI: 83, PO: 84, AT: 85,
                   RN: 86, FR: 87, RA: 88, AC: 89, TH: 90, PA: 91,
                   U: 92, NP: 93, PU: 94, AM: 95, CM: 96, BK: 97,
                   CF: 98, ES: 99, FM: 100, MD: 101, NO: 102,
                   LR: 103, RF: 104, DB: 105, SG: 106, BH: 107,
                   HS: 108, MT: 109, DS: 110, RG: 111, CN: 112,
                   UUB: 112, UUT: 113, UUQ: 114, UUP: 115, UUH: 116,
                   UUS: 117, UUO: 118 }.freeze

  ATOM_VALENCE_RADII = [0, # Avoid atomic number to index conversion
                        230, 930, 680, 350, 830, 680, 680, 680, 640,
                        1120, 970, 1100, 1350, 1200, 750, 1020, 990,
                        1570, 1330, 990, 1440, 1470, 1330, 1350, 1350,
                        1340, 1330, 1500, 1520, 1450, 1220, 1170, 1210,
                        1220, 1210, 1910, 1470, 1120, 1780, 1560, 1480,
                        1470, 1350, 1400, 1450, 1500, 1590, 1690, 1630,
                        1460, 1460, 1470, 1400, 1980, 1670, 1340, 1870,
                        1830, 1820, 1810, 1800, 1800, 1990, 1790, 1760,
                        1750, 1740, 1730, 1720, 1940, 1720, 1570, 1430,
                        1370, 1350, 1370, 1320, 1500, 1500, 1700, 1550,
                        1540, 1540, 1680, 1700, 2400, 2000, 1900, 1880,
                        1790, 1610, 1580, 1550, 1530, 1510, 1500, 1500,
                        1500, 1500, 1500, 1500, 1500, 1500, 1600, 1600,
                        1600, 1600, 1600, 1600, 1600, 1600, 1600, 1600,
                        1600, 1600, 1600, 1600, 1600, 1600].map { |i| i / 1000.0 }

  ATOM_RADII = ATOM_VALENCE_RADII.map { |i| i * 0.4 }
end
