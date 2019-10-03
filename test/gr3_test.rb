# frozen_string_literal: true

require_relative 'test_helper'
require 'gr3'

class GR3Test < Minitest::Test
  def test_gr3_ffi_lib
    assert_instance_of String, GR3.ffi_lib
  end
end
