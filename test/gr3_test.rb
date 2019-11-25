# frozen_string_literal: true

require_relative 'test_helper'
require 'gr3'

class GR3Test < Minitest::Test
  def setup
    begin
      GR3.init(nil)
    rescue => error
      skip "GR3 isn't available: #{error.message}"
    end
  end

  def test_gr3_ffi_lib
    assert_instance_of String, GR3.ffi_lib
  end

  def test_version
    assert_instance_of String, GR3::VERSION
  end

  def test_getimage
    assert_equal [0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255],
                 GR3.getimage(2, 2, true)
  end

  def teardown
    GR3.terminate
  end
end
