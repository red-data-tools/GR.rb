# frozen_string_literal: true

require_relative 'test_helper'
require 'gr_commons'

class GRCommonsTest < Minitest::Test
  def setup
    @utils = Module.new { extend GRCommons::GRCommonUtils }
  end

  def test_version
    assert_instance_of String, GRCommons::VERSION
  end

  def test_equal_length_array
    a = [1, 2, 3, 4, 5]
    b = [11, 12, 13, 14, 15]
    assert_equal 5, @utils.send(:equal_length, a, b)
  end

  def test_equal_length_narray
    a = Numo::DFloat[1, 2, 3, 4, 5]
    b = Numo::DFloat[11, 12, 13, 14, 15]
    assert_equal 5, @utils.send(:equal_length, a, b)
  end

  def test_equal_length_array_error
    a = [1, 2, 3, 4, 5]
    b = [11, 12, 13, 14, 15, 16]
    e = assert_raises ArgumentError do
      @utils.send(:equal_length, a, b)
    end

    assert_equal 'Sequences must have same length.', e.message
  end

  def test_equal_length_narray_error
    a = Numo::DFloat[1, 2, 3, 4, 5]
    b = Numo::DFloat[11, 12, 13, 14, 15, 16]
    e = assert_raises ArgumentError do
      @utils.send(:equal_length, a, b)
    end

    assert_equal 'Sequences must have same length.', e.message
  end

  def test_int_array
    a = [1, 2, 3, 4, 5]
    b = @utils.send(:int, a)
    c = @utils.send(:read_ffi_pointer, b, int: 5)
    assert_equal(a, c)
  end

  def test_int_narray
    a = Numo::Int32[1, 2, 3, 4, 5]
    b = @utils.send(:int, a)
    c = @utils.send(:read_ffi_pointer, b, int: 5)
    assert_equal(a, c)
  end

  def test_inquiry_int
    a = @utils.send(:inquiry_int) do |pt|
      pt.write_int 3
    end
    assert_equal(a, 3)
  end
end
