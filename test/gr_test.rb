# frozen_string_literal: true

require_relative 'test_helper'
require 'gr'

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

  def test_setinq_methods
    assert_kind_of Array, GR.inqdspsize
    assert_kind_of Array, GR.inqtext(0, 0, 'Ruby')
    # gridit
    assert_nil GR.setlinetype(3)
    assert_equal 3, GR.inqlinetype

    assert_nil GR.setlinewidth(3)
    assert_equal 3, GR.inqlinewidth

    assert_nil GR.setlinecolorind(3)
    assert_equal 3, GR.inqlinecolorind

    assert_nil GR.setmarkertype(3)
    assert_equal 3, GR.inqmarkertype

    assert_nil GR.setmarkercolorind(3)
    assert_equal 3, GR.inqmarkercolorind

    assert_nil GR.setfillintstyle(3)
    assert_equal 3, GR.inqfillintstyle

    assert_nil GR.setfillstyle(3)
    assert_equal 3, GR.inqfillstyle

    assert_nil GR.setfillcolorind(3)
    assert_equal 3, GR.inqfillcolorind

    assert_equal 0, GR.setscale(8)
    assert_equal 8, GR.inqscale

    assert_nil GR.setwindow(0.1, 0.9, 0.11, 0.99)
    assert_equal [0.1, 0.9, 0.11, 0.99], GR.inqwindow

    assert_nil GR.setviewport(0.1, 0.9, 0.11, 0.99)
    assert_equal [0.1, 0.9, 0.11, 0.99], GR.inqviewport

    assert_equal 0, GR.setspace(0.1, 0.9, 40, 50)
    assert_equal [0.1, 0.9, 40, 50], GR.inqspace

    assert_kind_of Array, GR.inqtextext(0, 0, 'Ruby')

    assert_nil GR.setcolormap(3)
    assert_equal 3, GR.inqcolormap

    assert_equal 0, GR.inqcolor(1)

    # assert_kind_of Array, GR.inqmathtex(0,0,"Ruby")
    assert_kind_of Array, GR.inqbbox

    assert_nil GR.setresamplemethod(3)
    assert_equal 3, GR.inqresamplemethod

    assert_nil GR.setborderwidth(2.5)
    assert_equal 2.5, GR.inqborderwidth

    assert_nil GR.setbordercolorind(1002)
    assert_equal 1002, GR.inqbordercolorind

    assert_nil GR.setprojectiontype(1)
    assert_equal 1, GR.inqprojectiontype
  end

  def test_readimage
    width, height, data = GR.readimage(File.expand_path('../examples/ruby-logo.png', __dir__))
    assert_equal 198, width
    assert_equal 244, height
    assert_equal 198 * 244, data.length
    assert_true data.all? { |i| i >= 0 }
    require 'digest/md5'
    assert_equal 'ef670ef7f4edc6261cb7ade2f8ce72ab', Digest::MD5.hexdigest(data.join)

    width, height, data = GR.readimage(File.expand_path('../examples/ball.png', __dir__))
    assert_equal 50, width
    assert_equal 50, height
    assert_equal 50 * 50, data.length
    assert_true data.all? { |i| i >= 0 }
    require 'digest/md5'
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
end
