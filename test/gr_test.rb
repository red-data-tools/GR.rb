# frozen_string_literal: true

require_relative 'test_helper'

class GRTest < Minitest::Test
  def test_version
    assert_instance_of String, GR::VERSION
  end
end

class GRClassTest < Minitest::Test
  def test_gr_ffi_lib
    assert_instance_of String, GR::GR.ffi_lib
  end

  def setup
    @g = GR::GR.new
  end

  def test_gr_version
    assert_instance_of String, @g.version
  end
end

class GR3ClassTest < Minitest::Test
  def test_gr3_ffi_lib
    assert_instance_of String, GR::GR3.ffi_lib
  end

  def setup
    @g = GR::GR3.new
  end
end
