# frozen_string_literal: true

# OverView of GR.rb
#
#  +--------------------+  +--------------------+
#  | GR module          |  | GR3 module         |
#  | +----------------+ |  | +----------------+ |
#  | | GR::FFI        | |  | | GR3::FFI       | |
#  | | +   libGR.so   | |  | | +    libGR3.so | |
#  | +----------------+ |  | +----------------+ |
#  |   | define_method  |  |   | define_method  |
#  | +----------------+ |  | +----------------+ |
#  | | | GR::GRBase   | |  | | | GR3::GR3Base | |
#  | | v  (Pri^ate)   | |  | | v  (Pri^ate)   | |
#  | +++--------------+ |  | +++--------------+ |
#  |  | Extend          |  |  | Extend          |
#  |  v                 |  |  v       +-------+ |
#  |      +-----------+ |  |          | Check | |
#  |      | GR::Plot  | |  |       <--+ Error | |
#  |      +-----------+ |  |          +-------+ |
#  +--------------------+  +----------+---------+
#            ^                        ^
#            |  +------------------+  |
#     Extend |  | GRCommons module |  | Extend
#            |  | +--------------+ |  |
#            |  | |    Fiddley   | |  |
#            |  | +--------------+ |  |
#            |  | +--------------+ |  |
#            +----+ CommonUtils  +----+
#            |  | +--------------+ |  |
#            |  | +--------------+ |  |
#            +----+    Version   +----+
#            |  | +--------------+ |
#            |  | +--------------+ |
#            +----+JupyterSupport| |
#               | +--------------+ |
#               +------------------+
#
# (You can edit the above AA diagram with http://asciiflow.com/)
#
# Fiddley is Ruby-FFI compatible API layer for Fiddle.
#
# Why not GR::GR3?
# * kojix2 did not want to force gr3 to be loaded when gr is loaded.
# * kojix2 did not want to write `GR3 = GR::GR3` or something.
# * This is a opinion of kojix2 and may be changed by future maintainers.
#
# GR3 uses Numo::Narrray.
# * It is difficult to write GR3 modules with only Ruby arrays.
# * Numo::Narray has better performance and is easier to read.
# * Numo::Narray does not work with JRuby.
#   * https://github.com/ruby-numo/numo-narray/issues/147
#
# This is a procedural interface to the GR3 in GR plotting library,
# https://github.com/sciapp/gr
module GR3
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  raise Error, 'Please set env variable GRDIR' unless ENV['GRDIR']

  # Platforms |  path
  # Windows   |  bin/libGR3.dll
  # MacOSX    |  lib/libGR3.so (NOT .dylib)
  # Ubuntu    |  lib/libGR3.so
  if Object.const_defined?(:RubyInstaller)
    self.ffi_lib = File.expand_path('bin/libGR3.dll', ENV['GRDIR'])
    RubyInstaller::Runtime.add_dll_directory(File.dirname(ffi_lib))
  else
    self.ffi_lib = File.expand_path('lib/libGR3.so', ENV['GRDIR'])
  end

  # change the default encoding to UTF-8.
  ENV['GKS_ENCODING'] ||= 'utf8'

  require_relative 'gr_commons/gr_commons'
  require_relative 'gr3/version'
  require_relative 'gr3/ffi'
  require_relative 'gr3/gr3base'

  # `inquiry` methods etc. are defined here.
  extend GRCommons::GRCommonUtils

  # `float` is the default type in GR3.
  # A Ruby array or NArray passed to GR3 method is automatically converted to
  # a Fiddley::MemoryPointer in the GR3Base class.
  extend GR3Base

  # This module is for adding error checking to all methods in GR3.
  module CheckError
    def geterror
      line = GRCommons::Fiddley::MemoryPointer.new(:int)
      file = GRCommons::Fiddley::MemoryPointer.new(:pointer)
      e = super(1, line, file)
      return [0, nil, nil] if e == 0

      line = line.read_int
      # to_ptr: Fiddley::MemoryPointer -> Fiddle::Pointer
      file = file.to_ptr.ptr.to_s
      [e, line, file]
    end

    FFI.ffi_methods.each do |method|
      method_name = method.to_s.sub(/^gr3_/, '')
      next if method_name == 'geterror'

      define_method(method_name) do |*args|
        values = super(*args)
        e, line, file = geterror
        if e != 0
          mesg = FFI.gr3_geterrorstring(e)
          raise "GR3 error #{file} #{line} #{mesg}"
        end
        values
      end
    end
  end
  extend CheckError

  # Now you can see a lot of methods just calling super here.
  # They are written to help the yard generate the documentation.
  class << self
    # This method initializes the gr3 context.
    # @return [Integer]
    def gr3_init(*)
      super
    end

    def free(*)
      super
    end

    # This function terminates the gr3 context.
    def terminate(*)
      super
    end

    # @!method geterror
    # This function returns information on the most recent GR3 error.
    # @return [Integer]
    # @note This method is defined in the CheckError module.

    # This function allows the user to find out how his commands are rendered.
    # If gr3 is initialized, a string in the format:
    # `"gr3 - " + window toolkit + " - " + framebuffer extension + " - " + OpenGL version + " - " + OpenGL renderer string`.
    # For example `"gr3 - GLX - GL_ARB_framebuffer_object - 2.1 Mesa 7.10.2 - Software Rasterizer"`
    # might be returned on a Linux system (using GLX) with an available GL_ARB_framebuffer_object implementation.
    # If gr3 is not initialized `"Not initialized"` is returned.
    # @return [String]
    def getrenderpathstring(*)
      super.to_s
    end

    # This function returns a string representation of a given error code.
    # @return [String]
    def geterrorstring(*)
      super.to_s
    end

    # This function clears the draw list.
    # @return [Integer]
    def clear(*)
      super
    end

    # Use the currently bound framebuffer as the framebuffer used for drawing to OpenGL (using gr3.drawimage).
    # This function is only needed when you do not want to render to 0, the default framebuffer.
    def usecurrentframebuffer(*)
      super
    end

    # Set the framebuffer used for drawing to OpenGL (using gr3.drawimage).
    # This function is only needed when you do not want to render to 0, the default framebuffer.
    def useframebuffer(*)
      super
    end

    # Set rendering quality
    # @param quality [] The quality to set
    # @return [Integer]
    def setquality(*)
      super
    end

    # @return [Integer]
    def getimage(width, height, use_alpha = true)
      bpp = use_alpha ? 4 : 3
      inquiry(uint8: width * height * bpp) do |bitmap|
        super(width, height, (use_alpha ? 1 : 0), bitmap)
      end
    end

    # @return [Integer]
    def export(*)
      super
    end

    # @return [Integer]
    def drawimage(*)
      super
    end

    # createmesh_nocopy
    # @return [Integer]
    def createmesh_nocopy(_n, vertices, normals, colors)
      inquiry_int do |mesh|
        super(mesh, vertices, normals, colors)
      end
    end

    # This function creates a int from vertex position, normal and color data.
    # Returns a mesh.
    # @param n [Integer] the number of vertices in the mesh
    # @param vertices [Array, NArray] the vertex positions
    # @param normals [Array, NArray] the vertex normals
    # @param colors [Array, NArray] the vertex colors,
    #  they should be white (1,1,1) if you want to change the color for each drawn mesh
    # @return [Integer]
    def createmesh(n, vertices, normals, colors)
      inquiry_int do |mesh|
        super(mesh, n, vertices, normals, colors)
      end
    end

    # This function creates a mesh from vertex position, normal and color data.
    # @return [Integer]
    def createindexedmesh_nocopy(num_vertices, vertices, normals, colors, num_indices, indices)
      inquiry_int do |mesh|
        super(mesh, num_vertices, vertices, normals, colors, num_indices, indices)
      end
    end

    # This function creates an indexed mesh from vertex information (position,
    # normal and color) and triangle information (indices).
    # Returns a mesh.
    # @param num_vertices [Integer] the number of vertices in the mesh
    # @param vertices [Array, NArray] the vertex positions
    # @param normals [Array, NArray] the vertex normals
    # @param colors [Array, NArray] the vertex colors,
    #  they should be white (1,1,1) if you want to change the color for each drawn mesh
    # @param num_indices [Integer] the number of indices in the mesh (three times the number of triangles)
    # @param indices [Array, NArray] the index array (vertex indices for each triangle)
    # @return [Integer]
    def createindexedmesh(num_vertices, vertices, normals, colors, num_indices, indices)
      inquiry_int do |mesh|
        super(mesh, num_vertices, vertices, normals, colors, num_indices, indices)
      end
    end

    # This function adds a mesh to the draw list, so it will be drawn when the user calls getpixmap.
    # The given data stays owned by the user, a copy will be saved in the draw list and the mesh reference counter will be increased.
    # @param mesh [Integer] The mesh to be drawn
    # @param n [Integer] The number of meshes to be drawn
    # @param positions [Array, NArray] The positions where the meshes should be drawn
    # @param directions [Array, NArray] The forward directions the meshes should be facing at
    # @param ups [Array, NArray] The up directions
    # @param colors [Array, NArray] The colors the meshes should be drawn in, it will be multiplied with each vertex color
    # @param scales [Array, NArray] The scaling factors
    def drawmesh(*)
      super
    end

    # This function marks a mesh for deletion and removes the user’s reference from the mesh’s referenc counter,
    # so a user must not use the mesh after calling this function.
    # @param mesh [Integer] The mesh that should be marked for deletion
    def deletemesh(*)
      super
    end

    # This function sets the view matrix by getting the position of the camera,
    # the position of the center of focus and the direction which should point up.
    # @param  camera_x [Array, NArray] The x-coordinate of the camera
    # @param  camera_y [Array, NArray] The y-coordinate of the camera
    # @param  camera_z [Array, NArray] The z-coordinate of the camera
    # @param  center_x [Array, NArray] The x-coordinate of the center of focus
    # @param  center_y [Array, NArray] The y-coordinate of the center of focus
    # @param  center_z [Array, NArray] The z-coordinate of the center of focus
    # @param  up_x [Array, NArray] The x-component of the up direction
    # @param  up_y [Array, NArray] The y-component of the up direction
    # @param  up_z [Array, NArray] The z-component of the up direction
    def cameralookat(*)
      super
    end

    # This function sets the projection parameters.
    # This function takes effect when the next image is created.
    # @param vertical_field_of_view [Numeric] This parameter is the vertical field of view in degrees.
    #  It must be greater than 0 and less than 180.
    # @param zNear [Numeric] The distance to the near clipping plane.
    # @param zFar [Numeric] The distance to the far clipping plane.
    # @return [Integer]
    def setcameraprojectionparameters(*)
      super
    end

    # Get the projection parameters.
    # @return [Integer]
    def getcameraprojectionparameters(*)
      super
    end

    # This function sets the direction of light.
    # If it is called with (0, 0, 0), the light is always pointing into the same direction as the camera.
    # @param x [Numeric] The x-component of the light's direction
    # @param y [Numeric] The y-component of the light's direction
    # @param z [Numeric] The z-component of the light's direction
    def setlightdirection(*)
      super
    end

    # This function sets the background color.
    def setbackgroundcolor(*)
      super
    end

    # @return [Integer]
    def createheightmapmesh(*)
      super
    end

    def drawheightmap(*)
      super
    end

    # This function allows drawing a cylinder without requiring a mesh.
    def drawconemesh(*)
      super
    end

    # This function allows drawing a cylinder without requiring a mesh.
    def drawcylindermesh(*)
      super
    end

    # This function allows drawing a sphere without requiring a mesh.
    def drawspheremesh(*)
      super
    end

    def drawcubemesh(*)
      super
    end

    def setobjectid(*)
      super
    end

    # @return [Integer]
    def selectid(*)
      super
    end

    def getviewmatrix(*)
      super
    end

    def setviewmatrix(*)
      super
    end

    # the current projection type: GR3_PROJECTION_PERSPECTIVE or GR3_PROJECTION_PARALLEL
    # @return [Integer]
    def getprojectiontype(*)
      super
    end

    # @param type [Integer] the new projection type: GR3_PROJECTION_PERSPECTIVE or GR3_PROJECTION_PARALLEL
    def setprojectiontype(*)
      super
    end

    # This function creates an isosurface from voxel data using the
    # marching cubes algorithm.
    # Returns a mesh.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    # @param isolevel [Integer] isovalue at which the surface will be created
    # @return [Integer]
    def createisosurfacemesh(grid, step, offset, isolevel)
      args = _preprocess_createslicemesh(grid, step, offset)
      grid = args.shift
      inquiry_int do |mesh|
        super(mesh, uint16(grid), isolevel, *args)
      end
    end

    # Create a mesh of a surface plot similar to gr_surface.
    # Uses the current colormap. To apply changes of the colormap
    # a new mesh has to be created.
    # @param nx [Integer] number of points in x-direction
    # @param ny [Integer] number of points in y-direction
    # @param x [Array, NArray] an array containing the x-coordinates
    # @param y [Array, NArray] an array containing the y-coordinates
    # @param z  [Array, NArray] an array of length nx * ny containing the z-coordinates
    # @param option [Integer] option for the surface mesh; the GR3_SURFACE constants can be combined with bitwise or. See the table below.
    #  * 0  : GR3_SURFACE_DEFAULT
    #    *    default behavior
    #  * 1  : GR3_SURFACE_NORMALS
    #    *    interpolate the vertex normals from the gradient
    #  * 2  : GR3_SURFACE_FLAT
    #    *    set all z-coordinates to zero
    #  * 4  : GR3_SURFACE_GRTRANSFORM
    #    *    use gr_inqwindow, gr_inqspace and gr_inqscale to transform the data to NDC coordinates
    #  * 8  : GR3_SURFACE_GRCOLOR
    #    *    color the surface according to the current gr colormap
    #  * 16 : GR3_SURFACE_GRZSHADED
    #    *    like GR3_SURFACE_GRCOLOR, but use the z-value directly as color index
    # @return [Integer]
    def createsurfacemesh(nx, ny, x, y, z, option = 0)
      inquiry_int do |mesh|
        super(mesh, nx, ny, x, y, z, option)
      end
    end

    # Draw a mesh with the projection of gr. It uses the current
    # projection parameters (rotation, tilt) of gr.
    # This function alters the projection type, the projection parameters,
    # the viewmatrix and the light direction. If necessary, the user has to
    # save them before the call to this function and restore them after
    # the call to gr3_drawimage.
    # @param mesh [Integer] the mesh to be drawn
    # @param n [Integer] the number of meshes to be drawn
    # @param positions [Array, NArray] the positions where the meshes should be drawn
    # @param directions [Array, NArray] the forward directions the meshes should be facing at
    # @param ups [Array, NArray] the up directions
    # @param colors [Array, NArray] the colors the meshes should be drawn in, it will be multiplied with each vertex color
    # @param scales [Array, NArray] the scaling factors
    def drawmesh_grlike(*)
      super
    end

    # Convenience function for drawing a surfacemesh.
    # @param mesh [Integer] the mesh to be drawn
    def drawsurface(*)
      super
    end

    # Create a surface plot with gr3 and draw it with gks as cellarray.
    # @param x [Array, NArray] an array containing the x-coordinates
    # @param y [Array, NArray] an array containing the y-coordinates
    # @param z  [Array, NArray] an array of length nx * ny containing the z-coordinates
    # @param option [Integer] see the option parameter of gr_surface.
    #  OPTION_COLORED_MESH and OPTION_Z_SHADED_MESH are supported.
    def surface(x, y, z, option)
      nx = x.length
      ny = y.length
      # TODO: Check out_of_bounds
      super(nx, ny, x, y, z, option)
    end

    # drawtubemesh
    # Draw a tube following a path given by a list of points. The colors and
    # radii arrays specify the color and radius at each point.
    # @param n [Integer] the number of points given
    # @param points [Array, NArray] the points the tube should go through
    # @param colors [Array, NArray] the color at each point
    # @param radii [Array, NArray]  the desired tube radius at each point
    # @param num_steps [Integer] the number of steps between each point, allowing for a more smooth tube
    # @param num_segments [Integer] the number of segments each ring of the tube consists of,
    #  e.g. 3 would yield a triangular tube
    # @return [Integer]
    def drawtubemesh(n, points, colors, radii, num_steps = 10, num_segments = 20)
      super(n, points, colors, radii, num_steps, num_segments)
    end

    # Create a mesh object in the shape of a tube following a path given by a
    # list of points. The colors and radii arrays specify the color and radius at
    # each point.
    # @param n [Integer] the number of points given
    # @param points [Array, NArray] the points the tube should go through
    # @param colors [Array, NArray] the color at each point
    # @param radii [Array, NArray] the desired tube radius at each point
    # @param num_steps [Integer] the number of steps between each point, allowing for a more smooth tube
    # @param num_segments [Integer] the number of segments each ring of the tube consists of, e.g. 3 would yield a triangular tube
    # @return [Integer]
    def createtubemesh(n, points, colors, radii, num_steps = 10, num_segments = 20)
      inquiry_uint do |mesh| # mesh should be Int?
        super(mesh, n, points, colors, radii, num_steps, num_segments)
      end
    end

    # drawspins
    def drawspins(positions, directions, colors = nil,
                  cone_radius = 0.4, cylinder_radius = 0.2,
                  cone_height = 1.0, cylinder_height = 1.0)
      n = positions.length
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

    # Creates meshes for slices through the given data, using the current GR
    # colormap. Use the parameters x, y or z to specify what slices should be
    # drawn and at which positions they should go through the data. If neither
    # x nor y nor z are set, 0.5 will be used for all three.
    # Returns meshes for the yz-slice, the xz-slice and the xy-slice.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param x [Numeric] the position of the slice through the xz-plane (0 to 1)
    # @param y [Numeric] the position of the slice through the xz-plane (0 to 1)
    # @param z [Numeric] the position of the slice through the xz-plane (0 to 1)
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    def createslicemeshes(grid, x = nil, y = nil, z = nil, step = nil, offset = nil)
      if [x, y, z].all?(&:nil?)
        x = 0.5
        y = 0.5
        z = 0.5
      end
      mesh_x = (createxslicemesh(grid, x, step, offset) if x)
      mesh_y = (createyslicemesh(grid, y, step, offset) if y)
      mesh_z = (createzslicemesh(grid, z, step, offset) if z)
      [mesh_x, mesh_y, mesh_z]
    end

    # Creates a meshes for a slices through the yz-plane of the given data,
    # using the current GR colormap. Use the x parameter to set the position of
    # the yz-slice.
    # Returns a mesh for the yz-slice.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param x [Numeric] the position of the slice through the xz-plane (0 to 1)
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    def createxslicemesh(grid, x = 0.5, step = nil, offset = nil)
      args = _preprocess_createslicemesh(grid, step, offset)
      grid = args.shift
      x = (x.clamp(0, 1) * args[0]).floor
      inquiry_int do |mesh|
        super(mesh, uint16(grid), x, *args)
      end
    end

    # Creates a meshes for a slices through the xz-plane of the given data,
    # using the current GR colormap. Use the y parameter to set the position of
    # the xz-slice.
    # Returns a mesh for the xz-slice.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param y [Numeric] the position of the slice through the xz-plane (0 to 1)
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    def createyslicemesh(grid, y = 0.5, step = nil, offset = nil)
      args = _preprocess_createslicemesh(grid, step, offset)
      grid = args.shift
      y = (y.clamp(0, 1) * args[1]).floor
      inquiry_int do |mesh|
        super(mesh, uint16(grid), y, *args)
      end
    end

    # Creates a meshes for a slices through the xy-plane of the given data,
    # using the current GR colormap. Use the z parameter to set the position of
    # the xy-slice.
    # Returns a mesh for the xy-slice.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param z [Numeric] the position of the slice through the xz-plane (0 to 1)
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    def createzslicemesh(grid, z = 0.5, step = nil, offset = nil)
      args = _preprocess_createslicemesh(grid, step, offset)
      grid = args.shift
      z = (z.clamp(0, 1) * args[2]).floor
      inquiry_int do |mesh|
        super(mesh, uint16(grid), z, *args)
      end
    end

    # Draw a yz-slice through the given data, using the current GR colormap.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param x [Numeric] the position of the slice through the yz-plane (0 to 1)
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    # @param position [Array] the positions where the meshes should be drawn
    # @param direction [Array] the forward directions the meshes should be facing at
    # @param up [Array] the up directions
    # @param color [Array] the colors the meshes should be drawn in, it will be multiplied with each vertex color
    # @param scale [Array] the scaling factors
    def drawxslicemesh(grid, x = 0.5, step = nil, offset = nil,
                       position = [0, 0, 0], direction = [0, 0, 1], up = [0, 1, 0],
                       color = [1, 1, 1], scale = [1, 1, 1])
      mesh = createxslicemesh(grid, x, step, offset)
      drawmesh(mesh, 1, position, direction, up, color, scale)
      deletemesh(mesh)
    end

    # Draw a xz-slice through the given data, using the current GR colormap.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param y [Numeric] the position of the slice through the xz-plane (0 to 1)
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    # @param position [Array] the positions where the meshes should be drawn
    # @param direction [Array] the forward directions the meshes should be facing at
    # @param up [Array] the up directions
    # @param color [Array] the colors the meshes should be drawn in, it will be multiplied with each vertex color
    # @param scale [Array] the scaling factors
    def drawyslicemesh(grid, y = 0.5, step = nil, offset = nil,
                       position = [0, 0, 0], direction = [0, 0, 1], up = [0, 1, 0],
                       color = [1, 1, 1], scale = [1, 1, 1])
      mesh = createyslicemesh(grid, y, step, offset)
      drawmesh(mesh, 1, position, direction, up, color, scale)
      deletemesh(mesh)
    end

    # Draw a xy-slice through the given data, using the current GR colormap.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param z [Numeric] the position of the slice through the xy-plane (0 to 1)
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    # @param position [Array] the positions where the meshes should be drawn
    # @param direction [Array] the forward directions the meshes should be facing at
    # @param up [Array] the up directions
    # @param color [Array] the colors the meshes should be drawn in, it will be multiplied with each vertex color
    # @param scale [Array] the scaling factors
    def drawzslicemesh(grid, z = 0.5, step = nil, offset = nil,
                       position = [0, 0, 0], direction = [0, 0, 1], up = [0, 1, 0],
                       color = [1, 1, 1], scale = [1, 1, 1])
      mesh = createzslicemesh(grid, z, step, offset)
      drawmesh(mesh, 1, position, direction, up, color, scale)
      deletemesh(mesh)
    end

    # raw slices through the given data, using the current GR colormap.
    # Use the parameters x, y or z to specify what slices should be drawn and at
    # which positions they should go through the data. If neither x nor y nor
    # z are set, 0.5 will be used for all three.
    # @param grid [NArray] 3D narray array containing the voxel data
    # @param x [Numeric] the position of the slice through the yz-plane (0 to 1)
    # @param y [Numeric] the position of the slice through the xz-plane (0 to 1)
    # @param z [Numeric] the position of the slice through the xy-plane (0 to 1)
    # @param step [Array] voxel sizes in each direction
    # @param offset [Array] coordinate origin in each direction
    # @param position [Array] the positions where the meshes should be drawn
    # @param direction [Array] the forward directions the meshes should be facing at
    # @param up [Array] the up directions
    # @param color [Array] the colors the meshes should be drawn in, it will be multiplied with each vertex color
    # @param scale [Array] the scaling factors
    def drawslicemeshes(grid, x = nil, y = nil, z = nil, step = nil,
                        offset = nil, position = [0, 0, 0], direction = [0, 0, 1], up = [0, 1, 0],
                        color = [1, 1, 1], scale = [1, 1, 1])
      meshes = createslicemeshes(grid, x, y, z, step, offset)
      meshes.each do |mesh|
        if mesh
          drawmesh(mesh, 1, position, direction, up, color, scale)
          deletemesh(mesh)
        end
      end
    end

    def volume(data, algorithm)
      data = Numo::DFloat.cast(data) if data.is_a? Array
      inquiry %i[double double] do |dmin, dmax|
        dmin.write_double(-1)
        dmax.write_double(-1)
        nx, ny, nz = data.shape
        super(nx, ny, nz, data, algorithm, dmin, dmax)
      end
    end

    private

    def _preprocess_createslicemesh(grid, step, offset)
      # TODO: raise error when grid is not narray
      # grid
      case grid.class::MAX
      when Integer
        input_max = grid.class::MAX
      when Float
        # floating point values are expected to be in range [0, 1]
        # Complex narrays are not taken into account
        input_max = 1
        grid[grid > 1] = 1
      else
        raise ArgumentError, 'grid must be three dimensional array of Real numbers'
      end
      scaling_factor = Numo::UInt16::MAX / input_max.to_f
      grid = (grid.cast_to(Numo::UInt64) * scaling_factor).cast_to(Numo::UInt16) # room for improvement

      # step & offset
      nx, ny, nz = grid.shape
      if step.nil? && offset.nil?
        step = [2.0 / (nx - 1), 2.0 / (ny - 1), 2.0 / (nz - 1)]
        offset = [-1.0, -1.0, -1.0]
      elsif offset.nil?
        offset = [-step[0] * (nx - 1) / 2.0,
                  -step[1] * (ny - 1) / 2.0,
                  -step[2] * (nz - 1) / 2.0]
      elsif step.nil?
        step = [-offset[0] * 2.0 / (nx - 1),
                -offset[1] * 2.0 / (ny - 1),
                -offset[2] * 2.0 / (nz - 1)]
      end

      step_x, step_y, step_z = step
      offset_x, offset_y, offset_z = offset

      # strides
      stride_x = ny * nz
      stride_y = nz
      stride_z = 1

      [grid, nx, ny, nz, stride_x, stride_y, stride_z, step_x, step_y, step_z, offset_x, offset_y, offset_z]
    end
  end

  # InitAttribute
  IA_END_OF_LIST        = 0
  IA_FRAMEBUFFER_WIDTH  = 1
  IA_FRAMEBUFFER_HEIGHT = 2

  # Error
  ERROR_NONE                   =  0
  ERROR_INVALID_VALUE          =  1
  ERROR_INVALID_ATTRIBUTE      =  2
  ERROR_INIT_FAILED            =  3
  ERROR_OPENGL_ERR             =  4
  ERROR_OUT_OF_MEM             =  5
  ERROR_NOT_INITIALIZED        =  6
  ERROR_CAMERA_NOT_INITIALIZED =  7
  ERROR_UNKNOWN_FILE_EXTENSION =  8
  ERROR_CANNOT_OPEN_FILE       =  9
  ERROR_EXPORT                 = 10

  # Quality
  QUALITY_OPENGL_NO_SSAA  =  0
  QUALITY_OPENGL_2X_SSAA  =  2
  QUALITY_OPENGL_4X_SSAA  =  4
  QUALITY_OPENGL_8X_SSAA  =  8
  QUALITY_OPENGL_16X_SSAA = 16
  QUALITY_POVRAY_NO_SSAA  =  0 + 1
  QUALITY_POVRAY_2X_SSAA  =  2 + 1
  QUALITY_POVRAY_4X_SSAA  =  4 + 1
  QUALITY_POVRAY_8X_SSAA  =  8 + 1
  QUALITY_POVRAY_16X_SSAA = 16 + 1

  # Drawable
  DRAWABLE_OPENGL = 1
  DRAWABLE_GKS    = 2

  # SurfaceOption
  SURFACE_DEFAULT     =  0
  SURFACE_NORMALS     =  1
  SURFACE_FLAT        =  2
  SURFACE_GRTRANSFORM =  4
  SURFACE_GRCOLOR     =  8
  SURFACE_GRZSHADED   = 16

  ATOM_COLORS =
    [[0, 0, 0],
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

  atom_number = {}
  { H: 1, HE: 2, LI: 3, BE: 4, B: 5, C: 6, N: 7,
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
    UUS: 117, UUO: 118 }.each do |key, value|
      atom_number[key] = value
      atom_number[key.to_s] = value # allow string keys
    end
  ATOM_NUMBERS = atom_number.freeze

  ATOM_VALENCE_RADII =
    [0, # Avoid atomic number to index conversion
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
