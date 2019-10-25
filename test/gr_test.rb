# frozen_string_literal: true

require_relative 'test_helper'
require 'gr'

class GRTest < Minitest::Test
  def test_gr_ffi_lib
    assert_instance_of String, GR.ffi_lib
  end

  def test_version
    assert_instance_of String, GR::VERSION
  end

  def test_gr_version
    assert_instance_of String, GR.version
  end

  def test_inqlinetype
    GR.setlinetype 3
    assert_equal GR.inqlinetype, 3
  end

  def test_hsvtorgb
    assert_equal [0.47, 0.5, 0.35], GR.hsvtorgb(0.2, 0.3, 0.5)
  end

  def test_reducepoints
    assert_equal [[10.0, 7.0], [2.0, 10.0]],
                 GR.reducepoints([10, 4, 7, 1], [2, 6, 10, 14], 2)
  end

  def test_COLORMAP_MAGMA
    assert_equal 47, GR::COLORMAP_MAGMA
  end

  def teardown
    GR.clearws
  end
end
