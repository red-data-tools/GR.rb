# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/gr'

require 'digest/md5'

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

    def test_textencoding
      assert_nil GR.settextencoding(300)
      assert_equal 300, GR.inqtextencoding
    end
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

  def test_constant
    assert_equal 47, GR::COLORMAP_MAGMA
  end

  def test_to_rgb_color
    GR.setcolormap(3)
    assert_equal [0, 1_081_558, 16_514_815], GR.to_rgb_color([1, 2, 3])
    assert_equal Numo::Int32[0, 1_081_558, 16_514_815], GR.to_rgb_color(Numo::Int32[1, 2, 3])
  end
end
