# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/gr'

require 'digest/md5'
require 'numo/narray'

class GRTest < Test::Unit::TestCase
  def setup
    GR.initgr
  end

  def teardown
    GR.clearws
  end

  def test_gr_ffi_lib
    assert_kind_of String, GR.ffi_lib
  end

  def test_version
    assert_kind_of String, GR::VERSION
  end

  def test_gr_version
    assert_kind_of String, GR.version
  end

  sub_test_case 'Set and Inquiry methods' do
    def test_inqdspsize
      assert_kind_of Array, GR.inqdspsize
    end

    def test_inqtext
      assert_kind_of Array, GR.inqtext(0, 0, 'Ruby')
    end

    def test_inqtextx
      assert_kind_of Array, GR.inqtextx(0, 0, 'Ruby',
                                        GR::TEXT_ENABLE_INLINE_MATH | \
                                        GR::TEXT_USE_WC)
    end

    def test_linetype
      assert_nil GR.setlinetype(3)
      assert_equal 3, GR.inqlinetype
    end

    def test_linewidth
      assert_nil GR.setlinewidth(3)
      assert_equal 3, GR.inqlinewidth
    end

    def test_linecolorind
      assert_nil GR.setlinecolorind(3)
      assert_equal 3, GR.inqlinecolorind
    end

    def test_markertype
      assert_nil GR.setmarkertype(3)
      assert_equal 3, GR.inqmarkertype
    end

    def test_markercolorind
      assert_nil GR.setmarkercolorind(3)
      assert_equal 3, GR.inqmarkercolorind
    end

    def test_fillintstyle
      assert_nil GR.setfillintstyle(3)
      assert_equal 3, GR.inqfillintstyle
    end

    def test_fillstyle
      assert_nil GR.setfillstyle(3)
      assert_equal 3, GR.inqfillstyle
    end

    def test_fillcolorind
      assert_nil GR.setfillcolorind(3)
      assert_equal 3, GR.inqfillcolorind
    end

    def test_nominalsize
      assert_nil GR.setnominalsize(0.2)
      assert_equal 0.2, GR.inqnominalsize
    end

    def test_scale
      assert_equal 0, GR.setscale(8)
      assert_equal 8, GR.inqscale
    end

    def test_window
      assert_nil GR.setwindow(0.1, 0.9, 0.11, 0.99)
      assert_equal [0.1, 0.9, 0.11, 0.99], GR.inqwindow
    end

    def test_viewport
      assert_nil GR.setviewport(0.1, 0.9, 0.11, 0.99)
      assert_equal [0.1, 0.9, 0.11, 0.99], GR.inqviewport
    end

    def test_space
      assert_equal 0, GR.setspace(0.1, 0.9, 40, 50)
      assert_equal [0.1, 0.9, 40, 50], GR.inqspace
    end

    def test_textext
      assert_kind_of Array, GR.inqtextext(0, 0, 'Ruby')
    end

    def test_mathtex3d
      assert_equal [16, 16, 16, 16], GR.inqmathtex3d(0, 0, 0, 'Ruby', 0).map(&:length)
    end

    def test_colormap
      assert_nil GR.setcolormap(3)
      assert_equal 3, GR.inqcolormap
    end

    def test_color
      assert_equal 0, GR.inqcolor(1)
    end

    # assert_kind_of Array, GR.inqmathtex(0,0,"Ruby")

    def test_box
      assert_kind_of Array, GR.inqbbox
    end

    def test_resamplemethod
      assert_nil GR.setresamplemethod(3)
      assert_equal 3, GR.inqresamplemethod
    end

    def test_borderwidth
      assert_nil GR.setborderwidth(2.5)
      assert_equal 2.5, GR.inqborderwidth
    end

    def test_bordercolorind
      assert_nil GR.setbordercolorind(1002)
      assert_equal 1002, GR.inqbordercolorind
    end

    def test_clipxform
      assert_nil GR.selectclipxform(3)
      assert_equal 3, GR.inqclipxform
    end

    def test_clip
      region, points = GR.inqclip
      assert_kind_of Integer, region
      assert_equal 4, points.length
    end

    def test_projectiontype
      assert_nil GR.setprojectiontype(1)
      assert_equal 1, GR.inqprojectiontype
    end

    def test_textcolorind
      assert_nil GR.settextcolorind(999)
      assert_equal 999, GR.inqtextcolorind
    end

    def test_charheight
      assert_nil GR.setcharheight(0.028)
      assert_equal 0.028, GR.inqcharheight
    end

    def test_scalefactors3d
      assert_nil GR.setscalefactors3d(2.3, 2.4, 2.5)
      assert_equal [2.3, 2.4, 2.5], GR.inqscalefactors3d
    end

    def test_space3d
      assert_nil GR.setspace3d(30, 40, 0, 10)
      assert_equal [1, 30.0, 40.0, 0.0, 10.0], GR.inqspace3d
    end

    def test_transparency
      assert_nil GR.settransparency(0.5)
      assert_equal 0.5, GR.inqtransparency
    end

    def test_textencoding
      assert_nil GR.settextencoding(300)
      assert_equal 300, GR.inqtextencoding
    end

    def test_colorlimits
      assert_nil GR.setcolorlimits(-1.5, 2.5)
      assert_equal [-1.5, 2.5], GR.inqcolorlimits
    end
  end

  def test_axis
    GR.setwindow(0.0, 3600.0, 0.0, 1.0)
    axis = GR.axis('TIMESTAMP')

    assert_equal 'TIMESTAMP', axis.spec
    assert_equal 0.0, axis.min
    assert_equal 3600.0, axis.max
    assert_false axis.ticks.empty?
    assert_nothing_raised { GR.drawaxis(axis) }
  end

  def test_format_reference
    reference = GR.getformat(0.0, 0.0, 1.0, 0.1, 2)

    assert_kind_of Integer, reference.scientific
    assert_kind_of Integer, reference.decimal_digits
    assert_kind_of String, GR.ftoa(0.5, reference)
  end

  def test_new_gr_0_73_27_ffi_methods
    assert_equal %w[spec min_val max_val tick org position major_count num_ticks ticks tick_size
                    num_tick_labels tick_labels label_position draw_axis_line label_orientation],
                 GR::FFI::Axis.members
    assert_equal %w[scientific decimal_digits], GR::FFI::FormatReference.members
    assert_respond_to GR::FFI, :gr_setmetadata
    assert_respond_to GR::FFI, :gr_getmetadata
    assert_respond_to GR::FFI, :gr_getmetadatafromstream
    assert_nil GR.getmetadata("#{__FILE__}.missing")
  end

  def test_readimage
    width, height, data = GR.readimage(File.expand_path('../examples/assets/ruby-logo.png', __dir__))
    assert_equal 198, width
    assert_equal 244, height
    assert_equal 198 * 244, data.length
    assert_true(data.all? { |i| i >= 0 })
    assert_equal 'ef670ef7f4edc6261cb7ade2f8ce72ab', Digest::MD5.hexdigest(data.join)

    width, height, data = GR.readimage(File.expand_path('../examples/assets/ball.png', __dir__))
    assert_equal 50, width
    assert_equal 50, height
    assert_equal 50 * 50, data.length
    assert_true(data.all? { |i| i >= 0 })
    assert_equal '11a9f559a454bf1882ba2c5cb6044310', Digest::MD5.hexdigest(data.join)
  end

  def test_hsvtorgb
    assert_equal [0.47, 0.5, 0.35], GR.hsvtorgb(0.2, 0.3, 0.5)
  end

  def test_reducepoints
    assert_equal [[10.0, 7.0], [2.0, 10.0]],
                 GR.reducepoints([10, 4, 7, 1], [2, 6, 10, 14], 2)
  end

  def test_hexbin_2pass
    result = GR.hexbin_2pass([0, 1, 2], [0, 1, 2], 10)
    assert_kind_of GR::FFI::Hexbin2Pass, result
    assert_true(result.nc.positive?)
    assert_true(result.cntmax.positive?)
  end

  def test_constant
    assert_equal 47, GR::COLORMAP_MAGMA
  end

  def test_to_rgb_color
    GR.setcolormap(3)
    assert_equal [0, 1_081_558, 16_514_815], GR.to_rgb_color([1, 2, 3])
    assert_equal Numo::Int32[0, 1_081_558, 16_514_815], GR.to_rgb_color(Numo::Int32[1, 2, 3])
  end

  def test_polyline_variants
    x = [0, 0.5, 1]
    y = [0, 1, 0]
    assert_nil GR.polyline(x, y)
    assert_nil GR.polyline(x, y, 2, 3)
    assert_nil GR.polyline(x, y, [1, 2, 3], [0.0, 0.5, 1.0])
    assert_nil GR.polyline(x, y, nil, 3)

    assert_raise(ArgumentError) { GR.polyline(x, y, [1, 2], 3) }
    assert_raise(ArgumentError) { GR.polyline(x, y, 2, [0.0, 1.0]) }
  end

  def test_polymarker_variants
    x = [0, 0.5, 1]
    y = [0, 1, 0]
    assert_nil GR.polymarker(x, y)
    assert_nil GR.polymarker(x, y, 2, 3)
    assert_nil GR.polymarker(x, y, [1, 2, 3], [0.0, 0.5, 1.0])
    assert_nil GR.polymarker(x, y, nil, 3)

    assert_raise(ArgumentError) { GR.polymarker(x, y, [1, 2], 3) }
    assert_raise(ArgumentError) { GR.polymarker(x, y, 2, [0.0, 1.0]) }
  end

  def test_nonuniform_cell_array_validation
    assert_nil GR.nonuniformcellarray([0, 0.5, 1], [0, 0.5, 1], 2, 2, [1, 2, 3, 4])
    assert_nil GR.nonuniformpolarcellarray([0, 180, 360], [0, 0.5, 1], 2, 2, [1, 2, 3, 4])

    assert_raise(ArgumentError) { GR.nonuniformcellarray([0, 1], [0, 1], 2, 2, [1, 2, 3, 4]) }
    assert_raise(ArgumentError) do
      GR.nonuniformpolarcellarray([0], [0, 1], 2, 2, [1, 2, 3, 4])
    end
  end

  def test_interpolation_wrappers
    assert_equal [[0.0, 1.0], [0.0, 1.0], [0.0, 1.0, 1.0, 0.0]],
                 GR.gridit([0, 1, 0, 1, 0.5], [0, 0, 1, 1, 0.5], [0, 1, 1, 0, 0.5], 2, 2)
    count, triangles = GR.delaunay([0, 1, 0, 1], [0, 0, 1, 1])
    assert_equal count, triangles.length
    assert_equal [3, 3], triangles.map(&:length)
    assert_equal [0, 1, 2, 3], triangles.flatten.uniq.sort
  end

  def test_colormap_from_rgb
    assert_nil GR.setcolormapfromrgb([0, 1], [0, 1], [0, 1])
    assert_nil GR.setcolormapfromrgb([0, 1], [0, 1], [0, 1], positions: [0, 1])

    error = assert_raise(ArgumentError) do
      GR.setcolormapfromrgb([0, 1], [0, 1], [0, 1], positions: [0])
    end
    assert_equal 'positions must have length 2 (got 1)', error.message
  end

  def test_limit_and_coordinate_helpers
    assert_equal [0.0, 10.0], GR.adjustlimits(0.12, 9.88)
    assert_equal [0.0, 10.0], GR.adjustrange(0.12, 9.88)
  end

  def test_surface_gradient_and_quiver_wrappers
    x = [0, 1]
    y = [0, 1]
    z = [0, 1, 1, 0]
    assert_equal [[1.0, 1.0, -1.0, -1.0], [1.0, -1.0, 1.0, -1.0]], GR.gradient(x, y, z)

    assert_raise(ArgumentError) { GR.surface(x, y, [0], GR::OPTION_LINES) }
    assert_raise(ArgumentError) { GR.gradient(x, y, [0]) }
    assert_raise(ArgumentError) { GR.quiver(x, y, [1], [1], false) }
  end

  def test_coordinate_transform_validation
    error = assert_raise(ArgumentError) { GR.setcoordxform([1, 0, 0]) }
    assert_equal 'mat must have 6 elements (got 3)', error.message
  end
end
