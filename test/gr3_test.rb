# frozen_string_literal: true

require_relative 'test_helper'
require 'gr3'

class GR3Test < Minitest::Test
  def setup
    GR3.init(nil)
  rescue StandardError => e
    skip "GR3 isn't available: #{e.message}"
  end

  def test_gr3_ffi_lib
    assert_instance_of String, GR3.ffi_lib
  end

  def test_gr3_geterror
    assert_instance_of Array, GR3.geterror
  end

  def test_version
    assert_instance_of String, GR3::VERSION
  end

  def test_getstringmethod
    assert_equal 'GR3_ERROR_INVALID_VALUE', GR3.geterrorstring(1)
    assert_instance_of String, GR3.getrenderpathstring
  end

  def test_getimage
    assert_equal [0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255],
                 GR3.getimage(2, 2, true)
  end

  def teardown
    GR3.terminate
  end
end
