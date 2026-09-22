# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/gr3'

class GR3Test < Test::Unit::TestCase
  def setup
    GR3.init(nil)
  rescue StandardError => e
    omit "GR3 isn't available: #{e.message}"
  end

  def teardown
    GR3.terminate
  end

  def test_gr3_ffi_lib
    assert_kind_of String, GR3.ffi_lib
  end

  def test_gr3_geterror
    assert_kind_of Array, GR3.geterror
  end

  def test_version
    assert_kind_of String, GR3::VERSION
  end

  def test_getstringmethod
    assert_equal 'GR3_ERROR_INVALID_VALUE', GR3.geterrorstring(1)
    assert_kind_of String, GR3.getrenderpathstring
  end

  def test_getimage
    assert_equal [0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255],
                 GR3.getimage(2, 2, true)
    assert_equal [0, 0, 0, 255, 0, 0], GR3.getimage(2, 1, false)
  end

  def test_alphamode
    GR3.setalphamode(1)
    assert_equal 1, GR3.getalphamode
    GR3.setalphamode(0)
    assert_equal 0, GR3.getalphamode
  end

  def test_lightsources
    # Test set/get lightsources
    # Note: getlightsources returns [num_lights, positions, colors]
    # positions and colors are arrays of floats

    # Set 1 light
    GR3.setlightsources(1, [0, 0, 1], [1, 1, 1])
    num, pos, col = GR3.getlightsources(1)
    assert_equal 1, num
    assert_equal [0.0, 0.0, 1.0], pos[0]
    assert_equal [1.0, 1.0, 1.0], col[0]
  end

  def test_cameraprojectionparameters
    GR3.setcameraprojectionparameters(45.0, 0.1, 100.0)
    vfov, znear, zfar = GR3.getcameraprojectionparameters
    assert_in_delta 45.0, vfov, 0.001
    assert_in_delta 0.1, znear, 0.001
    assert_in_delta 100.0, zfar, 0.001
  end

  def test_viewmatrix
    assert_equal 16, GR3.getviewmatrix.length
  end

  def test_lightparameters
    GR3.setlightparameters(0.2, 0.6, 0.3, 20.0)
    params = GR3.getlightparameters
    assert_in_delta 0.2, params[0], 0.001
    assert_in_delta 0.6, params[1], 0.001
    assert_in_delta 0.3, params[2], 0.001
    assert_in_delta 20.0, params[3], 0.001
  end

  def test_clipping
    GR3.setclipping(0.1, 0.9, 0.1, 0.9, 0.1, 0.9)
    clipping = GR3.getclipping
    assert_equal 6, clipping.length
    assert_in_delta 0.1, clipping[0], 0.001
    assert_in_delta 0.9, clipping[1], 0.001
  end

  def test_mesh_lifecycle
    mesh = GR3.createmesh(3, triangle_vertices, triangle_normals, triangle_colors)
    assert_kind_of Integer, mesh
    assert_nothing_raised do
      GR3.drawmesh(mesh, 1, [0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 1, 1], [1, 1, 1])
    end
  ensure
    GR3.deletemesh(mesh) if mesh
  end

  def test_indexed_mesh_lifecycle
    mesh = GR3.createindexedmesh(
      3, triangle_vertices, triangle_normals, triangle_colors, 3, [0, 1, 2]
    )
    assert_kind_of Integer, mesh
  ensure
    GR3.deletemesh(mesh) if mesh
  end

  def test_surface_mesh_lifecycle
    mesh = GR3.createsurfacemesh(2, 2, [0, 1], [0, 1], [0, 1, 1, 0])
    assert_kind_of Integer, mesh
  ensure
    GR3.deletemesh(mesh) if mesh
  end

  def test_tube_mesh_lifecycle
    points = [0, 0, 0, 0, 0, 1]
    colors = [1, 0, 0, 0, 1, 0]
    radii = [0.1, 0.1]
    mesh = GR3.createtubemesh(2, points, colors, radii, 3, 6)
    assert_kind_of Integer, mesh
    assert_nothing_raised { GR3.drawtubemesh(2, points, colors, radii, 3, 6) }
  ensure
    GR3.deletemesh(mesh) if mesh
  end

  def test_projection_and_surface_options
    GR3.setprojectiontype(GR3::PROJECTION_ORTHOGRAPHIC)
    assert_equal GR3::PROJECTION_ORTHOGRAPHIC, GR3.getprojectiontype
    GR3.setprojectiontype(GR3::PROJECTION_PERSPECTIVE)
    assert_equal GR3::PROJECTION_PERSPECTIVE, GR3.getprojectiontype

    option = GR3::SURFACE_NORMALS | GR3::SURFACE_GRCOLOR
    GR3.setsurfaceoption(option)
    assert_equal option, GR3.getsurfaceoption
  end

  def test_native_errors_are_reported
    error = assert_raise(RuntimeError) do
      GR3.setcameraprojectionparameters(0, 0.1, 100)
    end
    assert_match(/GR3_ERROR_INVALID_VALUE/, error.message)
  end

  def test_isosurface_mesh_lifecycle
    mesh = GR3.createisosurfacemesh(voxel_grid, nil, nil, 32_768)
    assert_kind_of Integer, mesh
  ensure
    GR3.deletemesh(mesh) if mesh
  end

  def test_slice_mesh_lifecycle
    meshes = GR3.createslicemeshes(voxel_grid)
    assert_equal 3, meshes.length
    assert(meshes.all? { |mesh| mesh.is_a?(Integer) })
  ensure
    meshes&.compact&.each { |mesh| GR3.deletemesh(mesh) }
  end

  def test_draw_slice_helpers
    assert_nothing_raised do
      GR3.drawslicemeshes(voxel_grid, 0.25, nil, 0.75)
    end
  end

  def test_surface_and_isosurface_helpers
    assert_nil GR3.surface([0, 1], [0, 1], [0, 1, 1, 0], 3)

    data = Numo::DFloat[[[0, 0], [0, 0]], [[1, 1], [1, 1]]]
    assert_nil GR3.isosurface(data)
    assert_nil GR3.isosurface(data, 0.25, [1, 0, 0], [4, 2, 1])
  end

  def test_draw_molecule_with_default_and_explicit_attributes
    positions = [[-1, 0, 0], [1, 0, 1]]
    assert_nil GR3.drawmolecule(positions, nil, nil, nil, nil, nil, nil, true, 30, 45)
    assert_nil GR3.drawmolecule(
      positions, [[1, 0, 0], [0, 1, 0]], [0.2, 0.3], nil,
      0.05, [0.5, 0.5, 0.5], 1.2, false
    )
  end

  def test_slice_preprocessing_defaults
    values = GR3.send(:_preprocess_createslicemesh, voxel_grid, nil, nil)
    converted, nx, ny, nz, stride_x, stride_y, stride_z, *geometry = values

    assert_kind_of Numo::UInt16, converted
    assert_equal [2, 2, 2], [nx, ny, nz]
    assert_equal [4, 2, 1], [stride_x, stride_y, stride_z]
    assert_equal [2.0, 2.0, 2.0, -1.0, -1.0, -1.0], geometry
  end

  def test_slice_preprocessing_derives_offset_or_step
    with_step = GR3.send(:_preprocess_createslicemesh, voxel_grid, [1.0, 2.0, 3.0], nil)
    assert_equal [-0.5, -1.0, -1.5], with_step.last(3)

    with_offset = GR3.send(:_preprocess_createslicemesh, voxel_grid, nil, [-1.0, -2.0, -3.0])
    assert_equal [2.0, 4.0, 6.0], with_offset[7, 3]
  end

  def test_slice_preprocessing_clamps_float_values
    grid = Numo::DFloat[[[0, 0.5], [1, 2]], [[0, 0.5], [1, 2]]]
    converted = GR3.send(:_preprocess_createslicemesh, grid, nil, nil).first

    assert_equal 1.0, grid.max
    assert_equal Numo::UInt16::MAX, converted.max
  end

  private

  def triangle_vertices
    [0, 0, 0, 1, 0, 0, 0, 1, 0]
  end

  def triangle_normals
    [0, 0, 1] * 3
  end

  def triangle_colors
    [1, 1, 1] * 3
  end

  def voxel_grid
    Numo::UInt8[[[0, 0], [0, 0]], [[255, 255], [255, 255]]]
  end
end
