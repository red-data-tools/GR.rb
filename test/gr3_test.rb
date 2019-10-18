# frozen_string_literal: true

require_relative 'test_helper'
require 'gr3'

class GR3Test < Minitest::Test
  def test_gr3_ffi_lib
    assert_instance_of String, GR3.ffi_lib
  end

  def test_getimage
    assert_equal GR3.getimage(2, 2, true),
                 [0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255]
  end

  def teardown
    GR3.terminate
  end
end
