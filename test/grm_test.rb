# frozen_string_literal: true

require_relative 'test_helper'
require 'grm'

class GRMTest < Test::Unit::TestCase
  def setup; end

  def teardown; end

  def test_grm_ffi_lib
    omit_unless fiddle_supports_variadic_functions?
    assert_kind_of String, GRM.ffi_lib
  end

  def test_version
    omit_unless fiddle_supports_variadic_functions?
    assert_kind_of String, GRM::VERSION
  end

  def fiddle_supports_variadic_functions?
    Fiddle.const_defined?(:VERSION) &&
      (Gem::Version.new(Fiddle::VERSION) > Gem::Version.new('1.0.0'))
  end
end
