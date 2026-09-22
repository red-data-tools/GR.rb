# frozen_string_literal: true

require_relative 'test_helper'

require 'fiddle'
require 'numo/narray'

class GRMTest < Test::Unit::TestCase
  class << self
    def fiddle_supports_variadic_functions?
      Fiddle.const_defined?(:VERSION) &&
        (Gem::Version.new(Fiddle::VERSION) > Gem::Version.new('1.0.0'))
    end

    def startup
      require('grm') if fiddle_supports_variadic_functions?
    end
  end

  setup
  def check_fiddle
    omit_unless GRMTest.fiddle_supports_variadic_functions?
  end

  def test_grm_ffi_lib
    assert_kind_of(String, GRM.ffi_lib)
  end

  def test_version
    assert_kind_of(String, GRM::VERSION)
  end

  class ArgsTest < self
    def test_empty
      GRM::Args.new
    end

    def test_string
      args = GRM::Args.new(x: 'hello')
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 's', :voidp, output)
        assert_equal('hello', Fiddle::Pointer.read(output[0, output.size].unpack1('J'), 5))
      end
    end

    def test_integer
      args = GRM::Args.new(x: 29)
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'i', :voidp, output)
        assert_equal([29], output[0, output.size].unpack('i'))
      end
    end

    def test_float
      args = GRM::Args.new(x: 2.9)
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'd', :voidp, output)
        assert_equal([2.9], output[0, output.size].unpack('d'))
      end
    end

    def test_bool
      args = GRM::Args.new(x: true)
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'i', :voidp, output)
        assert_equal([1], output[0, output.size].unpack('i'))
      end
    end

    def test_args
      sub_args = GRM::Args.new
      args = GRM::Args.new(x: sub_args)
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'a', :voidp, output)
        assert_equal(sub_args.address, output[0, output.size].unpack1('J'))
      end
    end

    def test_hash
      args = GRM::Args.new(x: { sub: 29 })
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'a', :voidp, output)
        address = output[0, output.size].unpack1('J')
        Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE) do |sub_output|
          GRM.args_values(address, 'sub', 'i', :voidp, sub_output)
          assert_equal([29], sub_output[0, sub_output.size].unpack('i'))
        end
      end
    end

    def test_array_string
      args = GRM::Args.new(x: %w[hello world])
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'S', :voidp, output)
        address = output[0, output.size].unpack1('J')
        value_addresses = Fiddle::Pointer.read(address, Fiddle::SIZEOF_VOIDP * 2).unpack('J*')
        values = value_addresses.collect do |value_address|
          Fiddle::Pointer.read(value_address, 5)
        end
        assert_equal(%w[hello world], values)
      end
    end

    def test_array_integer
      args = GRM::Args.new(x: [2, 9])
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'I', :voidp, output)
        address = output[0, output.size].unpack1('J')
        assert_equal([2, 9], Fiddle::Pointer.read(address, Fiddle::SIZEOF_INT * 2).unpack('i*'))
      end
    end

    def test_array_float
      args = GRM::Args.new(x: [2.9, -9.2])
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'D', :voidp, output)
        address = output[0, output.size].unpack1('J')
        assert_equal([2.9, -9.2],
                     Fiddle::Pointer.read(address, Fiddle::SIZEOF_DOUBLE * 2).unpack('d*'))
      end
    end

    def test_array_mixed_numeric
      args = GRM::Args.new(x: [2, 9.2])
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'D', :voidp, output)
        address = output[0, output.size].unpack1('J')
        assert_equal([2.0, 9.2],
                     Fiddle::Pointer.read(address, Fiddle::SIZEOF_DOUBLE * 2).unpack('d*'))
      end
    end

    def test_array_args
      sub_args1 = GRM::Args.new
      sub_args2 = GRM::Args.new
      args = GRM::Args.new(x: [sub_args1, sub_args2])
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'A', :voidp, output)
        address = output[0, output.size].unpack1('J')
        assert_equal([sub_args1.address, sub_args2.address],
                     Fiddle::Pointer.read(address, Fiddle::SIZEOF_VOIDP * 2).unpack('J*'))
      end
    end

    def test_array_hash
      args = GRM::Args.new(x: [{ sub1: 29 }, { sub2: 2.9 }])
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, 'x', 'A', :voidp, output)
        address = output[0, output.size].unpack1('J')
        args_addresses = Fiddle::Pointer.read(address, Fiddle::SIZEOF_VOIDP * 2).unpack('J*')
        Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE) do |sub1_output|
          GRM.args_values(args_addresses[0], 'sub1', 'i', :voidp, sub1_output)
          assert_equal([29], sub1_output[0, sub1_output.size].unpack('i'))
        end
        Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE, Fiddle::RUBY_FREE) do |sub2_output|
          GRM.args_values(args_addresses[1], 'sub2', 'd', :voidp, sub2_output)
          assert_equal([2.9], sub2_output[0, sub2_output.size].unpack('d'))
        end
      end
    end

    def test_try_convert
      converted = GRM::Args.try_convert(value: 29)
      assert_kind_of GRM::Args, converted
      assert_equal 1, GRM.args_contains(converted, 'value')
      assert_nil GRM::Args.try_convert(29)
    end

    def test_symbol_key_and_clear
      args = GRM::Args.new(value: 29)
      assert_equal 1, GRM.args_contains(args, 'value')

      args.clear
      assert_equal 0, GRM.args_contains(args, 'value')
    end

    def test_empty_array_is_rejected
      error = assert_raise(ArgumentError) { GRM::Args.new(values: []) }
      assert_equal "Array value for key 'values' cannot be empty", error.message
    end

    def test_ragged_matrix_is_rejected
      error = assert_raise(ArgumentError) { GRM::Args.new(values: [[1, 2], [3]]) }
      assert_equal "All rows in 2D array for key 'values' must have the same length", error.message
    end

    def test_two_dimensional_array_is_flattened_with_dimensions
      args = GRM::Args.new(values: [[1, 2, 3], [4, 5, 6]])
      assert_equal [1, 2, 3, 4, 5, 6], read_integer_array(args, 'values', 6)
      assert_equal [3, 2], read_integer_array(args, 'values_dims', 2)
    end

    def test_one_dimensional_narray
      args = GRM::Args.new(values: Numo::Int32[2, 9])
      assert_equal [2, 9], read_integer_array(args, 'values', 2)
    end

    def test_two_dimensional_narray
      args = GRM::Args.new(values: Numo::Int32[[1, 2], [3, 4]])
      assert_equal [1, 2, 3, 4], read_integer_array(args, 'values', 4)
      assert_equal [2, 2], read_integer_array(args, 'values_dims', 2)
    end

    def test_narray_with_more_than_two_dimensions_is_rejected
      error = assert_raise(ArgumentError) do
        GRM::Args.new(values: Numo::Int32.zeros(2, 2, 2))
      end
      assert_equal "Numo::NArray with dimension > 2 is not supported for key 'values'", error.message
    end

    private

    def read_integer_array(args, key, length)
      Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE) do |output|
        GRM.args_values(args, key, 'I', :voidp, output)
        address = output[0, output.size].unpack1('J')
        Fiddle::Pointer.read(address, Fiddle::SIZEOF_INT * length).unpack('i*')
      end
    end
  end
end
