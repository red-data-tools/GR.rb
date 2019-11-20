# frozen_string_literal: true

require_relative 'test_helper'
require 'gr_commons'

class GRCommonsTest < Minitest::Test
  def setup
    @utils = Module.new { extend GRCommons::GRCommonUtils }
    @supportedtypes = GRCommons::GRCommonUtils::SupportedTypes
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

  def test_convert_array_into_ffi_pointer
    a = [1, 2, 3, 4, 5]
    @supportedtypes.each do |type|
      b = @utils.send(type, a)
      c = GRCommons::Fiddley::Utils.str2array(type, b)
      assert_equal(a, c)
    end
  end

  def test_convert_narray_into_ffi_pointer
    [Numo::Int32[1, 2, 3, 4, 5],
     Numo::UInt8[1, 2, 3, 4, 5],
     Numo::Int64[1, 2, 3, 4, 5],
     Numo::SFloat[1, 2, 3, 4, 5],
     Numo::DFloat[1, 2, 3, 4, 5]].each do |a|
      @supportedtypes.each do |type|
        b = @utils.send(type, a)
        c = GRCommons::Fiddley::Utils.str2array(type, b)
        assert_equal(a.to_a, c)
      end
    end
  end

  def test_inquiry_int
    a = @utils.send(:inquiry_int) do |pt|
      pt.write_int 3
    end
    assert_equal(a, 3)
  end

  def test_inquiry_double
    a = @utils.send(:inquiry_double) do |pt|
      pt.write_double 3.3
    end
    assert_equal(a, 3.3)
  end

  def test_inquiry_hash_int
    a = [1, 2, 3]
    b = @utils.send(:inquiry, int: 3) do |pt|
      pt.write_array_of_int(a)
    end
    assert_equal(a, b)
  end

  def test_inquiry_hash_double
    a = [1.1, 2.2, 3.3]
    b = @utils.send(:inquiry, double: 3) do |pt|
      pt.write_array_of_double(a)
    end
    assert_equal(a, b)
  end

  def test_inquiry_hash_int_and_double
    a = [1, 2, 3]
    b = [1.1, 2.2, 3.3, 4.4]
    c = @utils.send(:inquiry, [{ int: 3 }, { double: 4 }]) do |pa, pb|
      pa.write_array_of_int(a)
      pb.write_array_of_double(b)
    end
    assert_equal([a, b], c)
  end
end
