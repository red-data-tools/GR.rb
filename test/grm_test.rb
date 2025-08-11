# frozen_string_literal: true

require_relative 'test_helper'

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
  end
end
