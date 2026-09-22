# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/gr_commons/fiddley'

class FiddleyTest < Test::Unit::TestCase
  Utils = GRCommons::Fiddley::Utils
  MemoryPointer = GRCommons::Fiddley::MemoryPointer

  def test_type_sizes
    {
      char: Fiddle::SIZEOF_CHAR, short: Fiddle::SIZEOF_SHORT,
      int: Fiddle::SIZEOF_INT, long: Fiddle::SIZEOF_LONG,
      long_long: Fiddle::SIZEOF_LONG_LONG, float: Fiddle::SIZEOF_FLOAT,
      double: Fiddle::SIZEOF_DOUBLE, size_t: Fiddle::SIZEOF_SIZE_T,
      pointer: Fiddle::SIZEOF_VOIDP
    }.each do |type, size|
      assert_equal size, Utils.type2size(type), type.to_s
    end

    error = assert_raise(RuntimeError) { Utils.type2size(:imaginary) }
    assert_equal 'unknown type imaginary', error.message
  end

  def test_fiddle_types
    {
      char: Fiddle::TYPE_CHAR, uchar: -Fiddle::TYPE_CHAR,
      short: Fiddle::TYPE_SHORT, ushort: -Fiddle::TYPE_SHORT,
      int: Fiddle::TYPE_INT, uint: -Fiddle::TYPE_INT,
      long: Fiddle::TYPE_LONG,
      ulong: -Fiddle::TYPE_LONG, long_long: Fiddle::TYPE_LONG_LONG,
      ulong_long: -Fiddle::TYPE_LONG_LONG, float: Fiddle::TYPE_FLOAT,
      double: Fiddle::TYPE_DOUBLE, size_t: Fiddle::TYPE_SIZE_T,
      pointer: Fiddle::TYPE_VOIDP,
      void: Fiddle::TYPE_VOID
    }.each do |type, fiddle_type|
      assert_equal fiddle_type, Utils.type2type(type), type.to_s
    end

    error = assert_raise(RuntimeError) { Utils.type2type(:imaginary) }
    assert_equal 'unknown type imaginary', error.message
  end

  def test_array_conversion_errors
    error = assert_raise(RuntimeError) do
      Utils.array2str(:imaginary, [1])
    end
    assert_equal 'unknown type imaginary', error.message
    error = assert_raise(RuntimeError) do
      Utils.str2array(:imaginary, "\0")
    end
    assert_equal 'unknown type imaginary', error.message
  end

  def test_signed_integer_accessors
    { 8 => [-2, 3], 16 => [-200, 300], 32 => [-20_000, 30_000],
      64 => [-2_000_000_000, 3_000_000_000] }.each do |bits, values|
      pointer = MemoryPointer.new(:char, bits / 8 * values.size)
      pointer.public_send("write_array_of_int#{bits}", values)
      assert_equal values, pointer.public_send("read_array_of_int#{bits}", values.size)
    end

    pointer = MemoryPointer.new(:int, 2)
    pointer.put_int32(Fiddle::SIZEOF_INT, -29)
    assert_equal(-29, pointer.get_int32(Fiddle::SIZEOF_INT))
  end

  def test_unsigned_integer_accessors
    { 8 => [2, 250], 16 => [200, 60_000], 32 => [20_000, 3_000_000_000],
      64 => [2_000_000_000, 9_000_000_000] }.each do |bits, values|
      pointer = MemoryPointer.new(:char, bits / 8 * values.size)
      pointer.public_send("write_array_of_uint#{bits}", values)
      assert_equal values, pointer.public_send("read_array_of_uint#{bits}", values.size)
    end

    pointer = MemoryPointer.new(:uint, 2)
    pointer.put_uint32(Fiddle::SIZEOF_INT, 29)
    assert_equal 29, pointer.get_uint32(Fiddle::SIZEOF_INT)
  end

  def test_float_and_double_accessors
    float_pointer = MemoryPointer.new(:float, 3)
    float_pointer.write_array_of_float([1.25, 2.5, 3.75])
    assert_equal [1.25, 2.5, 3.75], float_pointer.read_array_of_float(3)

    double_pointer = MemoryPointer.new(:double, 3)
    double_pointer.write_array_of_double([1.25, 2.5, 3.75])
    assert_equal [1.25, 2.5, 3.75], double_pointer.read_array_of_double(3)
    double_pointer.write_double(5.5)
    assert_equal 5.5, double_pointer.read_double
  end

  def test_byte_and_string_accessors
    pointer = MemoryPointer.new(:char, 8)
    pointer.put_bytes(1, 'abcdef', 2, 3)
    assert_equal 'cde', pointer.get_bytes(1, 3)
    pointer.write_bytes('abcdef', 1)
    assert_equal 'bcdef', pointer.read_bytes(5)

    pointer.write_string('hello', 4)
    assert_equal 'hell', pointer.read_string(4)
    pointer.write_string_length('world', 3)
    assert_equal 'wor', pointer.get_string(0, 3)
  end

  def test_pointer_wrapping
    raw = Fiddle::Pointer.malloc(4, Fiddle::RUBY_FREE)
    pointer = MemoryPointer.new(:char, raw)
    pointer.write_bytes('ruby')
    assert_equal 'ruby', pointer.read_bytes(4)

    target = Fiddle::Pointer['target']
    holder = MemoryPointer.new(:pointer)
    holder.to_ptr[0, Fiddle::SIZEOF_VOIDP] = [target.to_i].pack('J')
    assert_equal target.to_i, holder.read_pointer.to_i
  end

  def test_function_wraps_a_fiddle_closure
    function = GRCommons::Fiddley::Function.new(:int, [:int]) { |value| value + 1 }
    assert_equal 42, function.call(41)
  end
end
