# frozen_string_literal: true

require_relative 'test_helper'
require 'gr'
require 'gr3'

class GRTest < Minitest::Test
  def test_gr_ffi_lib
    assert_instance_of String, GR.ffi_lib
  end

  def test_gr_version
    assert_instance_of String, GR.version
  end
end

class GR3Test < Minitest::Test
  def test_gr3_ffi_lib
    assert_instance_of String, GR3.ffi_lib
  end
end
