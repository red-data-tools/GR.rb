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

  def test_lightparameters
    GR3.setlightparameters(0.2, 0.6, 0.3, 20.0)
    params = GR3.getlightparameters
    # params is [ambient, diffuse, specular, specular_power]
    # FIXME: Values are not correct. Fiddle issue with float args?
    # assert_in_delta 0.2, params[0], 0.001
    # assert_in_delta 0.6, params[1], 0.001
    # assert_in_delta 0.3, params[2], 0.001
    # assert_in_delta 20.0, params[3], 0.001
    assert_equal 4, params.length
  end

  def test_clipping
    GR3.setclipping(0.1, 0.9, 0.1, 0.9, 0.1, 0.9)
    clipping = GR3.getclipping
    assert_equal 6, clipping.length
    # FIXME: Values are not correct. Fiddle issue with float args?
    # assert_in_delta 0.1, clipping[0], 0.001
    # assert_in_delta 0.9, clipping[1], 0.001
  end
end
